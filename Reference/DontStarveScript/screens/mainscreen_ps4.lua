local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
require "os"

local PopupDialogScreen = require "screens/popupdialog"
local LoadGameScreen = require "screens/loadgamescreen"
local CreditsScreen = require "screens/creditsscreen"
local BigPopupDialogScreen = require "screens/bigpopupdialog"
local MovieDialog = require "screens/moviedialog"

local ControlsScreen = require "screens/controlsscreen_ps4"
local OptionsScreen = require "screens/optionsscreen_ps4"

local RoGUpgrade = require "widgets/rogupgrade"

local rcol = RESOLUTION_X/2 -200
local lcol = -RESOLUTION_X/2 +200
local bottom_offset = 60

local MainScreen = Class(Screen, function(self, profile)
    Screen._ctor(self, "MainScreen")
    self.profile = profile
    self.log = true
    self:DoInit() 
    self.default_focus = self.menu
    self.music_playing = false
end)


function MainScreen:DoInit( )
    STATS_ENABLE = false
    TheFrontEnd:GetGraphicsOptions():DisableStencil()
    TheFrontEnd:GetGraphicsOptions():DisableLightMapComponent()
    
    TheInputProxy:SetCursorVisible(true)

    if IsDLCInstalled(REIGN_OF_GIANTS) then
        self.bg = self:AddChild(Image("images/ps4_dlc0001.xml", "ps4_mainmenu.tex"))
    else
        self.bg = self:AddChild(Image("images/ps4.xml", "ps4_mainmenu.tex"))
    end

    --self.bg:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 1)

    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    
    
    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.anim = self.fixed_root:AddChild(UIAnim())
    self.anim:GetAnimState():SetBuild("animated_title")
    self.anim:GetAnimState():SetBank("animated_title")
    self.anim:GetAnimState():PlayAnimation("anim", true)
    --self.anim:SetScale(2)
    self.anim:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.anim:SetVAnchor(ANCHOR_MIDDLE)
    self.anim:SetHAnchor(ANCHOR_MIDDLE)
    self.anim:GetAnimState():OverrideSymbol("willow_title_fire", "title_fire", "willow_title_fire")
    self.anim:GetAnimState():OverrideSymbol("wilson_title_fire", "title_fire", "wilson_title_fire")
    
    --center stuff
    if IsDLCInstalled(REIGN_OF_GIANTS) then
        self.shield = self.fixed_root:AddChild(Image("images/ps4_dlc0001.xml", "ps4_mainmenu_title.tex"))
    else
        self.shield = self.fixed_root:AddChild(Image("images/ps4.xml", "ps4_mainmenu_title.tex"))
    end

    self.shield:SetVRegPoint(ANCHOR_MIDDLE)
    self.shield:SetHRegPoint(ANCHOR_MIDDLE)
    self.shield:SetPosition(0,30,0)
    self.shield:SetScale(1, 0.95)

    self.bannerroot = self.shield:AddChild(Widget("bann"))

    if JapaneseOnPS4() then
        self.bannerroot:SetPosition(0, -175, 0)
    else
        self.bannerroot:SetPosition(0, -165, 0)
    end

    self.banner = self.bannerroot:AddChild(Image("images/ui.xml", "update_banner.tex"))
    self.banner:SetVRegPoint(ANCHOR_MIDDLE)
    self.banner:SetHRegPoint(ANCHOR_MIDDLE)
    if JapaneseOnPS4() then
        self.banner:SetScale(0.9, 1.4 )
    else
        self.banner:SetScale(0.7, 1)
    end

    
    self.updatename = self.bannerroot:AddChild(Text(BUTTONFONT, 30*.8))
    if JapaneseOnPS4() then
        self.updatename:SetPosition(0,12,0)
        self.updatename:SetRegionSize(120,90)
        self.updatename:EnableWordWrap(true)
    else
        self.updatename:SetPosition(0,8,0)
    end

    self.updatename:SetString(STRINGS.UI.MAINSCREEN.CONSOLE_EDITION_TEXT)
    self.updatename:SetColour(0,0,0,1)

    --RIGHT COLUMN

    self.right_col = self.fixed_root:AddChild(Widget("right"))
    self.right_col:SetPosition(0, 0)

    self.menu = self.right_col:AddChild(Menu(nil, -70))
    if JapaneseOnPS4() then
        self.menu:SetPosition(0, -182, 0)
    else
        self.menu:SetPosition(0, -180, 0)
    end
    self.menu:SetScale(.8)

    if not IsDLCInstalled(REIGN_OF_GIANTS) then
        self.RoGUpgrade = self.fixed_root:AddChild(RoGUpgrade())
        self.RoGUpgrade:SetScale(.8)
        self.RoGUpgrade:SetPosition(-445, 205, 0)
    end


    self:MainMenu()
    self.menu:SetFocus()
end

