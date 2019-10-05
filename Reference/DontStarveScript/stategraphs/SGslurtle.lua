require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.PICKUP, "eat_pre"),
    ActionHandler(ACTIONS.EAT, "eat_loop"),
    ActionHandler(ACTIONS.STEAL, "steal"),
    ActionHandler(ACTIONS.GOHOME, "action"),
}

local events=
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("entershield", function(inst) inst.sg:GoToState("shield") end),
    EventHandler("exitshield", function(inst) inst.sg:GoToState("shield_end") end),
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
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,
        
        timeline = 
        {
		    TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/idle") end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "taunt",
       
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,
        
        timeline = 
        {
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/taunt") end ),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/taunt") end ),
            TimeEvent(33*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/taunt") end ),
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
            inst.AnimState:PlayAnimation("idle", true)
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
    	name = "shield",
    	tags = {"busy","hiding"},

    	onenter = function(inst)
            --If taking fire damage, spawn fire effect. 

    		inst.components.health:SetAbsorbAmount(TUNING.SLURTLE_SHELL_ABSORB)
    		inst.Physics:Stop()
    		inst.AnimState:PlayAnimation("hide")
    		inst.AnimState:PushAnimation("hide_loop")
            inst:AddTag("shell")
    	end,

        onexit = function(inst)
            inst:RemoveTag("shell")
            inst.components.health:SetAbsorbAmount(0)
        end,

        timeline = 
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/hide") end ),
        },
	},

    State{
        name = "shield_end",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("emerge")
        end,

        timeline = 
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/emerge") end ),
        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "eat_pre",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat_pre", false)
        end,

        timeline = 
        {
            TimeEvent(11*FRAMES, function(inst) 
            inst:PerformBufferedAction()
            inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/bite") end ), --take food
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
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat_loop", true)
            inst.sg:SetTimeout(2+math.random()*3)
        end,

        timeline = 
        {
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/eat") end ),
            TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/eat") end ),
        },

        events = 
        {
            EventHandler("attacked", function(inst) inst.components.inventory:DropItem(inst:GetBufferedAction().target) inst.sg:GoToState("idle") end) --drop food
        },
        
        ontimeout= function(inst)
            inst.lastmeal = GetTime()
            inst:PerformBufferedAction()
            inst.sg:GoToState("idle", "eat_pst")
        end,
    }, 

    State{
        name = "steal", --aquire food aggressively
        tags = {"attack", "busy"},
        onenter = function(inst, target)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("atk")
        end,
         events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
        timeline =
        {
            TimeEvent(11*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },

    },
}

CommonStates.AddWalkStates(states,
{
    starttimeline = 
    {
	    TimeEvent(0*FRAMES, function(inst) inst.Physics:Stop() end ),
    },
	walktimeline = {
		    TimeEvent(0*FRAMES, function(inst)
		    inst.Physics:Stop()             
            if math.random() <= 0.33 then inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/idle") end
            inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/slide_out")
            end ),

            TimeEvent(13*FRAMES, function(inst)               
                inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/slide_in")
                inst.components.locomotor:WalkForward()
            end ),
            TimeEvent(21*FRAMES, function(inst)               
                inst.Physics:Stop()
            end ),
	},
}, nil, true)


local function hitanim(inst)
	local statename = inst.sg.currentstate.name
	if statename == "shield" then
		return "hit_shield"
	else
		return "hit_out"
	end
end

local combatanims =
{
	hit = hitanim,
}

CommonStates.AddCombatStates(states,
{
    attacktimeline = 
    {
       TimeEvent(10*FRAMES, function(inst) inst.components.combat:DoAttack()
        inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/bite")
        end),
    },
    deathtimeline =
    {
        TimeEvent(1*FRAMES, function(inst)  
        inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/death")
        end),
    },
}, combatanims)

CommonStates.AddFrozenStates(states)


return StateGraph("slurtle", states, events, "idle", actionhandlers)
