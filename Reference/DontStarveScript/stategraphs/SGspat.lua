require("stategraphs/commonstates")

local actionhandlers = 
{
    --ActionHandler(ACTIONS.PICKUP, "doshortaction"),
    --ActionHandler(ACTIONS.EAT, "eat"),
    --ActionHandler(ACTIONS.CHOP, "chop"),
    --ActionHandler(ACTIONS.PICKUP, "pickup"),
}


local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),

    EventHandler("doattack", function(inst, data)
        if not inst.components.health:IsDead() then
            local weapon = inst.components.combat and inst.components.combat:GetWeapon()
            if weapon then
                if weapon:HasTag("snotbomb") then
                    inst.sg:GoToState("launchprojectile", data.target)
                else
                    inst.sg:GoToState("attack", data.target)
                end
            end
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("hit")
        end
    end),    
    EventHandler("heardhorn", function(inst, data)
        if not inst.components.health:IsDead()
           and not inst.sg:HasStateTag("attack")
           and data and data.musician then
            inst:FacePoint(Vector3(data.musician.Transform:GetWorldPosition()))
            inst.sg:GoToState("bellow")
        end
    end),    
    EventHandler("loseloyalty", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("shake") end end),    
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
        
        ontimeout=function(inst)
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
            inst.SoundEmitter:PlaySound(inst.sounds.grunt)
        end,
       
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
    State{
        name = "matingcall",
        tags = {},
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("mating_taunt1")
            inst.SoundEmitter:PlaySound(inst.sounds.yell)
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
        end,
        
        ontimeout= function(inst)
            inst.sg:GoToState("idle")
        end,

    },
    
    State{
        name = "alert",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.SoundEmitter:PlaySound(inst.sounds.curious)
            inst.AnimState:PlayAnimation("alert_pre")
            inst.AnimState:PushAnimation("alert_idle", true)
        end,
    },
    
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst, target)    
            inst.sg.statemem.target = target
            inst.SoundEmitter:PlaySound(inst.sounds.angry)
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("strike")
            inst.AnimState:PushAnimation("strike_pst", false)
        end,
        
        
        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) 
                inst.components.locomotor:StopMoving()
                inst.components.combat:DoAttack(inst.sg.statemem.target) 
            end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },    
    
    State{
        name = "launchprojectile",
        tags = {"attack", "busy"},
        
        onenter = function(inst, target)    
			inst.sg.statemem.target = target
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("snot_pre")
            inst.AnimState:PushAnimation("snot", false)
            inst.AnimState:PushAnimation("snot_pst", false)
        end,
        
        
        timeline=
        {
            TimeEvent(19*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.spit)
            end),
            TimeEvent(27*FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
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
			inst.SoundEmitter:PlaySound(inst.sounds.death)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },
}

CommonStates.AddWalkStates(
    states,
    {
        walktimeline = 
        { 
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.walk) end),
            TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.walk) end),
        }
    })
    
CommonStates.AddRunStates(
    states,
    {
        runtimeline = 
        { 
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.walk) end),
        }
    })

CommonStates.AddSimpleState(states,"hit", "hit")
CommonStates.AddFrozenStates(states)

CommonStates.AddSleepStates(states,
{
    sleeptimeline = 
    {
        TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end)
    },
})
    
return StateGraph("spat", states, events, "idle", actionhandlers)

