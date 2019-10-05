require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnLocomote(false,true),
    EventHandler("attacked", function(inst)
        if inst.components.health and not inst.components.health:IsDead() then
            inst.sg:GoToState("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/hurt")
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
            
            if not inst.sg.mem.pant_ducking or inst.sg:InNewState() then
				inst.sg.mem.pant_ducking = 1
			end
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        timeline=
        {
            TimeEvent(7*FRAMES, function(inst) 
				inst.sg.mem.pant_ducking = inst.sg.mem.pant_ducking or 1
				inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/pant", nil, inst.sg.mem.pant_ducking) 
				if inst.sg.mem.pant_ducking and inst.sg.mem.pant_ducking > .35 then
					inst.sg.mem.pant_ducking = inst.sg.mem.pant_ducking - .05
				end
			end),
        },        
   },
    
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.components.container:Close()
            inst.components.container:DropEverything()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/death")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
        end,
    },

    State{
        name = "open",
        tags = {"busy", "open"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.components.sleeper:WakeUp()
            inst.AnimState:PlayAnimation("open")
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("open_idle") end ),
        },

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/open") end),
        },        
    },

    State{
        name = "open_idle",
        tags = {"busy", "open"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_loop_open")
            
            if not inst.sg.mem.pant_ducking or inst.sg:InNewState() then
				inst.sg.mem.pant_ducking = 1
			end
            
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("open_idle") end ),
        },

        timeline=
        {
            TimeEvent(3*FRAMES, function(inst) 
				inst.sg.mem.pant_ducking = inst.sg.mem.pant_ducking or 1
				inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/pant", nil, inst.sg.mem.pant_ducking) 
				if inst.sg.mem.pant_ducking and inst.sg.mem.pant_ducking > .35 then
					inst.sg.mem.pant_ducking = inst.sg.mem.pant_ducking - .05
				end
			end),
        },
    },

    State{
        name = "close",
        tags = {""},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("closed")
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/close") end),
        },        
    },


    State{
        name = "transition",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()

            local shadow, snow = inst:CanMorph()
            --Check that you are still valid to transform
            if not (shadow or snow) then
                inst.sg:GoToState("idle")
                return
            end

            --Remove ability to open chester for short time.
            inst.components.container.canbeopened = false

            --Create light shaft
            inst.sg.statemem.light = SpawnPrefab("chesterlight")
            inst.sg.statemem.light.Transform:SetPosition(inst:GetPosition():Get())
            inst.sg.statemem.light:TurnOn()

            inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/raise")

            inst.AnimState:PlayAnimation("idle_loop")
            inst.AnimState:PushAnimation("idle_loop")
            inst.AnimState:PushAnimation("idle_loop")
            inst.AnimState:PushAnimation("transition", false)
        end,

        onexit = function(inst)
            --Add ability to open chester again.
            inst.components.container.canbeopened = true
            --Remove light shaft
            if inst.sg.statemem.light then
                inst.sg.statemem.light:TurnOff()
            end
        end,

        timeline = 
        {
            TimeEvent(75*FRAMES, function(inst) 
                local smokeFX = SpawnPrefab("chester_transform_fx")
                local sparkleFX = SpawnPrefab("sparklefx")
                local pos = inst:GetPosition()
                pos.y = pos.y + 1
                smokeFX.Transform:SetPosition(pos:Get())
                sparkleFX.Transform:SetPosition(pos:Get())
            end),
            TimeEvent(75*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/pop")
                inst:MorphChester()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },
}

CommonStates.AddWalkStates(states, {
    walktimeline = 
    { 
        --TimeEvent(0*FRAMES, function(inst)  end),
        TimeEvent(1*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/boing")
            inst.components.locomotor:RunForward() 
        end),
        --TimeEvent(12*FRAMES, function(inst) PlayFootstep(inst) end),
        TimeEvent(14*FRAMES, function(inst) 
            PlayFootstep(inst)
            inst.components.locomotor:WalkForward()
        end),
    }
}, nil, true)

CommonStates.AddSleepStates(states,
{
    starttimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/close") end)
    },
    waketimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/open") end)
    },
})

CommonStates.AddSimpleState(states, "hit", "hit", {"busy"})

return StateGraph("chester", states, events, "idle", actionhandlers)

