local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local FogOver = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "FogOver")
    self:SetClickable(false)

    self.bg2 = self:AddChild(Image("images/fx5.xml", "fog_over.tex"))
    self.bg2:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg2:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg2:SetVAnchor(ANCHOR_MIDDLE)
    self.bg2:SetHAnchor(ANCHOR_MIDDLE)
    self.bg2:SetScaleMode(SCALEMODE_FILLSCREEN)

    self.alpha = 0
    self.alphagoal = 0
    self.transitiontime = 2.0
    self.time = self.transitiontime

    self:Hide()
end)

function FogOver:StartFog()
    if not self.foggy then
        self.time = self.transitiontime
        self.alphagoal = 1
        self.foggy = true

        self:StartUpdating()
        self:Show()
    end
end


function FogOver:SetFog(off)
    if off and self.foggy then
            self.time = 0
            self.alphagoal = 0
            self.foggy = false
            self.alpha = 0
            self:StopUpdating()
            self:Hide()
    else
        if not self.foggy then
            self.time = 0
            self.alphagoal = 1
            self.foggy = true
            self.alpha = 1
            self:StartUpdating()
            self:Show()
        end
    end
end

function FogOver:StopFog()
    if self.foggy then
        self.time = self.transitiontime
        self.alphagoal = 0
        self.foggy = false
    end
end

function FogOver:UpdateAlpha(dt)
    if self.alphagoal ~= self.alpha then
        if self.time > 0 then
            self.time = math.max(0, self.time - dt)
            if self.alphagoal < self.alpha then
                self.alpha = Remap(self.time, self.transitiontime, 0, 1, 0)
            else
                self.alpha = Remap(self.time, self.transitiontime, 0, 0, 1)
            end
        end
    end
end

function FogOver:OnUpdate(dt)
    local equippeditem = GetPlayer().components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    local wearingbathat = equippeditem and equippeditem:HasTag("clearfog") -- equippeditem.prefab == "bathat" or 

    self:UpdateAlpha(dt)

    if TheCamera.interior or wearingbathat then
        self:Hide()
    else
        self:Show()
    end

    local color = GetClock().currentColour
    local x = math.min(color.x * 1.5, 1)
    local y = math.min(color.y * 1.5, 1)
    local z = math.min(color.z * 1.5, 1)

    self.bg2:SetTint(x, y, z, self.alpha)

    if self.alpha == 0 and self.alphagoal == 0 then
        self:Hide()
        self:StopUpdating()
    end
end

return FogOver
