local Screen = require "widgets/screen"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Progression = require "progressionconstants"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Menu = require "widgets/menu"



local function ShowLoading()
	if global_loading_widget then 
		global_loading_widget:SetEnabled(true)
	end
end

local DeathScreen = Class(Screen, function(self, days_survived, start_xp, escaped, capped)

    Widget._ctor(self, "Progress")
    self.owner = GetPlayer()
	self.log = true

    TheInputProxy:SetCursorVisible(true)

    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0,0,0,.75)

    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)


    if capped then
        self:Capped(days_survived, start_xp, escaped)
    else
        self:NotCapped(days_survived, start_xp, escaped)
    end
end)

function DeathScreen:NotCapped(days_survived, start_xp, escaped)
    local font = BUTTONFONT
    
    self.bg = self.root:AddChild(Image("images/globalpanels.xml", "panel_upsell_small.tex"))
    self.progbar = self.root:AddChild(UIAnim())
    
    self.progbar:GetAnimState():SetBank("progressbar") --XP Bar
    self.progbar:GetAnimState():SetBuild("progressbar")
    self.progbar:GetAnimState():PlayAnimation("anim", true)
    self.progbar:GetAnimState():SetPercent("anim", 0)
    self.progbar:SetPosition(Vector3(-220, 5,0))
    self.progbar:SetScale(.65,.7,.7)
    
    self.title = self.root:AddChild(Text(TITLEFONT, 60))
    self.title:SetPosition(0,140,0)
    if escaped == nil then
        self.title:SetString(STRINGS.UI.DEATHSCREEN.YOUAREDEAD)     
    else   
        self.title:SetString(STRINGS.UI.DEATHSCREEN.YOUESCAPED)
    end
    if JapaneseOnPS4() then
        -- not "You survived" X "days"
        -- but X "day" "survived"
        self.survivedtext = self.root:AddChild(Text(font, 40)) -- Day Count
        self.survivedtext:SetPosition(-160,55,0)

        self.t2 = self.root:AddChild(Text(font, 40))
        self.t2:SetPosition(-80,55,0)
        self.t2:SetString(STRINGS.UI.DEATHSCREEN.DAYS) --"Days"

        self.t1 = self.root:AddChild(Text(font, 40))
        self.t1:SetPosition(0,55,0)
        self.t1:SetString(STRINGS.UI.DEATHSCREEN.SURVIVEDDAYS) --"You survived..."
    else    
        self.t1 = self.root:AddChild(Text(font, 40))
        self.t1:SetPosition(-160,55,0)
        self.t1:SetString(STRINGS.UI.DEATHSCREEN.SURVIVEDDAYS) --"You survived..."

        self.survivedtext = self.root:AddChild(Text(font, 40)) -- Day Count
        self.survivedtext:SetPosition(-50,55,0)

        self.t2 = self.root:AddChild(Text(font, 40))
        self.t2:SetPosition(30,55,0)
        self.t2:SetString(STRINGS.UI.DEATHSCREEN.DAYS) --"Days"
    end

    self.leveltext = self.root:AddChild(Text(font, 35)) --Level #: 
    self.leveltext:SetHAlign(ANCHOR_LEFT)
    self.leveltext:SetPosition(-180,3,0)

    self.xptext = self.root:AddChild(Text(font, 35)) --XP: ####
    self.xptext:SetHAlign(ANCHOR_LEFT)
    self.xptext:SetPosition(-180,-45,0)
    
    self.rewardtext = self.root:AddChild(Text(font, 35)) --"Next Reward..."
    self.rewardtext:SetString(STRINGS.UI.DEATHSCREEN.NEXTREWARD)
    self.rewardtext:SetHAlign(ANCHOR_LEFT)
    self.rewardtext:SetPosition(5,-45,0)

    local menu_items = 
    {
        {text = STRINGS.UI.DEATHSCREEN.MAINMENU, cb = function() self:OnMenu(escaped) end}
    }

    if escaped then
        table.insert(menu_items,  {text = STRINGS.UI.DEATHSCREEN.CONTINUE, cb = function() self:OnContinue() end})
    else
        table.insert(menu_items,  {text = STRINGS.UI.DEATHSCREEN.RETRY, cb = function() self:OnRetry() end})
    end

    self.menu = self.root:AddChild(Menu(menu_items, 180, true))
    self.menu:SetPosition(-((#menu_items-1)*135)/2, -140, 0)
    self.menu:SetScale(.75,.75,.75)

    local portrait_pos = {x = 155, y = -60}
    local portrait_scale = 1.25
    self.portrait_background = self.root:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
    self.portrait_background:SetPosition(Vector3(portrait_pos.x, portrait_pos.y, 0))
    self.portrait_background:SetScale(portrait_scale,portrait_scale,portrait_scale)
    self.portrait_background:SetVRegPoint(ANCHOR_BOTTOM)

    self.portrait = self.root:AddChild(Image("images/saveslot_portraits.xml", "wilson.tex"))
    self.portrait:SetPosition(Vector3(portrait_pos.x , portrait_pos.y - 1, 0))
    self.portrait:SetScale(portrait_scale,portrait_scale,portrait_scale)
    self.portrait:SetTint(0,0,0,1)
    self.portrait:SetVRegPoint(ANCHOR_BOTTOM)
    self:ShowButtons(false)    
    
    self:ShowResults(days_survived, start_xp)
    self.default_focus = self.menu
end

function DeathScreen:Capped(days_survived, start_xp, escaped)
    local font = BUTTONFONT
    
    self.bg = self.root:AddChild(Image("images/globalpanels.xml", "small_dialog.tex"))
    self.bg:SetScale(1.25, 1.3, 1)
    self.title = self.root:AddChild(Text(TITLEFONT, 60))
    self.title:SetPosition(0,70,0)
    if escaped == nil then
        self.title:SetString(STRINGS.UI.DEATHSCREEN.YOUAREDEAD)     
    else   
        self.title:SetString(STRINGS.UI.DEATHSCREEN.YOUESCAPED)
    end

    local line_y = 0

    if JapaneseOnPS4() then
        -- not "You survived" X "days"
        -- but X "day" "survived"
        self.survivedtext = self.root:AddChild(Text(font, 40)) -- Day Count
        self.survivedtext:SetPosition(-160+60,line_y,0)

        self.t2 = self.root:AddChild(Text(font, 40))
        self.t2:SetPosition(-80+60,line_y,0)
        self.t2:SetString(STRINGS.UI.DEATHSCREEN.DAYS) --"Days"

        self.t1 = self.root:AddChild(Text(font, 40))
        self.t1:SetPosition(0+60,line_y,0)
        self.t1:SetString(STRINGS.UI.DEATHSCREEN.SURVIVEDDAYS) --"You survived..."
    else    
        self.t1 = self.root:AddChild(Text(font, 40))
        self.t1:SetPosition(-70,line_y,0)
        self.t1:SetString(STRINGS.UI.DEATHSCREEN.SURVIVEDDAYS) --"You survived..."

        self.survivedtext = self.root:AddChild(Text(font, 40)) -- Day Count
        self.survivedtext:SetPosition(30,line_y,0)

        self.t2 = self.root:AddChild(Text(font, 40))
        self.t2:SetPosition(90,line_y,0)
        self.t2:SetString(STRINGS.UI.DEATHSCREEN.DAYS) --"Days"
    end


    local menu_items = 
    {
        {text = STRINGS.UI.DEATHSCREEN.MAINMENU, cb = function() self:OnMenu(escaped) end}
    }

    if escaped then
        table.insert(menu_items,  {text = STRINGS.UI.DEATHSCREEN.CONTINUE, cb = function() self:OnContinue() end})
    else
        table.insert(menu_items,  {text = STRINGS.UI.DEATHSCREEN.RETRY, cb = function() self:OnRetry() end})
    end

    self.menu = self.root:AddChild(Menu(menu_items, 180, true))
    self.menu:SetPosition(-((#menu_items-1)*135)/2, -60, 0)
    self.menu:SetScale(.75,.75,.75)
   
    self:ShowResults(days_survived, start_xp)
    self.default_focus = self.menu
end

local function DoReload(slot)
    StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = slot or SaveGameIndex:GetCurrentSaveSlot()})
end

function DeathScreen:OnRetry()
    local function OnProfileSaved()
        self.menu:Disable()
        local slot = SaveGameIndex:GetCurrentSaveSlot()
        SaveGameIndex:DeleteSlot(slot, function() 
                   TheFrontEnd:Fade(false, 2, function () 
                        DoReload() 
                    end )
                end, true)
    end
    
    -- Record the start of a new game
    local starts = Profile:GetValue("starts") or 0
    Profile:SetValue("starts", starts+1)
    Profile:Save(OnProfileSaved)        
end

function DeathScreen:OnContinue()
    self.menu:Disable()
    TheFrontEnd:Fade(false, 2, DoReload)
end

function DeathScreen:OnMenu(escaped)
	
    self.menu:Disable()
    TheFrontEnd:Fade(false, 2, function()
        if escaped then
            StartNextInstance()
        else
            ShowLoading()
            EnableAllDLC()
            SaveGameIndex:DeleteSlot(SaveGameIndex:GetCurrentSaveSlot(), function() 
                StartNextInstance()
            end)
        end
    end)
end

function DeathScreen:ShowButtons(show)
    if show then
        self.menu:Show()
        --self.menu:SetFocus()
    else
		--self.menu:Hide()
    end
end

function DeathScreen:SetStatus(xp, ignore_image)
    local level, percent = Progression.GetLevelForXP(xp)

    if not ignore_image and self.portrait then
        self.portrait:SetTint(0,0,0,1)
        local reward = Progression.GetRewardForLevel(level)
        if reward then
            self.portrait:Show()

			--print("images/saveslot_portraits/"..reward..".tex")
            self.portrait:SetTexture("images/saveslot_portraits.xml", reward..".tex")
        else
            self.portrait:Hide()
        end
    end
    if self.leveltext then    
        self.leveltext:SetString(STRINGS.UI.DEATHSCREEN.LEVEL.." "..tostring(level+1))
    end
    if self.progbar then
        self.progbar:GetAnimState():SetPercent("anim", percent)
    end
    if self.xptext then
	   self.xptext:SetString(string.format("XP: %d", xp))
    end
    if xp >= Progression.GetXPCap() and self.rewardtext then
		self.rewardtext:SetString(STRINGS.UI.DEATHSCREEN.ATCAP)
	end
	
end

function DeathScreen:ShowResults(days_survived, start_xp)
    
    self:Show()
    local xpreward = Progression.GetXPForDays(days_survived)
    local xpcap = Progression.GetXPCap()
    if start_xp + xpreward > xpcap then
		xpreward = xpcap - start_xp
    end
    
    
    if self.thread then
        KillThread(self.thread)
    end
        self:SetStatus(start_xp)
        
        self.thread = self.inst:StartThread( function() 
        self:ShowButtons(false)
        local end_xp = start_xp + xpreward
        self.survivedtext:SetString(tostring(days_survived))
        
        if days_survived == 1 then
			self.t2:SetString(STRINGS.UI.DEATHSCREEN.DAY)
		end
		
        local start_level, start_percent = Progression.GetLevelForXP(start_xp)
        local end_level, end_percent = Progression.GetLevelForXP(end_xp)
        
        local fills = end_level - start_level + 1
        local dt = GetTickTime()
        
        local xplevel = start_level 
        local short = fills > 1
        local total_fill_time = short and 2 or 5
        
        local fill_rate = 1/total_fill_time
        --print (start_level, start_percent, "TO", end_level, end_percent, "->", fills)
        
        for k = 1, fills do
            
            local xp_for_level, level_xp_size = Progression.GetXPForLevel(xplevel)
            if xp_for_level then
                local end_p = k == fills and end_percent or 1
                local p = k == 1 and start_percent or 0
                if end_p > p then
                    
                    --print (k, xplevel, xp_for_level, level_xp_size, p, end_p, total_fill_time)
                    
                    if short then
                        self.owner.SoundEmitter:PlaySound("dontstarve/HUD/XP_bar_fill_fast", "fillsound")
                    else
                        self.owner.SoundEmitter:PlaySound("dontstarve/HUD/XP_bar_fill_slow", "fillsound")
                    end
                    
                    repeat
                        p = p + dt*fill_rate
                        local xp = xp_for_level + math.min(end_p,p)*level_xp_size
                        self:SetStatus(xp, p >= 1)
                        if self.progbar then
                            self.progbar:GetAnimState():SetPercent("anim", p)
                        end
                        Yield()
                    until p >= end_p
                    self.owner.SoundEmitter:KillSound("fillsound")
                    if end_p >= 1 then
                        self.owner.SoundEmitter:PlaySound("dontstarve/HUD/XP_bar_fill_unlock")
                        if self.progbar then
                            self.progbar:GetAnimState():SetPercent("anim", 1)
                        end
                        if self.portrait then
                            self.portrait:SetTint(1,1,1,1)
                            self.portrait:ScaleTo((1.25 * 1.5), 1.25, .25)
                        end
                        Sleep(1)
                    end
                end
            end
            xplevel = xplevel + 1
        end
        
        
        self:ShowButtons(true)
        self.thread = nil
    end )
    
    return xpreward
end

return DeathScreen
