local HAVE_SUBMIT_ERRORREPORT = ENABLE_BUG_REPORTER

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

local WorldGenScreen = require "screens/worldgenscreen"
local PopupDialogScreen = require "screens/popupdialog"
local PlayerHud = require "screens/playerhud"
local EmailSignupScreen = require "screens/emailsignupscreen"
local LoadGameScreen = require "screens/loadgamescreen"
local CreditsScreen = require "screens/creditsscreen"
local ModsScreen = require "screens/modsscreen"
local BigPopupDialogScreen = require "screens/bigpopupdialog"
local MovieDialog = require "screens/moviedialog"

local ControlsScreen = require "screens/controlsscreen"
local OptionsScreen = require "screens/optionsscreen"
local BroadcastingOptionsScreen = require "screens/broadcastingoptionsscreen"

local DLCUpgrade = require "widgets/dlcupgrade"

local BetaRegistration = require "widgets/betaregistration"
local BugReportScreen = require "screens/bugreportscreen"
local LanguageScreen = require "screens/languagescreen"

local rcol = RESOLUTION_X / 2 - 200
local lcol = -RESOLUTION_X / 2 + 200

local bottom_offset = 60

local MainScreen = Class(Screen, function(self, profile)
    Screen._ctor(self, "MainScreen")
    self.profile = profile
    self.log = true
    self:AddEventHandler("onsetplayerid", function(...)
        self:OnSetPlayerID(...)
    end)
    self:DoInit()
    self.menu.reverse = true
    self.default_focus = self.menu
    self.music_playing = false
end)

