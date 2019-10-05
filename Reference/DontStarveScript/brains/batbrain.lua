require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/wander"
require "behaviours/chaseandattack"

local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 40

local BatBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

local function GoHomeAction(inst)
    if inst.components.homeseeker and 
       inst.components.homeseeker.home and 
       inst.components.homeseeker.home:IsValid() and 
       inst.components.homeseeker.home.components.childspawner and not 
       inst.components.teamattacker.inteam then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function EatFoodAction(inst)

    local target = nil

    if inst.sg:HasStateTag("busy") then
        return
    end

    if inst.components.inventory and inst.components.eater then
        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        if target then return BufferedAction(inst,target,ACTIONS.EAT) end
    end

    if not target then
        target = FindEntity(inst, 30, function(item)
            if item:GetTimeAlive() < 8 then return false end
            if not item:IsOnValidGround() then
                return false
            end
            return inst.components.eater:CanEat(item)

            end)
    end

    if target then
        return BufferedAction(inst,target,ACTIONS.PICKUP)
    end

    -- local target = FindEntity(inst, 30, function(item) return inst.components.eater:CanEat(item) and not (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) end)
    -- if target then
    --     local act = BufferedAction(inst, target, ACTIONS.EAT)
    --     act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld()) end
    --     return act
    -- end
end

function BatBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage and not self.inst.components.teamattacker.inteam end, "OnFire", Panic(self.inst)),
        AttackWall(self.inst),
        ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),
        WhileNode(function() return GetClock():IsDay() end, "IsDay",
            DoAction(self.inst, function() return GoHomeAction(self.inst) end ) ), 
        WhileNode(function() return self.inst.components.teamattacker.teamleader == nil end, "No Leader Eat Action",
            DoAction(self.inst, EatFoodAction)),
        WhileNode(function() return self.inst.components.teamattacker.teamleader == nil end, "No Leader Wander Action", 
            Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, 40)),


    }, .25)
    
    self.bt = BT(self.inst, root)
end

return BatBrain