function MainScreen:OnControl(control, down)
    -- don't do anything until we have space to save
    if not TheSystemService:IsStorageAvailable() then return end
    
    if MainScreen._base.OnControl(self, control, down) then return true end
    
    if not down and control == CONTROL_CANCEL then
        if not self.mainmenu then
            self:MainMenu()
            return true
        end
    end
end


-- SUBSCREENS

function MainScreen:Settings()
    TheFrontEnd:PushScreen(OptionsScreen(false))
end

function MainScreen:OnControlsButton()
    TheFrontEnd:PushScreen(ControlsScreen())
end

function MainScreen:Refresh()
    self:MainMenu()
    TheFrontEnd:GetSound():PlaySound("dontstarve/music/music_FE","FEMusic")
    if IsDLCInstalled(REIGN_OF_GIANTS) then
        if self.RoGUpgrade then self.RoGUpgrade:Hide() end
    else
        if self.RoGUpgrade then self.RoGUpgrade:Show() end
    end
end

function MainScreen:ShowMenu(menu_items)
    self.mainmenu = false
    self.menu:Clear()
    
    for k = #menu_items, 1, -1  do
        local v = menu_items[k]
        if v.widestring then
            local button = self.menu:AddItem(v.text, v.cb, nil, nil, .9)
            button.image:SetScale(1.3,1,1)
        else
            local button = self.menu:AddItem(v.text, v.cb)
            button.image:SetScale(1.3,1,1)
        end
    end

    self.menu:SetFocus()
end


function MainScreen:DoOptionsMenu()

    local menu_items = {}
    table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.CREDITS, cb= function() self:OnCreditsButton() end})
    table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.CONTROLS, cb= function() self:OnControlsButton() end})
    table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.SETTINGS, cb= function() self:Settings() end})
    --table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.CANCEL, cb= function() self:MainMenu() end})
    self:ShowMenu(menu_items)
end

function MainScreen:OnCreditsButton()
    TheFrontEnd:GetSound():KillSound("FEMusic")
    TheFrontEnd:PushScreen( CreditsScreen() )
end
    

function MainScreen:MainMenu()
    
    local menu_items = {}
    table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.OPTIONS, cb= function() self:DoOptionsMenu() end})
    table.insert(menu_items, {text=STRINGS.UI.MAINSCREEN.PLAY, cb= function() TheFrontEnd:PushScreen(LoadGameScreen())end})
    self:ShowMenu(menu_items)
    self.mainmenu = true
end

function MainScreen:OnBecomeActive()
    MainScreen._base.OnBecomeActive(self)
end

function MainScreen:CheckStorage()            
    if TheSystemService:IsStorageAvailable() then    
        local operation, status = TheSystemService:GetLastOperation()
        --print("MainScreen:Saveload result", operation, status)
        if operation ~= SAVELOAD.OPERATION.NONE and status ~= SAVELOAD.STATUS.OK then
            TheFrontEnd:OnSaveLoadError(operation, "", status)        
            return
        else        
            self:CheckDisplayArea()
        end        
    else
        TheSystemService:PrepareStorage(function(success) self:CheckStorage() end)
    end
end

function MainScreen:CheckDisplayArea()
    local isAdjusted = TheSystemService:IsDisplaySafeAreaAdjusted()
    local sawAdjustmentPopup = Profile:SawDisplayAdjustmentPopup()
    if (not isAdjusted and not sawAdjustmentPopup) then
    
        local function adjust()  
            TheSystemService:AdjustDisplaySafeArea()
            Profile:ShowedDisplayAdjustmentPopup()
            TheFrontEnd:PopScreen() -- pop after updating settings otherwise this dialog might show again!
            Profile:Save()
        end
        
        local function nothanks()   
            Profile:ShowedDisplayAdjustmentPopup()
            TheFrontEnd:PopScreen() -- pop after updating settings otherwise this dialog might show again!
            Profile:Save()
        end
        
        local popup = BigPopupDialogScreen(STRINGS.UI.MAINSCREEN.ADJUST_DISPLAY_HEADER, STRINGS.UI.MAINSCREEN.ADJUST_DISPLAY_TEXT,
            {
                {text=STRINGS.UI.MAINSCREEN.YES, cb = adjust},
                {text=STRINGS.UI.MAINSCREEN.NO, cb = nothanks}  
            }
        )
        TheFrontEnd:PushScreen(popup)    
    end
end


function MainScreen:OnUpdate(dt)
    if TheSim:ShouldPlayIntroMovie() then
     TheFrontEnd:PushScreen( MovieDialog("movies/forbidden_knowledge.mp4", function() TheFrontEnd:GetSound():PlaySound("dontstarve/music/music_FE","FEMusic") self:CheckStorage() end ) )
        self.music_playing = true
    elseif not self.music_playing then
        TheFrontEnd:GetSound():PlaySound("dontstarve/music/music_FE","FEMusic")
        self.music_playing = true
        
        self:CheckStorage()
    end      
end

function MainScreen:GetHelpText()
    if not self.mainmenu then
        local controller_id = TheInput:GetControllerID()
        return TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK
    else
        return ""
    end
end


return MainScreen
