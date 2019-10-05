local PopupDialogScreen = require "screens/popupdialog"
local RunningProfilePopup = require "screens/runningprofilepopup"
local SubmittingBugReportPopup = require "screens/submittingbugreportpopup"

function ShowBugReportPopup()
    SetPause(true, "bugreportconf")

    local function onNo()
        SetPause(false, "bugreportconf")
        TheFrontEnd:PopScreen()
    end

    local RECORD_SECONDS = 3

    local function onYes()
        SetPause(false, "bugreportconf")
        TheFrontEnd:PopScreen()
		SaveGameIndex:SaveCurrent()
        local profilepopup = RunningProfilePopup(RECORD_SECONDS, function()
            local data = {
                Current_Slot = SaveGameIndex:GetCurrentSaveSlot() or "<unknown>",
                Current_Mode = SaveGameIndex:GetCurrentMode() or "<unknown>",
                Slot_Gen_Options = SaveGameIndex:GetSlotGenOptions() or {},
                Slot_Mods = SaveGameIndex:GetSlotMods() or {},
                Filename = SaveGameIndex:GetSaveGameName( SaveGameIndex:GetCurrentMode(), SaveGameIndex:GetCurrentSaveSlot() ) or "<unknown>",
				Update = GetLastPerfEntLists()
            }
            local s = DataDumper(data, nil, false, 0)
            TheSystemService:FileBugReport(s)
            TheFrontEnd:PushScreen(SubmittingBugReportPopup())
        end)
        TheFrontEnd:PushScreen(profilepopup)
    end

    local popup = PopupDialogScreen(
        STRINGS.UI.BUGREPORTSCREEN.SUBMIT_TITLE,
        string.format(STRINGS.UI.BUGREPORTSCREEN.SUBMIT_TEXT, RECORD_SECONDS),
        {
            {text=STRINGS.UI.BUGREPORTSCREEN.NO, cb = onNo},
            {text=STRINGS.UI.BUGREPORTSCREEN.YES, cb = onYes},
        }
    )

    TheFrontEnd:PushScreen(popup)
end

