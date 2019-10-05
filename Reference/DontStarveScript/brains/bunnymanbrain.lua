require "behaviours/wander"
require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
--require "behaviours/choptree"
require "behaviours/findlight"
require "behaviours/panic"
require "behaviours/chattynode"
require "behaviours/leash"


local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 5
local MAX_FOLLOW_DIST = 9
local MAX_WANDER_DIST = 20

local LEASH_RETURN_DIST = 10
local LEASH_MAX_DIST = 30

local START_FACE_DIST = 6
local KEEP_FACE_DIST = 8
local START_RUN_DIST = 3
local STOP_RUN_DIST = 30
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30
local SEE_LIGHT_DIST = 20
local TRADE_DIST = 20
local SEE_TREE_DIST = 15
local SEE_TARGET_DIST = 20
local SEE_FOOD_DIST = 10

local KEEP_CHOPPING_DIST = 10

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8
local SEE_PLAYER_DIST = 6

local function GetTraderFn(inst)
    return FindEntity(inst, TRADE_DIST, function(target) return inst.components.trader:IsTryingToTradeWithMe(target) end, {"player"})
end

local function KeepTraderFn(inst, target)
    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function FindFoodAction(inst)
    local target = nil

	if inst.sg:HasStateTag("busy") then
		return
	end
    
    if inst.components.inventory and inst.components.eater then
        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
    end
    
    local time_since_eat = inst.components.eater:TimeSinceLastEating()
    local noveggie = time_since_eat and time_since_eat < TUNING.PIG_MIN_POOP_PERIOD*4
    
    if not target and (not time_since_eat or time_since_eat > TUNING.PIG_MIN_POOP_PERIOD*2) then
        target = FindEntity(inst, SEE_FOOD_DIST, function(item) 
				if item:GetTimeAlive() < 8 then return false end
				if item.prefab == "mandrake" then return false end
				if noveggie and item.components.edible and item.components.edible.foodtype ~= "MEAT" then
					return false
				end
				if not item:IsOnValidGround() then
					return false
				end
				return inst.components.eater:CanEat(item) 
			end)
    end
    if target then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end
end


local function HasValidHome(inst)
    return inst.components.homeseeker and 
       inst.components.homeseeker.home and 
       inst.components.homeseeker.home:IsValid()
end

local function GoHomeAction(inst)
    if not inst.components.follower.leader and
        HasValidHome(inst) and
        not inst.components.combat.target then
            return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function GetLeader(inst)
    return inst.components.follower.leader 
end

local function GetHomePos(inst)
    return HasValidHome(inst) and inst.components.homeseeker:GetHomePos()
end


local function GetNoLeaderHomePos(inst)
    if GetLeader(inst) then
        return nil
    end
    return GetHomePos(inst)
end

local BunnymanBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function BunnymanBrain:OnStart()
    --print(self.inst, "PigBrain:OnStart")
    local clock = GetClock()

    local root = 
        PriorityNode(
        {
            
            WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
                Panic(self.inst)),
            WhileNode(function() return self.inst.components.health:GetPercent() < TUNING.BUNNYMAN_PANIC_THRESH end, "LowHealth",
				ChattyNode(self.inst, STRINGS.RABBIT_RETREAT,
					RunAway(self.inst, "scarytoprey", SEE_PLAYER_DIST, STOP_RUN_DIST))),
            ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),
            FaceEntity(self.inst, GetTraderFn, KeepTraderFn),            
            DoAction(self.inst, FindFoodAction ),
            Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
            WhileNode( function() return not self.inst.beardlord and clock and clock:IsDay() end, "IsDay",
                        DoAction(self.inst, GoHomeAction, "go home", true ), 1),
            Leash(self.inst, GetNoLeaderHomePos, LEASH_MAX_DIST, LEASH_RETURN_DIST),
            Wander(self.inst, GetNoLeaderHomePos, MAX_WANDER_DIST)

        }, .5)
    
    self.bt = BT(self.inst, root)
    
end

return BunnymanBrain
