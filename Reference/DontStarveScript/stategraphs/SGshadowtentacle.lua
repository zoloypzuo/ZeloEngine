require("stategraphs/commonstates")

local events=
{
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("newcombattarget", function(inst,data)            
            if inst.sg:HasStateTag("idle") and data.target then
                inst.sg:GoToState("taunt")
            end
        end)
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "invisible"},
        onenter = function(inst)
            inst.AnimState:PushAnimation("idle", true)
            inst.sg:SetTimeout(GetRandomWithVariance(10, 5) )
        end,
                
        ontimeout = function(inst)
			inst.sg:GoToState("rumble")
        end,
    },
    
    State{
        name = "taunt",
        tags = {"taunting"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("breach_pre")
            inst.AnimState:PushAnimation("breach_loop", true)
        end,

        onupdate = function(inst)
            if inst.sg.timeinstate > .75 and inst.components.combat:TryAttack() then
                inst.sg:GoToState("attack_pre")
            elseif inst.components.combat.target == nil then
                inst:Remove()
            end

        end,
    },
    
    State{
        name ="attack_pre",
        tags = {"attack"},
        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("attack") end),
        },        
    },
    
    State{ 
        name = "attack",
        tags = {"attack"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk_loop")
            inst.AnimState:PushAnimation("atk_idle", false)
        end,
        
        timeline=
        {
			TimeEvent(7*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            TimeEvent(17*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            TimeEvent(18*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) 
                    inst.sg:GoToState("attack_post") 
            end),
        },
    },
    
    State{
        name ="attack_post",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk_pst")
        end,
        events=
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },
    },
    
    
	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            RemovePhysicsColliders(inst)
        end,     
    },
    
        
    State{
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
    
}
CommonStates.AddFrozenStates(states)
    
return StateGraph("shadowtentacle", states, events, "idle")

