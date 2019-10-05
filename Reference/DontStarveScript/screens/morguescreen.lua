local Screen = require "widgets/screen"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"

local Text = require "widgets/text"
local Image = require "widgets/image"

local Widget = require "widgets/widget"
local Levels = require "map/levels"

require("constants")

local controls_per_screen = 8
local controls_per_scroll = 8

local column_offsets_x_pos = -RESOLUTION_X*0.18;
local column_offsets_y_pos = RESOLUTION_Y*0.23;

local column_offsets
if JapaneseOnPS4() then
     column_offsets ={ 
        DAYS_LIVED = -35,
        DECEASED = 100,
        CAUSE = 290,
        MODE = 500,
    }
else
    column_offsets ={ 
        DAYS_LIVED = 0,
        DECEASED = 120,
        CAUSE = 290,
        MODE = 460,
    }
end

local MorgueScreen = Class(Screen, function(self, in_game)
    Widget._ctor(self, "MorgueScreen")
    	
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
    self.scaleroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root = self.scaleroot:AddChild(Widget("root"))
    self.root:SetScale(.9)
    self.root:SetPosition(0,10,0)
    
    local left_col = -RESOLUTION_X*.05 - 60
    local right_col = RESOLUTION_X*.40 - 130
    
	
	--add the controls panel	
	
	self.control_offset = 0
    self.obits_panel = self.root:AddChild(Widget("obits_panel"))
    self.obits_panel:SetPosition(left_col,0,0)
    self.obits_panelbg = self.obits_panel:AddChild(Image("images/fepanels.xml", "panel_obituaries.tex"))
    if JapaneseOnPS4() then
        self.obits_panelbg:SetScale(1.15,1,1)
    end

    self.devicetitle = self.obits_panel:AddChild(Text(TITLEFONT, 55))
    self.devicetitle:SetHAlign(ANCHOR_MIDDLE)
    self.devicetitle:SetPosition(0, RESOLUTION_Y*0.30, 0)
    self.devicetitle:SetRegionSize( 400, 70 )
    self.devicetitle:SetString(STRINGS.UI.MORGUESCREEN.TITLE)

    local font_size = 35
    if JapaneseOnPS4() then
        font_size = 35 * 0.75;
    end
   
    self.obits_titles = self.obits_panel:AddChild(Widget("obits_titles"))
    self.obits_titles:SetPosition(column_offsets_x_pos, column_offsets_y_pos, 0)

    if JapaneseOnPS4() then
        self.DAYS_LIVED = self.obits_titles:AddChild(Text(TITLEFONT, font_size * 0.8))
    else
        self.DAYS_LIVED = self.obits_titles:AddChild(Text(TITLEFONT, font_size))
    end
    self.DAYS_LIVED:SetHAlign(ANCHOR_MIDDLE)
    self.DAYS_LIVED:SetPosition(column_offsets.DAYS_LIVED, 0, 0)
    self.DAYS_LIVED:SetRegionSize( 400, 70 )
    self.DAYS_LIVED:SetString(STRINGS.UI.MORGUESCREEN.DAYS_LIVED)
    self.DAYS_LIVED:SetColour(177.0/255.0,154/255.0,120/255.0, 1)

    self.DECEASED = self.obits_titles:AddChild(Text(TITLEFONT, font_size))
    self.DECEASED:SetHAlign(ANCHOR_MIDDLE)
    self.DECEASED:SetPosition(column_offsets.DECEASED, 0, 0)
    self.DECEASED:SetRegionSize( 400, 70 )
    self.DECEASED:SetString(STRINGS.UI.MORGUESCREEN.DECEASED)
    self.DECEASED:SetColour(177/255.0,154/255.0,120/255.0, 1)

    self.CAUSE = self.obits_titles:AddChild(Text(TITLEFONT, font_size))
    self.CAUSE:SetHAlign(ANCHOR_MIDDLE)
    self.CAUSE:SetPosition(column_offsets.CAUSE, 0, 0)
    self.CAUSE:SetRegionSize( 400, 70 )
    self.CAUSE:SetString(STRINGS.UI.MORGUESCREEN.CAUSE)
    self.CAUSE:SetColour(177/255.0,154/255.0,120/255.0, 1)

    self.MODE = self.obits_titles:AddChild(Text(TITLEFONT, font_size))
    self.MODE:SetHAlign(ANCHOR_MIDDLE)
    self.MODE:SetPosition(column_offsets.MODE, 0, 0)
    self.MODE:SetRegionSize( 400, 70 )
    self.MODE:SetString(STRINGS.UI.MORGUESCREEN.MODE)
    self.MODE:SetColour(177/255.0,154/255.0,120/255.0, 1)

    self.obits_rows = self.obits_panel:AddChild(Widget("obits_rows"))
    self.obits_rows:SetPosition(column_offsets_x_pos, -RESOLUTION_Y*0.075, 0)
    -- self.obits_rows:SetVAlign(ANCHOR_MIDDLE)


 	self.list_widgets = {}
    self.control_offset = 0
    self.mogue = Morgue:GetRows()
    self:RefreshControls()

    if not Input:ControllerAttached() then

        self.OK_button = self.root:AddChild(ImageButton())
        self.OK_button:SetPosition(right_col, -250, 0)
        self.OK_button:SetText(STRINGS.UI.MORGUESCREEN.OK)
        self.OK_button.text:SetColour(0,0,0,1)
        self.OK_button:SetOnClick( function() self:OK() end )
        self.OK_button:SetFont(BUTTONFONT)
        self.OK_button:SetTextSize(40)
    end


    self.down_button = self.obits_panel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    if JapaneseOnPS4() then
        self.down_button:SetPosition(360 * 1.15, 0, 0)
    else
        self.down_button:SetPosition(360, 0, 0)
    end
    --self.down_button:SetRotation(90)
    self.down_button:SetOnClick( function() self:Scroll(controls_per_scroll) end)
    
    self.up_button = self.obits_panel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    if JapaneseOnPS4() then
        self.up_button:SetPosition(-360 * 1.15,0, 0)
    else
        self.up_button:SetPosition(-360,0, 0)
    end
    self.up_button:SetScale(-1,1,1)
    --self.up_button:SetRotation(-90)
    self.up_button:SetOnClick( function() self:Scroll(-controls_per_scroll) end)    
    self.up_button:Hide()

    if self.control_offset + controls_per_screen < #self.mogue then
        self.down_button:Show()
    else
        self.down_button:Hide()
    end

end)

