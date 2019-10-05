require("constants")
local Screen = require "widgets/screen"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"


local PopupDialogScreen = require "screens/popupdialog"

local controls_per_screen = 10
local controls_per_scroll = 5 -- why not == controls_per_screen you ask? some logical pairs (prev/next, up/down) get split accross screens, and this way you can scroll half a screen to see them both at the same time

local kbcontrols = {    
	--clicking
    CONTROL_PRIMARY,
    CONTROL_SECONDARY,
        
    --click modifiers
    CONTROL_FORCE_INSPECT,
    CONTROL_FORCE_ATTACK,
    
    --actions	
	CONTROL_ATTACK,
    CONTROL_ACTION,
    
    --walking
    CONTROL_MOVE_UP,
    CONTROL_MOVE_DOWN,
    CONTROL_MOVE_LEFT,
    CONTROL_MOVE_RIGHT,

    -- view controls
    CONTROL_ROTATE_LEFT,
    CONTROL_ROTATE_RIGHT,
    CONTROL_ZOOM_IN,
    CONTROL_ZOOM_OUT,
    CONTROL_MAP_ZOOM_IN,
    CONTROL_MAP_ZOOM_OUT,

    -- player movement controls
    CONTROL_PAUSE,
    CONTROL_MAP,

    --moals
    CONTROL_OPEN_CRAFTING,
    
    --inventory actions and modifiers
    CONTROL_INV_1,
    CONTROL_INV_2,
    CONTROL_INV_3,
    CONTROL_INV_4,
    CONTROL_INV_5,
    CONTROL_INV_6,
    CONTROL_INV_7,
    CONTROL_INV_8,
    CONTROL_INV_9,
    CONTROL_INV_10,

	CONTROL_INSPECT,
    CONTROL_SPLITSTACK,
    CONTROL_TRADEITEM,
--    CONTROL_TRADESTACK,     -- isn't in DontStarveInputHandler::DontStarveInputHandler
    CONTROL_FORCE_TRADE,
    CONTROL_FORCE_STACK,

	--menu controls
    CONTROL_ACCEPT,
    CONTROL_CANCEL,

    CONTROL_PAGELEFT,
    CONTROL_PAGERIGHT,

    CONTROL_PREVVALUE,
    CONTROL_NEXTVALUE,
    
	CONTROL_FOCUS_UP,
	CONTROL_FOCUS_DOWN,
	CONTROL_FOCUS_LEFT,
	CONTROL_FOCUS_RIGHT,

	--debugging
    CONTROL_OPEN_DEBUG_CONSOLE,
    CONTROL_TOGGLE_LOG,
    CONTROL_TOGGLE_DEBUGRENDER,
    
	--broadcasting
	--CONTROL_TOGGLE_BROADCASTING,
}

local controllercontrols = {    
    --actions
	CONTROL_CONTROLLER_ATTACK,
    CONTROL_CONTROLLER_ACTION,
    CONTROL_CONTROLLER_ALTACTION,
    
    --walking
    CONTROL_MOVE_UP,
    CONTROL_MOVE_DOWN,
    CONTROL_MOVE_LEFT,
    CONTROL_MOVE_RIGHT,

    -- view controls
    CONTROL_ROTATE_LEFT,
    CONTROL_ROTATE_RIGHT,
    CONTROL_ZOOM_IN,
    CONTROL_ZOOM_OUT,
    CONTROL_MAP_ZOOM_IN,
    CONTROL_MAP_ZOOM_OUT,

    CONTROL_PAUSE,
    CONTROL_MAP,

	--in-game menu popups
	CONTROL_OPEN_CRAFTING,
	CONTROL_OPEN_INVENTORY,
	
	CONTROL_INVENTORY_LEFT,
	CONTROL_INVENTORY_RIGHT,
	CONTROL_INVENTORY_UP,
	CONTROL_INVENTORY_DOWN,
	
	CONTROL_INVENTORY_USEONSELF,
	CONTROL_INVENTORY_USEONSCENE,
	CONTROL_INVENTORY_DROP,
	CONTROL_PUTSTACK,
	CONTROL_USE_ITEM_ON_ITEM,
    CONTROL_INSPECT,

	--menu controls
    CONTROL_ACCEPT,
    CONTROL_CANCEL,

    CONTROL_PAGELEFT,
    CONTROL_PAGERIGHT,
    CONTROL_PREVVALUE,
    CONTROL_NEXTVALUE,

	CONTROL_FOCUS_UP,
	CONTROL_FOCUS_DOWN,
	CONTROL_FOCUS_LEFT,
	CONTROL_FOCUS_RIGHT,

    CONTROL_OPEN_DEBUG_MENU,
}


