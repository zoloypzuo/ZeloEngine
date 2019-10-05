require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"

local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5
local SEE_FOOD_DIST = 20
local SEE_BUSH_DIST = 40
local MAX_WANDER_DIST = 80


local PerdBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function FindNearestBush(inst)
    local bush = FindEntity(inst, SEE_BUSH_DIST, function(bush) return bush.components.pickable and bush.components.pickable:CanBePicked() end, {"bush"})
    return bush or (inst.components.homeseeker and inst.components.homeseeker.home)
end

local function HomePos(inst)
    local bush = FindNearestBush(inst)
    if bush then
        return Vector3(bush.Transform:GetWorldPosition() )
    end
end

local function GoHomeAction(inst)
    local bush = FindNearestBush(inst)
    if bush then
        return BufferedAction(inst, bush, ACTIONS.GOHOME, nil, Vector3(bush.Transform:GetWorldPosition() ) )
    end
end

local function EatFoodAction(inst)
    local target = nil
    if inst.components.inventory and inst.components.eater then
        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
    end
    if not target then
        target = FindEntity(inst, SEE_FOOD_DIST, function(item) return inst.components.eater:CanEat(item) end)
        if target then
            --check for scary things near the food
            local predator = GetClosestInstWithTag("scarytoprey", target, SEE_PLAYER_DIST)
            if predator then target = nil end
        end
    end
    if target then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem.owner and target.components.inventoryitem.owner ~= inst) end
        return act
    end
end

local function PickBerriesAction(inst)
    local target = FindEntity(inst, SEE_FOOD_DIST, function(item)
        return item.components.pickable
               and item.components.pickable:CanBePicked()
               and item.components.pickable.product == "berries"
    end)
    if target then
        --check for scary things near the bush
        local predator = GetClosestInstWithTag("scarytoprey", target, SEE_PLAYER_DIST)
        if predator then target = nil end
    end
    if target then
        return BufferedAction(inst, target, ACTIONS.PICK)
    end
end


function PerdBrain:OnStart()
    local clock = GetClock()
    
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        WhileNode(function() return clock and not clock:IsDay() end, "IsNight",
            DoAction(self.inst, GoHomeAction, "Go Home", true )),
        DoAction(self.inst, EatFoodAction, "Eat Food"),
        RunAway(self.inst, "scarytoprey", SEE_PLAYER_DIST, STOP_RUN_DIST),
        DoAction(self.inst, PickBerriesAction, "Pick Berries", true),
        Wander(self.inst, HomePos, MAX_WANDER_DIST),
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return PerdBrain