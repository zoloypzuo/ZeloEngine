require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/useshield"

local RockyBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

local START_FACE_DIST = 4
local KEEP_FACE_DIST = 6
local MAX_CHASE_TIME = 20
local MAX_CHASE_DIST = 16
local WANDER_DIST = 16

local MIN_FOLLOW_DIST = 4
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST = 10

local DAMAGE_UNTIL_SHIELD = 200
local AVOID_PROJECTILE_ATTACKS = true
local SHIELD_TIME = 5


local function GetFaceTargetFn(inst)
    local target = GetClosestInstWithTag("player", inst, START_FACE_DIST)
    if target and not target:HasTag("notarget") then
        return target
    end
end

local function KeepFaceTargetFn(inst, target)
    return inst:GetDistanceSqToInst(target) <= KEEP_FACE_DIST*KEEP_FACE_DIST and not target:HasTag("notarget")
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
        target = FindEntity(inst, 15, function(item)
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


function RockyBrain:OnStart()
	local root = PriorityNode(
	{
        UseShield(self.inst, DAMAGE_UNTIL_SHIELD, SHIELD_TIME, AVOID_PROJECTILE_ATTACKS),
		ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),
        DoAction(self.inst, EatFoodAction),
        Follow(self.inst, function(inst) return inst.components.follower.leader end , MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
		Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("herd") end, WANDER_DIST)        
	} ,0.25)

	self.bt = BT(self.inst, root)

end

return RockyBrain