local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"


local UIClock = Class(Widget, function(self)
    Widget._ctor(self, "Clock")
    --self:SetHAnchor(ANCHOR_RIGHT)
    --self:SetVAnchor(ANCHOR_TOP)

    self.DAY_COLOUR = Vector3(254/255,212/255,86/255)
    self.DUSK_COLOUR = Vector3(165/255,91/255,82/255)
    self.DARKEN_PERCENT = .75


    self.base_scale = 1
    
    self:SetScale(self.base_scale,self.base_scale,self.base_scale)
    self:SetPosition(0,0,0)

    self.moonanim = self:AddChild(UIAnim())
    --self.moonanim:SetScale(.4,.4,.4)
    self.moonanim:GetAnimState():SetBank("moon_phases_clock")
    self.moonanim:GetAnimState():SetBuild("moon_phases_clock")
    self.moonanim:GetAnimState():PlayAnimation("hidden")
    
    
    self.anim = self:AddChild(UIAnim())
    local sc = 1
    self.anim:SetScale(sc,sc,sc)
    self.anim:GetAnimState():SetBank("clock01")
    self.anim:GetAnimState():SetBuild("clock_transitions")
    self.anim:GetAnimState():PlayAnimation("idle_day",true)
    
    
    
    self.face = self:AddChild(Image("images/hud.xml", "clock_NIGHT.tex"))
    self.segs = {}
	local segscale = .4
    local numsegs = 16
    for i = 1, numsegs do
		local seg = self:AddChild(Image("images/hud.xml", "clock_wedge.tex"))
        seg:SetScale(segscale,segscale,segscale)
        seg:SetHRegPoint(ANCHOR_LEFT)
        seg:SetVRegPoint(ANCHOR_BOTTOM)
        seg:SetRotation((i-1)*(360/numsegs))
        seg:SetClickable(false)
        table.insert(self.segs, seg)
    end
    

    
    self.rim = self:AddChild(Image("images/hud.xml", "clock_rim.tex"))
    self.hands = self:AddChild(Image("images/hud.xml", "clock_hand.tex"))
    self.text = self:AddChild(Text(BODYTEXTFONT, 33/self.base_scale))
    self.text:SetPosition(5, 0/self.base_scale, 0)

    self.rim:SetClickable(false)
    self.hands:SetClickable(false)
    self.face:SetClickable(false)
    
    local ground = GetWorld()   
    self.world_num = SaveGameIndex:GetSlotWorld()
    
    self.inst:ListenForEvent( "clocktick", function(inst, data) 
    				self:SetTime(data.normalizedtime, data.phase) 
    			end, GetWorld())


	self:UpdateDayString()

    self.inst:ListenForEvent( "daycomplete", function() self:UpdateDayString() end, GetWorld())

	self.inst:ListenForEvent( "daytime", function(inst, data) 
        self.text:SetString(STRINGS.UI.HUD.CLOCKDAY.." "..tostring(data.day)+1) 
        self.anim:GetAnimState():PlayAnimation("trans_night_day") 
        self.anim:GetAnimState():PushAnimation("idle_day", true) 
        self.moonanim:GetAnimState():PlayAnimation("trans_in") 
        
    end, GetWorld())
	
	  
	self.inst:ListenForEvent( "nighttime", function(inst, data) 
		
        self.anim:GetAnimState():PlayAnimation("trans_dusk_night") 
        self.anim:GetAnimState():PushAnimation("idle_night", true) 
        self:ShowMoon()

    end, GetWorld())
    
	self.inst:ListenForEvent( "dusktime", function(inst, data) 
        self.anim:GetAnimState():PlayAnimation("trans_day_dusk")
    end, GetWorld())
    
	self.inst:ListenForEvent( "daysegschanged", function(inst, data) 
        self:RecalcSegs()
    end, GetWorld())
    
    
    self.old_t = 0 
    self:RecalcSegs()
    
    if GetClock():IsNight() then
		self:ShowMoon()
    end
end)

function UIClock:UpdateDayString()
    local clock_str = STRINGS.UI.HUD.CLOCKDAY.." "..tostring(GetClock().numcycles+1)
    self.text:SetString(clock_str)
end

function UIClock:OnGainFocus()
	UIClock._base.OnGainFocus(self)
	local clock_str = STRINGS.UI.HUD.WORLD.." ".. tostring(self.world_num or 1)
	self.text:SetString(clock_str)
	return true
end

function UIClock:OnLoseFocus()
	UIClock._base.OnLoseFocus(self)
	self:UpdateDayString()
	return true
end


function UIClock:ShowMoon()
    local mp = GetClock():GetMoonPhase()
    local moon_syms = 
    {
        full="moon_full",
        quarter="moon_quarter",
        new="moon_new",
        threequarter="moon_three_quarter",
        half="moon_half",
    }
    self.moonanim:GetAnimState():OverrideSymbol("swap_moon", "moon_phases", moon_syms[mp] or "moon_full")        
    self.moonanim:GetAnimState():PlayAnimation("trans_out") 
    self.moonanim:GetAnimState():PushAnimation("idle", true) 
end

function UIClock:RecalcSegs()
    
    local dark = true
    for k,seg in pairs(self.segs) do
        
        local color = nil
        
        local daysegs = GetClock():GetDaySegs()
        local dusksegs = GetClock():GetDuskSegs()
        
        if k > daysegs + dusksegs then
			seg:Hide()
		else
	        seg:Show()
			
			if k <= daysegs then
				color = self.DAY_COLOUR 
			else
				color = self.DUSK_COLOUR
			end
	        
			if dark then
				color = color * self.DARKEN_PERCENT
			end
			seg:SetTint(color.x, color.y, color.z, 1)
			dark = not dark
		end
    end
    
end


function UIClock:SetTime(t, phase)

    if phase == "day" then
        local segs = 16
        if math.floor(t * segs) > 0 and math.floor(t * segs) ~= math.floor(self.old_t * segs) then
            self.anim:GetAnimState():PlayAnimation("pulse_day") 
            self.anim:GetAnimState():PushAnimation("idle_day", true)            
        end
    end
    
    self.hands:SetRotation(t*360)
    
    
    self.old_t = t
end


return UIClock