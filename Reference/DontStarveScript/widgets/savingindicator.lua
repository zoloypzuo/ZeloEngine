local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"


local SavingIndicator = Class(Widget, function(self, owner)
    self.owner = owner

    Widget._ctor(self, "Saving")
    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("saving")
    self.anim:GetAnimState():SetBuild("saving")
    self:Hide()
    local scale = .5
    
    self.text = self:AddChild(Text(UIFONT, 50/scale))
    
    self.text:SetString(STRINGS.UI.HUD.SAVING)
    self.text:SetColour(241/255, 199/255, 66/255, 1)
    self.text:SetHAlign(ANCHOR_LEFT)
    self.text:SetPosition(160, -170, 0)
    self.text:Hide()
    self:SetScale(scale,scale,scale)
    self:SetPosition(100, 0,0)
end)

function SavingIndicator:EndSave()
    self.text:Hide() self.anim:GetAnimState():PlayAnimation("save_post")  
end

function SavingIndicator:StartSave()
    self:Show()
    self.anim:GetAnimState():PlayAnimation("save_pre")
    self.inst:DoTaskInTime(.5, function() self.text:Show()end)  
    self.anim:GetAnimState():PushAnimation("save_loop", true)
end

return SavingIndicator
