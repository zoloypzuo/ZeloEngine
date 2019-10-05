require("stategraphs/commonstates")

local events=
{
    EventHandler("death", function(inst)
        if inst.sg:HasStateTag("vine") then
            inst.sg:GoToState("deathvine")
        else
            inst.sg:GoToState("death")
        end
    end),

    EventHandler("attacked", function(inst, data) 
        if not inst.components.health:IsDead() then  
            if inst.sg:HasStateTag("hiding") then
                if inst.sg:HasStateTag("vine") then
                    inst.sg:GoToState("hitin")
                else
                    inst.sg:GoToState("hithibernate")
                end
            else
                inst.sg:GoToState("hitout")
            end
        end 
    end),
}

local states=
{
     State
     {
        
        name = "idleout",
        tags = {"idle"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle_out", true)
            else
                inst.AnimState:PlayAnimation("idle_out", true)
            end
        end,

        
        events=
        {
            EventHandler("animover", function(inst)
            if math.random() > 0.1 then
            	inst.sg:GoToState("idleout")
        	else
        		inst.sg:GoToState("taunt")
        	end 
        	end),
        },
    },

    State
    {

    	name = "idlein",
    	tags = {"idle", "hiding", "vine"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle", true)
        end,
    },

    State
    {

        name = "emerge",
        tags = {"idle", "hiding"},
        onenter = function(inst, playanim)
            inst.AnimState:PlayAnimation("idle_trans")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/vine_emerge") 
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idlein") end),
        },
    },

    State
    {
        name = "hibernate",
        tags = {"idle", "hiding"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle_hidden", true)
            else
                inst.AnimState:PlayAnimation("idle_hidden", true)
            end
        end,
    },


    State
    {
    	name = "taunt",
    	tags = {"idle"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt", true)

            inst.sg:SetTimeout(math.random()*4+2)    
        end,
        
        ontimeout= function(inst)
            inst.sg:GoToState("idleout")
        end,
	},

	State
	{
		name = "hidebait",
		tags = {"busy", "hiding"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()          
            inst.AnimState:PlayAnimation("hide")            
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/lure_close") end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idlein") end),
        },
	},

	State
	{
		name = "showbait",
		tags = {"busy"},
        onenter = function(inst, playanim)
        	
        	if inst.lure then     
	        	inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", inst.lure.prefab)
	            inst.Physics:Stop()          
	            inst.AnimState:PlayAnimation("emerge")            
	        else
	        	inst.sg:GoToState("idlein")
	        end
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/lure_open") end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("taunt") end),
        },

	},

    State{
        name = "hitin",
        tags = {"busy", "hit", "hiding"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idlein") end),
        },        
    },  


    State{
        name = "hithibernate",
        tags = {"busy", "hit", "hiding"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit_hidden")            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("hibernate") end),
        },        
    },  

    State{
        name = "hitout",
        tags = {"busy", "hit"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit_out")            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst:PushEvent("hidebait") end),
        }, 
    },

    State
    {
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("death_hidden")
            RemovePhysicsColliders(inst)   
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/lure_die")                           
        end,        
    },

    State
    {
        name = "deathvine",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            RemovePhysicsColliders(inst)   
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/lure_die")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/vine_retract")  
                                    
        end,        
    },


    State{

        name = "picked",
        tags = {"busy", "hiding"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("pick")    
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/lure_close")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/vine_retract")  
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("hibernate") end),
        },
	},

    State{

        name = "spawn",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("grow")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst:PushEvent("freshspawn") inst.sg:GoToState("hibernate") end),
        },
    },

}
    
return StateGraph("lureplant", states, events, "idlein")