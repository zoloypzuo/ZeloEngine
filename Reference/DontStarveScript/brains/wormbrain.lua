require "behaviours/standstill"
require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/leash"

local WormBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function LayInWait(inst)
    if not inst.sg:HasStateTag("idle") then
        --Only transition into this state from the idle state.
        return
    end

    inst:PushEvent("dolure")
end

local function GoHomeAction(inst)
    if GetTime() - inst.lastluretime < TUNING.WORM_LURE_COOLDOWN then
        return
    end

    local homePos = inst.components.knownlocations:GetLocation("home")

    if homePos and not inst.components.combat.target then
        local ba = BufferedAction(inst, nil, ACTIONS.WALKTO, nil, homePos, nil, 5) 
        ba:AddSuccessAction(function() inst:PushEvent("dolure") end)
        return ba
    end
end

local function EatFoodAction(inst)
    local target = nil
    if inst.sg:HasStateTag("busy") or 
    (inst.components.eater:TimeSinceLastEating() and inst.components.eater:TimeSinceLastEating() < TUNING.WORM_EATING_COOLDOWN)  then
        return
    end
    
    if inst.components.inventory and inst.components.eater then
        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        if target then return BufferedAction(inst,target,ACTIONS.EAT) end
    end
    if inst.components.inventory and inst.components.inventory:IsFull() then
        return
    end
    --Get the stuff around you and store it in ents
    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.WORM_FOOD_DIST)  

    --Look for food on the ground, pick it up
    if not target then
        for k,item in pairs(ents) do
            if item:GetTimeAlive() > 8 and item:IsOnValidGround() and inst.components.eater:CanEat(item) and not (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) then
                target = item
                break
            end
        end
    end
    if target then
        return BufferedAction(inst,target,ACTIONS.PICKUP)
    end

    if not target then
        for k,item in pairs(ents) do
            if item.components.pickable and item.components.pickable.caninteractwith and item.components.pickable:CanBePicked()
            and not item.prefab == inst.prefab then
                target = item
                break
            end
        end
    end
    if target then
        return BufferedAction(inst, target, ACTIONS.PICK)
    end

    if not target then
        for k,item in pairs(ents) do
            if item.components.crop and item.components.crop:IsReadyForHarvest() then
                target = item
                break
            end
        end
    end
    if target then
        return BufferedAction(inst, target, ACTIONS.HARVEST)
    end
end

function WormBrain:OnStart()
    local root = PriorityNode(
    { 
        --Don't do anything while you're in the lure state. You're basically a plant at this point.
        WhileNode(function() return self.inst.sg:HasStateTag("lure") end, "Lure", StandStill(self.inst)),

        WhileNode(function() return self.inst.components.knownlocations:GetLocation("home") ~= nil end, "Has Home", 
            --Worm has found hunting grounds at this point. 
            PriorityNode{

                Leash(self.inst, self.inst.components.knownlocations:GetLocation("home"), TUNING.WORM_CHASE_DIST, TUNING.WORM_CHASE_DIST - 15), -- Don't go too far from your hunting grounds.
                ChaseAndAttack(self.inst, TUNING.WORM_CHASE_TIME, TUNING.WORM_CHASE_DIST),
                DoAction(self.inst, GoHomeAction), --Go home and set up your lure if conditions are met.
                DoAction(self.inst, EatFoodAction), --Eat food if conditions are met.
                Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, TUNING.WORM_WANDER_DIST),  
                StandStill(self.inst),

            }),

        ChaseAndAttack(self.inst, TUNING.WORM_CHASE_TIME, TUNING.WORM_CHASE_DIST),
        Wander(self.inst, function() return self.inst:GetPosition() end, TUNING.WORM_WANDER_DIST),        
        StandStill(self.inst),

    }, .25)
    
    self.bt = BT(self.inst, root)
end

return WormBrain