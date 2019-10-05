require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chaseandattack"
require "behaviours/leash"

local MIN_FOLLOW_DIST = 5
local TARGET_FOLLOW_DIST = 7
local MAX_FOLLOW_DIST = 10

local RUN_AWAY_DIST = 7
local STOP_RUN_AWAY_DIST = 15

local SEE_FOOD_DIST = 10

local MAX_WANDER_DIST = 20

local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 40

local TIME_BETWEEN_EATING = 30

local LEASH_RETURN_DIST = 15
local LEASH_MAX_DIST = 20

local MonkeyBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function ShouldRunFn(inst, hunter)
    if inst.components.combat.target then
        return hunter == GetPlayer()
    end
end

local function GetPoop(inst)
    local target = nil

    if inst.sg:HasStateTag("busy") then
        return
    end
    target = FindEntity(inst, SEE_FOOD_DIST, function(item)    
    
    if item.prefab ~= "poop" then
        return false
    end
    if not item.components.inventoryitem or (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) then 
        return false
    end
    if not item:IsOnValidGround() then
        return false
    end
    if distsq(inst.components.combat.target:GetPosition(), item:GetPosition()) < RUN_AWAY_DIST * RUN_AWAY_DIST then
        return false
    end
    
    return true
    
    end)

    if target then
        return BufferedAction(inst,target,ACTIONS.PICKUP)
    end

end

local ValidFoodsToPick = 
{
    "berries",
    "cave_banana",
    "carrot",   
    "red_cap",
    "blue_cap",
    "green_cap", 
}

local function ItemIsInList(item, list)
    for k,v in pairs(list) do
        if v == item or k == item then
            return true
        end
    end
end

local function EatFoodAction(inst)

    local target = nil

    if inst.sg:HasStateTag("busy") or 
    (inst.components.eater:TimeSinceLastEating() and inst.components.eater:TimeSinceLastEating() < TIME_BETWEEN_EATING) or
    (inst.components.inventory and inst.components.inventory:IsFull()) or
    math.random() < 0.75 then
        return
    end

    if inst.components.inventory and inst.components.eater then

        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        if target then return BufferedAction(inst,target,ACTIONS.EAT) end
    end

    --Get the stuff around you and store it in ents
    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, SEE_FOOD_DIST)  


    --If you're not wearing a hat, look for a hat to wear!
    if not target then
        for i,item in ipairs(ents) do
            if item.components.equippable and
             item.components.equippable.equipslot == EQUIPSLOTS.HEAD and
             (inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)) and
             (item.components.inventoryitem and not (item.components.inventoryitem:IsHeld() or not item.components.inventoryitem.canbepickedup)) and
			 item:IsOnValidGround() then
                target = item
                break
            end
        end
    end

    if target then
        --Alright, yeah! That's - no that's a pretty good job!
        return BufferedAction(inst,target,ACTIONS.PICKUP)
    end

    --Look for food on the ground, pick it up
    if not target then
        for i,item in ipairs(ents) do
            if item:GetTimeAlive() > 8 and inst.components.eater:CanEat(item) and not (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) and item:IsOnValidGround() then
                target = item
                break
            end
        end
    end

    if target then
        return BufferedAction(inst,target,ACTIONS.PICKUP)
    end

    --Look for harvestable items, pick them.
    if not target then
        for i,item in ipairs(ents) do
            if item.components.pickable and item.components.pickable.caninteractwith and item.components.pickable:CanBePicked()
            and (ItemIsInList(item.components.pickable.product, ValidFoodsToPick) or item.prefab == "worm") then
                target = item
                break
            end
        end
    end

    if target then
        return BufferedAction(inst, target, ACTIONS.PICK)
    end

    --Look for crops items, harvest them.
    if not target then
        for i,item in ipairs(ents) do
            if item.components.crop and item.components.crop:IsReadyForHarvest() then
                target = item
                break
            end
        end
    end

    if target then
        return BufferedAction(inst, target, ACTIONS.HARVEST)
    end

    if not inst.curious or inst.components.combat.target then
        return
    end

    ---At the very end, look for a random item to pick up and do that.
    if not target then

        for i,item in ipairs(ents) do
            if item.components.inventoryitem and item.components.inventoryitem.canbepickedup and not
                item.components.inventoryitem:IsHeld() and item:IsOnValidGround() then
                target = item
                break
            end
        end
    end

    if target then
        inst.curious = false
        inst:DoTaskInTime(10, function() inst.curious = true end)
        return BufferedAction(inst,target,ACTIONS.PICKUP)
    end

end