function MainScreen:DoInit()
    STATS_ENABLE = true
    TheFrontEnd:GetGraphicsOptions():DisableStencil()
    TheFrontEnd:GetGraphicsOptions():DisableLightMapComponent()

    TheInputProxy:SetCursorVisible(true)

    if PLATFORM == "NACL" then
        TheSim:RequestPlayerID()
    end

    -- Make sure that DLC starts as on every time
    EnableAllDLC()

    self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
    self.bg:SetTint(BGCOLOURS.RED[1], BGCOLOURS.RED[2], BGCOLOURS.RED[3], 1)

    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)

    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.right_col = self.fixed_root:AddChild(Widget("right"))
    self.right_col:SetPosition(rcol, 0)

    self.left_col = self.fixed_root:AddChild(Widget("left"))
    self.left_col:SetPosition(lcol, 0)


    -- UPSELLS (mixed loc)

    --on Steam and does not own DST beta SKU or not on Steam
    -- if ((PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM") and not TheSim:GetUserHasLicenseForApp(DONT_STARVE_TOGETHER_APPID)) 
    -- 	or (PLATFORM ~= "WIN32_STEAM" and PLATFORM ~= "LINUX_STEAM" and PLATFORM ~= "OSX_STEAM" and PLATFORM ~= "PS4") then

    if PLATFORM == "WIN32_STEAM" then
        self.DLCUpgrade = self.right_col:AddChild(DLCUpgrade())
        self.DLCUpgrade:SetScale(.7)
        self.DLCUpgrade:SetPosition(0, 215, 0)
    end
    -- self.beta_reg = self.left_col:AddChild(BetaRegistration())
    -- self.beta_reg:SetScale(.76)
    -- self.beta_reg:SetPosition(0, -185, 0)

    -- Chester upsell for now: later, uncomment the above and turn the beta upsell back on
    --[[self.chester_upsell = self.left_col:AddChild(ImageButton("images/fepanels_DSTbeta.xml", "chester_menu_button_360.tex", "chester_menu_mouseover_360.tex"))
    self.chester_upsell:SetPosition(0, -185, 0)
    self.chester_upsell:SetOnClick( function()
        VisitURL("http://bit.ly/1NSqpJZ")
    end)]]

    --  	else --owns DST beta SKU and on Steam

    --  		self.RoGUpgrade = self.left_col:AddChild(RoGUpgrade())
    --    self.RoGUpgrade:SetScale(.9)
    --    self.RoGUpgrade:SetPosition(0, -185, 0)

    --  		local function KickOffScreecherMod()
    -- 	KnownModIndex:Enable("screecher")
    -- 	KnownModIndex:Save()
    -- 	TheSim:Quit()
    -- end

    --    self.screecher = self.right_col:AddChild(ImageButton("images/fepanels.xml", "DS_Scary_button.tex", "DS_Scary_button-rollover.tex"))
    --    self.screecher:SetPosition(0, 225, 0)
    -- self.screecher:SetScale(.6)
    -- self.screecher:SetOnClick( function()
    -- 	if PLATFORM == "NACL" then
    -- 		TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.SCREECHER_NACL_DIALOG_TITLE, STRINGS.UI.MAINSCREEN.SCREECHER_NACL_DIALOG_TEXT,
    -- 		{
    -- 			{text=STRINGS.UI.MODSSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end},
    -- 			{text=STRINGS.UI.MAINSCREEN.SCREECHER_NACL_OKAY, cb = function() VisitURL("http://www.dontstarvegame.com/chrome-version-retired") end },
    -- 		}))
    -- 	else
    -- 		TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.SCREECHER_DIALOG_TITLE, STRINGS.UI.MAINSCREEN.SCREECHER_DIALOG_TEXT,
    -- 		{
    -- 			{text=STRINGS.UI.MODSSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end},
    -- 			{text=STRINGS.UI.MODSSCREEN.RESTART, cb = function() KickOffScreecherMod() end },
    -- 		}))
    -- 	end
    -- end)

    -- self.wilson = self.left_col:AddChild(UIAnim())
    -- self.wilson:GetAnimState():SetBank("corner_dude")
    -- self.wilson:GetAnimState():SetBuild("corner_dude")
    -- self.wilson:GetAnimState():PlayAnimation("idle", true)
    -- self.wilson:SetPosition(0,-370,0)

    -- end


    --RIGHT COLUMN

    self.menu = self.right_col:AddChild(Menu(nil, 70))
    self.menu:SetPosition(0, -120, 0)
    self.menu:SetScale(.8)

    local submenuitems = {
        { text = STRINGS.UI.MAINSCREEN.NOTIFY, cb = function()
            self:EmailSignup()
        end },
        { text = STRINGS.UI.MAINSCREEN.FORUM, cb = function()
            self:Forums()
        end }
    }
    self.submenu = self.right_col:AddChild(Menu(submenuitems, 70))
    self.submenu:SetPosition(0, -300, 0)
    self.submenu:SetScale(.6)


    --center stuff
    self.shield = self.fixed_root:AddChild(Image("images/fepanels.xml", "panel_shield.tex"))
    self.shield:SetVRegPoint(ANCHOR_MIDDLE)
    self.shield:SetHRegPoint(ANCHOR_MIDDLE)

    self.banner = self.shield:AddChild(Image("images/ui.xml", "update_banner.tex"))
    self.banner:SetVRegPoint(ANCHOR_MIDDLE)
    self.banner:SetHRegPoint(ANCHOR_MIDDLE)
    self.banner:SetPosition(0, -210, 0)
    self.updatename = self.banner:AddChild(Text(BUTTONFONT, 30))
    self.updatename:SetPosition(0, 8, 0)
    local suffix = ""
    if BRANCH == "dev" then
        suffix = " (internal)"
    elseif BRANCH == "staging" then
        suffix = " (preview)"
    end
    self.updatename:SetString(STRINGS.UI.MAINSCREEN.UPDATENAME .. suffix)
    self.updatename:SetColour(0, 0, 0, 1)


    --LEFT COLUMN

    self.motd = self.left_col:AddChild(Widget("motd"))
    self.motd:SetScale(.9, .9, .9)
    self.motd:SetPosition(0, 0, 0)
    --self.motd:Hide()
    self.motdbg = self.motd:AddChild(Image("images/globalpanels.xml", "panel.tex"))
    self.motdbg:SetScale(.75 * .9, .75, .75)
    self.motd.motdtitle = self.motdbg:AddChild(Text(TITLEFONT, 50))
    self.motd.motdtitle:SetPosition(0, 130, 0)
    self.motd.motdtitle:SetRegionSize(350, 60)
    self.motd.motdtitle:SetString(STRINGS.UI.MAINSCREEN.MOTDTITLE)

    self.motd.motdtext = self.motd:AddChild(Text(NUMBERFONT, 30))
    self.motd.motdtext:SetHAlign(ANCHOR_MIDDLE)
    self.motd.motdtext:SetVAlign(ANCHOR_MIDDLE)
    self.motd.motdtext:SetPosition(0, -10, 0)
    self.motd.motdtext:SetRegionSize(250, 160)
    self.motd.motdtext:SetString(STRINGS.UI.MAINSCREEN.MOTD)

    self.motd.motdimage = self.motd:AddChild(ImageButton("images/global.xml", "square.tex", "square.tex", "square.tex"))
    self.motd.motdimage.image:SetScale(1.12, 1.12, 1.12)
    self.motd.motdimage:SetPosition(0, -10, 0)
    self.motd.motdimage:Hide()

    self.motd.motdimage.OnGainFocus = function()
        self.motd.motdimage.image:SetTexture(self.motd.motdimage.atlas, self.motd.motdimage.image_normal)
        self.motd:SetScale(0.93, 0.93, 0.93)
    end
    self.motd.motdimage.OnLoseFocus = function()
        self.motd.motdimage.image:SetTexture(self.motd.motdimage.atlas, self.motd.motdimage.image_normal)
        self.motd:SetScale(.9, .9, .9)
    end
    self.motd.motdimage:SetOnClick(
            function()
                self.motd.button.onclick()
            end)

    self.motd.button = self.motd:AddChild(ImageButton())
    self.motd.button:SetPosition(0, -185, 0)
    self.motd.button:SetScale(.8)
    self.motd.button:SetText(STRINGS.UI.MAINSCREEN.MOTDBUTTON)
    self.motd.button:SetOnClick(function()
        VisitURL("http://forums.kleientertainment.com/index.php?/topic/28171-halloween-mod-challenge/")
    end)
    self.motd.motdtext:EnableWordWrap(true)

    local PopupDialogScreen = require("screens/popupdialog")
    local ImageButton = require("widgets/imagebutton")

    if PLATFORM == "NACL" then

        self.playerid = self.fixed_root:AddChild(Text(NUMBERFONT, 35))
        self.playerid:SetPosition(RESOLUTION_X / 2 - 400, RESOLUTION_Y / 2 - 60, 0)
        self.playerid:SetRegionSize(600, 50)
        self.playerid:SetHAlign(ANCHOR_RIGHT)

        self.purchasebutton = self.right_col:AddChild(ImageButton("images/ui.xml", "special_button.tex", "special_button_over.tex"))
        self.purchasebutton:SetScale(.5, .5, .5)
        self.purchasebutton:SetPosition(0, 200, 0)
        self.purchasebutton:SetFont(BUTTONFONT)
        self.purchasebutton:SetTextSize(80)

        if not IsGamePurchased() then
            self.purchasebutton:SetOnClick(function()
                self:Buy()
            end)
            self.purchasebutton:SetText(STRINGS.UI.MAINSCREEN.BUYNOW)
        else
            self.purchasebutton:SetOnClick(function()
                self:SendGift()
            end)
            self.purchasebutton:SetText(STRINGS.UI.MAINSCREEN.GIFT)
        end
    end

    if PLATFORM ~= "NACL" then
        self:UpdateMOTD()
    end

    --focus moving

    self.motd.button:SetFocusChangeDir(MOVE_RIGHT, self.menu)
    self.menu:SetFocusChangeDir(MOVE_LEFT, self.motd.button)
    self.submenu:SetFocusChangeDir(MOVE_LEFT, self.motd.button)

    self.menu:SetFocusChangeDir(MOVE_DOWN, self.submenu, -1)
    self.submenu:SetFocusChangeDir(MOVE_UP, self.menu, 1)

    self:MainMenu()
    self.menu:SetFocus()
