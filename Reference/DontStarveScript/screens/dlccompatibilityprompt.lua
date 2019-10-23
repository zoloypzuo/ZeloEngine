local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local UIAnim = require "widgets/uianim"

local DlcCompatibilityPrompt = Class(Screen, function(self, done_fn)
    Screen._ctor(self, "DlcCompatibilityPrompt")

    self.done_fn = done_fn
    local buttons = { { text = STRINGS.UI.SAVEINTEGRATION.OK,
                        cb = function()
                            if self.done_fn then
                                self.done_fn(self)
                            end
                        end
                      },
                      { text = STRINGS.UI.SAVEINTEGRATION.CANCEL,
                        cb = function()
                            TheFrontEnd:PopScreen(self)
                            TheFrontEnd:PopScreen()
                        end
                      } }

    --darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, .75)

    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0, 0, 0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    --throw up the background
    self.bg = self.proot:AddChild(Image("images/globalpanels.xml", "panel_upsell_small.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetScale(1.25)

    --title 
    self.title = self.proot:AddChild(Text(TITLEFONT, 50))
    self.title:SetPosition(Vector3(0, 155, 0))
    self.title:SetString(STRINGS.UI.SAVEINTEGRATION.DLC_CHOICE_TITLE)

    --text
    if JapaneseOnPS4() then
        self.text_1:SetRegionSize(500, 150)
        self.text_2:SetRegionSize(500, 150)
        self.text_1 = self.proot:AddChild(Text(BODYTEXTFONT, 28))
        self.text_2 = self.proot:AddChild(Text(BODYTEXTFONT, 28))

    else
        self.text_1 = self.proot:AddChild(Text(BODYTEXTFONT, 30))
        self.text_2 = self.proot:AddChild(Text(BODYTEXTFONT, 30))
        self.text_1:SetRegionSize(500, 100)
        self.text_2:SetRegionSize(500, 200)
    end

    self.text_1:SetPosition(0, 80, 0)
    self.text_1:SetString(STRINGS.UI.SAVEINTEGRATION.DLC_CHOICE_DESC_1)
    self.text_1:EnableWordWrap(true)

    self.text_2:SetPosition(0, -60, 0)
    self.text_2:SetString(STRINGS.UI.SAVEINTEGRATION.DLC_CHOICE_DESC_2)
    self.text_2:EnableWordWrap(true)

    self.dlc_buttons = {}
    table.insert(self.dlc_buttons, self:MakeDLCButton(CAPY_DLC, "SWicontoggle.tex"))
    table.insert(self.dlc_buttons, self:MakeDLCButton(PORKLAND_DLC, "pork_icon.tex"))

    local xPos = -80
    for i, v in ipairs(self.dlc_buttons) do
        v:SetPosition(xPos, 10, 0)
        xPos = xPos * -1
    end

    --create the menu itself
    local button_w = 200
    local spacing = 165

    self.menu = self.proot:AddChild(Menu(buttons, spacing, true))
    self.menu:SetPosition(-(spacing * (#buttons - 1)) / 2, -140, 0)
    self.buttons = buttons
    self.default_focus = self.menu

    self:HookupFocusMoves()
end)

function DlcCompatibilityPrompt:HookupFocusMoves()
    self.dlc_buttons[1]:SetFocusChangeDir(MOVE_RIGHT, self.dlc_buttons[2])
    self.dlc_buttons[1]:SetFocusChangeDir(MOVE_DOWN, self.menu.items[1])

    self.dlc_buttons[2]:SetFocusChangeDir(MOVE_LEFT, self.dlc_buttons[1])
    self.dlc_buttons[2]:SetFocusChangeDir(MOVE_DOWN, self.menu.items[2])

    self.menu.items[1]:SetFocusChangeDir(MOVE_UP, self.dlc_buttons[1])
    self.menu.items[2]:SetFocusChangeDir(MOVE_UP, self.dlc_buttons[2])
end

function DlcCompatibilityPrompt:OnUpdate(dt)
    if self.timeout then
        self.timeout.timeout = self.timeout.timeout - dt
        if self.timeout.timeout <= 0 then
            self.timeout.cb()
        end
    end
    return true
end

function DlcCompatibilityPrompt:OnControl(control, down)
    if DlcCompatibilityPrompt._base.OnControl(self, control, down) then
        return true
    end
end

--TODO: this is basically the same as NewGameScreen:MakeDLCButton, we should unify them
function DlcCompatibilityPrompt:MakeDLCButton(dlc_index, dlc_icon)
    local dlc_btn = self.proot:AddChild(Widget("option"))
    --local dlc_btn = self:AddChild(Widget("option"))
    dlc_btn.image = dlc_btn:AddChild(Image("images/ui.xml", dlc_icon))
    dlc_btn.image:SetPosition(25, 0, 0)
    dlc_btn.image:SetTint(1, 1, 1, .3)

    dlc_btn.checkbox = dlc_btn:AddChild(Image("images/ui.xml", "button_checkbox1.tex"))
    dlc_btn.checkbox:SetPosition(-35, 0, 0)
    dlc_btn.checkbox:SetScale(0.5, 0.5, 0.5)
    dlc_btn.checkbox:SetTint(1.0, 0.5, 0.5, 1)

    dlc_btn.bg = dlc_btn:AddChild(UIAnim())
    dlc_btn.bg:GetAnimState():SetBuild("savetile_small")
    dlc_btn.bg:GetAnimState():SetBank("savetile_small")
    dlc_btn.bg:GetAnimState():PlayAnimation("anim")
    dlc_btn.bg:SetPosition(-75, 0, 0)
    dlc_btn.bg:SetScale(1.12, 1, 1)

    dlc_btn.OnGainFocus = function()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
        dlc_btn:SetScale(1.1, 1.1, 1)
        dlc_btn.bg:GetAnimState():PlayAnimation("over")
    end

    dlc_btn.OnLoseFocus = function()
        dlc_btn:SetScale(1, 1, 1)
        dlc_btn.bg:GetAnimState():PlayAnimation("anim")
    end

    dlc_btn.OnControl = function(_, control, down)
        if Widget.OnControl(dlc_btn, control, down) then
            return true
        end
        if control == CONTROL_ACCEPT and not down then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            dlc_btn.is_enabled = not dlc_btn.is_enabled

            if dlc_btn.is_enabled then
                dlc_btn.enable()
                for i, v in ipairs(self.dlc_buttons) do
                    if v.dlc_index ~= dlc_btn.dlc_index then
                        v.disable()
                    end
                end
            else
                dlc_btn.disable()
            end

            return true
        end
    end

    dlc_btn.enable = function()
        dlc_btn.is_enabled = true
        dlc_btn.checkbox:SetTint(1, 1, 1, 1)
        dlc_btn.image:SetTint(1, 1, 1, 1)
        dlc_btn.checkbox:SetTexture("images/ui.xml", "button_checkbox2.tex")
    end

    dlc_btn.disable = function()
        dlc_btn.is_enabled = false
        dlc_btn.checkbox:SetTint(1.0, 0.5, 0.5, 1)
        dlc_btn.image:SetTint(1, 1, 1, .3)
        dlc_btn.checkbox:SetTexture("images/ui.xml", "button_checkbox1.tex")
    end

    dlc_btn.GetHelpText = function()
        local controller_id = TheInput:GetControllerID()
        local t = {}
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.TOGGLE)
        return table.concat(t, "  ")
    end

    dlc_btn.set_enabled = function(enabled)
        if enabled then
            dlc_btn.enable()
        else
            dlc_btn.disable()
        end
    end

    dlc_btn.dlc_index = dlc_index
    dlc_btn.set_enabled(IsDLCEnabled(dlc_index))

    return dlc_btn
end

function DlcCompatibilityPrompt:GetEnabledDLC()
    for i, v in ipairs(self.dlc_buttons) do
        if v.is_enabled then
            return v.dlc_index
        end
    end
end

return DlcCompatibilityPrompt
