local Screen = require "widgets/screen"
local AnimButton = require "widgets/animbutton"
local Spinner = require "widgets/spinner"
local ImageButton = require "widgets/imagebutton"
local TextButton = require "widgets/textbutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local NumericSpinner = require "widgets/numericspinner"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Menu = require "widgets/menu"
local PopupDialogScreen = require "screens/popupdialog"
local ModConfigurationScreen = require "screens/modconfigurationscreen"

local text_font = DEFAULTFONT--NUMBERFONT

local display_rows = 5

local DISABLE = 0
local ENABLE = 1

local mid_col = RESOLUTION_X * .2
local left_col = -RESOLUTION_X * .2
local right_col = RESOLUTION_X * .22

local ModsScreen = Class(Screen, function(self, cb)
    Widget._ctor(self, "ModsScreen")
    self.cb = cb

    -- save current mod index before user configuration
    KnownModIndex:CacheSaveData()
    -- get the latest mod info
    KnownModIndex:UpdateModInfo()

    self.modnames = KnownModIndex:GetModNames()
    local function alphasort(moda, modb)
        if not moda then
            return false
        end
        if not modb then
            return true
        end
        return string.lower(KnownModIndex:GetModFancyName(moda)) < string.lower(KnownModIndex:GetModFancyName(modb))
    end
    table.sort(self.modnames, alphasort)

    self.infoprefabs = {}

    self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
    SetBGcolor(self.bg)

    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)

    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    -- self.cancelbutton = self.root:AddChild(ImageButton())
    -- self.cancelbutton:SetText(STRINGS.UI.MODSSCREEN.CANCEL)
    -- self.cancelbutton:SetPosition(Vector3(80,-220,0))
    -- self.cancelbutton:SetOnClick(function() self:Cancel() end)

    -- self.applybutton = self.root:AddChild(ImageButton())
    -- self.applybutton:SetText(STRINGS.UI.MODSSCREEN.APPLY)
    -- self.applybutton:SetPosition(Vector3(-80, -220, 0))
    -- self.applybutton:SetOnClick(function() self:Apply() end)

    -- mod details panel
    self:CreateDetailPanel()

    self.mainmenu = self.root:AddChild(Menu(nil, 0, true))
    self.mainmenu:SetPosition(mid_col, 0, 0)
    self.applybutton = self.mainmenu:AddItem(STRINGS.UI.MODSSCREEN.APPLY, function()
        self:Apply()
    end, Vector3(-170, -285, 0))
    self.cancelbutton = self.mainmenu:AddItem(STRINGS.UI.MODSSCREEN.CANCEL, function()
        self:Cancel()
    end, Vector3(0, -285, 0))
    self.modconfigbutton = self.mainmenu:AddItem(STRINGS.UI.MODSSCREEN.CONFIGUREMOD, function()
        self:ConfigureSelectedMod()
    end, Vector3(0, -165, 0))
    self.modconfigbutton:SetScale(.85)

    if PLATFORM ~= "WIN32_RAIL" then
        self.morebutton = self.mainmenu:AddItem(STRINGS.UI.MODSSCREEN.MOREMODS, function()
            self:MoreMods()
        end, Vector3(170, -285, 0))
    end

    self.option_offset = 0
    self.optionspanel = self.root:AddChild(Menu(nil, -98, false))
    self.optionspanel:SetPosition(left_col, 0, 0)
    self.optionspanelbg = self.optionspanel:AddChild(Image("images/fepanels.xml", "panel_mod1.tex"))

    --------Build controller support
    self.optionspanel:SetFocusChangeDir(MOVE_RIGHT, self.mainmenu)

    self.applybutton:SetFocusChangeDir(MOVE_LEFT, self.optionspanel)
    self.applybutton:SetFocusChangeDir(MOVE_RIGHT, self.cancelbutton)
    self.applybutton:SetFocusChangeDir(MOVE_UP, self.modconfigbutton)

    self.cancelbutton:SetFocusChangeDir(MOVE_LEFT, self.applybutton)
    self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.modconfigbutton)

    if PLATFORM ~= "WIN32_RAIL" then
        self.cancelbutton:SetFocusChangeDir(MOVE_RIGHT, self.morebutton)
        self.morebutton:SetFocusChangeDir(MOVE_LEFT, self.cancelbutton)
        self.morebutton:SetFocusChangeDir(MOVE_UP, self.featuredbutton)
        self.morebutton:SetFocusChangeDir(MOVE_DOWN, self.modconfigbutton)
        self.modconfigbutton:SetFocusChangeDir(MOVE_RIGHT, self.morebutton)
    end

    self.modconfigbutton:SetFocusChangeDir(MOVE_LEFT, self.optionspanel)
    self.modconfigbutton:SetFocusChangeDir(MOVE_DOWN, self.applybutton)

    self.leftbutton = self.optionspanel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.leftbutton:SetPosition(0, 290, 0)
    self.leftbutton:SetRotation(-90)
    self.leftbutton:SetOnClick(function()
        self:Scroll(-display_rows)
    end)

    self.rightbutton = self.optionspanel:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.rightbutton:SetPosition(0, -300, 0)
    self.rightbutton:SetRotation(90)
    self.rightbutton:SetOnClick(function()
        self:Scroll(display_rows)
    end)

    ---- Workshop blinker

    --self.workshopupdatenote = self.optionspanel:AddChild(Text(TITLEFONT, 40))
    --self.workshopupdatenote:SetHAlign(ANCHOR_MIDDLE)
    --self.workshopupdatenote:SetPosition(0, 0, 0)
    --self.workshopupdatenote:SetString("Updating Steam Workshop Info...")
    --self.workshopupdatenote:Hide()

    self.optionwidgets = {}

    self:StartWorkshopUpdate()

    self.default_focus = self.cancelbutton

    self.cancelbutton:MoveToFront()
    self.applybutton:MoveToFront()
