require "behaviours/standandattack"
require "behaviours/faceentity"

local START_FACE_DIST = 10
local KEEP_FACE_DIST = 15

local EyeTurretBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetFaceTargetFn(inst)
    local target = GetClosestInstWithTag("player", inst, START_FACE_DIST)
    if target and not target:HasTag("notarget") then
        return target
    end
end

local function KeepFaceTargetFn(inst, target)
    return inst:GetDistanceSqToInst(target) <= KEEP_FACE_DIST*KEEP_FACE_DIST and not target:HasTag("notarget")
end

function EyeTurretBrain:OnStart()
    local root = PriorityNode(
    {
        StandAndAttack(self.inst),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),

    }, .25)
    
    self.bt = BT(self.inst, root)
end

return EyeTurretBrain