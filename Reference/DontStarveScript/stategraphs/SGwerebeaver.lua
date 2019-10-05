require("stategraphs/commonstates")

local actionhandlers = 
{
    
    ActionHandler(ACTIONS.CHOP, "work"),
    ActionHandler(ACTIONS.MINE, "work"),
    ActionHandler(ACTIONS.DIG, "work"),
    ActionHandler(ACTIONS.HAMMER, "work"),
    ActionHandler(ACTIONS.EAT, "eat"),
}


local events=
{
    CommonHandlers.OnLocomote(true,false),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("transform_person", function(inst) inst.sg:GoToState("towoodie") end)
}

local states=
{
    
    State{
        name = "towoodie",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("death")
            inst.sg:SetTimeout(3)
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/death_beaver")
            inst.components.beaverness.doing_transform = true
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:KillSound("beavermusic") end)
        },
        
        ontimeout = function(inst) 
            TheFrontEnd:Fade(false,2)
            inst:DoTaskInTime(2, function() 
                
                GetClock():MakeNextDay()
                
                inst.components.beaverness.makeperson(inst)
                inst.components.sanity:SetPercent(.25)
                inst.components.health:SetPercent(.33)
                inst.components.hunger:SetPercent(.25)
                inst.components.beaverness.doing_transform = false
                inst.sg:GoToState("wakeup")
                TheFrontEnd:Fade(true,1)
            end)
        end
    },

    State{
        name = "transform_pst",
        tags = {"busy"},
        onenter = function(inst)
			inst.components.playercontroller:Enable(false)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("transform_pst")
            inst.components.health:SetInvincible(true)
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.components.playercontroller:Enable(true)
        end,
        
        events=
        {
            EventHandler("animover", function(inst) TheCamera:SetDistance(30) inst.sg:GoToState("idle") end ),
        },        
    },    

    State{
        name = "work",
        tags = {"busy", "working"},
        
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("atk")
            inst.sg.statemem.action = inst:GetBufferedAction()
        end,
        
        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh") end),
            TimeEvent(6*FRAMES, function(inst) inst:PerformBufferedAction() end),
            TimeEvent(7*FRAMES, function(inst) inst.sg:RemoveStateTag("working") inst.sg:RemoveStateTag("busy") inst.sg:AddStateTag("idle") end),
            TimeEvent(8*FRAMES, function(inst)
                if (TheInput:IsMouseDown(MOUSEBUTTON_LEFT) or
                   TheInput:IsKeyDown(KEY_SPACE)) and 
                    inst.sg.statemem.action and 
                    inst.sg.statemem.action:IsValid() and 
                    inst.sg.statemem.action.target and 
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and 
                    inst.sg.statemem.action.target.components.workable then
                        inst:ClearBufferedAction()
                        inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),            
        },
    },

    State{
        name = "eat",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("eat")
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/eat_beaver") 
        end,
        
        timeline=
        {
            TimeEvent(9*FRAMES, function(inst) inst:PerformBufferedAction()  end),
            TimeEvent(12*FRAMES, function(inst) inst.sg:RemoveStateTag("busy") inst.sg:AddStateTag("idle") end),
        },        
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },
}

CommonStates.AddCombatStates(states,
{
    hittimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/hurt_beaver") end),
    },
    
    attacktimeline = 
    {
    
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh") end),
        TimeEvent(6*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        TimeEvent(8*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") inst.sg:RemoveStateTag("busy") inst.sg:AddStateTag("idle") end),
    },

    deathtimeline=
    {
    },
})

CommonStates.AddRunStates(states,
{
	runtimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(10*FRAMES, PlayFootstep ),
	},
})

CommonStates.AddIdle(states)
    
return StateGraph("werebeaver", states, events, "idle", actionhandlers)

