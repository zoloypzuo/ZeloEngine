require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/useshield"
require "behaviours/wander"
require "behaviours/chaseandattack"

local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 40
local DAMAGE_UNTIL_SHIELD = TUNING.SLURTLE_DAMAGE_UNTIL_SHIELD
local AVOID_PROJECTILE_ATTACKS = true
local SHIELD_TIME = 2
local SEE_FOOD_DIST = 13
local HUNGER_TOLERANCE = 70

local SlurtleBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

local function GoHomeAction(inst)
    if inst.components.homeseeker then
        inst.components.homeseeker:GoHome()
    end
end

local function ShouldGoHome(inst)
    return GetTime() - inst.lastmeal > HUNGER_TOLERANCE
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
        local ba = BufferedAction(inst,target,ACTIONS.PICKUP)
        ba.distance = 1.5
        return ba
    end
end

local function StealFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, SEE_FOOD_DIST)

    for k,v in pairs(ents) do
        if inst:GetDistanceSqToInst(v) < SEE_FOOD_DIST * SEE_FOOD_DIST then
            --go through player inv and find valid food
            local inv = v.components.inventory
            if inv then
                local pack = inv:GetEquippedItem(EQUIPSLOTS.BODY)
                local validfood = {}
                if pack and pack.components.container then
                    for k = 1, pack.components.container.numslots do
                        local item = pack.components.container.slots[k]
                        if item and item.components.edible and inst.components.eater:CanEat(item) then
                            table.insert(validfood, item)
                        end
                    end
                end

                for k = 1, inv.maxslots do
                    local item = inv.itemslots[k]
                    if item and item.components.edible and inst.components.eater:CanEat(item) then
                        table.insert(validfood, item)
                    end
                end

                if #validfood > 0 then
                    local itemtosteal = validfood[math.random(1, #validfood)]
                    if itemtosteal and 
                    itemtosteal.components.inventoryitem and
                    itemtosteal.components.inventoryitem.owner and not
                    itemtosteal.components.inventoryitem.owner:HasTag("slurtle") then
                        local act = BufferedAction(inst, itemtosteal, ACTIONS.STEAL)
                        act.validfn = function() return (itemtosteal.components.inventoryitem and itemtosteal.components.inventoryitem:IsHeld()) end
                        act.attack = true
                        return act
                    end
                end
            end

            local container = v.components.container
            if container then
                local validfood = {}
                for k = 1, container.numslots do
                    local item = container.slots[k]
                    if item and item.components.edible and inst.components.eater:CanEat(item) then
                        table.insert(validfood, item)
                    end
                end                

                if #validfood > 0 then
                    local itemtosteal = validfood[math.random(1, #validfood)]
                    local act = BufferedAction(inst, itemtosteal, ACTIONS.STEAL)
                    act.validfn = function() return (itemtosteal.components.inventoryitem and itemtosteal.components.inventoryitem:IsHeld()) end
                    act.attack = true
                    return act
                end

            end
        end 
    end   
end

function SlurtleBrain:OnStart()
    local root = PriorityNode(
    {
        UseShield(self.inst, DAMAGE_UNTIL_SHIELD, SHIELD_TIME, AVOID_PROJECTILE_ATTACKS),
        ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),
        DoAction(self.inst, EatFoodAction),
        DoAction(self.inst, StealFoodAction),
        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
        DoAction(self.inst, GoHomeAction, "Go Home", true )),   
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, 40),
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return SlurtleBrain