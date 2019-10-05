require "behaviours/chaseandattack"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/panic"

local MAX_CHASE_TIME = 20
local MAX_WANDER_DIST = 16
local MAX_CHASEAWAY_DIST = 32
local START_FACE_DIST = 6
local KEEP_FACE_DIST = 8
local WARN_BEFORE_ATTACK_TIME = 2


local function GoHomeAction(inst)
    if inst.components.homeseeker and 
       inst.components.homeseeker:HasHome() then 
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME, nil, nil, nil, 0.2)
    end
end

local function DefendHomeAction(inst)
    if inst.components.homeseeker and 
       inst.components.homeseeker:HasHome() then 
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.WALKTO, nil, nil, nil, 0.2)
    end
end

local function LayEggAction(inst)
    if inst.components.homeseeker and 
       inst.components.homeseeker:HasHome() and
	   inst.components.homeseeker.home.readytolay then 
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.LAYEGG, nil, nil, nil, 0.2)
    end
end

local function IsNestEmpty(inst)
    return inst.components.homeseeker and 
		inst.components.homeseeker:HasHome() and 
		(not inst.components.homeseeker.home.components.pickable or not inst.components.homeseeker.home.components.pickable:CanBePicked() )
end

local function GetNearbyThreatFn(inst)
    return FindEntity(inst, START_FACE_DIST, nil, nil, {'tallbird', 'notarget'}, {'character', 'animal'})
end

local function KeepFaceTargetFn(inst, target)
    return target.components.health and
        not target.components.health:IsDead() and
        inst:GetDistanceSqToInst(target) <= KEEP_FACE_DIST*KEEP_FACE_DIST
end

local TallbirdBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function TallbirdBrain:OnStart()

    local clock = GetClock()
    
    local root =
        PriorityNode(
        {
            WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
			ChaseAndAttack(self.inst, MAX_CHASE_TIME),
			WhileNode(function() return self.inst.components.homeseeker and self.inst.components.homeseeker:HasHome() and GetNearbyThreatFn(self.inst.components.homeseeker.home) end, "ThreatNearNest",
				DoAction(self.inst, function() return DefendHomeAction(self.inst) end, "GoHome", true)
			),
            WhileNode(function() return clock and not clock:IsDay() end, "IsNight",
				DoAction(self.inst, function() return GoHomeAction(self.inst) end, "GoHome", true)
			),
			DoAction(self.inst, function() return LayEggAction(self.inst) end, "LayEgg", true),
			Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST),
      },1)
    
    self.bt = BT(self.inst, root) 
           
end

function TallbirdBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
end

return TallbirdBrain