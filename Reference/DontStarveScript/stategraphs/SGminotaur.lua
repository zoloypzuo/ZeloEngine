require("stategraphs/commonstates")

local actionhandlers = 
{
}


local events=
{
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("doattack", function(inst)
        local nstate = "attack"
        if inst.sg:HasStateTag("running") then
            nstate = "runningattack"
        end
        if inst.components.health and not inst.components.health:IsDead()
           and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState(nstate)
        end
    end),

    EventHandler("locomote", function(inst)
        local is_attacking = inst.sg:HasStateTag("attack") or inst.sg:HasStateTag("runningattack")
        local is_busy = inst.sg:HasStateTag("busy")
        local is_idling = inst.sg:HasStateTag("idle")
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running") or inst.sg:HasStateTag("runningattack")

        if is_attacking or is_busy then return end

        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()
        
        if is_moving and not should_move then
            inst.SoundEmitter:KillSound("charge")
            if is_running then
                inst.sg:GoToState("run_stop")
            else
                inst.sg:GoToState("walk_stop")
            end
        elseif (not is_moving and should_move) or (is_moving and should_move and is_running ~= should_run) then
            if should_run then
                inst.sg:GoToState("run_start")
            else
                inst.sg:GoToState("walk_start")
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
            inst.SoundEmitter:KillSound("charge")
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end

            inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/voice")

        end,
        
       
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },


    State{  name = "run_start",
            tags = {"moving", "running", "busy", "atk_pre", "canrotate"},
            
            onenter = function(inst)
                inst.Physics:Stop()
                -- inst.components.locomotor:RunForward()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/pawground")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/voice")
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PlayAnimation("paw_loop", true)
                inst.sg:SetTimeout(1.5)
            end,
            
            ontimeout= function(inst)
                inst.sg:GoToState("run")
                inst:PushEvent("attackstart" )
            end,

            timeline=
            {
		    TimeEvent(12*FRAMES, function(inst)
                                    inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/pawground")
                                end ),

            --TimeEvent(30*FRAMES,  function(inst) inst.sg:RemoveStateTag("canrotate") end ),

		    TimeEvent(30*FRAMES, function(inst)
                                    inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/pawground")
                                end ),
            },        

            onexit = function(inst)
                --inst.SoundEmitter:PlaySound(inst.soundpath .. "charge_LP","charge")
            end,
        },

    State{  name = "run",
            tags = {"moving", "running"},
            
            onenter = function(inst) 
                inst.components.locomotor:RunForward()
                inst.AnimState:PlayAnimation("atk")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/step")

            end,
            
            timeline=
            {
                TimeEvent(5*FRAMES, function(inst)
                        inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/step")                                        
                                    end ),
            },
            
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
            },
        },
    
    State{  name = "run_stop",
            tags = {"canrotate", "idle"},
            
            onenter = function(inst) 
                inst.SoundEmitter:KillSound("charge")
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("gore")
            end,
            
            timeline =
            {
                TimeEvent(5*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            },
            
            events =
            {
                EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
            },
        },    

   State{
        name = "taunt",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/voice")
        end,
        
        timeline = 
        {
		    TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/voice") end ),
		    TimeEvent(27*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/voice") end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{  
        name = "runningattack",
        tags = {"runningattack"},
        
        onenter = function(inst)
            inst.SoundEmitter:KillSound("charge")
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("gore")
        end,
        
        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },
        
        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("attack") end),
        },
    },
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("gore")
        end,
        
        timeline =
        {
            TimeEvent(5*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },
        
        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "hit",
        tags = {"hit", "busy"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
        end,
        
        hittimeline = 
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/hurt") end),
        },
        
        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "death",
        tags = {"death", "busy"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death")
            inst.components.lootdropper:DropLoot()
        end,
        
        TimeEvent(0*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/death")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/death_voice")
        end),
        
    },
}

CommonStates.AddWalkStates(states,
{
    starttimeline = 
    {
	    TimeEvent(0*FRAMES, function(inst) inst.Physics:Stop() end ),
    },
	walktimeline = {
		    TimeEvent(0*FRAMES, function(inst) inst.Physics:Stop() end ),
            TimeEvent(7*FRAMES, function(inst) 
                inst.components.locomotor:WalkForward()
            end ),
            TimeEvent(20*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/step")
                --       :Shake(shakeType, duration, speed, scale)
                TheCamera:Shake("VERTICAL", 0.5, 0.05, 0.1)
                inst.Physics:Stop()
            end ),
	},
}, nil,true)

CommonStates.AddSleepStates(states,
{
    starttimeline = 
    {
		TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/liedown") end ),
    },
    
	sleeptimeline = {
        TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/sleep") end),
	},
})

-- CommonStates.AddCombatStates(states,
-- {
--     attacktimeline = 
--     {
--         TimeEvent(17*FRAMES, function(inst)
--                                 inst.components.combat:DoAttack()
--                              end),
--     },
--     hittimeline = 
--     {
--         TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/hurt") end),
--     },
--     deathtimeline = 
--     {
--         TimeEvent(0*FRAMES, function(inst) 
--             inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/death")
--             inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/death_voice")
--         end),
--     },
-- })

CommonStates.AddFrozenStates(states)

    
return StateGraph("rook", states, events, "idle", actionhandlers)

