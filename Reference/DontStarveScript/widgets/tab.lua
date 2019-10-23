local Widget = require "widgets/widget"
local Image = require "widgets/image"

local Tab = Class(Widget, function(self, tabgroup, name, atlas, icon_atlas, icon, imnorm, imselected, imhighlight, imalthighlight, imoverlay, highlightpos, selectfn, deselectfn, collapsed)
    Widget._ctor(self, "Tab")
    self.group = tabgroup
    self.atlas = atlas
    self.icon_atlas = icon_atlas
    self.selectfn = selectfn
    self.deselectfn = deselectfn
    self.imnormal = imnorm
    self.imselected = imselected
    self.imhighlight = imhighlight
    self.imalthighlight = imalthighlight
    self.collapsed = collapsed
    self.basescale = .5
    self.selected = false
    self.highlighted = false
    self:SetTooltip(name)
    self:SetScale(self.basescale, self.basescale, self.basescale)

    self.bg = self:AddChild(Image(atlas, imnorm))
    local w, h = self.bg:GetSize()

    self.bg:SetPosition(w / 2, 0, 0)
    self.icon = self:AddChild(Image(icon_atlas, icon))
    self.icon:SetClickable(false)
    self.icon:SetPosition(w / 2, 0, 0)

    self.overlay = self:AddChild(Image(atlas, imoverlay))
    self.overlay:SetPosition(w / 2, 0, 0)
    self.overlay:Hide()
    self.overlay:SetClickable(false)
end)

function Tab:OnControl(control, down)
    if Tab._base.OnControl(self, control, down) then
        return true
    end

    if not down and control == CONTROL_ACCEPT then
        if self.selected then
            self:Deselect()
        else
            self:Select()
        end

        self.group:OnTabsChanged()
        return true
    end
end

function Tab:Overlay()
    if not self.overlayshow then
        self.overlayshow = true
        self.overlay:Show()
        local delay = nil
        if self.group.onoverlay then
            delay = self.group.onoverlay()
        end

        local applychange = function()
            self:ScaleTo(2 * self.basescale, (self.selected and 1.25 or 1) * self.basescale, .25)
            self.overlay:Show()
        end

        if delay then
            scheduler:ExecuteInTime(delay, applychange)
        else
            applychange()
        end
    end
end

function Tab:HideOverlay()
    self.overlayshow = false
    self.overlay:Hide()
end

function Tab:Highlight(num)
    local change_scale = not self.highlightnum or self.highlightnum < num
    local change_texture = not self.selected and change_scale

    self.highlighted = true
    self.highlightnum = num

    if change_texture or change_scale then

        local delay = nil

        if self.group.onhighlight then
            delay = self.group.onhighlight()
        end

        local applychange = function()
            if change_texture then
                self.bg:SetTexture(self.atlas, self.imhighlight)
            end

            if change_scale then
                self:ScaleTo(2 * self.basescale, (self.selected and 1.25 or 1) * self.basescale, .25)
            end
        end

        if delay then
            scheduler:ExecuteInTime(delay, applychange)
        else
            applychange()
        end
    end
end

function Tab:AlternateHighlight(num, doscaling)
    local change_scale = not self.alternatehighlightnum or self.alternatehighlightnum < num
    local change_texture = not self.selected and change_scale

    self.alternatehighlighted = true
    self.alternatehighlightnum = num

    if change_texture or change_scale then

        local delay = nil

        if self.group.onalthighlight then
            delay = self.group.onalthighlight()
        end

        local applychange = function()
            if change_texture then
                self.bg:SetTexture(self.atlas, self.imalthighlight)
            end

            if change_scale and doscaling then
                self:ScaleTo(2 * self.basescale, (self.selected and 1.25 or 1) * self.basescale, .25)
            end
        end

        if delay then
            scheduler:ExecuteInTime(delay, applychange)
        else
            applychange()
        end
    end
end

function Tab:UnHighlight(noscaling)
    if not self.selected then
        self.bg:SetTexture(self.atlas, self.imnormal)
    end

    if not noscaling and (self.highlighted or self.alternatehighlighted) then
        self:ScaleTo(.75 * self.basescale, (self.selected and 1.25 or 1) * self.basescale, .33)
    end

    self.highlighted = false
    self.alternatehighlighted = false
    self.highlightnum = nil
    self.alternatehighlightnum = nil
end

function Tab:Deselect()
    if self.selected then
        self:ScaleTo(1.25 * self.basescale, 1 * self.basescale, .125)

        if self.deselectfn then
            self.deselectfn(self)
        end

        if self.highlighted then
            self.bg:SetTexture(self.atlas, self.imhighlight)
        elseif self.alternatehighlighted then
            self.bg:SetTexture(self.atlas, self.imalthighlight)
        else
            self.bg:SetTexture(self.atlas, self.imnormal)
        end

        self.selected = false
    end
end

function Tab:Select()
    if not self.selected then
        self:ScaleTo(1 * self.basescale, 1.25 * self.basescale, .25)
        self.group:DeselectAll()

        if self.selectfn then
            self.selectfn(self)
        end

        self.bg:SetTexture(self.atlas, self.imselected)
        self.selected = true
    end
end

return Tab
