require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "migrate"),
    ActionHandler(ACTIONS.WALKTO, "migrate"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.EAT, "eat_loop"),
}


local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("doattack", function(inst,target)
                                local nstate = "attack"
                                local targ = target.target
                                if target then
                                    inst.sg.statemem.target = target.target
                                    targ = target.target
                                    eprint(inst,"dattack targ",target.target)
                                end
                                if inst.sg:HasStateTag("running") then
                                    nstate = "runningattack"
                                end
                                if inst.components.health and not inst.components.health:IsDead()
                                   and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
                                    inst.SoundEmitter:KillSound("slide")
                                    inst.sg:GoToState(nstate,targ)
                                end
                            end),

    EventHandler("locomote", function(inst)
                                local is_attacking = inst.sg:HasStateTag("attack") or inst.sg:HasStateTag("runningattack")
                                local is_busy = inst.sg:HasStateTag("busy")
                                local is_idling = inst.sg:HasStateTag("idle")
                                local is_moving = inst.sg:HasStateTag("moving")
                                local is_running = inst.sg:HasStateTag("running") or inst.sg:HasStateTag("runningattack")

                                if is_attacking or is_busy then return end
                                if inst.sg:HasStateTag("flying") then return end

                                local should_move = inst.components.locomotor:WantsToMoveForward()
                                local should_run = inst.components.locomotor:WantsToRun()
                                
                                if is_moving and not should_move then
                                    inst.SoundEmitter:KillSound("slide")
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
    EventHandler("flyaway", function(inst) 
        if inst.components.health:GetPercent() > 0 and not inst.sg:HasStateTag("flying") then 
            inst.sg:GoToState("flyaway") 
        end 
    end),
}

