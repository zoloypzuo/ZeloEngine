require "behaviours/follow"
require "behaviours/wander"


local GhostBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)


local function GetFollowTarget(ghost)
    if ghost.brain.followtarget then
        if (not ghost.brain.followtarget.components.health or ghost.brain.followtarget.components.health:IsDead()) or
            ghost:GetDistanceSqToInst(ghost.brain.followtarget) > 15*15 then
            ghost.brain.followtarget = nil
        end
    end
    
    if not ghost.brain.followtarget then
        ghost.brain.followtarget = FindEntity(ghost, 10, function(target)
            return target:HasTag("character") and not (target.components.health and target.components.health:IsDead() )
        end)
    end
    
    return ghost.brain.followtarget
end

function GhostBrain:OnStart()

    local clock = GetClock()
    
    local root = PriorityNode(
    {
        Follow(self.inst, function() return GetFollowTarget(self.inst) end, TUNING.GHOST_RADIUS*.25, TUNING.GHOST_RADIUS*.5, TUNING.GHOST_RADIUS),
        SequenceNode{
			ParallelNodeAny{
				WaitNode(10),
				Wander(self.inst),
			},
            ActionNode(function() self.inst.sg:GoToState("dissipate") end),
        }
    }, 1)
        
    self.bt = BT(self.inst, root)
         
end

return GhostBrain
