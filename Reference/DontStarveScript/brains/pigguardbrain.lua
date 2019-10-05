require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chattynode"

local START_FACE_DIST = 6
local KEEP_FACE_DIST = 8
local GO_HOME_DIST = 10
local MAX_WANDER_DIST = 8
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 20
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8


local function GoHomeAction(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    if homePos and 
       not inst.components.combat.target then
        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, homePos)
    end
end

local function AddFuelAction(inst)
    local home = inst.components.homeseeker and inst.components.homeseeker.home
    if home and home.components.fueled:GetCurrentSection() <= 1 then-- home.components.fueled.sections then
        local fuel = inst.components.inventory:FindItem(function(item) return item.prefab == "pigtorch_fuel" end)
        if not fuel then
            fuel = SpawnPrefab("pigtorch_fuel")
            inst.components.inventory:GiveItem(fuel)
        end
        if fuel then
            return BufferedAction(inst, home, ACTIONS.ADDFUEL, fuel)
        end
    end
end

local function FindFoodAction(inst)
    if inst.components.inventory and inst.components.eater then
        local target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        if target then
            return BufferedAction(inst, target, ACTIONS.EAT)
        end
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
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    return (homePos and distsq(homePos, myPos) > GO_HOME_DIST*GO_HOME_DIST)
end


local PigGuardBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function PigGuardBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        ChattyNode(self.inst, STRINGS.PIG_GUARD_TALK_FIGHT,
            WhileNode( function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
                ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST) ) ),       
        ChattyNode(self.inst, STRINGS.PIG_GUARD_TALK_FIGHT,
            WhileNode( function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge",
                RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST) ) ),
        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
            ChattyNode(self.inst, STRINGS.PIG_GUARD_TALK_GOHOME,
               DoAction(self.inst, GoHomeAction, "Go Home", true ) ) ),
        ChattyNode(self.inst, STRINGS.PIG_TALK_FIND_MEAT,
            DoAction(self.inst, function() return FindFoodAction(self.inst) end )),
        ChattyNode(self.inst, STRINGS.PIG_GUARD_TALK_TORCH,
               DoAction(self.inst, AddFuelAction, "Add Fuel", true ) ),
        ChattyNode(self.inst, STRINGS.PIG_GUARD_TALK_LOOKATWILSON,
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn) ),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)
    }, .25)
    
    self.bt = BT(self.inst, root)
    
end

return PigGuardBrain