end)

function ModsScreen:GenerateRandomPicks(num, numrange)
    local picks = {}

    while #picks < num do
        local num = math.random(1, numrange)
        if not table.contains(picks, num) then
            table.insert(picks, num)
        end
    end
    return picks
end

function ModsScreen:OnStatsQueried(result, isSuccessful, resultCode)

    if TheFrontEnd.screenstack[#TheFrontEnd.screenstack] ~= self then
        return
    end

    if not result or not isSuccessful or string.len(result) <= 1 then
        return
    end

    local status, jsonresult = pcall(function()
        return json.decode(result)
    end)

    if not jsonresult or type(jsonresult) ~= "table" or not status or jsonresult["modnames"] == nil then
        return
    end

    if next(jsonresult["modnames"]) == nil then
        return
    end

    local randomPicks = self:GenerateRandomPicks(#self.modlinks, 20)

    for i = 1, #self.modlinks do
        local title = jsonresult["modnames"][randomPicks[i]]
        if title then
            local url = jsonresult["modlinks"][title]
            title = string.gsub(title, "(ws%-)", "")
            if string.len(title) > 25 then
                title = string.sub(title, 0, 25) .. "..."
            end
            self.modlinks[i]:SetText(title)
            if url then
                self.modlinks[i]:SetOnClick(function()
                    VisitURL(url)
                end)
            end
        end
    end

    local title, url = next(jsonresult["modfeature"])
    if title and url then
        title = string.gsub(title, "(ws%-)", "")
        self.featuredbutton:SetText(title)
        self.featuredbutton:SetOnClick(function()
            VisitURL(url)
        end)
    end
end

function ModsScreen:CreateTopModsPanel()

    --Top Mods Stuff--
    self.topmods = self.root:AddChild(Widget("topmods"))
    self.topmods:SetPosition(right_col, 0, 0)

    self.topmodsbg = self.topmods:AddChild(Image("images/fepanels.xml", "panel_topmods.tex"))
    self.topmodsbg:SetScale(1, 1, 1)

    if PLATFORM ~= "WIN32_RAIL" then
        self.morebutton = self.topmods:AddChild(ImageButton())
        self.morebutton:SetText(STRINGS.UI.MODSSCREEN.MOREMODS)
        self.morebutton:SetPosition(Vector3(0, -220, 0))
        self.morebutton:SetOnClick(function()
            self:MoreMods()
        end)
    end

    self.title = self.topmods:AddChild(Text(TITLEFONT, 40))
    self.title:SetPosition(Vector3(0, 225, 0))
    self.title:SetString(STRINGS.UI.MODSSCREEN.TOPMODS)

    self.modlinks = {}

    local yoffset = 170
    for i = 1, 5 do
        local modlink = self.topmods:AddChild(TextButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex", "blank.tex"))
        modlink:SetPosition(Vector3(0, yoffset, 0))
        modlink:SetText(STRINGS.UI.MODSSCREEN.LOADING .. "...")
        modlink:SetFont(BUTTONFONT)
        modlink:SetTextColour(0.9, 0.8, 0.6, 1)
        modlink:SetTextFocusColour(1, 1, 1, 1)
        table.insert(self.modlinks, modlink)
        yoffset = yoffset - 45
    end

    self.featuredtitle = self.topmods:AddChild(Text(TITLEFONT, 40))
    self.featuredtitle:SetPosition(Vector3(0, -70, 0))
    self.featuredtitle:SetString(STRINGS.UI.MODSSCREEN.FEATUREDMOD)

    self.featuredbutton = self.topmods:AddChild(TextButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex", "blank.tex"))
    self.featuredbutton:SetPosition(Vector3(0, -130, 0))
    self.featuredbutton:SetText(STRINGS.UI.MODSSCREEN.LOADING .. "...")
    self.featuredbutton:SetFont(BUTTONFONT)
    self.featuredbutton:SetTextColour(0.9, 0.8, 0.6, 1)
    self.featuredbutton:SetTextFocusColour(1, 1, 1, 1)
end

function ModsScreen:CreateDetailPanel()
    if self.detailpanel then
        self.detailpanel:Kill()
    end

    self.detailpanel = self.root:AddChild(Widget("detailpanel"))
    self.detailpanel:SetPosition(mid_col, 90, 0)
    self.detailpanelbg = self.detailpanel:AddChild(Image("images/fepanels.xml", "panel_mod2.tex"))
    self.detailpanelbg:SetScale(1, 1, 1)

    if #self.modnames > 0 then
        self.detailimage = self.detailpanel:AddChild(Image("images/ui.xml", "portrait_bg.tex"))
        self.detailimage:SetSize(102, 102)
        --self.detailimage:SetScale(0.8,0.8,0.8)
        self.detailimage:SetPosition(-130, 127, 0)

        self.detailtitle = self.detailpanel:AddChild(Text(TITLEFONT, 40))
        self.detailtitle:SetHAlign(ANCHOR_LEFT)
        self.detailtitle:SetPosition(70, 155, 0)
        self.detailtitle:SetRegionSize(270, 70)

        --self.detailversion = self.detailpanel:addchild(text(titlefont, 20))
        --self.detailversion:setvalign(anchor_top)
        --self.detailversion:sethalign(anchor_left)
        --self.detailversion:setposition(200, 100, 0)
        --self.detailversion:setregionsize( 180, 70 )

        self.detailauthor = self.detailpanel:AddChild(Text(TITLEFONT, 30))
        self.detailauthor:SetColour(1.0, 1.0, 1.0, 1)
        --self.detailauthor:SetColour(0.9,0.8,0.6,1) -- link colour
        self.detailauthor:SetHAlign(ANCHOR_LEFT)
        self.detailauthor:SetPosition(70, 113, 0)
        self.detailauthor:SetRegionSize(270, 70)
        self.detailauthor:EnableWordWrap(true)

        self.detailcompatibility = self.detailpanel:AddChild(Text(TITLEFONT, 25))
        self.detailcompatibility:SetColour(1.0, 1.0, 1.0, 1)
        self.detailcompatibility:SetHAlign(ANCHOR_LEFT)
        self.detailcompatibility:SetPosition(70, 83, 0)
        self.detailcompatibility:SetRegionSize(270, 70)

        self.detaildesc = self.detailpanel:AddChild(Text(BODYTEXTFONT, 25))
        self.detaildesc:SetPosition(6, -8, 0)
        self.detaildesc:SetRegionSize(352, 165)
        self.detaildesc:EnableWordWrap(true)

        self.detailwarning = self.detailpanel:AddChild(Text(BODYTEXTFONT, 25))
        self.detailwarning:SetColour(0.9, 0, 0, 1)
        self.detailwarning:SetPosition(15, -160, 0)
        self.detailwarning:SetRegionSize(600, 107)
        self.detailwarning:EnableWordWrap(true)

        self.modlinkbutton = self.detailpanel:AddChild(TextButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex", "blank.tex"))
        self.modlinkbutton:SetPosition(5, -119, 0)
        self.modlinkbutton:SetText(STRINGS.UI.MODSSCREEN.MODLINK)
        self.modlinkbutton:SetFont(BUTTONFONT)
        self.modlinkbutton:SetTextSize(30)
        self.modlinkbutton:SetTextColour(0.9, 0.8, 0.6, 1)
        self.modlinkbutton:SetTextFocusColour(1, 1, 1, 1)
        self.modlinkbutton:SetOnClick(function()
            self:ModLinkCurrent()
        end)

        --local enableoptions = {{text="Disabled", data=DISABLE},{text="Enabled",data=ENABLE}}
        --self.enablespinner = self.detailpanel:AddChild(Spinner(enableoptions, 200, 60))
        --self.enablespinner:SetTextColour(0,0,0,1)
        --self.enablespinner:SetPosition(-100, -150, 0)
        --self.enablespinner.OnChanged = function( _, data )
        --self:EnableCurrent(data)
        --end
    else
        self.detaildesc = self.detailpanel:AddChild(Text(BODYTEXTFONT, 25))
        self.detaildesc:SetString(STRINGS.UI.MODSSCREEN.NO_MODS)
        self.detaildesc:SetPosition(6, -8, 0)
        self.detaildesc:SetRegionSize(352, 165)
        self.detaildesc:EnableWordWrap(true)

        self.modlinkbutton = self.detailpanel:AddChild(TextButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex", "blank.tex"))
        self.modlinkbutton:SetPosition(5, -119, 0)
        self.modlinkbutton:SetFont(BUTTONFONT)
        self.modlinkbutton:SetTextSize(30)
        self.modlinkbutton:SetTextColour(0.9, 0.8, 0.6, 1)
        self.modlinkbutton:SetTextFocusColour(1, 1, 1, 1)
        self.modlinkbutton:SetText(STRINGS.UI.MODSSCREEN.NO_MODS_LINK)
        self.modlinkbutton:SetOnClick(function()
            self:MoreMods()
        end)
    end
end

-- Not currently used, for testing only.
local function OnUpdateWorkshopModsComplete(success, msg)
    print("OnUpdateWorkshopModsComplete", success, msg)

    local status = TheSim:GetWorkshopUpdateStatus()
    for k, v in pairs(status) do
        print("-", k, v)
    end

    local modInfo = TheSim:GetWorkshopMods()
    for i, v in ipairs(modInfo) do
        print("   ", i)
        for k, v in pairs(v) do
            print("   ", k, v)
        end
    end
end

function ModsScreen:StartWorkshopUpdate()
    if TheSim:UpdateWorkshopMods(function()
        self:WorkshopUpdateComplete()
    end) then
        self.updatetask = scheduler:ExecutePeriodic(0, self.ShowWorkshopStatus, nil, 0, "workshopupdate", self)
    else
        self:WorkshopUpdateComplete()
    end
end

function ModsScreen:WorkshopUpdateComplete(status, message)
    --bool, string

    if self.updatetask then
        self.updatetask:Cancel()
        self.updatetask = nil
    end
    if self.workshopupdatenote then
        TheFrontEnd:PopScreen()
        self.workshopupdatenote = nil
    end

    KnownModIndex:UpdateModInfo()
    self.modnames = KnownModIndex:GetModNames()
    local function alphasort(moda, modb)
        if not moda then
            return false
        end
        if not modb then
            return true
        end
        return string.lower(KnownModIndex:GetModFancyName(moda)) < string.lower(KnownModIndex:GetModFancyName(modb))
    end
    table.sort(self.modnames, alphasort)

    self:ReloadModInfoPrefabs()

    self:CreateDetailPanel()
    self:Scroll(0)

    if #self.modnames > 0 then
        self:ShowModDetails(1)
    end
end

function ModsScreen:ShowWorkshopStatus()
    if not self.workshopupdatenote then
        self.workshopupdatenote = PopupDialogScreen(STRINGS.UI.MODSSCREEN.WORKSHOP.UPDATE_TITLE, "", {  })
        TheFrontEnd:PushScreen(self.workshopupdatenote)
    end

    local status = TheSim:GetWorkshopUpdateStatus()
    local statetext = ""
    if status.state == "list" then
        statetext = STRINGS.UI.MODSSCREEN.WORKSHOP.STATE_LIST
    elseif status.state == "details" then
        statetext = STRINGS.UI.MODSSCREEN.WORKSHOP.STATE_DETAILS
    elseif status.state == "download" then
        local progressstring = ""
        if status.progress == 0 then
            progressstring = STRINGS.UI.MODSSCREEN.WORKSHOP.STATE_DOWNLOAD_0
        else
            progressstring = string.format(STRINGS.UI.MODSSCREEN.WORKSHOP.STATE_DOWNLOAD_PERCENT, string.match(tostring(status.progress * 100), "^%d*"))
        end
        statetext = STRINGS.UI.MODSSCREEN.WORKSHOP.STATE_DOWNLOAD .. "\n" .. progressstring
    end
    self.workshopupdatenote.text:SetString(statetext)
end

function ModsScreen:OnControl(control, down)
    if ModsScreen._base.OnControl(self, control, down) then
        return true
    end

    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:PopScreen()
        return true
    end
end

function ModsScreen:RefreshOptions()

    for k, v in pairs(self.optionwidgets) do
        v:Kill()
    end
    self.optionwidgets = {}
    self.optionspanel:Clear()

    local page_total = math.min(#self.modnames - self.option_offset, display_rows)
    for k = 1, page_total do

        local idx = self.option_offset + k

        local modname = self.modnames[idx]
        local modinfo = KnownModIndex:GetModInfo(modname)

        local opt = self.optionspanel:AddCustomItem(Widget("option"))

        opt.idx = idx

        opt.bg = opt:AddChild(UIAnim())
        opt.bg:GetAnimState():SetBuild("savetile")
        opt.bg:GetAnimState():SetBank("savetile")
        opt.bg:GetAnimState():PlayAnimation("anim")

        opt.checkbox = opt:AddChild(Image("images/ui.xml", "button_checkbox1.tex"))
        opt.checkbox:SetPosition(-140, 0, 0)
        opt.checkbox:SetScale(0.5, 0.5, 0.5)

        opt.image = opt:AddChild(Image("images/ui.xml", "portrait_bg.tex"))
        --opt.image:SetScale(imscale,imscale,imscale)
        opt.image:SetPosition(-75, 0, 0)
        if modinfo and modinfo.icon and modinfo.icon_atlas then
            opt.image:SetTexture("../mods/" .. modname .. "/" .. modinfo.icon_atlas, modinfo.icon)
        end
        opt.image:SetSize(76, 76)

        opt.name = opt:AddChild(Text(TITLEFONT, 35))
        opt.name:SetVAlign(ANCHOR_MIDDLE)
        opt.name:SetHAlign(ANCHOR_LEFT)
        opt.name:SetString(modname)
        if modinfo and modinfo.name then
            opt.name:SetString(modinfo.name)
        end
        opt.name:SetPosition(65, 8, 0)
        opt.name:SetRegionSize(200, 50)

        opt.status = opt:AddChild(Text(BODYTEXTFONT, 20))
        opt.status:SetVAlign(ANCHOR_MIDDLE)
        opt.status:SetHAlign(ANCHOR_LEFT)
        opt.status:SetString(modname)
        local modStatus = self:GetBestModStatus(modname)
        if modStatus == "WORKING_NORMALLY" then
            opt.status:SetString(STRINGS.UI.MODSSCREEN.STATUS.WORKING_NORMALLY)
        elseif modStatus == "WILL_ENABLE" then
            opt.status:SetString(STRINGS.UI.MODSSCREEN.STATUS.WILL_ENABLE)
        elseif modStatus == "WILL_DISABLE" then
            opt.status:SetColour(.7, .7, .7, 1)
            opt.status:SetString(STRINGS.UI.MODSSCREEN.STATUS.WILL_DISABLE)
        elseif modStatus == "DISABLED_ERROR" then
            opt.status:SetColour(0.9, 0.3, 0.3, 1)
            opt.status:SetString(STRINGS.UI.MODSSCREEN.STATUS.DISABLED_ERROR)
        elseif modStatus == "DISABLED_OLD" then
            opt.status:SetColour(0.8, 0.8, 0.3, 1)
            opt.status:SetString(STRINGS.UI.MODSSCREEN.STATUS.DISABLED_OLD)
        elseif modStatus == "DISABLED_MANUAL" then
            opt.status:SetColour(.7, .7, .7, 1)
            opt.status:SetString(STRINGS.UI.MODSSCREEN.STATUS.DISABLED_MANUAL)
        end
        opt.status:SetPosition(66, -22, 0)
        opt.status:SetRegionSize(200, 50)

        local scale = 1.5
        local nudgex = 8
        local nudgey = -3

        opt.HAMcompatible = opt:AddChild(Image("images/ui.xml", "ham_off.tex"))
        if modinfo and modinfo.hamlet_compatible then
            if modinfo.hamlet_compatibility_specified == false then
                opt.HAMcompatible:SetTexture("images/ui.xml", "ham_unknown.tex")
            else
                opt.HAMcompatible:SetTexture("images/ui.xml", "ham_on.tex")
            end
        end
        opt.HAMcompatible:SetClickable(false)
        opt.HAMcompatible:SetScale(.35 / scale, .33 / scale, 1 / scale)
        opt.HAMcompatible:SetPosition(144 + nudgex, -21 + nudgey, 0)

        opt.SWcompatible = opt:AddChild(Image("images/ui.xml", "sw_off.tex"))
        if modinfo and modinfo.shipwrecked_compatible then
            if modinfo.shipwrecked_compatibility_specified == false then
                opt.SWcompatible:SetTexture("images/ui.xml", "sw_unknown.tex")
            else
                opt.SWcompatible:SetTexture("images/ui.xml", "sw_on.tex")
            end
        end
        opt.SWcompatible:SetClickable(false)
        opt.SWcompatible:SetScale(.35 / scale, .33 / scale, 1 / scale)
        opt.SWcompatible:SetPosition(115 + nudgex, -21 + nudgey, 0)

        opt.RoGcompatible = opt:AddChild(Image("images/ui.xml", "rog_off.tex"))
        if modinfo and modinfo.reign_of_giants_compatible then
            if modinfo.reign_of_giants_compatibility_specified == false then
                opt.RoGcompatible:SetTexture("images/ui.xml", "rog_unknown.tex")
            else
                opt.RoGcompatible:SetTexture("images/ui.xml", "rog_on.tex")
            end
        end
        opt.RoGcompatible:SetClickable(false)
        opt.RoGcompatible:SetScale(.35 / scale, .33 / scale, 1 / scale)
        opt.RoGcompatible:SetPosition(86 + nudgex, -21 + nudgey, 0)

        opt.DScompatible = opt:AddChild(Image("images/ui.xml", "ds_off.tex"))
        if modinfo and modinfo.dont_starve_compatible then
            if modinfo.dont_starve_compatibility_specified == false then
                opt.DScompatible:SetTexture("images/ui.xml", "ds_unknown.tex")
            else
                opt.DScompatible:SetTexture("images/ui.xml", "ds_on.tex")
            end
        end
        opt.DScompatible:SetClickable(false)
        opt.DScompatible:SetScale(.35 / scale, .33 / scale, 1 / scale)
        opt.DScompatible:SetPosition(57 + nudgex, -21 + nudgey, 0)

        if KnownModIndex:IsModEnabled(modname) then
            opt.image:SetTint(1, 1, 1, 1)
            opt.checkbox:SetTexture("images/ui.xml", "button_checkbox2.tex")
            opt.checkbox:SetTint(1, 1, 1, 1)
            opt.name:SetColour(1, 1, 1, 1)
            opt.HAMcompatible:SetTint(1, 1, 1, 1)
            opt.SWcompatible:SetTint(1, 1, 1, 1)
            opt.RoGcompatible:SetTint(1, 1, 1, 1)
            opt.DScompatible:SetTint(1, 1, 1, 1)
        else
            opt.image:SetTint(1.0, 0.5, 0.5, 1)
            opt.checkbox:SetTexture("images/ui.xml", "button_checkbox1.tex")
            opt.checkbox:SetTint(1.0, 0.5, 0.5, 1)
            opt.name:SetColour(.7, .7, .7, 1)
            opt.HAMcompatible:SetTint(1.0, 0.5, 0.5, 1)
            opt.SWcompatible:SetTint(1.0, 0.5, 0.5, 1)
            opt.RoGcompatible:SetTint(1.0, 0.5, 0.5, 1)
            opt.DScompatible:SetTint(1.0, 0.5, 0.5, 1)
        end

        local spacing = 105

        opt.OnGainFocus = function()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
            self:ShowModDetails(idx)
            opt:SetScale(1.1, 1.1, 1)
            opt.bg:GetAnimState():PlayAnimation("over")
        end

        opt.OnLoseFocus = function()
            opt:SetScale(1, 1, 1)
            opt.bg:GetAnimState():PlayAnimation("anim")
        end

        opt.OnControl = function(_, control, down)
            if Widget.OnControl(opt, control, down) then
                return true
            end
            if control == CONTROL_ACCEPT and not down then
                self:EnableCurrent()
                self.optionspanel.items[k]:SetFocus() -- this menu gets recreated in EnableCurrent so refocus.
                return true
            end
        end

        opt:SetPosition(0, (display_rows - 1) * spacing * .5 - (k - 1) * spacing - 00, 0)

        table.insert(self.optionwidgets, opt)
    end

    for k, v in ipairs(self.optionspanel.items) do
        if k > 1 then
            self.optionspanel.items[k]:SetFocusChangeDir(MOVE_UP, function()
                self:ShowModDetails(self.optionspanel.items[k - 1].idx)
                return self.optionspanel.items[k - 1]
            end)
        end

        if k < #self.optionspanel.items then
            self.optionspanel.items[k]:SetFocusChangeDir(MOVE_DOWN, function()
                self:ShowModDetails(self.optionspanel.items[k + 1].idx)
                return self.optionspanel.items[k + 1]
            end)
        end
    end

    if self.optionspanel.items == nil or #self.optionspanel.items == 0 then
        return
    end

    self.optionspanel.items[1]:SetFocusChangeDir(MOVE_UP, function()
        if not self:OnFirstPage() then
            self:ShowModDetails(self.optionspanel.items[1].idx - 1)
            self:Scroll(-display_rows)
            return self.optionspanel.items[#self.optionspanel.items]
        end
        return self.optionspanel.items[1]
    end)

    self.optionspanel.items[#self.optionspanel.items]:SetFocusChangeDir(MOVE_DOWN, function()
        if not self:OnLastPage() then
            self:ShowModDetails(self.optionspanel.items[#self.optionspanel.items].idx + 1)
            self:Scroll(display_rows)
            return self.optionspanel.items[1]
        end
        return self.optionspanel.items[#self.optionspanel.items]
    end)


end

function ModsScreen:OnFirstPage()
    return self.option_offset == 0
end

function ModsScreen:OnLastPage()
    return self.option_offset + display_rows >= #self.modnames
end

function ModsScreen:Scroll(dir)
    if (dir > 0 and (self.option_offset + display_rows) < #self.modnames) or
            (dir < 0 and self.option_offset + dir >= 0) then

        self.option_offset = self.option_offset + dir
    end

    self:RefreshOptions()

    if self.option_offset > 0 then
        self.leftbutton:Show()
    else
        self.leftbutton:Hide()
    end

    if self.option_offset + display_rows < #self.modnames then
        self.rightbutton:Show()
    else
        self.rightbutton:Hide()
    end
end

function ModsScreen:GetBestModStatus(modname)
    local modinfo = KnownModIndex:GetModInfo(modname)
    if KnownModIndex:IsModEnabled(modname) then
        if KnownModIndex:WasModEnabled(modname) then
            return "WORKING_NORMALLY"
        else
            return "WILL_ENABLE"
        end
    else
        if KnownModIndex:WasModEnabled(modname) then
            return "WILL_DISABLE"
        else
            if KnownModIndex:GetModInfo(modname).failed or KnownModIndex:IsModKnownBad(modname) then
                return "DISABLED_ERROR"
            elseif KnownModIndex:GetModInfo(modname).old then
                return "DISABLED_OLD"
            else
                return "DISABLED_MANUAL"
            end
        end
    end
end

function ModsScreen:ShowModDetails(idx)
    self.currentmod = idx

    local modname = self.modnames[idx]
    local modinfo = KnownModIndex:GetModInfo(modname)

    if modinfo.icon and modinfo.icon_atlas then
        self.detailimage:SetTexture("../mods/" .. modname .. "/" .. modinfo.icon_atlas, modinfo.icon)
        self.detailimage:SetSize(102, 102)
    else
        self.detailimage:SetTexture("images/ui.xml", "portrait_bg.tex")
        self.detailimage:SetSize(102, 102)
    end
    if modinfo.name then
        self.detailtitle:SetString(modinfo.name)
    else
        self.detailtitle:SetString(modname)
    end
    if modinfo.version then
        --self.detailversion:setstring( string.format(strings.ui.modsscreen.version, modinfo.version))
    else
        --self.detailversion:setstring( string.format(strings.ui.modsscreen.version, 0))
    end
    if modinfo.author then
        self.detailauthor:SetString(string.format(STRINGS.UI.MODSSCREEN.AUTHORBY, modinfo.author))
    else
        self.detailauthor:SetString(string.format(STRINGS.UI.MODSSCREEN.AUTHORBY, "unknown"))
    end
    if modinfo.description then
        self.detaildesc:SetString(modinfo.description)
    else
        self.detaildesc:SetString("")
    end

    if modinfo.forumthread then
        self.modlinkbutton:SetText(STRINGS.UI.MODSSCREEN.MODLINK)
    else
        self.modlinkbutton:SetText(STRINGS.UI.MODSSCREEN.MODLINKGENERIC)
    end

    if modinfo.dont_starve_compatible and modinfo.reign_of_giants_compatible and modinfo.shipwrecked_compatible and modinfo.hamlet_compatible then
        if modinfo.dont_starve_compatibility_specified == false and modinfo.reign_of_giants_compatibility_specified == false and modinfo.shipwrecked_compatibility_specified == false then
            self.detailcompatibility:SetString(STRINGS.UI.MODSSCREEN.COMPATIBILITY_UNKNOWN)
        else
            self.detailcompatibility:SetString(STRINGS.UI.MODSSCREEN.COMPATIBILITY_ALL)
        end
    else
        if modinfo.dont_starve_compatible and not modinfo.reign_of_giants_compatible and not modinfo.shipwrecked_compatible and not modinfo.hamlet_compatible then
            self.detailcompatibility:SetString(STRINGS.UI.MODSSCREEN.COMPATIBILITY_DS_ONLY)
        elseif not modinfo.dont_starve_compatible and modinfo.reign_of_giants_compatible and not modinfo.shipwrecked_compatible and not modinfo.hamlet_compatible then
            self.detailcompatibility:SetString(STRINGS.UI.MODSSCREEN.COMPATIBILITY_ROG_ONLY)
        elseif not modinfo.dont_starve_compatible and not modinfo.reign_of_giants_compatible and modinfo.shipwrecked_compatible and not modinfo.hamlet_compatible then
            self.detailcompatibility:SetString(STRINGS.UI.MODSSCREEN.COMPATIBILITY_SW_ONLY)
        elseif not modinfo.dont_starve_compatible and not modinfo.reign_of_giants_compatible and not modinfo.shipwrecked_compatible and modinfo.hamlet_compatible then
            self.detailcompatibility:SetString(STRINGS.UI.MODSSCREEN.COMPATIBILITY_SW_ONLY)
        elseif modinfo.dont_starve_compatible or modinfo.reign_of_giants_compatible or modinfo.shipwrecked_compatible then
            --[[local str = STRINGS.UI.MODSSCREEN.COMPATIBILITY_SOME
            if modinfo.dont_starve_compatible then
                str = str .. STRINGS.UI.MODSSCREEN.COMPATIBILITY_DS .. " "
            end
            if modinfo.reign_of_giants_compatible then
                str = str .. STRINGS.UI.MODSSCREEN.COMPATIBILITY_ROG .. " "
            end
            if modinfo.shipwrecked_compatible then
                str = str .. STRINGS.UI.MODSSCREEN.COMPATIBILITY_SW .. " "
            end]]
            self.detailcompatibility:SetString("")
        else
            self.detailcompatibility:SetString(STRINGS.UI.MODSSCREEN.COMPATIBILITY_NONE)
        end
    end

    if KnownModIndex:HasModConfigurationOptions(modname) then
        self.modconfigbutton:Show()

        -- Rebuild controller focus directions
        if (TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse) then
            self.applybutton:SetFocusChangeDir(MOVE_UP, self.modconfigbutton)
            self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.modconfigbutton)
            self.modconfigbutton:SetFocusChangeDir(MOVE_LEFT, self.optionspanel)
            self.modconfigbutton:SetFocusChangeDir(MOVE_DOWN, self.applybutton)
            if PLATFORM ~= "WIN32_RAIL" then
                self.modconfigbutton:SetFocusChangeDir(MOVE_RIGHT, self.morebutton)
            end
        end
    else
        self.modconfigbutton:Hide()

        -- Clear out controller focus directions when we hide it
        if (TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse) then
            self.applybutton:SetFocusChangeDir(MOVE_UP, nil)
            self.cancelbutton:SetFocusChangeDir(MOVE_UP, nil)
            self.modconfigbutton:ClearFocusDirs()
        end
    end

    self.detailwarning:SetColour(1, 1, 1, 1)
    local modStatus = self:GetBestModStatus(modname)
    if modStatus == "WORKING_NORMALLY" then
        --self.enablespinner:SetSelected(ENABLE)
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.WORKING_NORMALLY)
    elseif modStatus == "WILL_ENABLE" then
        --self.enablespinner:SetSelected(ENABLE)
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.WILL_ENABLE)
    elseif modStatus == "WILL_DISABLE" then
        --self.enablespinner:SetSelected(DISABLE)
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.WILL_DISABLE)
    elseif modStatus == "DISABLED_ERROR" then
        --self.enablespinner:SetSelected(DISABLE)
        self.detailwarning:SetColour(0.9, 0.3, 0.3, 1)
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.DISABLED_ERROR)
    elseif modStatus == "DISABLED_OLD" then
        --self.enablespinner:SetSelected(DISABLE)
        self.detailwarning:SetColour(0.8, 0.8, 0.3, 1)
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.DISABLED_OLD)
    elseif modStatus == "DISABLED_MANUAL" then
        --self.enablespinner:SetSelected(DISABLE)
        self.detailwarning:SetString(STRINGS.UI.MODSSCREEN.DISABLED_MANUAL)
    end
end

function ModsScreen:OnConfirmEnableCurrent(data, restart)
    local modname = self.modnames[self.currentmod]
    if data == DISABLE then
        KnownModIndex:Disable(modname)
    elseif data == ENABLE then
        KnownModIndex:Enable(modname)
    else
        if KnownModIndex:IsModEnabled(modname) then
            KnownModIndex:Disable(modname)
        else
            KnownModIndex:Enable(modname)
        end
    end
    self:Scroll(0)
    self:ShowModDetails(self.currentmod)

    if restart then
        KnownModIndex:Save()
        TheSim:Quit()
    end
end

function ModsScreen:EnableCurrent(data)
    local modname = self.modnames[self.currentmod]
    local modinfo = KnownModIndex:GetModInfo(modname)

    if modinfo.restart_required then
        print("RESTART REQUIRED")
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MODSSCREEN.RESTART_TITLE, STRINGS.UI.MODSSCREEN.RESTART_REQUIRED,
                {
                    { text = STRINGS.UI.MODSSCREEN.RESTART, cb = function()
                        self:OnConfirmEnableCurrent(data, true)
                    end },
                    { text = STRINGS.UI.MODSSCREEN.CANCEL, cb = function()
                        TheFrontEnd:PopScreen()
                    end }
                }))
    else
        self:OnConfirmEnableCurrent(data, false)
    end
end

function ModsScreen:ModLinkCurrent()
    local modname = self.modnames[self.currentmod]
    local thread = KnownModIndex:GetModInfo(modname).forumthread

    local url = ""
    if thread then
        url = "http://forums.kleientertainment.com/index.php?%s"
        url = string.format(url, KnownModIndex:GetModInfo(modname).forumthread)
    else
        url = "http://forums.kleientertainment.com/index.php?/forum/26-dont-starve-mods-and-tools/"
    end

    VisitURL(url)
end

function ModsScreen:MoreMods()
    if PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM" then
        VisitURL("https://steamcommunity.com/app/219740/workshop/")
    else
        VisitURL("http://forums.kleientertainment.com/files/")
    end
end

function ModsScreen:Cancel()
    KnownModIndex:RestoreCachedSaveData()
    self:UnloadModInfoPrefabs(self.infoprefabs)
    self.cb(false)
end

function ModsScreen:Apply()
    KnownModIndex:Save()
    self:UnloadModInfoPrefabs(self.infoprefabs)
    self.cb(true)
end

function ModsScreen:ConfigureSelectedMod()
    local modname = self.modnames[self.currentmod]
    local modinfo = KnownModIndex:GetModInfo(modname)
    TheFrontEnd:PushScreen(ModConfigurationScreen(modname))
end

function ModsScreen:LoadModInfoPrefabs(prefabtable)
    for i, modname in ipairs(KnownModIndex:GetModNames()) do
        local info = KnownModIndex:GetModInfo(modname)
        if info.icon_atlas and info.icon then
            local atlaspath = "../mods/" .. modname .. "/" .. info.icon_atlas
            local iconpath = string.gsub(atlaspath, "/[^/]*$", "") .. "/" .. info.icon
            if softresolvefilepath(atlaspath) and softresolvefilepath(iconpath) then
                local modinfoassets = {
                    Asset("ATLAS", atlaspath),
                    Asset("IMAGE", iconpath),
                }
                local prefab = Prefab("modbaseprefabs/MODSCREEN_" .. modname, nil, modinfoassets, nil)
                RegisterPrefabs(prefab)
                table.insert(prefabtable, prefab.name)
            else
                -- This prevents malformed icon paths from crashing the game.
                print(string.format("WARNING: icon paths for mod %s are not valid. Got icon_atlas=\"%s\" and icon=\"%s\".\nPlease ensure that these point to valid files in your mod folder, or else comment out those lines from your modinfo.lua.", ModInfoname(modname), info.icon_atlas, info.icon))
                info.icon_atlas = nil
                info.icon = nil
            end
        end
    end

    print("Loading Mod Info Prefabs")
    TheSim:LoadPrefabs(prefabtable)
end

function ModsScreen:UnloadModInfoPrefabs(prefabtable)
    print("Unloading Mod Info Prefabs")
    TheSim:UnloadPrefabs(prefabtable)
    for k, v in pairs(prefabtable) do
        prefabtable[k] = nil
    end
end

function ModsScreen:ReloadModInfoPrefabs()
    print("Reloading Mod Info Prefabs")
    -- load before unload -- this prevents the refcounts of prefabs from going 1,
    -- 0, 1 (which triggers a resource unload and crashes). Instead we load first,
    -- so the refcount goes 1, 2, 1 for existing prefabs so everything stays the
    -- same.
    local oldprefabs = self.infoprefabs
    local newprefabs = {}
    self:LoadModInfoPrefabs(newprefabs)
    self:UnloadModInfoPrefabs(oldprefabs)
    self.infoprefabs = newprefabs
end

function ModsScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}


    -- table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_PAGELEFT) .. " " .. STRINGS.UI.HELP.SCROLLBACK)
    -- table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_PAGERIGHT) .. " " .. STRINGS.UI.HELP.SCROLLFWD)

    --table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_FOCUS_LEFT) .. " " .. STRINGS.UI.HELP.NEXTCHARACTER)
    --table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_FOCUS_RIGHT) .. " " .. STRINGS.UI.HELP.PREVCHARACTER)

    if table.contains(self.optionwidgets, TheFrontEnd:GetFocusWidget()) then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.TOGGLE)
    end

    if not self.no_cancel then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    end

    return table.concat(t, "  ")
end

return ModsScreen
