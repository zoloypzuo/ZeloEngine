require("stategraphs/commonstates")


local function startaura(inst)
    inst.Light:SetColour(255/255, 32/255, 32/255)
    if inst:HasTag("girl") then
        inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_girl_attack_LP", "angry")
    else
        inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_attack_LP", "angry")
    end

    inst.AnimState:SetMultColour(207/255,92/255,92/255,1)

end

local function stopaura(inst)
    inst.Light:SetColour(180/255, 195/255, 225/255)
    inst.SoundEmitter:KillSound("angry")
    inst.AnimState:SetMultColour(1,1,1,1)
end


local events=
{
    CommonHandlers.OnLocomote(true, true),
    EventHandler("startaura",  function(inst) startaura(inst) end),
    EventHandler("stopaura", function(inst) stopaura(inst) end),
    EventHandler("attacked", function(inst) if inst.components.health:GetPercent() > 0 then inst.sg:GoToState("hit") end end),
	EventHandler("death", function(inst) inst.sg:GoToState("dissipate") end),
}

local function getidleanim(inst)
    if inst.components.combat.target or inst.components.aura.applying then
        return "angry"
    elseif inst.components.health:GetPercent() < .25 then
        return "shy"
    else
        return "idle"
    end

end

local states=
{
    State
    {
        name = "idle",
        tags = {"idle", "canrotate", "canslide"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation(getidleanim(inst), true)
        end,
    },
    
    State
    {
        name = "appear",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("appear")
            if inst:HasTag("girl") then
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_girl_howl")
            else
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl")
            end
        end,
        
        events=
        {
            EventHandler("animover", function(inst, data) inst.components.aura:Enable(true) inst.sg:GoToState("idle") end)
        },
        
    },    
    
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            if inst:HasTag("girl") then
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_girl_howl")
            else
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl")
            end
                
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State
    {
        name = "dissipate",
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            if inst:HasTag("girl") then
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_girl_howl")
            else
                inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl")
            end
            
        end,
        
        events=
        {
            EventHandler("animover", function(inst, data) 
                if inst.components.lootdropper then
                    inst.components.lootdropper:DropLoot()
                end
                inst:Remove() end)
        },
    },
   
}


CommonStates.AddSimpleWalkStates(states, getidleanim)
CommonStates.AddSimpleRunStates(states, getidleanim)
    
return StateGraph("ghost", states, events, "appear")