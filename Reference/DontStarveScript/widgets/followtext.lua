local Widget = require "widgets/widget"
local Text = require "widgets/text"

local FollowText = Class(Widget, function(self, font, size, text)
    Widget._ctor(self, "followtext")

    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(1.25)
    self.text = self:AddChild(Text(font, size, text))
    self.offset = Vector3(0,0,0)
    self.screen_offset = Vector3(0,0,0)

    self:StartUpdating()
end)

function FollowText:SetTarget(target)
    self.target = target
    self:OnUpdate()
end

function FollowText:SetOffset(offset)
    self.offset = offset
    self:OnUpdate()
end

function FollowText:SetScreenOffset(x,y)
    self.screen_offset.x = x
    self.screen_offset.y = y
    self:OnUpdate()
end

function FollowText:GetScreenOffset()
    return self.screen_offset.x, self.screen_offset.y
end

function FollowText:OnUpdate(dt)
    if self.target and self.target:IsValid() then
        local scale = TheFrontEnd:GetHUDScale()
        self.text:SetScale(scale)

        local world_pos = nil

        if self.target.AnimState then
            world_pos = Vector3(self.target.AnimState:GetSymbolPosition(self.symbol or "", self.offset.x, self.offset.y, self.offset.z))
        else
            world_pos = self.target:GetPosition()
        end

        if world_pos then
            local screen_pos = Vector3(TheSim:GetScreenPos(world_pos:Get())) 

            screen_pos.x = screen_pos.x + self.screen_offset.x
            screen_pos.y = screen_pos.y + self.screen_offset.y
            self:SetPosition(screen_pos)
        end
    end
end

return FollowText