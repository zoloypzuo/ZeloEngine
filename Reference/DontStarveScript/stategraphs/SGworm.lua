require("stategraphs/commonstates")

local function doattackfn(inst, data)
    if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
        if inst.sg:HasStateTag("lure") then
            inst.sg:GoToState("attack_pre")
        else
            inst.sg:GoToState("attack")
        end
    end
end

local function onattackedfn(inst, data)
    if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("invisible") 
        and not inst.sg:HasStateTag("nohit") then
        --Will handle the playing of the "hit" animation
        inst.sg:GoToState("hit")
    end
end

local actionhandlers =
{
    ActionHandler(ACTIONS.PICKUP, "action"),
    ActionHandler(ACTIONS.PICK, "action"),
    ActionHandler(ACTIONS.HARVEST, "action"),
    ActionHandler(ACTIONS.EAT, "eat"),
}

local events=
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnSleep(),
    EventHandler("doattack", doattackfn),
    EventHandler("attacked", onattackedfn),
    EventHandler("dolure", function(inst) inst.sg:GoToState("lure_enter") end)
}

local states=
{
    State{
        name = "idle_enter",
        tags = {"idle", "invisible", "dirt"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("mound")
            inst.SoundEmitter:KillAllSounds()
        end,
        
        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State{
        name = "idle",
        tags = {"idle", "invisible", "dirt"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("mound_idle", true)
            inst.SoundEmitter:KillAllSounds()
        end,
        
        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State{
        name = "idle_exit",
        tags = {"idle", "invisible", "dirt"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("mound_out")
            inst.SoundEmitter:KillAllSounds()
        end,
        
        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State{
        name = "action",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pickup")
            inst.SoundEmitter:KillAllSounds()    
            inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/emerge")        
        end,

        timeline=
        {           
            TimeEvent(10*FRAMES, function(inst) inst.sg:AddStateTag("nohit") end),
            TimeEvent(15*FRAMES, function(inst) inst:PerformBufferedAction()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/bite") end),
            TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/retract") end), 

        },        

        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },    
    
    State{        
        name = "eat",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/emerge")
        end,
        
        timeline=
        {           
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/eat") end),
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/eat") end),
            TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/eat") end),
            TimeEvent(60*FRAMES, function(inst) inst.sg:AddStateTag("nohit") inst:PerformBufferedAction() end),
            TimeEvent(75*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/retract") end), 

        },
        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    },

    State{
        name = "taunt",
        tags = {"taunting"},
        onenter = function(inst)
            inst.Physics:Stop()        
            inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/emerge")
            inst.AnimState:PlayAnimation("taunt")
        end,
        timeline=
        {           
            TimeEvent(20*FRAMES, function(inst) inst.sg:AddStateTag("nohit") end),
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/retract") end), 

        },
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack_pre",
        tags = {"canrotate", "invisible"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.components.lighttweener:StartTween(nil, 0, nil, nil, nil, .66, function(inst, light) if light then light:Enable(false) end end)
        end,
        
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("attack") end),
        },
    },
       
    State{ 
        name = "attack",
        tags = {"attack", "nohit"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
            inst.components.combat:StartAttack()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/emerge")
        end,
        
        timeline=
        {           
            --TimeEvent(20*FRAMES, function(inst) inst.sg:AddStateTag("nohit") end),
			TimeEvent(25*FRAMES, function(inst) inst.components.combat:DoAttack()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/bite") end),
            TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/retract") end), 

        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
    
	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,   
        timeline=
        {           
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/retract") end), 
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/death") end),            
        },      
    },    
        
    State{
        name = "hit",
        tags = {"busy", "hit"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
        end,          
        timeline=
        {           
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/retract") end), 
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/hurt") end),            
        },         
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },        
    },  

    State{
        name = "walk_start",
        tags = {"moving", "canrotate", "dirt", "invisible"},

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_pre")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/move", "walkloop")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("walkloop")
        end,

        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end)
        },
    },

    State{
        name = "walk",
        tags = {"moving", "canrotate", "dirt", "invisible"},

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_loop")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/move", "walkloop")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("walkloop")
        end,

        timeline = 
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/dirt") end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/dirt") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/dirt") end),
        },

        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end)
        },
    },

    State{
        name = "walk_stop",
        tags = {"canrotate", "dirt", "invisible"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pst")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/move", "walkloop")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("walkloop")
        end,

        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_enter") end)
        },
    },  

    State{
        name = "lure_enter",
        tags = {"invisible", "lure"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("lure_enter")
            inst.SoundEmitter:KillAllSounds()
            inst.components.pickable.canbepicked = true
            ChangeToInventoryPhysics(inst)

            inst.Light:Enable(true)
            inst.components.lighttweener:StartTween(nil, 1.5, nil, nil, nil, .66)
        end,
        timeline=
        {           
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/lure_emerge") end),            
        }, 


        onexit = function(inst)
            inst.components.pickable.canbepicked = false
            ChangeToCharacterPhysics(inst)
        end,
                
        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("lure") end)
        },
    },

    State{
        name = "lure",
        tags = {"invisible", "lure"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop", true)
            inst.SoundEmitter:KillAllSounds()
            inst.components.pickable.canbepicked = true
            ChangeToInventoryPhysics(inst)
            inst.sg:SetTimeout(GetRandomWithVariance(TUNING.WORM_LURE_TIME, TUNING.WORM_LURE_VARIANCE))
        
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("lure_exit")
        end,

        onexit = function(inst)
            inst.lastluretime = GetTime()
            inst.components.pickable.canbepicked = false
            ChangeToCharacterPhysics(inst)
        end,
    },

    State{
        name = "lure_exit",
        tags = {"invisible", "lure"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("lure_exit")
            inst.SoundEmitter:KillAllSounds()
            inst.components.pickable.canbepicked = true
            ChangeToInventoryPhysics(inst)
            
            inst.components.lighttweener:StartTween(nil, 0, nil, nil, nil, .66, function(inst, light) if light then light:Enable(false) end end)
        end,

        onexit = function(inst)
            inst.components.pickable.canbepicked = false
            ChangeToCharacterPhysics(inst)
        end,

        timeline=
        {           
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/worm/lure_retract") end),            
        }, 
                
        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_enter") end)
        },
    },


}

CommonStates.AddFrozenStates(states)
    
return StateGraph("worm", states, events, "idle", actionhandlers)

