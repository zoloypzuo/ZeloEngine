require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"

local SEE_PLAYER_DIST = 5
local SEE_FOOD_DIST = 10
local MAX_WANDER_DIST = 15
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 20
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8


local MermBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

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

local function GoHomeAction(inst)
    if inst.components.homeseeker and 
       inst.components.homeseeker.home and 
       inst.components.homeseeker.home:IsValid() and
       not inst.components.combat.target then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function GetFaceTargetFn(inst)
    return GetClosestInstWithTag("player", inst, SEE_PLAYER_DIST)
end

local function KeepFaceTargetFn(inst, target)
    return inst:GetDistanceSqToInst(target) <= SEE_PLAYER_DIST*SEE_PLAYER_DIST
end

local function ShouldGoHome(inst)
    --one merm should stay outside
    local home = inst.components.homeseeker and inst.components.homeseeker.home
    local shouldStay = home and home.components.childspawner
                      and home.components.childspawner:CountChildrenOutside() <= 1
    return GetClock():IsDay() and not shouldStay
end

function MermBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        WhileNode( function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
            ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST) ),
        WhileNode( function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge",
            RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST) ),
        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
            DoAction(self.inst, GoHomeAction, "Go Home", true )),
        DoAction(self.inst, EatFoodAction, "Eat Food"),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST),
    }, .25)
    
    self.bt = BT(self.inst, root)

end

return MermBrain