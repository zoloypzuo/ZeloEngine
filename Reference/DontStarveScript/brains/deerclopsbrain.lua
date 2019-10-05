require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/minperiod"


local SEE_DIST = 40

local CHASE_DIST = 32
local CHASE_TIME = 20

local function BaseDestroy(inst)
    if inst.components.knownlocations:GetLocation("targetbase") then
    	local target = FindEntity(inst, SEE_DIST, function(item) 
    		if item.components.workable
    		   and item.components.workable.action == ACTIONS.HAMMER
    		   and not item:HasTag("wall") then
    				return true
    			end
    		end)
    	if target then
    		return BufferedAction(inst, target, ACTIONS.HAMMER)
    	end
    end
end

local function GoHome(inst)
    if inst.components.knownlocations:GetLocation("home") then
        return BufferedAction(inst, nil, ACTIONS.GOHOME, nil, inst.components.knownlocations:GetLocation("home") )
    end
end

local function GetWanderPos(inst)
    if inst.components.knownlocations:GetLocation("targetbase") then
        return inst.components.knownlocations:GetLocation("targetbase")
	elseif inst.components.knownlocations:GetLocation("home") then
		return inst.components.knownlocations:GetLocation("home")
	elseif inst.components.knownlocations:GetLocation("spawnpoint") then
		return inst.components.knownlocations:GetLocation("spawnpoint")
	end
end

local DeerclopsBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function DeerclopsBrain:OnStart()

    local clock = GetClock()

    local root =
        PriorityNode(
        {
			AttackWall(self.inst),
            ChaseAndAttack(self.inst, CHASE_TIME, CHASE_DIST),
            DoAction(self.inst, function() return BaseDestroy(self.inst) end, "DestroyBase", true),
            WhileNode(function() return self.inst.components.knownlocations:GetLocation("home") end, "HasHome",
                DoAction(self.inst, function() return GoHome(self.inst) end, "GoHome", true) ),
            Wander(self.inst, GetWanderPos, 30, {minwwwalktime = 10}),
        },1)
    
    self.bt = BT(self.inst, root)
         
end

function DeerclopsBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", Point(self.inst.Transform:GetWorldPosition()))
end

return DeerclopsBrain
