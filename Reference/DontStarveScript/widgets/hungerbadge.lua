local Badge = require "widgets/badge"

local HungerBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "hunger", owner)
end)

return HungerBadge