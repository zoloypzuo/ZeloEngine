require("stategraphs/commonstates")

local WALK_SPEED = 5

local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "action"),
    ActionHandler(ACTIONS.POLLINATE, function(inst)
		if inst.sg:HasStateTag("landed") then
			return "pollinate"
		else 
			return "land"
		end
    end),
}

local events=
{
    EventHandler("attacked", function(inst) if inst.components.health:GetPercent() > 0 then inst.sg:GoToState("hit") end end),
    EventHandler("doattack", function(inst) if inst.components.health:GetPercent() > 0 and not inst.sg:HasStateTag("busy") then inst.sg:GoToState("attack") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    
    EventHandler("locomote", function(inst) 
        if not inst.sg:HasStateTag("busy") then
			local is_moving = inst.sg:HasStateTag("moving")
			local wants_to_move = inst.components.locomotor:WantsToMoveForward()
			if not inst.sg:HasStateTag("attack") and is_moving ~= wants_to_move then
				if wants_to_move then
					inst.sg:GoToState("premoving")
				else
					inst.sg:GoToState("idle")
				end
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
            inst.SoundEmitter:KillSound("buzz")
            inst.SoundEmitter:PlaySound(inst.sounds.death)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
			if inst.components.lootdropper then
				inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
			end
        end,
    },

    State{
        name = "action",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)
            inst:PerformBufferedAction()
        end,
        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    },    
    
    State{
        name = "premoving",
        tags = {"moving", "canrotate"},
        
        onenter = function(inst)
			inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_pre")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("moving") end),
        },
    },
    
    State{
        name = "moving",
        tags = {"moving", "canrotate"},
        
        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PushAnimation("walk_loop", true)
            inst.sg:SetTimeout(2.5+math.random())
        end,
        
        ontimeout = function(inst)
            if (inst.components.combat and not inst.components.combat.target)
               and not inst:GetBufferedAction() and
               inst:HasTag("worker") then
                inst.sg:GoToState("catchbreath")
            else
                inst.sg:GoToState("moving")
            end
        end,
    },    
    
    
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            local animname = "idle"
            if inst.components.combat and inst.components.combat.target or inst:HasTag("killer") then
                animname = "idle_angry"
            end
            
            if start_anim then
                inst.AnimState:PlayAnimation(start_anim)
                inst.AnimState:PushAnimation(animname, true)
            else
                inst.AnimState:PlayAnimation(animname, true)
            end
        end,
    },
    
    State{
        name = "catchbreath",
        tags = {"busy", "landed"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("land")
            inst.AnimState:PushAnimation("land_idle", true)
            inst.sg:SetTimeout(GetRandomWithVariance(4, 2) )
        end,
        
        timeline=
        {
            TimeEvent(20*FRAMES, function(inst)
                inst.SoundEmitter:KillSound("buzz")
                inst.SoundEmitter:PlaySound("dontstarve/bee/bee_tired_LP", "tired")
            end),
        },
        
        ontimeout = function(inst)
            if not (inst.components.homeseeker and inst.components.homeseeker:HasHome() )
               and inst.components.pollinator
               and inst.components.pollinator:HasCollectedEnough()
               and inst.components.pollinator:CheckFlowerDensity() then
                inst.components.pollinator:CreateFlower()
            end
            inst.sg:GoToState("takeoff")
        end,
        
        onexit = function(inst)
            inst.SoundEmitter:KillSound("tired")
        end,
    },
    
    
    State{
        name = "land",
        tags = {"busy", "landing"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("land")
        end,
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.SoundEmitter:KillSound("buzz")
                if inst.bufferedaction and inst.bufferedaction.action == ACTIONS.POLLINATE then
					inst.sg:GoToState("pollinate")
				else
					inst.sg:GoToState("land_idle")
				end
            end),
        },
    },
    
    State{
        name = "land_idle",
        tags = {"busy", "landed"},
        
        onenter = function(inst)
            inst.AnimState:PushAnimation("land_idle", true)
        end,
    },
    
    State{
        name = "pollinate",
        tags = {"busy", "landed"},
        
        onenter = function(inst)
            inst.AnimState:PushAnimation("land_idle", true)
            inst.sg:SetTimeout(GetRandomWithVariance(3, 1) )
        end,
        
        ontimeout = function(inst)
            inst:PerformBufferedAction()
            inst.sg:GoToState("takeoff")
        end,
    },
    
    State{
        name = "takeoff",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("take_off")
            inst.SoundEmitter:PlaySound(inst.sounds.takeoff)
        end,
        
        events =
        {
            EventHandler("animover", function(inst) inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz") inst.sg:GoToState("idle") end),
        },
        
    },

    State{
        name = "taunt",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle")
            inst.SoundEmitter:PlaySound(inst.sounds.takeoff)
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },    
    
    State{
        name = "attack",
        tags = {"attack"},
        
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
        end,
        
        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack) end),
            TimeEvent(15*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.hit)
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
    starttimeline = 
    {
        TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:KillSound("buzz") end)
    },
    waketimeline = 
    {
        TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz") end)
    },
})
CommonStates.AddFrozenStates(states)

return StateGraph("bee", states, events, "idle", actionhandlers)

