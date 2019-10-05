require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.HARVEST, "eat_enter"),
    ActionHandler(ACTIONS.PICK, "eat_enter"),
    ActionHandler(ACTIONS.PICKUP, "eat_enter"),
    ActionHandler(ACTIONS.MURDER, "action"),
}


local events=
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnDeath(),
    EventHandler("attacked", function(inst) 
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then           
            inst.sg:GoToState("hit") 
        end 
    end),
}

local states=
{
    State
    {
        name = "spawn",
        tags = {"busy"},

        onenter = function(inst, playanim)
            inst.Physics:Stop()           
            inst.AnimState:PlayAnimation("spawn")
            inst.AnimState:PushAnimation("idle", true)   
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_emerge")        
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

    },

    State
    {        
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)
        end,


    },

    State
    {        
        name = "action",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst:PerformBufferedAction()            
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State
    {
        
        name = "alert",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if inst.components.combat.target then    
                inst:ForceFacePoint(inst.components.combat.target.Transform:GetWorldPosition())
            end
            inst.AnimState:PlayAnimation("lookat", true) 
        end,

        events = 
        {
            EventHandler("losttarget", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State
    {
        name = "hit",
        tags = {"busy", "hit"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("attack") end),
        },
        
    },  

    State
    { 
        name = "attack",
        tags = {"attack", "canrotate"},
        onenter = function(inst)
            if inst.components.combat.target then    
                inst:ForceFacePoint(inst.components.combat.target.Transform:GetWorldPosition())
            end
            inst.AnimState:PlayAnimation("atk")
        end,
        
        timeline=
        {
            TimeEvent(14*FRAMES, function(inst) inst.components.combat:DoAttack()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_bite")
            end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) 
                if inst.components.combat.target and 
                    distsq(inst.components.combat.target:GetPosition(),inst:GetPosition()) <= 
                    inst.components.combat:CalcAttackRangeSq(inst.components.combat.target) then

                    inst.sg:GoToState("attack")
                else
                    inst.sg:GoToState("alert")
                end
            end),
        },
    },

    State
    {
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("despawn")
            RemovePhysicsColliders(inst) 
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_retract")      

        end,        
    },

    State
    {
        name = "eat_enter",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk", false)
        end,

        timeline = 
        {
            TimeEvent(14*FRAMES, function(inst) 
            if inst:GetBufferedAction().target then
                inst:GetBufferedAction().target:PushEvent("ontrapped")
            end
            inst:PerformBufferedAction() 
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_bite")
            end ), --take food
        },

        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State
    {
        name = "eat_loop",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit", true)
            inst.sg:SetTimeout(1+math.random()*2)
        end,

        ontimeout= function(inst)
            inst.lastmeal = GetTime()
            inst:PerformBufferedAction()
            inst.sg:GoToState("idle")
        end,

        events = 
        {
            EventHandler("attacked", function(inst) inst.components.inventory:DropEverything() inst.sg:GoToState("idle") end) --drop food
        },
    },

    State
    {

        name = "walk_start",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            print("EYEPLANT WALK START!")
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end

            inst:PerformBufferedAction()

        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

    },
}


CommonStates.AddFrozenStates(states)
    
return StateGraph("eyeplant", states, events, "idle", actionhandlers)