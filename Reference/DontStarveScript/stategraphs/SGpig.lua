require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.CHOP, "chop"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.EQUIP, "pickup"),
    ActionHandler(ACTIONS.ADDFUEL, "pickup"),
    ActionHandler(ACTIONS.TAKEITEM, "pickup"),
    ActionHandler(ACTIONS.UNPIN, "pickup"),
}


local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(true),
    CommonHandlers.OnDeath(),
    EventHandler("transformnormal", function(inst) if inst.components.health:GetPercent() > 0 then inst.sg:GoToState("transformNormal") end end),
    EventHandler("doaction", 
        function(inst, data) 
            if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
                if data.action == ACTIONS.CHOP then
                    inst.sg:GoToState("chop", data.target)
                end
            end
        end),
}

local states=
{
    State{
        name= "funnyidle",
        tags = {"idle"},
        
        onenter = function(inst)
			inst.Physics:Stop()
            local daytime = not GetClock():IsNight()
            inst.SoundEmitter:PlaySound("dontstarve/pig/oink")
            
            if inst.components.follower.leader and inst.components.follower:GetLoyaltyPercent() < 0.05 then
                inst.AnimState:PlayAnimation("hungry")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")
            elseif inst:HasTag("guard") then
                inst.AnimState:PlayAnimation("idle_angry")
            elseif daytime then
                if inst.components.combat.target then
                    inst.AnimState:PlayAnimation("idle_angry")
                elseif inst.components.follower.leader and inst.components.follower:GetLoyaltyPercent() > 0.3 then
                    inst.AnimState:PlayAnimation("idle_happy")
                else
                    inst.AnimState:PlayAnimation("idle_creepy")
                end
            else
                inst.AnimState:PlayAnimation("idle_scared")
            end
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
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
            inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },

    State{
        name = "daily_gift",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.talker:Say(STRINGS.PIG_TALK_DAILY_GIFTING[math.random(1, #STRINGS.PIG_TALK_DAILY_GIFTING)])
            inst.AnimState:PlayAnimation("pig_take")
            inst.Physics:Stop()
        end,

        timeline=
        {
            TimeEvent(13*FRAMES, 
                function(inst)
                    local resources = { "flint", "log", "rocks", "cutgrass", "seeds", "twigs" }

                    GetPlayer().components.inventory:GiveItem(
                        SpawnPrefab(resources [math.random(1, #resources)]),
                        nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
                end ),
        },
        
        events=
        {
            EventHandler("animover", 
                function(inst) 
                    inst.sg:GoToState("idle") 
                    inst:DoTaskInTime(4, function() inst.daily_gifting = false end)
                end ),
        },
    },
    
    State{
		name = "abandon",
		tags = {"busy"},
		
		onenter = function(inst, leader)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("abandon")
            inst:FacePoint(Vector3(leader.Transform:GetWorldPosition()))
		end,
		
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },
    
    State{
		name = "transformNormal",
		tags = {"transform", "busy", "sleeping"},
		
		onenter = function(inst)
			inst.Physics:Stop()
			inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/transformToPig")
            inst.AnimState:SetBuild("werepig_build")
			inst.AnimState:PlayAnimation("transform_were_pig")
		    inst:RemoveTag("hostile")
			
		end,
		
		onexit = function(inst)
            inst.AnimState:SetBuild(inst.build)
		end,
		
        events=
        {
            EventHandler("animover", function(inst)
				inst.components.sleeper:GoToSleep(15+math.random()*4)
				inst.sg:GoToState("sleeping")
			end ),
        },        
    },
    
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/pig/attack")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,
        
        timeline=
        {
            TimeEvent(13*FRAMES, function(inst) inst.components.combat:DoAttack() inst.sg:RemoveStateTag("attack") inst.sg:RemoveStateTag("busy") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "chop",
        tags = {"chopping"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,
        
        timeline=
        {
            
            TimeEvent(13*FRAMES, function(inst) inst:PerformBufferedAction() end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
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
            TimeEvent(10*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/pig/oink")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },    
}

CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(12*FRAMES, PlayFootstep ),
	},
})
CommonStates.AddRunStates(states,
{
	runtimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(10*FRAMES, PlayFootstep ),
	},
})

CommonStates.AddSleepStates(states,
{
	sleeptimeline = 
	{
		TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/pig/sleep") end ),
	},
})

CommonStates.AddIdle(states,"funnyidle")
CommonStates.AddSimpleState(states,"refuse", "pig_reject", {"busy"})
CommonStates.AddFrozenStates(states)

CommonStates.AddSimpleActionState(states,"pickup", "pig_pickup", 10*FRAMES, {"busy"})

CommonStates.AddSimpleActionState(states, "gohome", "pig_pickup", 4*FRAMES, {"busy"})

    
return StateGraph("pig", states, events, "idle", actionhandlers)