local ControlsScreen = Class(Screen, function(self, in_game)
    Widget._ctor(self, "ControlsScreen")
    self.in_game = in_game
    self.is_mapping = false
    
    TheInputProxy:StartMappingControls()
    
	self.options = 
	{ 
		preset = {},
		tweak = {}
	}
	
	self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
	SetBGcolor(self.bg)


    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    
	self.scaleroot = self:AddChild(Widget("scaleroot"))
    self.scaleroot:SetVAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetHAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetPosition(0,0,0)
    self.scaleroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root = self.scaleroot:AddChild(Widget("root"))
    self.root:SetScale(.9)


    local left_col =-RESOLUTION_X*.25 - 70
    local right_col = RESOLUTION_X*.25 - 130
    
	self.applybutton = self.root:AddChild(ImageButton())
    self.applybutton:SetPosition(left_col, -110, 0)
    self.applybutton:SetText(STRINGS.UI.CONTROLSSCREEN.APPLY)
    self.applybutton.text:SetColour(0,0,0,1)
    self.applybutton:SetOnClick( function() self:Apply() end )
    self.applybutton:SetFont(BUTTONFONT)
    self.applybutton:SetTextSize(40)    
    self.applybutton:Hide()
    
	self.resetbutton = self.root:AddChild(ImageButton())
    self.resetbutton:SetPosition(left_col, -180, 0)
    self.resetbutton:SetText(STRINGS.UI.CONTROLSSCREEN.RESET)
    self.resetbutton.text:SetColour(0,0,0,1)
    self.resetbutton:SetOnClick( function() self:LoadDefaultControls() end )
    self.resetbutton:SetFont(BUTTONFONT)
    self.resetbutton:SetTextSize(40)
    
	self.cancelbutton = self.root:AddChild(ImageButton())
    self.cancelbutton:SetPosition(left_col, -250, 0)
    self.cancelbutton:SetText(STRINGS.UI.CONTROLSSCREEN.CANCEL)
    self.cancelbutton.text:SetColour(0,0,0,1)
    self.cancelbutton:SetOnClick( function() self:Cancel() end )
    self.cancelbutton:SetFont(BUTTONFONT)
    self.cancelbutton:SetTextSize(40)

	--set up the device spinner

    self.devices = TheInput:GetInputDevices()
        
    self.devicepanel = self.root:AddChild(Widget("devicepanel"))
    self.devicepanel:SetPosition(left_col,100,0)
    self.devicepanelbg = self.devicepanel:AddChild(Image("images/globalpanels.xml", "panel.tex"))
    self.devicepanelbg:SetScale(0.8,-0.60, 1)

    self.devicetitle = self.devicepanel:AddChild(Text(TITLEFONT, 50))
    self.devicetitle:SetHAlign(ANCHOR_MIDDLE)
    self.devicetitle:SetPosition(0, 75, 0)
	self.devicetitle:SetRegionSize( 400, 70 )
    self.devicetitle:SetString(STRINGS.UI.CONTROLSSCREEN.DEVICE_TITLE)
	
	self.devicespinner = self.devicepanel:AddChild(Spinner( self.devices, 350 ))
	self.devicespinner:SetPosition(0, 0, 0)
	self.devicespinner:SetTextColour(0,0,0,1)
	self.devicespinner.OnChanged =
		function( _, data )
		    self.control_offset = 0     -- show controls from the first rather than the current page
		    self:Scroll(0)              -- update the scroll arrows
            self:RefreshControls()
		end


    local enableDisableOptions = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }
    self.enablespinner = self.devicepanel:AddChild( Spinner( enableDisableOptions ))
    self.enablespinner:SetPosition(0,-70,0)
    self.enablespinner:SetTextColour(0,0,0,1)
    self.enablespinner.OnChanged =
        function( _, data )
            TheInputProxy:EnableInputDevice(self.devicespinner:GetSelectedData(), data)
            self:RefreshControls()
            self:MakeDirty()
            self.enablespinner:SetFocus()
        end   
    self.enablespinner:Hide()     
	
	--add the controls panel	
	
	self.control_offset = 0
    self.controlspanel = self.root:AddChild(Widget("controlspanel"))
    self.controlspanel:SetPosition(right_col,0,0)
    self.controlspanelbg = self.controlspanel:AddChild(Image("images/fepanels.xml", "panel_controls.tex"))

	self.rightbutton = self.controlspanel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.rightbutton:SetPosition(340, 0, 0)
    self.rightbutton:SetOnClick( function() self:Scroll(controls_per_scroll) end)
	
	self.leftbutton = self.controlspanel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.leftbutton:SetPosition(-340, 0, 0)
    self.leftbutton:SetScale(-1,1,1)
    self.leftbutton:SetOnClick( function() self:Scroll(-controls_per_scroll) end)	
    self.leftbutton:Hide()
	
    self.inputhandlers = {}
    table.insert(self.inputhandlers, TheInput:AddControlMappingHandler(
        function(deviceId, controlId, inputId, hasChanged)  
            self:OnControlMapped(deviceId, controlId, inputId, hasChanged)
        end
    ))
    
	self.controlwidgets = {}
	self:LoadCurrentControls()
	self.devicespinner:SetFocus()
	self.default_focus = self.devicespinner