local states=
{
    State{  name = "idle",
            tags = {"idle", "canrotate"},
            onenter = function(inst, playanim)
                inst.Physics:Stop()
                inst.components.locomotor:Stop()
                inst.SoundEmitter:KillSound("slide")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/idle")
                if playanim then
                    inst.AnimState:PlayAnimation(playanim)
                    inst.AnimState:SetTime(math.random()*2)
                    inst.AnimState:PushAnimation("idle_loop", true)
                else
                    inst.AnimState:PlayAnimation("idle_loop", true)
                end
            end,
            
            timeline = 
            {
                --TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/idle") end ),
            },
            
            events=
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
            },
        },

    State{  name = "run_start",
            tags = {"moving", "running", "canrotate"},
            
            onenter = function(inst)
                inst.components.locomotor:RunForward()
                inst.AnimState:SetTime(math.random()*2)
                inst.SoundEmitter:KillSound("slide")
                if GetSeasonManager():GetSnowPercent() < 0.1 then
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/land")
                else
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/land_dirt")
                end
                inst.AnimState:PlayAnimation("slide_bounce")
                inst.sg.mem.foosteps = 0
            end,

            events =
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
            },
            
            onexit = function(inst)
                if GetSeasonManager():IsWinter() then
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/slide","slide")
                else
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/slide_dirt","slide")
                end
            end,

            timeline=
            {
            },        
        },

    State{  name = "run",
            tags = {"moving", "running", "canrotate"},
            
            onenter = function(inst) 
                inst.components.locomotor:RunForward()
                inst.AnimState:PlayAnimation("slide_loop")
            end,
            
            timeline=
            {
            },
            
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
            },
        },
    
    State{  name = "run_stop",
            tags = {"canrotate", "idle"},
            
            onenter = function(inst) 
                inst.SoundEmitter:KillSound("slide")
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("slide_post")
            end,
            
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("walk_start") end ),        
            },
        },    

    
    State{  name = "walk_start",
            tags = {"moving", "canrotate"},
            
            onenter = function(inst)
                inst.SoundEmitter:KillSound("slide")
                inst.components.locomotor:WalkForward()
                -- inst.AnimState:SetTime(math.random()*2)
                inst.AnimState:PlayAnimation("walk")
            end,

            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
            },
        },      
    
    State{  name = "walk",
            tags = {"moving", "canrotate"},
            
            onenter = function(inst) 
                inst.components.locomotor:WalkForward()
                inst.AnimState:PlayAnimation("walk", true)
                inst.SoundEmitter:KillSound("slide")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/idle")
            end,
    
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
            },

            timeline = {
                TimeEvent(5*FRAMES, function(inst)
                                        if GetSeasonManager():IsWinter() then
                                            inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep")
                                        else
                                            inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep_dirt")
                                        end
                                    end),
                TimeEvent(21*FRAMES, function(inst)
                                        if GetSeasonManager():IsWinter() then
                                            inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep")
                                        else
                                            inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep_dirt")
                                        end
                                    end),
            },
        },

    State{  name = "walk_stop",
            tags = {"canrotate", "idle"},
            
            onenter = function(inst) 
                inst.SoundEmitter:KillSound("slide")
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("idle_loop", true)
            end,

            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
            },
        },   
    
    State{  name = "eat_pre",
            tags = {"busy"},
            onenter = function(inst)
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("atk_pre", false)
                inst.SoundEmitter:KillSound("slide")
            end,

            timeline = 
            {
                TimeEvent(4*FRAMES, function(inst) 
                                        inst:PerformBufferedAction()
                                        --inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/bite")
                                     end ), --take food
            },        
            
            events = 
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("eat_loop") end)
            },

        },


    State{  name = "eat_loop",
            tags = {"busy"},
            onenter = function(inst)
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("eat", true)
                inst.sg:SetTimeout(0.8+math.random())
            end,

            timeline = 
            {
            },

            events = 
            {
                EventHandler("attacked",
                             function(inst)
                                 inst.components.inventory:DropItem(inst:GetBufferedAction().target)
                                 inst.sg:GoToState("idle")
                             end) --drop food
            },
            
            ontimeout= function(inst)
                            inst.lastmeal = GetTime()
                            inst:PerformBufferedAction()
                            inst.sg:GoToState("idle", "walk")
                        end,
        }, 

    State{  name = "pickup",
            tags = {"busy"},
            onenter = function(inst)
                inst.SoundEmitter:KillSound("slide")
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", true)
                inst.sg:SetTimeout(0.2)
            end,

            timeline = 
            {
            },

            events = 
            {
                EventHandler("attacked",
                             function(inst)
                                 inst.components.inventory:DropItem(inst:GetBufferedAction().target)
                                 inst.sg:GoToState("idle")
                             end) --drop food
            },
            
            ontimeout= function(inst)
                            inst.lastmeal = GetTime()
                            inst:PerformBufferedAction()
                            inst.sg:GoToState("idle")
                        end,
        }, 

    State{  name = "action",
            onenter = function(inst, playanim)
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("idle", true)
                inst:PerformBufferedAction()
            end,
            timeline = 
            {
                TimeEvent(GetRandomWithVariance(30,15)*FRAMES, function(inst)
                                        inst.sg:GoToState("walk_start") 
                                     end),
            },
            --[[
            events=
            {
                EventHandler("animover", function (inst)
                    inst.sg:GoToState("idle")
                end),
            }
            --]]
        },  

    State{  name = "migrate",
            onenter = function(inst, playanim)
                inst.SoundEmitter:KillSound("slide")
                inst:PerformBufferedAction()
                inst.components.locomotor:WalkForward()
                inst.AnimState:PlayAnimation("walk", true)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/idle")
            end,
            timeline = {
                TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep") end),
                TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep") end),
            },
            events=
            {
                EventHandler("animover", function (inst)
                    inst.sg:GoToState("walk_start")
                end),
            }
        },  

	State{  name = "death",
            tags = {"busy"},
            
            onenter = function(inst)
                inst.SoundEmitter:KillSound("slide")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/death")
                inst.Physics:Stop()	
                inst.AnimState:PlayAnimation("death")
                inst.components.locomotor:StopMoving()
                inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
            end,
            
        },
    
    
    State{  name = "appear",
            tags = {"busy"},
            
            onenter = function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/splash")
                inst.Physics:Stop()	
                inst.AnimState:PlayAnimation("slide_pre")
            end,

            events =
            {
                EventHandler("animqueueover", function(inst) inst.sg:GoToState("landing") end),
            },
        },
        
    State{  name = "landing",
            tags = {"busy"},
            
            onenter = function(inst)
                inst.components.locomotor:RunForward()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/jumpin")
                inst.AnimState:PushAnimation("slide_loop", "loop")
            end,
            
            timeline = 
            {
                TimeEvent(GetRandomWithVariance(30,15)*FRAMES, function(inst)
                                        inst.sg:GoToState("walk_start") 
                                        --inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/slide")
                                     end),
            },
        },
        
   State{ name = "taunt",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/taunt")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{  name = "attack",
            tags = {"attack"},
            
            onenter = function(inst,target)
                eprint(inst,"StateAttack onenter:",target,inst.sg.statemem.target)
                if target then
                    inst.sg.statemem.target = target
                end
                inst.SoundEmitter:KillSound("slide")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/attack")
                inst.components.combat:StartAttack()
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
            end,
            
            timeline =
            {
                TimeEvent(15*FRAMES, function(inst)
                                        eprint(inst,"DoAttack()",inst.sg.statemem.target)
                                        inst.components.combat:DoAttack(inst.sg.statemem.target)
                                        -- inst.components.combat:DoAttack()
                                     end),
            },
            
            events =
            {
                EventHandler("animqueueover", function(inst) inst.sg:GoToState("walk_start") end),
            },
        },

    State{ name = "flyaway",
        tags = {"flying", "busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.Physics:ClearCollisionMask()
            inst.Physics:SetCollides(false)
            inst.sg:SetTimeout(.1+math.random()*.2)
            inst.sg.statemem.vert = math.random() > .1

            inst.Physics:SetMotorVelOverride(00,15,0)
            
	        inst.DynamicShadow:Enable(false)
            -- inst.SoundEmitter:PlaySound(inst.sounds.takeoff)
            
            if inst.sg.statemem.vert then
                --inst.AnimState:PlayAnimation("takeoff_vertical_pre")
                inst.AnimState:PushAnimation("atk_pre", true)
            else
                --inst.AnimState:PlayAnimation("takeoff_diagonal_pre")
                inst.AnimState:PushAnimation("atk_pre", true)
            end
        end,
        
        ontimeout= function(inst)
            if inst.sg.statemem.vert then
                --inst.AnimState:PushAnimation("takeoff_vertical_loop", true)
                inst.AnimState:PushAnimation("idle_loop", true)
                --inst.Physics:SetMotorVel(-1 + math.random(),15+(math.random()*5),-2 + math.random())
                inst.Physics:SetMotorVelOverride(00,15,0)
            else
                --inst.AnimState:PushAnimation("takeoff_diagonal_loop", true)
                inst.AnimState:PushAnimation("idle_loop", true)
                local x = 8+ math.random()*8
                --inst.Physics:SetMotorVel(x,15+(math.random()*5),-2 + math.random()*4)
                inst.Physics:SetMotorVelOverride(00,15,0)
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("flyaway") end),
        },
        
        timeline = 
        {
            TimeEvent(2, function(inst) inst:Remove() end)
            --TimeEvent(8*FRAMES, function(inst) inst.Physics:SetMotorVelOverride(20,0,0) end),
        }
        
    },

    State{  name = "runningattack",
            tags = {"runningattack"},
            
            onenter = function(inst)
                inst.SoundEmitter:KillSound("slide")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/attack")
                inst.components.combat:StartAttack()
                --inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("slide_bounce")
            end,
            
            timeline =
            {
                TimeEvent(1*FRAMES, function(inst)
                                        inst.components.combat:DoAttack()
                                     end),
            },
            
            events =
            {
                EventHandler("animqueueover", function(inst) inst.sg:GoToState("walk_start") end),
            },
        },
}

CommonStates.AddSleepStates(states,
    {
        starttimeline = 
        {
            -- TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/sleep") end ),
        },
        sleeptimeline = {
            TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/sleep") end),
        },
    })


CommonStates.AddSimpleState(states,"hit","hit", {"busy"})
    
return StateGraph("penguin", states, events, "idle", actionhandlers)

