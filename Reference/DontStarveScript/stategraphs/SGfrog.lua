require("stategraphs/commonstates")


local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "action"),
}

local events=
{
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst) if inst.components.health:GetPercent() > 0 and not inst.sg:HasStateTag("busy") then inst.sg:GoToState("attack") end end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    
    EventHandler("locomote", 
        function(inst) 
            if not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving") then return end
            
            if not inst.components.locomotor:WantsToMoveForward() then
                if not inst.sg:HasStateTag("idle") then
                    inst.sg:GoToState("idle")
                end
            else
                if not inst.sg:HasStateTag("hopping") then
					if inst.components.locomotor:WantsToRun() then
						inst.sg:GoToState("aggressivehop")
					else
						inst.sg:GoToState("hop")
					end
                end
            end
        end),
}

local states=
{
 
    State{
        
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
            inst.sg:SetTimeout(1*math.random()+.5)
        end,
        
        ontimeout= function(inst)
            if inst.components.locomotor:WantsToMoveForward() then
                inst.sg:GoToState("hop")
            else
                
                
                local num_frogs = 0
                local x,y,z = inst.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x,y,z, 10, "frog")
                
                local volume = 1
                for k,v in pairs(ents) do
                    if volume > .5 and v ~= inst then
                        volume = volume - .1
                        if volume <= .5 then
                            break
                        end
                    end
                end
                inst.SoundEmitter:PlaySound("dontstarve/frog/grunt", nil, volume)
                inst.sg:GoToState("idle")
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
        name = "aggressivehop",
        tags = {"moving", "canrotate", "hopping", "running"},
        
        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) 
                inst.components.locomotor:RunForward()
            end ),
            TimeEvent(20*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve/frog/walk")
                inst.Physics:Stop() 
            end ),
        },
        
        onenter = function(inst) 
            inst.Physics:Stop() 
            inst.AnimState:PlayAnimation("jump_pre")
            inst.AnimState:PushAnimation("jump")
            inst.AnimState:PushAnimation("jump_pst", false)
        end,
        
        events=
        {
            EventHandler("animqueueover", function (inst) inst.sg:GoToState("idle") end),
        },
    },
    
    State{
        name = "hop",
        tags = {"moving", "canrotate", "hopping"},
        
        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) 
                inst.components.locomotor:WalkForward()
            end ),
            TimeEvent(20*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve/frog/walk")
                inst.Physics:Stop() 
            end ),
        },
        
        onenter = function(inst) 
            inst.Physics:Stop() 
            inst.AnimState:PlayAnimation("jump_pre")
            inst.AnimState:PushAnimation("jump")
            inst.AnimState:PushAnimation("jump_pst", false)
        end,
        
        events=
        {
            EventHandler("animqueueover", function (inst) inst.sg:GoToState("idle") end),
        },
    },
    
    State{
        name = "attack",
        tags = {"attack"},
        
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,
        
        timeline=
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/frog/attack_spit") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/frog/attack_voice") end),
            TimeEvent(25*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
    State{
        name = "fall",
        tags = {"busy"},
        onenter = function(inst)
			inst.Physics:SetDamping(0)
            inst.Physics:SetMotorVel(0,-20+math.random()*10,0)
            inst.AnimState:PlayAnimation("fall_idle", true)
        end,
        
        onupdate = function(inst)
            local pt = Point(inst.Transform:GetWorldPosition())
            if pt.y < 2 then
				inst.Physics:SetMotorVel(0,0,0)
            end
            
            if pt.y <= .1 then
                pt.y = 0

				-- TODO: 20% of the time, they should explode on impact!

                inst.Physics:Stop()
				inst.Physics:SetDamping(5)
                inst.Physics:Teleport(pt.x,pt.y,pt.z)
	            inst.DynamicShadow:Enable(true)
                inst.SoundEmitter:PlaySound("dontstarve/frog/splat")
                inst.sg:GoToState("idle", "jump_pst")
            end
        end,

        onexit = function(inst)
            local pt = inst:GetPosition()
            pt.y = 0
            inst.Transform:SetPosition(pt:Get())
        end,
    },    
    
   
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/frog/die")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },

    
}

CommonStates.AddSleepStates(states,
{
	waketimeline = {
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/frog/wake") end ),
	},
})
CommonStates.AddFrozenStates(states)


    
return StateGraph("frog", states, events, "idle", actionhandlers)

