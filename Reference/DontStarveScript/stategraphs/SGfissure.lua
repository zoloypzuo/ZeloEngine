require("stategraphs/commonstates")

local events=
{
    EventHandler("attacked", function(inst) end),
    EventHandler("death", function(inst) end),
}

local states=
{
    State{
        name = "idle_off",
        tags = {"idle"},
        onenter = function(inst)

        end,
        onexit = function(inst)

        end,
    }, 
        State{
        name = "idle_turnoff",
        tags = {"idle"},
        onenter = function(inst)
            inst.sg:SetTimeout(4)
            inst.turnoff(inst)
        end,
        ontimeout = function(inst)
            inst.sg:GoToState("idle_off")
        end,
    },    

    State{
        name = "idle_on",
        tags = {"idle"},
        onenter = function(inst)
        
        end,
        onexit = function(inst)

        end,
    },
        State{
        name = "idle_turnon",
        tags = {"idle"},
        onenter = function(inst)
            inst.sg:SetTimeout(4)
            inst.turnon(inst)
        end,
        ontimeout = function(inst)
            inst.sg:GoToState("idle_on")
        end,
    },    
}
    
return StateGraph("fissure", states, events, "idle")

