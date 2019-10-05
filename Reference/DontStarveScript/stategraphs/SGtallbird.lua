require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.LAYEGG, "lay"),
    ActionHandler(ACTIONS.EAT, "eat"),
}

local events=
{
    
    
    CommonHandlers.OnAttacked(),
    EventHandler("doattack", function(inst) 
        if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then 
			if inst:HasTag("teenbird") and inst:HasTag("peck_attack") then
				inst.sg:GoToState("peck") 
			else
				inst.sg:GoToState("attack") 
			end
        end 
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnLocomote(false,true),
}


local states=
{
    
	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/death")
            inst.AnimState:PlayAnimation("death")
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },
    
    
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            
            if start_anim then
                inst.AnimState:PlayAnimation(start_anim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end

            if inst:HasTag("teenbird") then
                inst.sg:SetTimeout(4 + 4*math.random())
            end
        end,
        
        ontimeout = function(inst)
            --print("tallbird - idle timeout")
            if inst:HasTag("teenbird") then
                if math.random() <= inst.userfunctions.GetPeepChance(inst) then
                    inst.sg:GoToState("idle_peep")
                else
                    inst.sg:GoToState("idle_blink")
                end
            end
        end,
    },
    
    State{
        name = "idle_blink",
        tags = {"idle"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_blink", true)
        end,
       
        timeline = 
        {
            TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teenbird/blink") end),
        },

        events=
        {
            EventHandler("animover", 
                function(inst,data) 
                    if math.random() < 0.1 then
                        inst.sg:GoToState("idle_blink")
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            ),
        },
    },

    State{
        name = "idle_peep",
        tags = {"idle"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hungry", true)
        end,
       
        timeline = 
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teenbird/chirp") end),
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teenbird/chirp") end),
        },

        events=
        {
            EventHandler("animover", 
                function(inst,data) 
                    if math.random() <= inst.userfunctions.GetPeepChance(inst) then
                        inst.sg:GoToState("idle_peep")
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            ),
        },
    },

    State{
        name = "idle_taunt",
        tags = {"idle"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/teenbird/chirp")
        end,
       
        timeline=
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teenbird/scratch_ground") end),
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teenbird/scratch_ground") end),
        },

        events=
        {
            EventHandler("animover", 
                function(inst,data) 
                    inst.sg:GoToState("idle")
                end
            ),
        },
    },

    State{
        name = "lay",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("layegg")
        end,
        
        timeline=
        {
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/egg") end),
            TimeEvent(65*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
        
    },
    

    State{
        name = "taunt",
        tags = {"canrotate"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/chirp")
            if inst.components.combat and inst.components.combat.target then
                inst:FacePoint(Vector3(inst.components.combat.target.Transform:GetWorldPosition()))
            end
        end,
        
        timeline=
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/scratch_ground") end),
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/scratch_ground") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },    
    
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,
        
        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/attack") end),
            TimeEvent(12*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            TimeEvent(14*FRAMES, function(inst) 
				inst.sg:RemoveStateTag("attack")
				inst.sg:RemoveStateTag("busy")
			end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "peck",
        tags = {"attack", "canrotate"},
        
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("teenatk_pre")
            inst.AnimState:PushAnimation("teenatk", false)
        end,
        
        timeline =
        {
            TimeEvent(11*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/teenbird/peck")
            end),
            TimeEvent(13*FRAMES, function(inst)
                inst.components.combat:DoAttack() 
                local target = inst.components.combat.target
                if target and target.components.talker then
                    target.components.talker:Say( GetString(target.prefab, "ANNOUNCE_PECKED") )
                end
            end),
        },
        
        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    
    State{
        name = "hit",
        tags = {"hit"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/hurt")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },    

    
    State{
        name = "gohome",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            if inst.components.sleeper then
                inst.components.sleeper:GoToSleep()
            end
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },    
    
    State{
        name = "eat",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("steal")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/smallbird/scratch_ground")
        end,
        
        timeline=
        {
            TimeEvent(11*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },

    State{
        name = "growup",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("growadult")
        end,
        timeline = 
        {
            TimeEvent(43*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/teenbird/grow") end),
            TimeEvent(45*FRAMES, function(inst) inst.Transform:SetScale(1,1,1)  end),
        },
        events=
        {
            EventHandler("animover", function(inst)
                inst.userfunctions.SpawnAdult(inst)
            end),
        },
    },
}

CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/footstep") end ),
		TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/footstep") end ),
	},
})

CommonStates.AddSleepStates(states,
{
	starttimeline = 
	{
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/sleep") end ),
	},
	waketimeline = 
	{
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/tallbird/wakeup") end ),
	},
})
CommonStates.AddFrozenStates(states)

return StateGraph("tallbird", states, events, "wake", actionhandlers)