local function AnnoyLeader(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end
    local player = GetPlayer() -- You will only ever harass the player.
    local p_pt = player:GetPosition()
    local m_pt = inst:GetPosition()
    local ents = TheSim:FindEntities(m_pt.x, m_pt.y, m_pt.z, 30)

    --Can we hassle the player by taking items from stuff he has killed or worked?
    for k,v in pairs(ents) do
        if v.components.inventoryitem and v.components.inventoryitem.canbepickedup and not v.components.inventoryitem:IsHeld() and v:GetTimeAlive() < 5 then
            return BufferedAction(inst, v, ACTIONS.PICKUP)
        end
    end

    --Can we hassle our leader by taking the items he wants?
    local ba = player:GetBufferedAction()
    if ba and ba.action.id == "PICKUP" then
        --The player wants to pick something up. Am I closer than the player?
        local tar = ba.target

        local t_pt = tar:GetPosition()

        if not tar.components.inventoryitem.owner and distsq(p_pt, t_pt) > distsq(m_pt, t_pt) then
            --I'm closer to the item than the player! Lets go get it!
            return BufferedAction(inst, tar, ACTIONS.PICKUP)
        end
    end

    ---Can we hassle our leader by toying with his chests?
    if inst.canlootchests == nil then
        inst.canlootchests = true
    end

    if inst.canlootchests then
        local items = {}
        for k,v in pairs(ents) do
            local cont = v.components.container
            if cont then
                local v_pt = v:GetPosition()
                if distsq(v_pt, p_pt) < 15*15 then
                    for k = 1, cont.numslots do
                        local item = cont.slots[k]
                        if item then
                            table.insert(items, item)
                        end
                    end
                end
            end
        end

        if #items > 0 then
            inst.canlootchests = false
            inst:DoTaskInTime(math.random(15, 30), function() inst.canlootchests = true end)
            local item = items[math.random(1, #items)]
            local act = BufferedAction(inst, item, ACTIONS.STEAL)
            act.validfn = function() return (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) end
            return act
        end
    end
end

local function GetFaceTargetFn(inst)
    return inst.components.combat.target
end

local function KeepFaceTargetFn(inst, target)
    return target == inst.components.combat.target
end

local function GoHome(inst)
    if inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home:IsValid() then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

function MonkeyBrain:OnStart()
    
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

        --Monkeys go home when quakes start.
        EventNode(self.inst, "gohome", 
            DoAction(self.inst, GoHome)),

        --In combat (with the player)... Should only ever use poop throwing.
        RunAway(self.inst, "character", RUN_AWAY_DIST, STOP_RUN_AWAY_DIST, function(hunter) return ShouldRunFn(self.inst, hunter) end),
        WhileNode(function() return self.inst.components.combat.target == GetPlayer() and self.inst.HasAmmo(self.inst) end, "Attack Player", 
            ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),
        --Pick up poop to throw
        WhileNode(function() return self.inst.components.combat.target == GetPlayer() and not self.inst.HasAmmo(self.inst) end, "Pick Up Poop", 
            DoAction(self.inst, GetPoop)),
        --Eat/ pick/ harvest foods.
        WhileNode(function() return self.inst.components.combat.target == GetPlayer() or self.inst.components.combat.target == nil end, "Should Eat",
            DoAction(self.inst, EatFoodAction)),
        --Priority must be lower than poop pick up or it will never happen.
        WhileNode(function() return self.inst.components.combat.target == GetPlayer() and not self.inst.HasAmmo(self.inst) end, "Leash to Player",
        PriorityNode{
            Leash(self.inst, function() if self.inst.components.combat.target then return self.inst.components.combat.target:GetPosition() end end, LEASH_MAX_DIST, LEASH_RETURN_DIST),
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)
        }),


        --In combat with everything else
        WhileNode(function() return self.inst.components.combat.target ~= nil and self.inst.components.combat.target ~= GetPlayer() end, "Attack NPC", --For everything else
            ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),

        
        --Following
        WhileNode(function() return self.inst.harassplayer end, "Annoy Leader", 
            DoAction(self.inst, AnnoyLeader)),
        Follow(self.inst, function() return self.inst.harassplayer and GetPlayer()  end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        
        --Doing nothing
        WhileNode(function() return self.inst.harassplayer  end, "Wander Around Leader", 
            Wander(self.inst, function() if self.inst.harassplayer  then return GetPlayer():GetPosition() end end, MAX_FOLLOW_DIST)),
        WhileNode(function() return not self.inst.harassplayer and not self.inst.components.combat.target end,
        "Wander Around Home", Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST))
    }, .25)
    self.bt = BT(self.inst, root)
end

return MonkeyBrain
