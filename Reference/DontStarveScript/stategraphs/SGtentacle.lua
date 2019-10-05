require("stategraphs/commonstates")

local events=
{
    EventHandler("attacked", function(inst) if inst.components.health:GetPercent() > 0 and not inst.sg:HasStateTag("hit") and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    CommonHandlers.OnFreeze(),
    EventHandler("newcombattarget", function(inst,data)
            
            if inst.sg:HasStateTag("idle") and data.target then
                inst.sg:GoToState("taunt")
            end
        end)
}

local states=
{


    State{
        name = "rumble",
        tags = {"idle", "invisible"},
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_rumble_LP", "tentacle")
            inst.SoundEmitter:SetParameter( "tentacle", "state", 0)
            inst.AnimState:PlayAnimation("ground_pre")
            inst.AnimState:PushAnimation("ground_loop", true)
            inst.sg:SetTimeout(GetRandomWithVariance(10, 5) )
        end,
        ontimeout = function(inst)
            inst.AnimState:PushAnimation("ground_pst", false)
            inst.sg:GoToState("idle")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("tentacle")
        end,
    },
   
    State{
        name = "idle",
        tags = {"idle", "invisible"},
        onenter = function(inst)
            inst.AnimState:PushAnimation("idle", true)
            inst.sg:SetTimeout(GetRandomWithVariance(10, 5) )
            inst.SoundEmitter:KillAllSounds()
        end,
                
        ontimeout = function(inst)
			inst.sg:GoToState("rumble")
        end,
    },
    
    State{
        name = "taunt",
        tags = {"taunting"},
        onenter = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_rumble_LP", "tentacle")
			inst.SoundEmitter:SetParameter( "tentacle", "state", 0)
            
            inst.AnimState:PlayAnimation("breach_pre")
            inst.AnimState:PushAnimation("breach_loop", true)
        end,

        onupdate = function(inst)
            if inst.sg.timeinstate > .75 and inst.components.combat:TryAttack() then
                inst.sg:GoToState("attack_pre")
            elseif inst.components.combat.target == nil then
                inst.AnimState:PlayAnimation("breach_pst")
                inst.sg:GoToState("idle")
            end

        end,
        onexit = function(inst)
            inst.SoundEmitter:KillSound("tentacle")
        end,
    },
    
    State{
        name ="attack_pre",
        tags = {"attack"},
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_emerge")
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
			if not inst.SoundEmitter:PlayingSound("tentacle") then
				inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_rumble_LP", "tentacle")
			end      
			inst.SoundEmitter:SetParameter( "tentacle", "state", 1)      
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("attack") end),
        },
        timeline=
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_emerge_VO") end),
        }
        
    },
    
    State{ 
        name = "attack",
        tags = {"attack"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk_loop")
            inst.AnimState:PushAnimation("atk_idle", false)
        end,
        
        timeline=
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") end),
			TimeEvent(7*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_attack") end),
            TimeEvent(17*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            TimeEvent(18*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) 
                if inst.components.combat.target then
                    inst.sg:GoToState("attack") 
                else
                    inst.sg:GoToState("attack_post") 
                end
            end),
        },
    },
    
    State{
        name ="attack_post",
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_disappear")
            inst.AnimState:PlayAnimation("atk_pst")
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.SoundEmitter:KillAllSounds() inst.sg:GoToState("idle") end),
        },
    },
    
    
	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_death_VO")
            inst.AnimState:PlayAnimation("death")
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
        
        events =
        {
            EventHandler("animover", function(inst) 
				inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_splat")
			end ),
        },        
    },
    
        
    State{
        name = "hit",
        tags = {"busy", "hit"},
        
        onenter = function(inst)
            --inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_hurt_VO")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("attack") end),
        },
        
    },    
    
}
CommonStates.AddFrozenStates(states)
    
return StateGraph("tentacle", states, events, "idle")