end

function MainScreen:DoLanguagePopup()
    if IsConsole() or IsSteam() then
        --Make sure we only do one mainscreen popup at a time
        --Do language assistance popup
        local interface_lang = TheSim:GetLanguageCode()
        if interface_lang ~= "english" then
            if Profile:GetValue("language_asked_" .. interface_lang) ~= true then
                local lang_id = LANGUAGE_STEAMCODE_TO_ID[interface_lang]
                local locale = LOC.GetLocale(lang_id)
                if locale ~= nil then
                    local show_dialog = false
                    if IsConsole() then
                        show_dialog = locale.in_console_menu
                    elseif IsSteam() then
                        show_dialog = locale.in_steam_menu
                    end

                    if show_dialog then
                        local popup_screen = PopupDialogScreen(STRINGS.PRETRANSLATED.LANGUAGES_TITLE[locale.id], STRINGS.PRETRANSLATED.LANGUAGES_BODY[locale.id],
                                {
                                    { text = STRINGS.PRETRANSLATED.LANGUAGES_YES[locale.id], cb = function()
                                        Profile:SetLanguageID(lang_id, function()
                                            SimReset()
                                        end)
                                    end },
                                    { text = STRINGS.PRETRANSLATED.LANGUAGES_NO[locale.id], cb = function()
                                        TheFrontEnd:PopScreen()
                                    end }
                                }
                        )
                        TheFrontEnd:PushScreen(popup_screen)
                        Profile:SetValue("language_asked_" .. interface_lang, true)
                        Profile:Save()
                    end
                end
            end
        end
    end
