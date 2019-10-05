require("stategraphs/commonstates")

local function OnWaterSound(inst)
    if inst.onwater then
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/flap")
        inst.components.locomotor:WalkForward() 
    end
end

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
            -- inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/hurt")
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("spawnin", function(inst) inst.sg:GoToState("spawn") end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
        end,
        
        events=
        {
            EventHandler("animover", function(inst)
                if math.random() < 0.1 then
                    inst.sg:GoToState("emote_idle") 
                else
                    inst.sg:GoToState("idle") 
                end
            end),
        },

        timeline=
        {   
            TimeEvent(1*FRAMES, function(inst) OnWaterSound(inst) end),
            TimeEvent(8*FRAMES, function(inst) OnWaterSound(inst) end),
            TimeEvent(15*FRAMES, function(inst) OnWaterSound(inst) end),
            TimeEvent(22*FRAMES, function(inst) OnWaterSound(inst) end),
            TimeEvent(29*FRAMES, function(inst) OnWaterSound(inst) end),
        },
    },

    State{
        name = "emote_idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("emote_idle")
        end,
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle") 
            end),
        },

        timeline=
        {   
            TimeEvent(5*FRAMES, function(inst)inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/emote_idle") end),
            TimeEvent(7*FRAMES, function(inst)inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/flap") end),
            TimeEvent(8*FRAMES, function(inst)inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/flap",nil,.5) end),
            TimeEvent(14*FRAMES, function(inst)inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/flap") end),
            TimeEvent(16*FRAMES, function(inst)inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/flap",nil,.5) end),
            TimeEvent(18*FRAMES, function(inst)inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/emote_idle") end), 
            TimeEvent(21*FRAMES, function(inst)inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/flap") end),
            TimeEvent(22*FRAMES, function(inst)inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/flap",nil,.5) end),
        },
   },
    
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.components.container:Close()
            inst.components.container:DropEverything()
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/death")
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
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/open")
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("open_idle") end ),
        },

        -- timeline=
        -- {
        --     TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/open") end),
        -- },        
    },

    State{
        name = "open_idle",
        tags = {"busy", "open"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_loop_open")
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("open_idle") end ),
        },


    },

    State{
        name = "close",
        tags = {""},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("closed")
            -- print("grabble")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/close")
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },

        -- timeline=
        -- {
        --     TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/close") end),
        -- },        
    },

    State{
        name = "take_off",
        tags = {"canrotate", "busy"},
        
        onenter = function(inst)
            local should_move = inst.components.locomotor:WantsToMoveForward()
            local should_run = inst.components.locomotor:WantsToRun()
            if should_move then
                inst.components.locomotor:WalkForward()
            elseif should_run then
                inst.components.locomotor:RunForward()
            end
            inst.AnimState:SetBank("robin_flight")
            inst.AnimState:PlayAnimation("takeoff")
        end,
       
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "land",
        tags = {"canrotate", "busy"},
        
        onenter = function(inst)
            local should_move = inst.components.locomotor:WantsToMoveForward()
            local should_run = inst.components.locomotor:WantsToRun()
            if should_move then
                inst.components.locomotor:WalkForward()
            elseif should_run then
                inst.components.locomotor:RunForward()
            end
            inst.AnimState:SetBank("robin_land")
            inst.AnimState:PlayAnimation("takeoff")
        end,
       
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end),
        },

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst)inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/mouth_open") end),
            TimeEvent(8*FRAMES, function(inst)inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/mouth_open",nil,.5) end),
        },
    },


    State{
        name = "spawn",
        tags = {"canrotate", "busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle")
        end,
       
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end),
        },
    },    

    State{
        name = "land",
        tags = {"canrotate", "busy"},
        
        onenter = function(inst)
            local should_move = inst.components.locomotor:WantsToMoveForward()
            local should_run = inst.components.locomotor:WantsToRun()
            if should_move then
                inst.components.locomotor:WalkForward()
            elseif should_run then
                inst.components.locomotor:RunForward()
            end
            inst.AnimState:SetBank("ro_bin_water")
            inst.AnimState:PlayAnimation("land")

        end,
       
        events=
        {    
            EventHandler("animover", function(inst) 
                inst.AnimState:SetBank("ro_bin")
                inst.sg:GoToState("idle")
            end),
        },
        
    },

    State{
        name = "takeoff",
        tags = {"canrotate", "busy"},
        
        onenter = function(inst)
            local should_move = inst.components.locomotor:WantsToMoveForward()
            local should_run = inst.components.locomotor:WantsToRun()
            if should_move then
                inst.components.locomotor:WalkForward()
            elseif should_run then
                inst.components.locomotor:RunForward()
            end

            inst.AnimState:SetBank("ro_bin_water")
            inst.AnimState:PlayAnimation("takeoff")
        end,
       
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end),
        },
    },

}

CommonStates.AddWalkStates(states,
{

    
    starttimeline = 
    {
        TimeEvent(1*FRAMES, function(inst) 
            if inst.onwater then
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/flap")
                inst.components.locomotor:WalkForward() 
            else
                -- inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/boing")
                -- inst.components.locomotor:RunForward() 
            end
        end),
    },

    walktimeline = 
    { 
        TimeEvent(0*FRAMES, function(inst)
            if inst.altstep  then               -- and not inst.onwater
                --inst.AnimState:PlayAnimation("walk_loop_alt")
                inst.altstep = nil
            else
                --inst.AnimState:PlayAnimation("walk_loop")
                if not inst.onwater then
                    inst.altstep = true
                end
            end   
        end),
        --TimeEvent(0*FRAMES, function(inst)  end),
        TimeEvent(1*FRAMES, function(inst) 
            if inst.onwater then
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/flap")
                inst.components.locomotor:WalkForward() 
            else
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/step")
                inst.components.locomotor:RunForward() 
            end
        end),

        TimeEvent(13*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/bounce")
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/foley/blubber_suit",nil,.3) end),
        TimeEvent(8*FRAMES, function(inst) 
            if inst.onwater then
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/flap")
            end
        end),        
    
        TimeEvent(12*FRAMES, function(inst) 
            if inst.onwater then
            else
                PlayFootstep(inst)
               -- inst.components.locomotor:Stop()
            end
        end),
    },    

    endtimeline = 
    {
        TimeEvent(1*FRAMES, function(inst) 
            if inst.onwater then
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/flap")
                inst.components.locomotor:WalkForward() 
            else
                -- inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/boing")
                -- inst.components.locomotor:RunForward() 
            end
        end),
    },
}, nil, true)

CommonStates.AddSleepStates(states,
{
    starttimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/hit") end)
    },
    
    sleeptimeline = 
    {
        -- TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/sleep_out") end),
        -- TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/sleep_in") end),
        -- TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/sleep_out") end),
        -- TimeEvent(60*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/sleep_in") end),
    },
    waketimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/ro_bin/hit") end)
    },



})

CommonStates.AddSimpleState(states, "hit", "hit", {"busy"})

return StateGraph("ro_bin", states, events, "idle", actionhandlers)

