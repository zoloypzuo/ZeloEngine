require "constants"
require "util"
require "strings"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local PopupDialogScreen = require "screens/popupdialog"

local LEFT_SIDE = -415
local RIGHT_SIDE = 415

local LABEL_WIDTH = 500
local LABEL_HEIGHT = 50

local DEVICE_DUALSHOCK4 = 2
local DEVICE_VITA = 3

local CONTROLLER_IMAGES = {
    [1] = "",
    [DEVICE_DUALSHOCK4] = "controls_image_ds4.tex",
    [DEVICE_VITA] = "controls_image_vita.tex",
}

local LABELS = {
    [1] = {},
    [DEVICE_DUALSHOCK4] = {
        { x = 20,        y = 275,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.TOUCHPAD },
        { x = 80,        y = 275,  anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.PS4.OPTIONS },

        { x = LEFT_SIDE, y = 255,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L2 },
        { x = LEFT_SIDE, y = 155,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L1 },

        { x = LEFT_SIDE, y = 55,   anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_UP },
        { x = LEFT_SIDE, y = 15,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_LEFT },
        { x = LEFT_SIDE, y = -25,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_BOTTOM },
        { x = LEFT_SIDE, y = -65, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_RIGHT },

        { x = LEFT_SIDE, y = -200, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L3 },

        { x = RIGHT_SIDE, y = 255,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R2 },
        { x = RIGHT_SIDE, y = 155,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R1 },

        { x = RIGHT_SIDE, y = 55,   anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.TRIANGLE },
        { x = RIGHT_SIDE, y = 15,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.CIRCLE },
        { x = RIGHT_SIDE, y = -25,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.CROSS },
        { x = RIGHT_SIDE, y = -65, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.SQUARE },

        { x = RIGHT_SIDE, y = -200, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R3 },
    },
    [DEVICE_VITA] = {
        { x = 20,         y = 290,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.TOUCHPAD },
        { x = RIGHT_SIDE, y = -25,  anchor = ANCHOR_LEFT,  text = STRINGS.UI.CONTROLSSCREEN.PS4.OPTIONS },

        { x = LEFT_SIDE, y = -175,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L1 },
        { x = LEFT_SIDE, y = 290,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L2 },

        { x = LEFT_SIDE, y = 170,   anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_UP },
        { x = LEFT_SIDE, y = 115,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_LEFT },
        { x = LEFT_SIDE, y = 75,  anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_BOTTOM },
        { x = LEFT_SIDE, y = 210, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.DPAD_RIGHT },

        { x = LEFT_SIDE, y = 25, anchor = ANCHOR_RIGHT, text = STRINGS.UI.CONTROLSSCREEN.PS4.L3 },

        { x = RIGHT_SIDE, y = -175,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R1 },
        { x = RIGHT_SIDE, y = 290,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R2 },

        { x = RIGHT_SIDE, y = 165,   anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.TRIANGLE },
        { x = RIGHT_SIDE, y = 120,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.CIRCLE },
        { x = RIGHT_SIDE, y = 75,  anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.CROSS },
        { x = RIGHT_SIDE, y = 205, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.SQUARE },

        { x = RIGHT_SIDE, y = 25, anchor = ANCHOR_LEFT, text = STRINGS.UI.CONTROLSSCREEN.PS4.R3 },
    }
}


local ControlsScreen = Class(Screen, function(self, in_game)
	Screen._ctor(self, "ControlsScreen")
	self.in_game = in_game

	
	self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
    SetBGcolor(self.bg)

    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    
	self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(-25,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
    self.layouts = {}
    self.layouts[DEVICE_DUALSHOCK4] = self:PopulateLayout(DEVICE_DUALSHOCK4)
    self.layouts[DEVICE_DUALSHOCK4]:Hide()
    self.layouts[DEVICE_VITA] = self:PopulateLayout(DEVICE_VITA)
    self.layouts[DEVICE_VITA]:Hide()
    
    local device = TheInputProxy:GetInputDeviceType(0)
    self.device = device
    self.layouts[device]:Show()        

end)

function ControlsScreen:PopulateLayout(device)

    local layout = self.root:AddChild(Widget("layout"))
    
    local image = layout:AddChild( Image( "images/ps4_controllers.xml", CONTROLLER_IMAGES[device] ) )
    image:SetPosition( 12,0,0 )
    
    for _, v in pairs(LABELS[device]) do
        local label
        if JapaneseOnPS4() then
            label = layout:AddChild(Text(TITLEFONT, 35 * 0.7))
        else
            label = layout:AddChild(Text(TITLEFONT, 35))
        end
        label:SetString(v.text)
        label:SetRegionSize( LABEL_WIDTH, LABEL_HEIGHT )
        label:SetHAlign(v.anchor)
        if v.anchor == ANCHOR_RIGHT then
            label:SetPosition(v.x - LABEL_WIDTH/2, v.y, 0)
        else
            label:SetPosition(v.x + LABEL_WIDTH/2, v.y, 0)
        end
    end
    
    return layout
end

function ControlsScreen:OnUpdate(dt)
    local device = TheInputProxy:GetInputDeviceType(0)   
    if self.device ~= device then    
        self.layouts[self.device]:Hide()
        self.device = device
        self.layouts[device]:Show()
    end
end

function ControlsScreen:OnControl(control, down)
    if ControlsScreen._base.OnControl(self, control, down) then return true end
    
    if not down and control == CONTROL_CANCEL then
    	self:Close()
    end
end

function ControlsScreen:Close()
	--TheFrontEnd:DoFadeIn(2)
	TheFrontEnd:PopScreen()
end	

function ControlsScreen:GetHelpText()
    local t = {}
    local controller_id = TheInput:GetControllerID()
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    return table.concat(t, "  ")
end

return ControlsScreen