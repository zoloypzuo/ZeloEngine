require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/follow"

local START_FACE_DIST = 6
local KEEP_FACE_DIST = 8
local GO_HOME_DIST = 1
local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 40
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8


local BishopBrain = Class(Brain, function(self, inst)
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
    local target = GetClosestInstWithTag("player", inst, START_FACE_DIST)
    if target and not target:HasTag("notarget") then
        return target
    end
end

local function KeepFaceTargetFn(inst, target)
    return inst:GetDistanceSqToInst(target) <= KEEP_FACE_DIST*KEEP_FACE_DIST and not target:HasTag("notarget")
end

local function ShouldGoHome(inst)

    if (inst.components.follower and inst.components.follower.leader) then
        return false
    end

    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    return (homePos and distsq(homePos, myPos) > GO_HOME_DIST*GO_HOME_DIST)
end

function BishopBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),
        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
            DoAction(self.inst, GoHomeAction, "Go Home", true )),
        Follow(self.inst, function() return self.inst.components.follower and self.inst.components.follower.leader end, 
             5, 7, 12),

        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        StandStill(self.inst),
    }, .25)
    
    self.bt = BT(self.inst, root)

end

return BishopBrain