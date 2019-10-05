require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/follow"
require "behaviours/attackwall"

local ShadowWaxwellBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

--Images will help chop, mine and fight.

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 4
local MAX_FOLLOW_DIST = 6

local START_FACE_DIST = 6
local KEEP_FACE_DIST = 8

local KEEP_WORKING_DIST = 10
local SEE_WORK_DIST = 15

local function HasStateTags(inst, tags)
    for k,v in pairs(tags) do
        if inst.sg:HasStateTag(v) then
            return true
        end
    end
end

local function KeepWorkingAction(inst, actiontags)
    return inst.components.follower.leader and inst.components.follower.leader:GetDistanceSqToInst(inst) <= KEEP_WORKING_DIST*KEEP_WORKING_DIST and 
    HasStateTags(inst.components.follower.leader, actiontags)
end

local function StartWorkingCondition(inst, actiontags)
    return inst.components.follower.leader and HasStateTags(inst.components.follower.leader, actiontags) and not HasStateTags(inst, actiontags)
end

local function FindObjectToWorkAction(inst, action)
    if inst.sg:HasStateTag("working") then
        return 
    end
    local target = FindEntity(inst.components.follower.leader, SEE_WORK_DIST, function(item) return item.components.workable and item.components.workable.action == action end)
    if target then
        --print(GetTime(), target)
        return BufferedAction(inst, target, action)
    end
end

local function GetLeader(inst)
    return inst.components.follower.leader 
end

local function GetFaceTargetFn(inst)
    local target = GetClosestInstWithTag("player", inst, START_FACE_DIST)
    if target and not target:HasTag("notarget") then
        return target
    end
end

local function KeepFaceTargetFn(inst, target)
    return inst:IsNear(target, KEEP_FACE_DIST) and not target:HasTag("notarget")
end

function ShadowWaxwellBrain:OnStart()
    local root = PriorityNode(
    {
        ChaseAndAttack(self.inst, 5),
                  
        WhileNode(function() return StartWorkingCondition(self.inst, {"chopping", "prechop"}) and 
        KeepWorkingAction(self.inst, {"chopping", "prechop"}) end, "keep chopping",
            DoAction(self.inst, function() return FindObjectToWorkAction(self.inst, ACTIONS.CHOP) end)),

        WhileNode(function() return StartWorkingCondition(self.inst, {"mining", "premine"}) and 
        KeepWorkingAction(self.inst, {"mining", "premine"}) end, "keep mining",                   
            DoAction(self.inst, function() return FindObjectToWorkAction(self.inst, ACTIONS.MINE) end)),

        Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        IfNode(function() return GetLeader(self.inst) end, "has leader",            
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn )),

    }, .25)
    
    self.bt = BT(self.inst, root)    
end

return ShadowWaxwellBrain