function MorgueScreen:OnBecomeActive()
    MorgueScreen._base.OnBecomeActive(self)
    --TheFrontEnd:GetSound():KillSound("FEMusic")    
end

function MorgueScreen:OnBecomeInactive()
    MorgueScreen._base.OnBecomeInactive(self)
    --TheFrontEnd:GetSound():PlaySound("dontstarve/music/music_FE","FEMusic")
end

function MorgueScreen:OnDestroy()
	self._base.OnDestroy(self)
end
local function tchelper(first, rest)
  return first:upper()..rest:lower()
end

function MorgueScreen:RefreshControls()
    
	for k,v in pairs(self.list_widgets) do
		v.root:Kill()
	end
	self.list_widgets = {}

    -- killed_by
    -- days_survived
    -- character
    -- location
    -- world    

    local font_size = 35
    if JapaneseOnPS4() then
   	 font_size = 35 * 0.75
    end
    local portrate_scale = 0.45
    local spacing = 52
            
	for k = 1, controls_per_screen do
	
		local idx = self.control_offset+k		
		
		if self.mogue[idx] then
			local death = self.mogue[idx]
			local group = self.obits_rows:AddChild(Widget("control"))

            local DAYS_LIVED = group:AddChild(Text(TITLEFONT, font_size))
            DAYS_LIVED:SetHAlign(ANCHOR_MIDDLE)
            DAYS_LIVED:SetPosition(column_offsets.DAYS_LIVED, 0, 0)
            DAYS_LIVED:SetRegionSize( 400, 70 )
            DAYS_LIVED:SetString(death["days_survived"] or "?")

            local DECEASED = group:AddChild(Widget("DECEASED"))
            DECEASED:SetPosition(column_offsets.DECEASED, 0, 0)

            DECEASED.portraitbg = DECEASED:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
            DECEASED.portraitbg:SetScale(portrate_scale, portrate_scale, 1)
            DECEASED.portraitbg:SetClickable(false)   
            DECEASED.base = DECEASED:AddChild(Widget("base"))
            
            DECEASED.portrait = DECEASED.base:AddChild(Image())
            DECEASED.portrait:SetClickable(false) 

            local character = death["character"]:lower()
            if character == "maxwell" then
                character = "waxwell"
            end

            local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
            if not table.contains(GetActiveCharacterList(), character) then
                character = "random" -- Use a question mark if the character isn't currently active
            end
            DECEASED.portrait:SetTexture(atlas, character..".tex")
            DECEASED.portrait:SetScale(portrate_scale, portrate_scale, 1)
 
            local CAUSE = group:AddChild(Text(TITLEFONT, font_size))
            CAUSE:SetHAlign(ANCHOR_MIDDLE)
            CAUSE:SetPosition(column_offsets.CAUSE, 0, 0)
            CAUSE:SetRegionSize( 400, 70 )
            local killed_by = death["killed_by"]:lower()
            if killed_by == "nil" then
                if character == "waxwell" then
                    killed_by = "charlie"
                else
                    killed_by = "darkness"
                end
            elseif killed_by == "unknown" then
                killed_by = "shenanigans"
            elseif killed_by == "moose" then
                if math.random() < .5 then
                    killed_by = "moose1"
                else
                    killed_by = "moose2"
                end
            end
            print("killed_by",killed_by)
            killed_by = STRINGS.NAMES[string.upper(killed_by)] or STRINGS.NAMES.SHENANIGANS
            CAUSE:SetString(killed_by:gsub("(%a)([%w_']*)", tchelper))

            local MODE = group:AddChild(Text(TITLEFONT, font_size))
            MODE:SetHAlign(ANCHOR_MIDDLE)
            MODE:SetPosition(column_offsets.MODE, 0, 0)
            MODE:SetRegionSize( 400, 70 )
            MODE:SetString(STRINGS.UI.MORGUESCREEN.LEVELTYPE[Levels.GetTypeForLevelID(death["world"])])
	    
			if k <= controls_per_screen then
				group:SetPosition(0, (controls_per_screen-1)*spacing*.5 - (k-1)*spacing - 10, 0)
			else
				group:SetPosition(0, (controls_per_screen-1)*spacing*.5 - (k-1-controls_per_screen)*spacing- 10, 0)
			end

            table.insert(self.list_widgets, {root = group, id=idx})	    
		end
	end	
