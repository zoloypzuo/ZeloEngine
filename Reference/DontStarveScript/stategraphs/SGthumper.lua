require("stategraphs/commonstates")

local actionhandlers = {}

local events = {}

local states =
{

    State
    {
        name = "idle",
        tags = {"idle"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        }
    },

    State
    {
        name = "raise",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/thumper/reset")
            inst.AnimState:PlayAnimation("reset")
        end,

        timeline = {    
            TimeEvent(2 * FRAMES, function(inst)                
                inst.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/thumper/steam")
            end),
            TimeEvent(6 * FRAMES, function(inst)                
                inst.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/thumper/steam")
            end),
            TimeEvent(17 * FRAMES, function(inst)                
                inst.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/thumper/steam")
            end),
            TimeEvent(28 * FRAMES, function(inst)                
                inst.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/thumper/steam")
            end),
            TimeEvent(34 * FRAMES, function(inst)                
                inst.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/thumper/steam")
            end),
            TimeEvent(51 * FRAMES, function(inst)    
                inst.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/thumper/hit")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("smash") end),
        }
    },

    State
    {
        name = "smash",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("smash")
        end,

        onexit = function(inst)
            inst.components.machine:TurnOff()
        end,

        timeline = {    
            TimeEvent(7 * FRAMES, function(inst)                
                inst.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/thumper/thump")
                inst.components.groundpounder:GroundPound()
                GetPlayer().components.playercontroller:ShakeCamera(inst, "FULL", 0.7, 0.02, 2, 40)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        }
    },

    State
    {
        name = "hit_low",
        tags = {"idle"},

        onenter = function(inst)
            --Stop some loop sound            
            inst.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/thumper/hit")
            inst.AnimState:PlayAnimation("hit_low")
        end,
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        }        
    },

    State
    {  
        name = "place",
        tags = {"busy"},

        onenter = function(inst, data)
            inst.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/thumper/place")
            inst.AnimState:PlayAnimation("deploy")
            -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/sprinkler/place")
            --Play some sound / good idea
        end,

        timeline = {},

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State
    {  
        name = "hit",
        tags = {"busy"},

        onenter = function(inst, data)
            if inst.on then 
                inst.AnimState:PlayAnimation("hit_on")
            else
                inst.AnimState:PlayAnimation("hit_off")
            end
            --Play some sound 
        end,

        timeline = {},

        events =
        {
            EventHandler("animover", function(inst) 
               inst.sg:GoToState("idle")
            end)
        },
    },
}

return StateGraph("thumper", states, events, "idle", actionhandlers)