end)

function ControlsScreen:OnDestroy()
    
    TheInputProxy:StopMappingControls()
    
    for k,v in pairs(self.inputhandlers) do
        v:Remove()
    end
	self._base.OnDestroy(self)
end

function ControlsScreen:MakeDirty()

	self.applybutton:Show()	
    self.cancelbutton:SetText(STRINGS.UI.CONTROLSSCREEN.CANCEL)
    self.dirty = true
    self:RefreshNav()
end

function ControlsScreen:MakeClean()
	
	
	self.applybutton:Hide()	
    self.cancelbutton:SetText(STRINGS.UI.CONTROLSSCREEN.CLOSE)
    self.dirty = false
    self:RefreshNav()
end

function ControlsScreen:IsDirty()
    return self.dirty
end

function ControlsScreen:RefreshNav()

	self.resetbutton:SetFocusChangeDir(MOVE_DOWN, self.cancelbutton)
	self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.resetbutton)

	if self.applybutton.shown then
		self.applybutton:SetFocusChangeDir(MOVE_UP, self.enablespinner.shown and self.enablespinner or self.devicespinner)
		self.applybutton:SetFocusChangeDir(MOVE_DOWN, self.resetbutton)
		self.resetbutton:SetFocusChangeDir(MOVE_UP, self.applybutton)
		self.enablespinner:SetFocusChangeDir(MOVE_DOWN, self.applybutton)
	else
		self.resetbutton:SetFocusChangeDir(MOVE_UP, self.enablespinner.shown and self.enablespinner or self.devicespinner)
		self.enablespinner:SetFocusChangeDir(MOVE_DOWN, self.resetbutton)
	end
	
	self.enablespinner:SetFocusChangeDir(MOVE_UP, self.devicespinner)
	self.devicespinner:SetFocusChangeDir(MOVE_DOWN, self.enablespinner.shown and self.enablespinner or (self.applybutton.shown and self.applybutton or self.resetbutton))


	local targets = {self.cancelbutton, self.resetbutton, self.devicespinner}
	if self.enablespinner and self.enablespinner.shown then
		table.insert(targets, self.enablespinner)
	end
	if self.applybutton and self.applybutton.shown then
		table.insert(targets, self.applybutton)
	end
	
	local function toleftcol()
		local current = TheFrontEnd:GetFocusWidget()
		if not current then return self.cancelbutton end
		
		local pt = current:GetWorldPosition()
		local closest = nil
		local closest_dist = nil
		for k,v in pairs(targets) do
			local dist = v:GetWorldPosition():DistSq(pt)
			if not closest or dist < closest_dist then
				closest = v
				closest_dist = dist
			end
		end
		
		return closest
	end

	local function torightcol()
		local current = TheFrontEnd:GetFocusWidget()
		if not current then return self.controlwidgets[1].button end
		
		local pt = current:GetWorldPosition()
		local closest = nil
		local closest_dist = nil
		for k,v in pairs(self.controlwidgets) do
			local dist = v.button:GetWorldPosition():DistSq(pt)
			if not closest or dist < closest_dist then
				closest = v.button
				closest_dist = dist
			end
		end
		return closest
	end
	
	for k,v in pairs(targets) do
		v:SetFocusChangeDir(MOVE_RIGHT, torightcol)
	end

	for k,v in pairs(self.controlwidgets) do
		v.button:SetFocusChangeDir(MOVE_LEFT, toleftcol)
	end
	