end

function MainScreen:OnSetPlayerID(playerid)
    if self.playerid then
        self.playerid:SetString(STRINGS.UI.MAINSCREEN.GREETING .. " " .. playerid)
    end
end

function MainScreen:OnControl(control, down)
    if MainScreen._base.OnControl(self, control, down) then
        return true
    end

    if not down and control == CONTROL_CANCEL then
        if not self.mainmenu then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            self:MainMenu()
            return true
        end
    end
end

function MainScreen:OnRawKey(key, down)

    if not self.focus then
        return
    end

    if not down and CHEATS_ENABLED then
        if key == KEY_RSHIFT then
            if TheInput:IsKeyDown(KEY_CTRL) then
                SaveGameIndex:DeleteSlot(1)
            elseif not SaveGameIndex:GetCurrentMode(1) then
                local function onsaved()
                    StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = 1 })
                end
                SaveGameIndex:StartSurvivalMode(1, "wilson", {}, onsaved, ALL_DLC_TABLE)
            else
                StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = 1 })
            end
            return true
        elseif key >= KEY_1 and key <= KEY_7 then
            local level_num = key - KEY_1 + 1
            local function onstart()
                StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = 1 })
            end
            SaveGameIndex:FakeAdventure(onstart, 1, level_num)
            return true
        elseif key == KEY_0 then
            local function onstart()
                StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = 1 })
            end
            SaveGameIndex:DeleteSlot(1, function()
                SaveGameIndex:EnterWorld("cave", onstart, 1, 1)
            end)
            return true
        elseif key == KEY_9 then
            local function onstart()
                StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = 1 })
            end
            SaveGameIndex:DeleteSlot(1, function()
                SaveGameIndex:EnterWorld("cave", onstart, 1, 1, 2)
            end)
            return true
        elseif key == KEY_MINUS then
            StartNextInstance({ reset_action = "test", save_slot = 1 })
            return true
        elseif key == KEY_M then
            self:OnModsButton()
            return true
        end
    end
end

-- NACL MENU OPTIONS
function MainScreen:Buy()
    TheSim:SendJSMessage("MainScreen:Buy")
    TheFrontEnd:GetSound():KillSound("FEMusic")
end

function MainScreen:EnterKey()
    TheSim:SendJSMessage("MainScreen:EnterKey")
end

function MainScreen:SendGift()
    TheSim:SendJSMessage("MainScreen:Gift")
    TheFrontEnd:GetSound():KillSound("FEMusic")
end

function MainScreen:ProductKeys()
    TheSim:SendJSMessage("MainScreen:ProductKeys")
end

function MainScreen:Rate()
    TheSim:SendJSMessage("MainScreen:Rate")
end

function MainScreen:Logout()
    TheSim:SendJSMessage("MainScreen:Logout")
end

-- SUBSCREENS

function MainScreen:Settings()
    TheFrontEnd:PushScreen(OptionsScreen(false))
