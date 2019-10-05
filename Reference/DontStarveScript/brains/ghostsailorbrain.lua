require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/leash"
require "behaviours/chattynode"

local MAX_LEASH = 30
local RETURN_LEASH = 20

local MAX_WANDER = 10
local MIN_WANDER = 5

local STOP_FACE_DIST = 5
local START_FACE_DIST = 2

local function GetFaceTargetFn(inst)
    return FindEntity(inst, START_FACE_DIST, function(guy)
        return guy:HasTag("player")
    end)
end

local function KeepFaceTargetFn(inst, target)
    return inst:GetPosition():Dist(target:GetPosition()) < STOP_FACE_DIST
end

local function HasValidHome(inst)
    return inst.components.homeseeker and 
       inst.components.homeseeker.home and 
       inst.components.homeseeker.home:IsValid()
end

local function GetHomePos(inst)
    return HasValidHome(inst) and inst.components.homeseeker:GetHomePos()
end

local GhostSailorBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function GhostSailorBrain:OnStart()
    local root = 
    PriorityNode({
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Leash(self.inst, GetHomePos, MAX_LEASH, RETURN_LEASH),
        ParallelNodeAny{
            WaitNode(10),
            ChattyNode(self.inst, STRINGS.SHIPWRECK_IDLE, 
                Wander(self.inst)),
        }
    }, .25)
    self.bt = BT(self.inst, root)
end

return GhostSailorBrain