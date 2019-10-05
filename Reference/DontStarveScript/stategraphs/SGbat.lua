require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "action"),
    ActionHandler(ACTIONS.EAT, "eat_loop"),
    ActionHandler(ACTIONS.PICKUP, "eat_enter")
}

local events=
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnSleep(),
}

local states =
{
    State{
        
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("fly_loop", true)
            else
                inst.AnimState:PlayAnimation("fly_loop", true)
            end
        end,
        
        timeline = 
        {
		    TimeEvent(7*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
            TimeEvent(17*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        
        name = "action",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("fly_loop", true)
            inst:PerformBufferedAction()
        end,
        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    }, 

    State{
        name = "taunt",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline = 
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/taunt") end ),
            TimeEvent(7*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
            TimeEvent(18*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
            TimeEvent(28*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
            TimeEvent(43*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "eat_enter",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat", false)
        end,

        onexit = function(inst)

        end,

        timeline = 
        {
            TimeEvent(7*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
            TimeEvent(9*FRAMES, function(inst) inst:PerformBufferedAction()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/bite") end ), --take food
            TimeEvent(17*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
        },

        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State{
        name = "eat_loop",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("eat_loop", true)
            inst.sg:SetTimeout(1+math.random()*2)
        end,

        ontimeout= function(inst)
            inst.lastmeal = GetTime()
            inst:PerformBufferedAction()
            inst.sg:GoToState("idle")
        end,

        timeline = 
        {
            TimeEvent(7*FRAMES, function(inst) inst:PushEvent("wingdown")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/chew")  end ),
            TimeEvent(17*FRAMES, function(inst) inst:PushEvent("wingdown")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/chew")  end ),
        },

        events = 
        {
            EventHandler("attacked", function(inst) inst.components.inventory:DropEverything() inst.sg:GoToState("idle") end) --drop food
        },
    },
}

local walkanims = 
{
    startwalk = "fly_loop",
    walk = "fly_loop",
    stopwalk = "fly_loop",
}

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(7*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
        TimeEvent(17*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
    },

	walktimeline = 
    {
	    TimeEvent(7*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
        TimeEvent(17*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
	},

    endtimeline =
    {
        TimeEvent(7*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
        TimeEvent(17*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
    },

},  walkanims, true)


CommonStates.AddSleepStates(states,
{
    starttimeline = 
    {
        TimeEvent(7*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
        TimeEvent(17*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),       
    },

    sleeptimeline = 
    {
        TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/sleep") end),
    },

    endtimeline =
    {
        TimeEvent(13*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
    },
})

CommonStates.AddCombatStates(states,
{
    attacktimeline = 
    {
        
        TimeEvent(8* FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/bite") end),
        TimeEvent(11*FRAMES, function(inst) 
        inst.components.combat:DoAttack()
        inst:PushEvent("wingdown")
        end),
    },

    hittimeline =
    {
        TimeEvent(1*FRAMES, function(inst)  
        inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/hurt")
        end),
        TimeEvent(7*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
    },

    deathtimeline =
    {
        TimeEvent(1*FRAMES, function(inst)  
        inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/death")
        end),
        TimeEvent(4*FRAMES, function(inst) inst:PushEvent("wingdown")  end ),
    },
})

CommonStates.AddFrozenStates(states)


return StateGraph("bat", states, events, "idle", actionhandlers)