end

function MainScreen:OnLanguageButton()
    TheFrontEnd:PushScreen(LanguageScreen())
end

function MainScreen:BroadcastingMenu()
    TheFrontEnd:PushScreen(BroadcastingOptionsScreen())
end

function MainScreen:OnControlsButton()
    TheFrontEnd:PushScreen(ControlsScreen())
end

function MainScreen:EmailSignup()
    TheFrontEnd:PushScreen(EmailSignupScreen())
end

function MainScreen:Forums()
    VisitURL("http://forums.kleientertainment.com/index.php?/forum/5-dont-starve/")
end

function MainScreen:Quit()
    TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.ASKQUIT, STRINGS.UI.MAINSCREEN.ASKQUITDESC, { { text = STRINGS.UI.MAINSCREEN.YES, cb = function()
        RequestShutdown()
    end }, { text = STRINGS.UI.MAINSCREEN.NO, cb = function()
        TheFrontEnd:PopScreen()
    end } }))
end

function MainScreen:OnExitButton()
    if PLATFORM == "NACL" then
        self:Logout()
    else
        self:Quit()
    end
end
function MainScreen:Refresh()
    self:MainMenu()
    TheFrontEnd:GetSound():PlaySound("dontstarve/music/music_FE", "FEMusic")
end

function MainScreen:ShowMenu(menu_items, posX, posY)
    self.mainmenu = false
    self.menu:Clear()

    for k = #menu_items, 1, -1 do
        local v = menu_items[k]
        self.menu:AddItem(v.text, v.cb, v.offset)
    end

    if posX and posY then
        self.menu:SetPosition(posX, posY, 0)
    end

    self.menu:SetFocus()
end

function MainScreen:DoOptionsMenu()

    local menu_items = {}

    if PLATFORM == "NACL" then
        table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.ACCOUNTINFO, cb = function()
            self:ProductKeys()
        end })
        if IsGamePurchased() then
            table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.ENTERKEY, cb = function()
                self:EnterKey()
            end })
        end
    end

    table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.SETTINGS, cb = function()
        self:Settings()
    end })
    table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.CONTROLS, cb = function()
        self:OnControlsButton()
    end })

    if not IsRail() then
        table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.LANGUAGES, cb = function()
            self:OnLanguageButton()
        end })
    end

    table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.CREDITS, cb = function()
        self:OnCreditsButton()
    end })

    if PLATFORM == "WIN32_STEAM" then
        table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.MOREGAMES, cb = function()
            VisitURL("http://store.steampowered.com/search/?developer=Klei%20Entertainment")
        end })
    end

    if BRANCH ~= "release" then
        table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.CHEATS, cb = function()
            self:CheatMenu()
        end })
    end

    if HAVE_SUBMIT_ERRORREPORT then
        table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.BUGREPORT, cb = function()
            self:BugReport()
        end })
    end

    if false then
        --PLATFORM == "WIN32_STEAM" or PLATFORM == "WIN32" then
        table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.BROADCASTING, cb = function()
            self:BroadcastingMenu()
        end })
    end

    table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.CANCEL, cb = function()
        self:MainMenu()
    end })

    if BRANCH ~= "release" then
        self:ShowMenu(menu_items, 0, -195)
    else
        self:ShowMenu(menu_items, 0, -175)
    end
end

function MainScreen:BugReport()
    TheFrontEnd:PushScreen(BugReportScreen())
end

function MainScreen:OnModsButton()
    TheFrontEnd:PushScreen(ModsScreen(function(needs_reset)
        if needs_reset then
            SimReset()
        end

        TheFrontEnd:PopScreen()
    end))
end

function MainScreen:ResetProfile()
    TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.RESETPROFILE, STRINGS.UI.MAINSCREEN.SURE, { { text = STRINGS.UI.MAINSCREEN.YES, cb = function()
        self.profile:Reset()
        TheFrontEnd:PopScreen()
    end }, { text = STRINGS.UI.MAINSCREEN.NO, cb = function()
        TheFrontEnd:PopScreen()
    end } }))
end

