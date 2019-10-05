local easing = require("easing")

local Blur = Class(function(self, inst)
    self.inst = inst        
    self.effects = {}
    self.inst:StartUpdatingComponent(self)
end)

function Blur:UpdateEffect(category,data)
    if not self.effects[category] then
        self.effects[category] = {}
    end

    self.effects[category] = data
end

function Blur:RemoveEffect(category)
    if self.effects[category] then
        self.effects[category] = nil
    end
end

function Blur:OnUpdate(dt)
    local data = {
        distortion = 1,
        radii = {0,1,0}, -- [3] is a weight
        fxtime = {0,0},  -- [2] is a weight
    }

    for i,effect in pairs(self.effects)do
        if effect.distortion and effect.distortion < data.distortion then
            data.distortion = effect.distortion
        end
        if effect.radii and effect.radii[3] > data.radii[3] then            
            data.radii = effect.radii        
        end
        if effect.fxtime and effect.fxtime[2] > data.fxtime[2] then
            data.fxtime = effect.fxtime
        end        
    end    
    PostProcessor:SetEffectTime(data.fxtime[1])
    PostProcessor:SetDistortionFactor( data.distortion)
    PostProcessor:SetDistortionRadii( data.radii[1], data.radii[2] )
end


return Blur
