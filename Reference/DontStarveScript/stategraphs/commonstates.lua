CommonStates = {}
CommonHandlers = {}

CommonHandlers.OnStep = function()
    return EventHandler("step", function(inst)
        local sound = inst.SoundEmitter
        if sound then
            sound:PlaySound("dontstarve/movement/run_dirt")
            --[[else
                sound:PlaySound("dontstarve/movement/walk_dirt")
            end--]]
        end
    end)
end

CommonHandlers.OnSleep = function()
    return EventHandler("gotosleep", function(inst)
        if inst.components.health and inst.components.health:GetPercent() > 0 then
            if inst.sg:HasStateTag("sleeping") then
                inst.sg:GoToState("sleeping")
            else
                inst.sg:GoToState("sleep")
            end
        end
    end)
end

CommonHandlers.OnFreeze = function()
    return EventHandler("freeze", function(inst)
        if inst.components.health and inst.components.health:GetPercent() > 0 then
            inst.sg:GoToState("frozen")
        end
    end)
end

CommonHandlers.OnAttacked = function()
    return EventHandler("attacked", function(inst)
        if inst.components.health and not inst.components.health:IsDead()
           and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("frozen") ) then
            inst.sg:GoToState("hit")
        end
    end)
end

CommonHandlers.OnAttack = function()
    return EventHandler("doattack", function(inst)
        if inst.components.health and not inst.components.health:IsDead()
           and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("attack")
        end
    end)
end

CommonHandlers.OnDeath = function()
    return EventHandler("death", function(inst) inst.sg:GoToState("death") end)
end

CommonHandlers.OnLocomote = function(can_run, can_walk)

    return EventHandler("locomote", function(inst)
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        
        local is_idling = inst.sg:HasStateTag("idle")
        
        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()
        if is_moving and not should_move then
            if is_running then
                inst.sg:GoToState("run_stop")
            else
                inst.sg:GoToState("walk_stop")
            end
        elseif (is_idling and should_move) or (is_moving and should_move and is_running ~= should_run and can_run and can_walk) then
            if can_run and (should_run or not can_walk) then
                inst.sg:GoToState("run_start")
            elseif can_walk then
                inst.sg:GoToState("walk_start")
            end
        end
    end)

end

CommonStates.AddIdle = function(states, funny_idle_state, anim_override, timeline)
    
    table.insert(states, State {
        name = "idle",
        tags = {"idle", "canrotate"},
        timeline = timeline,
        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()
            local anim = "idle_loop"
            if anim_override then
                if type(anim_override) == "function" then
                    anim = anim_override(inst)
                else
                    anim = anim_override
                end
            end
               
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation(anim, true)
            else
                inst.AnimState:PlayAnimation(anim, true)
            end
        end,
        
        events=
        {
            EventHandler("animover", function(inst) 
                if funny_idle_state and math.random() < .1 then
                    inst.sg:GoToState(funny_idle_state)
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })
end

    
CommonStates.AddSimpleState = function(states, name, anim, tags)
    table.insert(states, State{
        name = name,
        tags = tags or {},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation(anim)
            inst.components.locomotor:StopMoving()
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    })
end

CommonStates.AddSimpleActionState = function(states, name, anim, time, tags)
    table.insert(states, State{
        name = name,
        
        tags = tags or {},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation(anim)
            inst.components.locomotor:StopMoving()
        end,
        
        timeline=
        {
            TimeEvent(time, function(inst) inst:PerformBufferedAction() end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    })
end

CommonStates.AddShortAction = function( states, name, anim, timeout )
    table.insert(states, State{
        name = "name",
        tags = {"doing"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation(anim)
            inst.sg:SetTimeout(timeout or 6*FRAMES)
        end,
        
        ontimeout= function(inst)
            doer:PerformBufferedAction()
        end,
        
        events=
        {
            EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end end ),
        },
    })
end


local function get_loco_state(inst, override, default)
    local anim = default
    if override then
        anim = type(override) == "function" and override(inst) or override
    end
    return anim
end

CommonStates.AddRunStates = function(states, timelines, anims, softstop)
   local startrun = State{
            name = "run_start",
            tags = {"moving", "running", "canrotate"},
            
            onenter = function(inst) 
                inst.components.locomotor:RunForward()
                inst.AnimState:PlayAnimation(get_loco_state(inst, anims and anims.startrun, "run_pre"))
            end,

            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),
            },
            
        }
    

    local run = State{
            
            name = "run",
            tags = {"moving", "running", "canrotate"},
            
            onenter = function(inst) 
                inst.components.locomotor:RunForward()
                inst.AnimState:PlayAnimation(get_loco_state(inst, anims and anims.run, "run_loop"))
            end,
            
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),
            },
        }
        
    local stoprun = State{
        
            name = "run_stop",
            tags = {"idle"},
            
            onenter = function(inst) 
                inst.components.locomotor:StopMoving()

                local should_softstop = (type(softstop) == "function" and softstop(inst)) or softstop

                if should_softstop then
                    inst.AnimState:PushAnimation(get_loco_state(inst, anims and anims.stoprun, "run_pst"))
                else
                    inst.AnimState:PlayAnimation(get_loco_state(inst, anims and anims.stoprun, "run_pst"))
                end
            end,
            
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
            },
        }
        
    if timelines then
        startrun.timeline = timelines.starttimeline
        run.timeline = timelines.runtimeline
        stoprun.timeline = timelines.endtimeline
    end        

    table.insert(states, startrun)
    table.insert(states, run)
    table.insert(states, stoprun)
