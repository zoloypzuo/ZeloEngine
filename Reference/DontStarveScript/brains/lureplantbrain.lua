require "behaviours/controlminions"
require "behaviours/standstill"

local LureplantBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function LureplantBrain:OnStart()
    local root = PriorityNode(
    {
        ControlMinions(self.inst),
        --StandStill(self.inst),
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return LureplantBrain