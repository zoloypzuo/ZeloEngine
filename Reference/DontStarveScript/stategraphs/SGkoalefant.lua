require("stategraphs/commonstates")

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),

    EventHandler("doattack", function(inst) if not inst.components.health:IsDead() then inst.sg:GoToState("attack") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("attacked", function(inst) if inst.components.health:GetPercent() > 0 and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),    
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("idle_loop", true)
            inst.sg:SetTimeout(2 + 2*math.random())
        end,
        
        ontimeout = function(inst)
            local rand = math.random()
            if rand < .3 then
                inst.sg:GoToState("graze")
            elseif rand < .6 then
                inst.sg:GoToState("bellow")
            else
                inst.sg:GoToState("shake")
            end
        end,
    },
    
    State{
        name = "shake",
        tags = {"canrotate"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("shake")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/shake")
        end,
       
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
    State{
        name = "bellow",
        tags = {"canrotate"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("bellow")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/grunt")
        end,
       
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
    State{
        name="graze",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("graze_loop", true)
            inst.sg:SetTimeout(5+math.random()*5)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/chew")
        end,
        
        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

    },
    
    State{
        name = "alert",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/alert")
            inst.AnimState:PlayAnimation("alert_pre")
            inst.AnimState:PushAnimation("alert_idle", true)
        end,
    },
    
    State{
        name = "attack",
        tags = {"attack"},
        
        onenter = function(inst)    
            inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/angry")
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,
        
        
        timeline=
        {
            TimeEvent(15*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },    
    
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/yell")
            inst.AnimState:PlayAnimation("death")
            inst.components.locomotor:StopMoving()
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },
 }

CommonStates.AddWalkStates(
    states,
    {
        walktimeline = 
        { 
            TimeEvent(10*FRAMES, PlayFootstep),
            TimeEvent(15*FRAMES, function(inst) 
                if math.random(1,3) == 2 then
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/walk")
                end
            end ),
            TimeEvent(40*FRAMES, PlayFootstep),
        }
    })
    
CommonStates.AddRunStates(
    states,
    {
        runtimeline = 
        { 
            TimeEvent(2*FRAMES, PlayFootstep),
        }
    })

CommonStates.AddSimpleState(states,"hit", "hit")

CommonStates.AddSleepStates(states,
{
    sleeptimeline = 
    {
        TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/grunt") end)
    },
})
CommonStates.AddFrozenStates(states)
    
return StateGraph("koalefant", states, events, "idle")

