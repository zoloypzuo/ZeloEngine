require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chaseandram"

local START_FACE_DIST = 14
local KEEP_FACE_DIST = 16
local GO_HOME_DIST = 40
local MAX_CHASE_TIME = 5
local MAX_CHARGE_DIST = 25
local CHASE_GIVEUP_DIST = 10
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 15


local MinotaurBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GoHomeAction(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    if homePos and 
       not inst.components.combat.target then
        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, homePos, nil, 0.2)
    end
end

local function GetFaceTargetFn(inst)

    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > 40*40) then
        return
    end

    local target = GetClosestInstWithTag("player", inst, START_FACE_DIST)
    if target and not target:HasTag("notarget") then
        return target
    end
end

local function KeepFaceTargetFn(inst, target)
    
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > 40*40) then
        return false
    end

    return inst:GetDistanceSqToInst(target) <= KEEP_FACE_DIST*KEEP_FACE_DIST and not target:HasTag("notarget")
end

local function ShouldGoHome(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    local dist = homePos and distsq(homePos, myPos)
    if not dist then
        return
    end
    return (dist > GO_HOME_DIST*GO_HOME_DIST) or (dist > 10*10 and inst.components.combat.target == nil)
end

function MinotaurBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.combat.target ~= nil and
        (distsq(self.inst.components.combat.target:GetPosition(), self.inst:GetPosition()) > 6*6 or
        self.inst.sg:HasStateTag("running")) end,
            "RamAttack", ChaseAndRam(self.inst, MAX_CHASE_TIME, CHASE_GIVEUP_DIST, MAX_CHARGE_DIST)),
        WhileNode( function() return self.inst.components.combat.target ~= nil and
        distsq(self.inst.components.combat.target:GetPosition(), self.inst:GetPosition()) < 6*6
        and not self.inst.sg:HasStateTag("running") end,
            "NormalAttack", ChaseAndAttack(self.inst, 3, 5)),
        WhileNode( function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Rest",
            StandStill(self.inst)),
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
            DoAction(self.inst, GoHomeAction, "Go Home", false )),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        StandStill(self.inst)
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return MinotaurBrain
