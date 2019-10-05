local GlobalColourModifier = Class(function(self, inst)
    self.inst = inst     
    self.modifycolorfndefault = function(ent)
        -- restore previous values
        if ent.StashedColourSettings then
            ent.AnimState:SetMultColour( ent.StashedColourSettings[1][1],  ent.StashedColourSettings[1][2],  ent.StashedColourSettings[1][3],  ent.StashedColourSettings[1][4])
            ent.AnimState:SetDesaturation( ent.StashedColourSettings[2] )
            if (ent.StashedColourSettings[3]) then
                ent.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            else
                ent.AnimState:ClearBloomEffectHandle()
            end
            ent.StashedColourSettings = nil
        end
        ent:SetAddColour(0,0,0,1)
    end
    self.modifycolorfn = self.modifycolorfndefault
end)

function GlobalColourModifier:SetModifyColourFn(fn)
    self.modifycolorfn = fn
    for i,ent in pairs(Ents)do
        if ent.AnimState and not ent:HasTag("widget") then
            -- back up existing values
            if not ent.StashedColourSettings then
                ent.StashedColourSettings = {{ent.AnimState:GetMultColourRaw()}, ent.AnimState:GetDesaturation(), ent.AnimState:GetHasBloom()}
            end
            self.modifycolorfn(ent)            
        end
    end
    self.modifycolorfn(GetWorld())
end

function GlobalColourModifier:Apply(ent)
    if ent.AnimState and not ent:HasTag("widget") then
        -- back up existing values
        if not ent.StashedColourSettings then
            ent.StashedColourSettings = {{ent.AnimState:GetMultColourRaw()}, ent.AnimState:GetDesaturation(), ent.AnimState:GetHasBloom()}
        end
        self.modifycolorfn(ent)            
    end
end

function GlobalColourModifier:Reset()
    self:SetModifyColourFn(self.modifycolorfndefault)    
end

return GlobalColourModifier
