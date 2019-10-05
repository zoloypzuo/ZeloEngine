local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"

local MIN_GEN_TIME = 9.5

local WorldGenScreen = Class(Screen, function(self, profile, cb, world_gen_options)
	Screen._ctor(self, "WorldGenScreen")
    self.profile = profile
	self.log = true

	self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
    self.bg:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 1)

    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)

    self.center_root = self:AddChild(Widget("root"))
    self.center_root:SetVAnchor(ANCHOR_MIDDLE)
    self.center_root:SetHAnchor(ANCHOR_MIDDLE)
    self.center_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.bottom_root = self:AddChild(Widget("root"))
    self.bottom_root:SetVAnchor(ANCHOR_BOTTOM)
    self.bottom_root:SetHAnchor(ANCHOR_MIDDLE)
    self.bottom_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
    self.worldanim = self.bottom_root:AddChild(UIAnim())
    
	local hand_scale = 1.5
    self.hand1 = self.bottom_root:AddChild(UIAnim())
    self.hand1:GetAnimState():SetBuild("creepy_hands")
    self.hand1:GetAnimState():SetBank("creepy_hands")
    self.hand1:GetAnimState():SetTime(math.random()*2)
    self.hand1:GetAnimState():PlayAnimation("idle", true)
    self.hand1:SetPosition(400, 0, 0)
    self.hand1:SetScale(hand_scale,hand_scale,hand_scale)

    self.hand2 = self.bottom_root:AddChild(UIAnim())
    self.hand2:GetAnimState():SetBuild("creepy_hands")
    self.hand2:GetAnimState():SetBank("creepy_hands")
    self.hand2:GetAnimState():PlayAnimation("idle", true)
    self.hand2:GetAnimState():SetTime(math.random()*2)
    self.hand2:SetPosition(-425, 0, 0)
	self.hand2:SetScale(-hand_scale,hand_scale,hand_scale)
    
    self.worldgentext = self.center_root:AddChild(Text(TITLEFONT, 100))
    self.worldgentext:SetPosition(0, 200, 0)
    
    
    if world_gen_options.level_type == "cave" then
	    self.bg:SetTint(BGCOLOURS.PURPLE[1],BGCOLOURS.PURPLE[2],BGCOLOURS.PURPLE[3], 1)
		self.worldanim:GetAnimState():SetBuild("generating_cave")
		self.worldanim:GetAnimState():SetBank("generating_cave")
	    self.worldgentext:SetString(STRINGS.UI.WORLDGEN.CAVETITLE)
	else
		if IsDLCEnabled(REIGN_OF_GIANTS) then
			self.bg:SetTint(BGCOLOURS.PURPLE[1],BGCOLOURS.PURPLE[2],BGCOLOURS.PURPLE[3], 1)
		end

		self.worldanim:GetAnimState():SetBuild("generating_world")
		self.worldanim:GetAnimState():SetBank("generating_world")
	    self.worldgentext:SetString(STRINGS.UI.WORLDGEN.TITLE)
	end
	
    self.worldanim:GetAnimState():PlayAnimation("idle", true)

    self.flavourtext= self.center_root:AddChild(Text(UIFONT, 40))
    self.flavourtext:SetPosition(0, 100, 0)

	Settings.save_slot = Settings.save_slot or 1
	local gen_parameters = {}
	
	gen_parameters.level_type = world_gen_options.level_type
	if gen_parameters.level_type == nil then
		gen_parameters.level_type = "free"
	end
		
	gen_parameters.world_gen_choices = world_gen_options.custom_options
	if gen_parameters.world_gen_choices == nil then
		gen_parameters.world_gen_choices = {
			 		monsters = "default", animals = "default", resources = "default",
	    			unprepared = "default", 
	    			--prepared = "default", day = "default"
    			}
	end
	
	gen_parameters.current_level = world_gen_options.level_world

	if gen_parameters.level_type == "adventure" then
		if gen_parameters.current_level == nil or gen_parameters.current_level < 1 then
			gen_parameters.current_level = 1
		end

		gen_parameters.adventure_progress = world_gen_options.adventure_progress or 1
	end

	gen_parameters.profiledata = world_gen_options.profiledata
	if gen_parameters.profiledata == nil then
		gen_parameters.profiledata = { unlocked_characters = {} }
	end
	
	local DLCEnabledTable = {}
	for i,v in pairs(DLC_LIST) do
		DLCEnabledTable[i] = IsDLCEnabled( i )
	end
	gen_parameters.DLCEnabled = DLCEnabledTable

	local moddata = {}
	moddata.index = KnownModIndex:CacheSaveData()

	self.genparam = json.encode(gen_parameters)
	self.modparam = json.encode(moddata)

    TheSim:GenerateNewWorld( self.genparam, self.modparam, function(worlddata) 
    		self.worlddata = worlddata
			self.done = true
		end)
		
	self.total_time = 0
	self.cb = cb
    TheFrontEnd:DoFadeIn(2)
    
    
	self.verbs = shuffleArray(STRINGS.UI.WORLDGEN.VERBS)
	self.nouns = shuffleArray(STRINGS.UI.WORLDGEN.NOUNS.BASE_GAME)
	
    self.verbidx = 1
    self.nounidx = 1
    self:ChangeFlavourText()
    
    if world_gen_options.level_type == "cave" then
    	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/caveGen", "worldgensound")    
	else
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/worldGen", "worldgensound")    
	end
end)

function WorldGenScreen:OnLoseFocus()
	Screen.OnLoseFocus(self)
	TheFrontEnd:GetSound():KillSound("worldgensound")    
end

function WorldGenScreen:OnUpdate(dt)
	self.total_time = self.total_time + dt
	if self.done then
		if self.worlddata == "" then
			print ("RESTARTING GENERATION")
			self.done = false
			self.worldata = nil
			TheSim:GenerateNewWorld( self.genparam, self.modparam, function(worlddata) 
    				self.worlddata = worlddata
					self.done = true
				end)
			return
		end
		
		if string.match(self.worlddata,"^error") then
			self.done = false
			self.cb(self.worlddata)
		elseif self.total_time > MIN_GEN_TIME and self.cb then
			self.done = false
			
			TheFrontEnd:Fade(false, 1, function() 
				self.cb(self.worlddata)
				end)
		end
	end
end

function WorldGenScreen:ChangeFlavourText()

	
	self.flavourtext:SetString(self.verbs[self.verbidx] .. " " .. self.nouns[self.nounidx])

	self.verbidx = (self.verbidx == #self.verbs) and 1 or (self.verbidx + 1)
	self.nounidx = (self.nounidx == #self.nouns) and 1 or (self.nounidx + 1)

	local time = GetRandomWithVariance(2, 1)
	self.inst:DoTaskInTime(time, function() self:ChangeFlavourText() end)
end

return WorldGenScreen