end

function ControlsScreen:RefreshControls()
	
	local focus = self:GetDeepestFocus()
	local old_idx = focus and focus.idx

	local deviceId = self.devicespinner:GetSelectedData()
    --print("Current device is [" .. deviceId .. "]")

    local enabled = true
    if deviceId ~= 0 then
        enabled = TheInputProxy:IsInputDeviceEnabled(deviceId)
        self.enablespinner:Show()
        self.enablespinner:SetSelectedIndex( enabled and 2 or 1)
    else
        self.enablespinner:Hide()
    end


	for k,v in pairs(self.controlwidgets) do
		v.root:Kill()
	end
	self.controlwidgets = {}
	
	local control_list = self.devicespinner:GetSelectedData() == 0 and kbcontrols or controllercontrols
	
	local last_button = nil
	for k = 1, controls_per_screen do
	
		local idx = self.control_offset+k		
		
		if control_list[idx] then
			local controlId = control_list[idx]
			local group = self.controlspanel:AddChild(Widget("control"))
			group:SetScale(0.75,0.75,0.75)
			
			local bg = group:AddChild(Image("images/ui.xml", "nondefault_customization.tex"))
			bg:SetPosition(180,0,0)
			bg:SetScale(2.5, 0.95, 1)
			local hasChanged = TheInputProxy:HasMappingChanged(deviceId, controlId)
			if hasChanged then
			    bg:Show()
			else
			    bg:Hide()
			end
			
			local button = group:AddChild(ImageButton("images/ui.xml", "button_long.tex", "button_long_over.tex", "button_long_disabled.tex"))
	        button:SetText(STRINGS.UI.CONTROLSSCREEN.CONTROLS[controlId+1])
	        button.text:SetColour(0,0,0,1)
	        button:SetFont(BUTTONFONT)
	        button:SetTextSize(30)  
			button:SetPosition(-25,0,0)
			button.idx = k
			--button:SetScale(1.25, 1, 1)
	        button:SetOnClick( 
	            function() 
	                self:MapControl(deviceId, controlId)
	            end 
	        )
            if enabled then
                button:Enable()
            else
                button:Disable()
            end
            
            if last_button then
				button:SetFocusChangeDir(MOVE_UP, last_button)
				last_button:SetFocusChangeDir(MOVE_DOWN, button)
            end
            
            last_button = button
            
	        
            local text = group:AddChild(Text(UIFONT, 40))
            text:SetString(TheInput:GetLocalizedControl(deviceId, controlId))
            text:SetHAlign(ANCHOR_LEFT)
	        text:SetRegionSize( 500, 50 )
			text:SetPosition(325,0,0)
	        text:SetClickable(false)
	        group.text = text
	    
			local spacing = 50
			
			if k <= controls_per_screen then
				group:SetPosition(-150, (controls_per_screen-1)*spacing*.5 - (k-1)*spacing - 10, 0)
			else
				group:SetPosition(150, (controls_per_screen-1)*spacing*.5 - (k-1-controls_per_screen)*spacing- 10, 0)
			end
			
			table.insert(self.controlwidgets, {root = group, bg = bg, id=controlId, button = button})
	    
		end
	end	
	self:RefreshNav()

	if old_idx then
		self.controlwidgets[math.min(#self.controlwidgets, old_idx)].button:SetFocus()
	end
end

function ControlsScreen:Scroll(dir)

	local controls = self.devicespinner:GetSelectedData() == 0 and kbcontrols or controllercontrols

	if (dir > 0 and (self.control_offset + controls_per_screen) < #controls) or
		(dir < 0 and self.control_offset + dir >= 0) then
	
		self.control_offset = self.control_offset + dir
	end
	
	if self.control_offset > 0 then
		self.leftbutton:Show()
	else
		self.leftbutton:Hide()
	end
	
	if self.control_offset + controls_per_screen < #controls then
		self.rightbutton:Show()
	else
		self.rightbutton:Hide()
	end

	self:RefreshControls()
	
	
end

function ControlsScreen:LoadDefaultControls()
	TheInputProxy:LoadDefaultControlMapping()
	self:MakeDirty()
	self:RefreshControls()	
end

function ControlsScreen:LoadCurrentControls()
	TheInputProxy:LoadCurrentControlMapping()
	self:MakeClean()
    self:RefreshControls()	
end

function ControlsScreen:MapControl(deviceId, controlId)
    --print("Mapping control [" .. controlIndex .. "] on device [" .. deviceId .. "]")
    local controlIndex = controlId + 1      -- C++ control id is zero-based, we were passed a 1-based (lua) array index
    local loc_text = TheInput:GetLocalizedControl(deviceId, controlId, true)
    local default_text = string.format(STRINGS.UI.CONTROLSSCREEN.DEFAULT_CONTROL_TEXT, loc_text)
    local body_text = STRINGS.UI.CONTROLSSCREEN.CONTROL_SELECT .. "\n\n" .. default_text
    local popup = PopupDialogScreen(STRINGS.UI.CONTROLSSCREEN.CONTROLS[controlIndex], body_text, {})
    popup.text:SetFont(UIFONT)
    popup.text:SetRegionSize(480, 150)
    popup.text:SetPosition(0, -25, 0)
    popup.OnControl = function(_, control, down) self:MapControlInputHandler(control, down) end
	TheFrontEnd:PushScreen(popup)
	
    TheInputProxy:MapControl(deviceId, controlId)
    self.is_mapping = true
end

function ControlsScreen:OnControlMapped(deviceId, controlId, inputId, hasChanged)
    if self.is_mapping then 
        --print("Control [" .. controlId .. "] is now [" .. inputId .. "]")
        TheFrontEnd:PopScreen()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        for k, v in pairs(self.controlwidgets) do
            if controlId == v.id then
                if hasChanged then
                    v.root.text:SetString(TheInput:GetLocalizedControl(deviceId, controlId))
                    -- hasChanged only refers to the immediate change, but if a control is modified
                    -- and then modified again to the original we shouldn't highlight it 
                    local changedFromOriginal = TheInputProxy:HasMappingChanged(deviceId, controlId)    
                    if changedFromOriginal then
                        v.bg:Show()
                    else
                        v.bg:Hide()
                    end
                end
            end
        end
        
        -- set the dirty flag (if something changed) if it hasn't yet been set
        if not self:IsDirty() and hasChanged then
            self:MakeDirty()
        end
        
	    self.is_mapping = false
    end 
end

function ControlsScreen:MapControlInputHandler(control, down)
    --[[if not down and control == CONTROL_CANCEL then
        TheInputProxy:CancelMapping()
        self.is_mapping = false
        TheFrontEnd:PopScreen()
    end--]]

end

function ControlsScreen:Cancel()
    if not self.dirty then
	    TheFrontEnd:PopScreen()
	else
	    local popup = PopupDialogScreen(STRINGS.UI.CONTROLSSCREEN.LOSE_CHANGES_TITLE, STRINGS.UI.CONTROLSSCREEN.LOSE_CHANGES_BODY, 
			{{text=STRINGS.UI.CONTROLSSCREEN.YES, cb = function() self.dirty = false TheFrontEnd:PopScreen() self:Cancel() end},
			{text=STRINGS.UI.CONTROLSSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  })
		TheFrontEnd:PushScreen(popup)
	end
end

function ControlsScreen:Apply()
    TheInputProxy:ApplyControlMapping()
    for index = 1, #self.devices do
        
        local guid, data, enabled = TheInputProxy:SaveControls(self.devices[index].data)
        
        if not(nil == guid) and not(nil == data) then
            Profile:SetControls(guid, data, enabled)
        end
    end
    Profile:Save()
    self:MakeClean()
    self:RefreshControls()  -- get rid of highlights on modified controls
    self.cancelbutton:SetFocus()
end

function ControlsScreen:OnControl(control, down)
    
    if ControlsScreen._base.OnControl(self, control, down) then return true end
    
    if down then
    	if control == CONTROL_PAGERIGHT then
    		if self.rightbutton.shown then
    			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
    			self:Scroll(controls_per_scroll)
    		end
    		
    	elseif control == CONTROL_PAGELEFT then
    		if self.leftbutton.shown then
    			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
    			self:Scroll(-controls_per_scroll)
    		end
    	end
    end

    if not down and control == CONTROL_CANCEL then self:Cancel() return true end
end



function ControlsScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()

	if self.leftbutton.shown then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PAGELEFT) .. " " .. STRINGS.UI.HELP.SCROLLBACK)
	end
	if self.rightbutton.shown then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PAGERIGHT) .. " " .. STRINGS.UI.HELP.SCROLLFWD)
	end


	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	return table.concat(t, "  ")
end

return ControlsScreen