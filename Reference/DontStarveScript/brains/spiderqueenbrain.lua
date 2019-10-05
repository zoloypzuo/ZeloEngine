require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/follow"
require "behaviours/doaction"
require "behaviours/minperiod"
require "behaviours/panic"


local SpiderQueenBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SpiderQueenBrain:CanSpawnChild()
	
	local player = GetPlayer()
	
	return self.inst:GetTimeAlive() > 5 and 
		self.inst.components.leader.numfollowers < TUNING.SPIDERQUEEN_FOLLOWERS and
		 (self.inst.components.combat.target or self.inst:GetDistanceSqToInst(player) < 20*20)

end


function SpiderQueenBrain:CanPlantNest()
	if self.inst:GetTimeAlive() > TUNING.SPIDERQUEEN_MINWANDERTIME then
		local pt = Vector3(self.inst.Transform:GetWorldPosition())
	    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, {'blocker'}) 
		local min_spacing = 3

	    for k, v in pairs(ents) do
			if v ~= self.inst and v:IsValid() and v.entity:IsVisible() then
				if distsq( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing*min_spacing then
					return false
				end
			end
		end
		
		local den = GetClosestInstWithTag("spiderden", self.inst, TUNING.SPIDERQUEEN_MINDENSPACING)		
		local queen = GetClosestInstWithTag("spiderqueen", self.inst, TUNING.SPIDERQUEEN_MINDENSPACING)		
		if den or queen then
			return false
		end
		
		
		return true
	end
end

local MIN_FOLLOW = 10
local MAX_FOLLOW = 20
local MED_FOLLOW = 15

function SpiderQueenBrain:OnStart()
    
    
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        
        IfNode(function() return self:CanPlantNest() end, "can plant nest",
			ActionNode(function() self.inst.sg:GoToState("makenest") end)),
		
		MinPeriod(self.inst, TUNING.SPIDERQUEEN_GIVEBIRTHPERIOD, 
			IfNode(function() return self:CanSpawnChild() end, "needs follower", 
				ActionNode(function() self.inst.sg:GoToState("poop") return SUCCESS end, "make child" ))),
        
        --SPIDERQUEEN_MINDENSPACING
        
        ChaseAndAttack(self.inst, 100),
        Wander(self.inst),
    }, 2)
    
    self.bt = BT(self.inst, root)
    
end

return SpiderQueenBrain