end

function MorgueScreen:Scroll(dir)
	if (dir > 0 and (self.control_offset + controls_per_screen) < #self.mogue) or
		(dir < 0 and self.control_offset + dir >= 0) then
	
		self.control_offset = self.control_offset + dir
		self:RefreshControls()
	end

	if self.control_offset > 0 then
		self.up_button:Show()
	else
		self.up_button:Hide()
	end
	
    if self.control_offset + controls_per_screen < #self.mogue then
		self.down_button:Show()
	else
		self.down_button:Hide()
	end
end

function MorgueScreen:OnControl(control, down)
    if MorgueScreen._base.OnControl(self, control, down) then return true end
    if not down then
        if control == CONTROL_CANCEL then 
            TheFrontEnd:PopScreen()
        elseif control == CONTROL_PAGELEFT then
            if self.up_button.shown then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                self:Scroll(-controls_per_scroll)
            end
        elseif control == CONTROL_PAGERIGHT then
            if self.down_button.shown then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                self:Scroll(controls_per_scroll)
            end
        else
            return false
        end

        return true
    end
end


function MorgueScreen:OK()
    TheFrontEnd:PopScreen()
end


function MorgueScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    if self.control_offset > 0 then
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_PAGELEFT) .. " " .. STRINGS.UI.HELP.SCROLLBACK)
    end

    if self.control_offset + controls_per_screen < #self.mogue then
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_PAGERIGHT) .. " " .. STRINGS.UI.HELP.SCROLLFWD)
    end

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    return table.concat(t, "  ")
end



return MorgueScreen