function MainScreen:UnlockEverything()
    TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.UNLOCKEVERYTHING, STRINGS.UI.MAINSCREEN.SURE, { { text = STRINGS.UI.MAINSCREEN.YES, cb = function()
        self.profile:UnlockEverything()
        TheFrontEnd:PopScreen()
    end }, { text = STRINGS.UI.MAINSCREEN.NO, cb = function()
        TheFrontEnd:PopScreen()
    end } }))
end

function MainScreen:OnCreditsButton()
    TheFrontEnd:GetSound():KillSound("FEMusic")
    TheFrontEnd:PushScreen(CreditsScreen())
end

function MainScreen:CheatMenu()
    local menu_items = {}
    table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.UNLOCKEVERYTHING, cb = function()
        self:UnlockEverything()
    end })
    table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.RESETPROFILE, cb = function()
        self:ResetProfile()
    end })
    table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.CANCEL, cb = function()
        self:DoOptionsMenu()
    end })
    self:ShowMenu(menu_items, 0, -120)
end

function MainScreen:OnPlayButtonNACL()
    TheFrontEnd:PushScreen(
            PopupDialogScreen(STRINGS.UI.MAINSCREEN.PLAY_ON_STEAM,
                    STRINGS.UI.MAINSCREEN.PLAY_ON_STEAM_DETAIL, {
                        { text = STRINGS.UI.MAINSCREEN.NEWGO, cb = function()
                            TheFrontEnd:PopScreen()
                            TheSim:SendJSMessage("MainScreen:MoveToSteam")
                            TheFrontEnd:GetSound():KillSound("FEMusic")
                        end },
                        { text = STRINGS.UI.MAINSCREEN.LATER, cb = function()
                            TheFrontEnd:PopScreen()
                            TheFrontEnd:PushScreen(LoadGameScreen())
                        end }
                    }))
end

function MainScreen:MainMenu()

    local menu_items = {}
    local purchased = IsGamePurchased()
    if purchased then
        if PLATFORM == "NACL" then
            table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.PLAY, cb = function()
                self:OnPlayButtonNACL()
            end, offset = Vector3(0, 20, 0) })
        else
            table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.PLAY, cb = function()
                TheFrontEnd:PushScreen(LoadGameScreen())
            end, offset = Vector3(0, 20, 0) })
        end
    else
        table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.ENTERPRODUCTKEY, cb = function()
            self:EnterKey()
        end })
    end

    if MODS_ENABLED then
        table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.MODS, cb = function()
            self:OnModsButton()
        end })
    end

    table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.OPTIONS, cb = function()
        self:DoOptionsMenu()
    end })

    if PLATFORM == "NACL" then
        table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.LOGOUT, cb = function()
            self:OnExitButton()
        end })
    else
        table.insert(menu_items, { text = STRINGS.UI.MAINSCREEN.EXIT, cb = function()
            self:OnExitButton()
        end })
    end
    self:ShowMenu(menu_items, 0, -120)
    self.mainmenu = true
end

function MainScreen:OnBecomeActive()
    MainScreen._base.OnBecomeActive(self)
    self.menu:SetFocus()
end

local anims = {
    scratch = 1,
    hungry = 1,
    eat = 1,
}

function MainScreen:OnUpdate(dt)
    if PLATFORM == "PS4" and TheSim:ShouldPlayIntroMovie() then
        TheFrontEnd:PushScreen(MovieDialog("movies/forbidden_knowledge.mp4", function()
            TheFrontEnd:GetSound():PlaySound("dontstarve/music/music_FE", "FEMusic")
        end))
        self.music_playing = true
    elseif not self.music_playing then
        TheFrontEnd:GetSound():PlaySound("dontstarve/music/music_FE", "FEMusic")
        self.music_playing = true
    end

    self.timetonewanim = self.timetonewanim and self.timetonewanim - dt or 5 + math.random() * 5
    if self.timetonewanim < 0 and self.wilson then
        self.wilson:GetAnimState():PushAnimation(weighted_random_choice(anims))
        self.wilson:GetAnimState():PushAnimation("idle", true)
        self.timetonewanim = 10 + math.random() * 15
    end

    if not self.doneLanguagePopup then
        --self.inst:DoTaskInTime(2, function() self:DoLanguagePopup() end)
        self:DoLanguagePopup()
        self.doneLanguagePopup = true
    end
