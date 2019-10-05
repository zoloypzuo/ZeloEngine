require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.EAT, "peck"),
    ActionHandler(ACTIONS.GOHOME, "flyaway"),
}



local events=
{
    EventHandler("gotosleep", function(inst)
        if inst.components.health:GetPercent() > 0 then
            local pt = Vector3(inst.Transform:GetWorldPosition())
            if pt.y > 1 then
                inst.sg:GoToState("fall")   --special bird behaviour
            elseif inst.sg:HasStateTag("sleeping") then
                inst.sg:GoToState("sleeping")
            else
                inst.sg:GoToState("sleep")
            end
        end
    end),
    CommonHandlers.OnFreeze(),
    EventHandler("attacked", function(inst) if inst.components.health:GetPercent() > 0 then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("flyaway", function(inst) 
        if inst.components.health:GetPercent() > 0 and not inst.sg:HasStateTag("busy") then 
            inst.sg:GoToState("flyaway") 
        end 
    end),
    EventHandler("onignite", function(inst) if inst.components.health:GetPercent() > 0 then inst.sg:GoToState("distress_pre") end end),
    EventHandler("trapped", function(inst) inst.sg:GoToState("trapped") end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
            inst.sg:SetTimeout(1 + math.random()*1)
        end,
        
        ontimeout= function(inst)
			if inst.bufferedaction and inst.bufferedaction.action == ACTIONS.EAT then
				inst.sg:GoToState("peck")
			else
				local r = math.random()
				if r < .5 then
					inst.sg:GoToState("idle")
				elseif r < .6 then
					inst.sg:GoToState("switch")
				elseif r < .7 then
					inst.sg:GoToState("peck")
				elseif r < .8 then
					inst.sg:GoToState("hop")
				elseif r < .9 then
					inst.sg:GoToState("flyaway")
				else 
					inst.sg:GoToState("caw")
				end
			end
        end,

    },
    
    State {
		name = "frozen",
		tags = {"busy"},
		
        onenter = function(inst)
            inst.AnimState:PlayAnimation("frozen")
            inst.Physics:Stop()
            --inst.components.highlight:SetAddColour(Vector3(82/255, 115/255, 124/255))
        end,
		
    },
    
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,

    },
    
    
    State{
        name = "caw",
        tags = {"idle"},
        onenter= function(inst)
            inst.AnimState:PlayAnimation("caw")
            inst.SoundEmitter:PlaySound(inst.sounds.chirp)
       end,
        events=
        {
            EventHandler("animover", function(inst) if math.random() < .5 then inst.sg:GoToState("caw") else inst.sg:GoToState("idle") end end ),
        },
    },
    
    State{
        name = "distress_pre",
        tags = {"busy"},
        onenter= function(inst)
            inst.AnimState:PlayAnimation("flap_pre")
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("distress") end ),
        },
    },
    
    State{
        name = "distress",
        tags = {"busy"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("flap_loop")
            inst.SoundEmitter:PlaySound("dontstarve/birds/wingflap_cage")
            inst.SoundEmitter:PlaySound(inst.sounds.chirp)
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("distress") end ),
            EventHandler("onextinguish", function(inst) if inst.components.health:GetPercent() > 0 then inst.sg:GoToState("idle", "flap_post") end end ),
        },
    },
    
    State{
        name = "glide",
        tags = {"idle", "flying"},
        onenter= function(inst)
            inst.AnimState:PlayAnimation("glide")
            inst.Physics:SetMotorVel(0,-20+math.random()*10,0)
            inst.SoundEmitter:PlaySound(inst.sounds.flyin, "flyin")
        end,
        
        onupdate= function(inst)
            local pt = Point(inst.Transform:GetWorldPosition())
            if pt.y < 2 then
				inst.Physics:SetMotorVel(0,0,0)
            end
            
            if pt.y <= .1 then
                pt.y = 0
                inst.Physics:Stop()
                inst.Physics:Teleport(pt.x,pt.y,pt.z)
                inst.AnimState:PlayAnimation("land")
	            inst.DynamicShadow:Enable(true)
                inst.sg:GoToState("idle", true)
            end
        end,
		
        events=
        {
            EventHandler("animover", function(inst) 
				inst.SoundEmitter:PlaySound(inst.sounds.flyin, "flyin")
				inst.sg:GoToState("glide")
            end ),
        },     
    },    
    
    State{
        name = "switch",
        tags = {"idle"},
        onenter= function(inst)
            inst.Transform:SetRotation(inst.Transform:GetRotation() + 180)
            inst.AnimState:PlayAnimation("switch")
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },    

    State{
        name = "peck",
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("peck")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) 
                if math.random() < .3 then
					inst:PerformBufferedAction()
					inst.sg:GoToState("idle")
                else
					inst.sg:GoToState("peck")
                end
            end ),
            
        },     
    },    
    
    State{
        name = "flyaway",
        tags = {"flying", "busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.sg:SetTimeout(.1+math.random()*.2)
            inst.sg.statemem.vert = math.random() > .5
            
	        inst.DynamicShadow:Enable(false)
            inst.SoundEmitter:PlaySound(inst.sounds.takeoff)
            
            if inst.components.periodicspawner and math.random() <= TUNING.CROW_LEAVINGS_CHANCE then
                inst.components.periodicspawner:TrySpawn()
            end
           
            if inst.sg.statemem.vert then
                inst.AnimState:PlayAnimation("takeoff_vertical_pre")
            else
                inst.AnimState:PlayAnimation("takeoff_diagonal_pre")
            end
        end,
        
        ontimeout= function(inst)
            if inst.sg.statemem.vert then
                inst.AnimState:PushAnimation("takeoff_vertical_loop", true)
                inst.Physics:SetMotorVel(-2 + math.random()*4,15+math.random()*5,-2 + math.random()*4)
            else
                inst.AnimState:PushAnimation("takeoff_diagonal_loop", true)
                local x = 8+ math.random()*8
                inst.Physics:SetMotorVel(x,15+math.random()*5,-2 + math.random()*4)
            end
        end,
        
        timeline = 
        {
            TimeEvent(2, function(inst) inst:Remove() end)
        }
        
    },

    State{
        name = "hop",
        tags = {"moving", "canrotate", "hopping"},
        
        onenter = function(inst) 
            inst.AnimState:PlayAnimation("hop")
            inst.Physics:SetMotorVel(5,0,0)
        end,
        
        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) 
                inst.Physics:Stop() 
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        }
    },
    
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
            local pt = Vector3(inst.Transform:GetWorldPosition())
            if pt.y > 1 then
                inst.sg:GoToState("fall")
            end
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },    

    State{
        name = "fall",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("fall_loop", true)
        end,
        
        onupdate = function(inst)
            local pt = Vector3(inst.Transform:GetWorldPosition())
            if pt.y <= .2 then
                pt.y = 0
                inst.Physics:Stop()
                inst.Physics:Teleport(pt.x,pt.y,pt.z)
	            inst.DynamicShadow:Enable(true)
                inst.sg:GoToState("stunned")
            end
        end,
    },    
    
    State{
        name = "trapped",
        tags = {"busy"},
        
        onenter = function(inst) 
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("stunned_loop", true)
            inst.sg:SetTimeout(1)
        end,
        
        ontimeout = function(inst) inst.sg:GoToState("flyaway") end,
    },
    
    State{
        name = "stunned",
        tags = {"busy"},
        
        onenter = function(inst) 
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("stunned_loop", true)
            inst.sg:SetTimeout(GetRandomWithVariance(6, 2) )
            if inst.components.inventoryitem then
                inst.components.inventoryitem.canbepickedup = true
            end
        end,
        
        onexit = function(inst)
            if inst.components.inventoryitem then
                inst.components.inventoryitem.canbepickedup = false
            end
        end,
        
            
        ontimeout = function(inst) inst:TrackInSpawner() inst.sg:GoToState("flyaway") end,
    },
    
}

CommonStates.AddSleepStates(states,
{
})
CommonStates.AddFrozenStates(states)
    
return StateGraph("bird", states, events, "glide")

