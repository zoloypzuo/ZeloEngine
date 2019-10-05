
FireLevel = Class( function(self, name, desc, minFuel, maxFuel, burnRate, intensity, colour, heat, spreadrate)
    self.name = name
    self.desc = desc
    
    -- Visibility changes - when do we go to a smaller or larger flame
    self.minFuel = minFuel
    self.maxFuel = maxFuel
    
    -- How quickly do we burn through this fuel: update in burnRate seconds
    self.burnRate = burnRate
    
    -- How bright is the flame light
    self.intensity = intensity
    -- What colour is the flame light
    self.colour = colour
    
    -- Distance to spread
    self.heat = heat
    -- Seconds before spreading again
    self.spreadrate = spreadrate
end)