end

function MainScreen:OnGetMOTDImageQueryComplete(is_successful)
    if is_successful then
        self.motd.motdimage:SetTextures("images/motd.xml", "motd.tex", "motd.tex", "motd.tex")
        self.motd.motdimage:Show()
    end
end

local function push_motd_event(_event, _url, _image_version)
    local event = {}
    event.event = _event
    event.values = {}
    event.values.url = _url .. "#" .. tostring(_image_version)
    PushMetricsEvent(event)
end

function MainScreen:SetMOTD(str, cache)
    --print("MainScreen:SetMOTD", str, cache)

    local status, motd = pcall(function()
        return json.decode(str)
    end)
    --print("decode:", status, motd)
    if status and motd then
        if cache then
            SavePersistentString("motd_image", str)
        end

        local platform_motd = nil
        if PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM" then
            platform_motd = motd.steam
        else
            platform_motd = motd.standalone
        end

        if platform_motd then
            self.motd:Show()
            if platform_motd.motd_title and string.len(platform_motd.motd_title) > 0 and
                    platform_motd.motd_body and string.len(platform_motd.motd_body) > 0 then

                self.motd.motdtitle:Show()
                self.motd.motdtitle:SetString(platform_motd.motd_title)
                self.motd.motdtext:Show()
                self.motd.motdtext:SetString(platform_motd.motd_body)
                self.motd.motdimage:Hide()

                if platform_motd.link_title and string.len(platform_motd.link_title) > 0 and
                        platform_motd.link_url and string.len(platform_motd.link_url) > 0 then
                    self.motd.button:SetText(platform_motd.link_title)
                    self.motd.button:SetOnClick(function()
                        push_motd_event("motd.clicked", platform_motd.link_url, platform_motd.image_version or 0)
                        VisitURL(platform_motd.link_url)
                    end)
                else
                    self.motd.button:Hide()
                end
            elseif platform_motd.image_url and string.len(platform_motd.image_url) > 0 then

                self.motd.motdtitle:Hide()
                self.motd.motdtext:Hide()

                local use_disk_file = not cache
                if use_disk_file then
                    self.motd.motdimage:Hide()
                end

                if platform_motd.link_title and string.len(platform_motd.link_title) > 0 and
                        platform_motd.link_url and string.len(platform_motd.link_url) > 0 then
                    self.motd.button:SetText(platform_motd.link_title)
                    self.motd.button:SetOnClick(function()
                        push_motd_event("motd.clicked", platform_motd.link_url, platform_motd.image_version or 0)
                        VisitURL(platform_motd.link_url)
                    end)
                else
                    self.motd.button:Hide()
                end

                TheSim:GetMOTDImage(platform_motd.image_url, use_disk_file, platform_motd.image_version or "", function(...)
                    self:OnGetMOTDImageQueryComplete(...)
                end)
            else
                self.motd:Hide()
            end

            if cache then
                --the one we cache is the latest we downloaded
                push_motd_event("motd.seen", platform_motd.link_url, platform_motd.image_version or 0)
            end
        else
            self.motd:Hide()
        end
    end
end

function MainScreen:OnMOTDQueryComplete(result, isSuccessful, resultCode)
    --print( "MainScreen:OnMOTDQueryComplete", result, isSuccessful, resultCode )
    if isSuccessful and string.len(result) > 1 and resultCode == 200 then
        self:SetMOTD(result, true)
    end
end

function MainScreen:OnCachedMOTDLoad(load_success, str)
    --print("MainScreen:OnCachedMOTDLoad", load_success, str)
    if load_success and string.len(str) > 1 then
        self:SetMOTD(str, false)
    end
    TheSim:QueryServer("https://d21wmy1ql1e52r.cloudfront.net/ds_image_motd.json", function(...)
        self:OnMOTDQueryComplete(...)
    end, "GET")
end

function MainScreen:UpdateMOTD()
    --print("MainScreen:UpdateMOTD()")
    TheSim:GetPersistentString("motd_image", function(...)
        self:OnCachedMOTDLoad(...)
    end)
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