end

CommonStates.AddSimpleRunStates = function(states, anim, timelines)
    CommonStates.AddRunStates(states, timelines, { startrun = anim, run = anim, stoprun = anim } )
end

CommonStates.AddWalkStates = function(states, timelines, anims, softstop)
    
    local startwalk = State{
            name = "walk_start",
            tags = {"moving", "canrotate"},

            onenter = function(inst) 
                inst.components.locomotor:WalkForward()
                inst.AnimState:PlayAnimation(get_loco_state(inst, anims and anims.startwalk, "walk_pre"))
            end,

            events =
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
            },
        }
        
    local walk = State{
            
            name = "walk",
            tags = {"moving", "canrotate"},
            
            onenter = function(inst) 
                inst.components.locomotor:WalkForward()
                inst.AnimState:PlayAnimation(get_loco_state(inst, anims and anims.walk, "walk_loop"))
            end,
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
            },
        }        
    
    local endwalk = State{
            
            name = "walk_stop",
            tags = {"canrotate"},
            
            onenter = function(inst) 
                inst.components.locomotor:StopMoving()
                
                local should_softstop = (type(softstop) == "function" and softstop(inst)) or softstop

                if should_softstop then
                    inst.AnimState:PushAnimation(get_loco_state(inst, anims and anims.stopwalk, "walk_pst"))
				else
                    inst.AnimState:PlayAnimation(get_loco_state(inst, anims and anims.stopwalk, "walk_pst"))
				end
            end,

            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
            },
        }
        
    if timelines then
        startwalk.timeline = timelines.starttimeline
        walk.timeline = timelines.walktimeline
        endwalk.timeline = timelines.endtimeline
    end
    
    table.insert(states, startwalk)    
    table.insert(states, walk)
    table.insert(states, endwalk)
end

CommonStates.AddSimpleWalkStates = function(states, anim, timelines)
    CommonStates.AddWalkStates(states, timelines, { startwalk = anim, walk = anim, stopwalk = anim }, true )
end

CommonStates.AddSleepStates = function(states, timelines, fns)
    
    local startsleep = State{
            name = "sleep",
            tags = {"busy", "sleeping"},
            
            onenter = function(inst) 
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("sleep_pre")
                if fns and fns.onsleep then
					fns.onsleep(inst)
                end
            end,

            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("sleeping") end ),
                EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
            },
        }
        
    local sleep = State{
            
            name = "sleeping",
            tags = {"busy", "sleeping"},
            
            onenter = function(inst) 
                inst.AnimState:PlayAnimation("sleep_loop")
            end,
            
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("sleeping") end ),
                EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
            },
        }
    
    local endsleep = State{
            
            name = "wake",
            tags = {"busy", "waking"},
            
            onenter = function(inst) 
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("sleep_pst")
                if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
                    inst.components.sleeper:WakeUp()
                end
                if fns and fns.onwake then
					fns.onwake(inst)
                end
                
            end,

            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
            },
        }


    local forcesleep = State{
            name = "forcesleep",
            tags = {"busy", "sleeping"},

            onenter = function(inst)
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("sleep_loop", true)
            end
        }
        
    if timelines then
        startsleep.timeline = timelines.starttimeline
        sleep.timeline = timelines.sleeptimeline
        endsleep.timeline = timelines.waketimeline
    end
    
    table.insert(states, startsleep)    
    table.insert(states, sleep)
    table.insert(states, endsleep)
    table.insert(states, forcesleep)
end

CommonStates.AddFrozenStates = function(states)

    local frozen = State{
        name = "frozen",
        tags = {"busy", "frozen"},
        
        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("frozen")
            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
        end,
        
        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,
        
        events=
        {   
            EventHandler("onthaw", function(inst) inst.sg:GoToState("thaw") end ),
        },
    }

    local thaw = State{
        name = "thaw",
        tags = {"busy", "thawing"},
        
        onenter = function(inst) 
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("frozen_loop_pst", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
        end,
        
        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,

        events =
        {   
            EventHandler("unfreeze", function(inst)
                if inst.sg.sg.states.hit then
                    inst.sg:GoToState("hit")
                else
                    inst.sg:GoToState("idle")
                end
            end ),
        },
    }

    table.insert(states, frozen)    
    table.insert(states, thaw)    
end

CommonStates.AddCombatStates = function(states, timelines, anims)
    local hit = State{
        name = "hit",
        tags = {"hit", "busy"},
        
        onenter = function(inst, cb)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            local hitanim = "hit"
            if anims and anims.hit then
                if type(anims.hit) == "function" then
                    hitanim = anims.hit(inst)
                else
                    hitanim = anims.hit
                end
            end
            inst.AnimState:PlayAnimation(hitanim)
            if inst.SoundEmitter and inst.sounds then
                if inst.sounds.hit then
                    inst.SoundEmitter:PlaySound(inst.sounds.hit)
                end
            end
        end,
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    }

    local attack = State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst, target)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation(anims and anims.attack or "atk")
            inst.sg.statemem.target = target
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    }

    local death = State{
        name = "death",  
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation(anims and anims.death or "death")
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
			inst.Physics:ClearCollisionMask()
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        end,
    }

    if timelines then
        hit.timeline = timelines.hittimeline
        attack.timeline = timelines.attacktimeline
        death.timeline = timelines.deathtimeline
    end
    
    table.insert(states, hit)    
    table.insert(states, attack)    
    table.insert(states, death)    
end