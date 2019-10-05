require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
}


local events =
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("transformwere", function(inst) if inst.components.health:GetPercent() > 0 then inst.sg:GoToState("transformWere") end end),
    EventHandler("giveuptarget", function(inst, data) if data.target then inst.sg:GoToState("howl") end end),
    EventHandler("newcombattarget", function(inst, data)
        if data.target and not inst.sg:HasStateTag("busy") then
            if math.random() < 0.3 then
                inst.sg:GoToState("howl")
            else
                inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/idle")
            end
        end
    end),
}

local states=
{


	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/grunt")
            inst.AnimState:PlayAnimation("death")
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },
    
    State{
		name = "howl",
		tags = {"busy"},
		
		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("beard_idle_loop")
		end,
		
		timeline = 
		{
			TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/howl") end),
		},
		
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
	},
	
    State{
		name = "transformWere",
		tags = {"transform", "busy"},
		
		onenter = function(inst)
			inst.Physics:Stop()
			inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/transformToWere")
            inst.AnimState:SetBuild(inst.build)
			inst.AnimState:PlayAnimation("transform_rabbit_beard")
		end,
		
		onexit = function(inst)
            inst.AnimState:SetBuild("manrabbit_beard_build")
		end,
		
        events=
        {
            EventHandler("animover", function(inst)
                inst.components.sleeper:WakeUp()
                inst.sg:GoToState("idle")
            end ),
        },        
    },
    
	State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation("beard_idle_loop", true)
            else
                inst.AnimState:PlayAnimation("beard_idle_loop", true)
            end
        end,
    },
    
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("beard_atk_pre")
            inst.AnimState:PushAnimation("beard_atk", false)
        end,
        
        timeline=
        {
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/attack") end),
            TimeEvent(16*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst)
                if not inst.components.combat.target and math.random() < 0.3 then
                    inst.sg:GoToState("idle")
                else
                    inst.sg:GoToState("idle")
                end
            end ),
        },
    },
    
	State{
		name = "run_start",
		tags = {"moving", "running", "canrotate"},
	    
		onenter = function(inst) 
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("beard_run_pre")
		end,

		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
		},
	},
    
	State{
		name = "run",
		tags = {"moving", "running", "canrotate"},
	    
		onenter = function(inst) 
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("beard_run_loop")
		end,
	    
		timeline = 
		{
		    TimeEvent(0*FRAMES, PlayFootstep ),
		    TimeEvent(10*FRAMES, PlayFootstep ),
		},
		
		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
		},
	},
        
	State{
		name = "run_stop",
		tags = {"canrotate"},
	    
		onenter = function(inst) 
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("beard_run_pst")
		end,
	    
		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
		},
	},
	
	State{
		name = "walk_start",
		tags = {"moving", "canrotate"},
	    
		onenter = function(inst) 
			inst.components.locomotor:WalkForward()
			inst.AnimState:PlayAnimation("beard_walk_pre")
		end,

		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
		},
	},
        
	State{
		name = "walk",
		tags = {"moving", "canrotate"},
	    
		onenter = function(inst) 
			inst.components.locomotor:WalkForward()
			inst.AnimState:PlayAnimation("beard_walk_loop")
		end,
		
		timeline = 
		{
		    TimeEvent(0*FRAMES, PlayFootstep),
		    TimeEvent(12*FRAMES, PlayFootstep),
		},
		
		events=
		{   
			EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
		},
	},
    
	State{
		name = "walk_stop",
		tags = {"canrotate"},
	    
		onenter = function(inst) 
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("beard_walk_pst")
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
            inst.AnimState:PlayAnimation("eat")
        end,
        
        timeline=
        {
            TimeEvent(20*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                if not inst.components.combat.target or math.random() < 0.3 then
                    inst.sg:GoToState("howl")
                else
                    inst.sg:GoToState("idle")
                end
            end ),
        },        
    },
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/hurt")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },    
}

CommonStates.AddSleepStates(states,
{
	sleeptimeline = 
	{
		TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/sleep") end ),
	},
})

CommonStates.AddFrozenStates(states)
CommonStates.AddSimpleActionState(states, "eat", "eat", 20*FRAMES, {"busy"})
    
return StateGraph("beardpig", states, events, "idle", actionhandlers)

