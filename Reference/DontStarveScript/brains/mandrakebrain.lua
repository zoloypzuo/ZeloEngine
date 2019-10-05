require "behaviours/follow"


local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 3
local MAX_FOLLOW_DIST = 8


local function GetFaceTargetFn(inst)
    return inst.components.follower and inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower and inst.components.follower.leader == target
end

local MandrakeBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function MandrakeBrain:OnStart()
    local root = 
    PriorityNode({
		Follow(self.inst, function() return self.inst.components.follower and self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
		FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
		},.25)
    self.bt = BT(self.inst, root)
end

return MandrakeBrain