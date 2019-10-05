require "util"
local Screen = require "widgets/screen"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local TextEdit = require "widgets/textedit"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local PopupDialogScreen = require "screens/popupdialog"
local BigPopupDialogScreen = require "screens/bigpopupdialog"
local SubmittingBugReportPopup = require "screens/submittingbugreportpopup"

local VALID_CHARS = [[ abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,:;[]\@!#$%&()'*+-/=?^_{|}~"]]

local BugReportScreen = Class(Screen, function(self)
    Screen._ctor(self, "BugReportScreen")

    if not IsPaused() then
        SetPause(true, "bugreport")
        self.needsUnPause = true
    end
    local fontsize = 30

    --darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, 0.75)

    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0, 0, 0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.panel_bg_frame = self.root:AddChild(Image("images/globalpanels.xml", "panel_upsell_small.tex"))
    self.panel_bg_frame:SetVRegPoint(ANCHOR_MIDDLE)
    self.panel_bg_frame:SetHRegPoint(ANCHOR_MIDDLE)
    self.panel_bg_frame:SetScale(1.6,1.4,1.2)

    self.title  = self.panel_bg_frame:AddChild(Text(BUTTONFONT, 
                                               fontsize, 
                                               STRINGS.UI.BUGREPORTSCREEN.DESCRIPTION_LABEL, 
                                               {0, 0, 0, 1}))
    self.title:SetPosition(0, 120)
    self.title:SetRegionSize(600, 60)
    self.title:SetHAlign(ANCHOR_MIDDLE)

    self.description_text = self.root:AddChild(Text(DEFAULTFONT, fontsize, ""))

    self.description_text:EnableWordWrap(true)

--    self.description_text.edit_text_color = {1, 1, 1, 1}
--    self.description_text.idle_text_color = {1, 1, 1, 1}
    self.description_text:SetPosition(0, 20, 0)
    self.description_text:SetRegionSize(760, 225+10)
    self.description_text:SetHAlign(ANCHOR_LEFT)
    self.description_text:SetVAlign(ANCHOR_TOP)
    self.description_text:SetColour(0.7,0.7,0.7,1)
    self.description_text:SetString(STRINGS.UI.BUGREPORTSCREEN.PLEASE_ENTER_BUG_DESCRIPTION)

    self.cancel_button = self.root:AddChild(ImageButton())
    self.cancel_button.image:SetScale(0.7)
    self.cancel_button:SetText(STRINGS.UI.MAINSCREEN.CANCEL)
    self.cancel_button:SetFont(BUTTONFONT)

    self.cancel_button:SetPosition(-350, -RESOLUTION_Y * 0.41)

    self.cancel_button:SetOnClick(function() self:CancelButton() end)

    self.submit_button = self.root:AddChild(ImageButton())
    self.submit_button.image:SetScale(0.7)
    self.submit_button:SetText(STRINGS.UI.BUGREPORTSCREEN.SUBMIT)
    self.submit_button:SetFont(BUTTONFONT)

    self.submit_button:SetPosition(350, -RESOLUTION_Y * 0.41)
    self.submit_button:Disable()

    self.submit_button:SetOnClick(function() self:FileBugReportButton() end)

    self.edit_button = self.root:AddChild(ImageButton())
    self.edit_button.image:SetScale(1.7, 0.7)
    self.edit_button:SetText(STRINGS.UI.BUGREPORTSCREEN.ENTER_BUG_DESCRIPTION)
    self.edit_button:SetFont(BUTTONFONT)

    local buttonpos = 0.2

    self.edit_button:SetPosition(0, -RESOLUTION_Y * buttonpos)

    self.edit_button:SetOnClick(function() self:EditDescription() end)

    local edit_width = 800
    local edit_bg_padding = 100
    local label_height = 50
    
    self.editroot = self.root:AddChild(Image())

    self.black = self.editroot:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0,0,0,0.5)	


    self.edit_bg = self.editroot:AddChild( Image() )
    self.edit_bg:SetTexture( "images/ui.xml", "textbox_long.tex" )
    self.edit_bg:SetPosition( 0, -RESOLUTION_Y * buttonpos )
    self.edit_bg:ScaleToSize( edit_width + edit_bg_padding, label_height )

    self.console_edit = self.editroot:AddChild( TextEdit( DEFAULTFONT, fontsize, "" ) )
    self.console_edit:SetPosition( 0, -RESOLUTION_Y * buttonpos)
    self.console_edit:SetRegionSize( edit_width, label_height )
    self.console_edit:SetHAlign(ANCHOR_LEFT)
    self.console_edit.OnTextInput = function(_self, text)
					TextEdit.OnTextInput(_self,text)
					local s = _self:GetString()
					s = string.gsub(s,"\n"," ")
					s = string.gsub(s,"\r"," ")
					_self:SetString(s)
					self.description_text:SetString(s)
				    end

    self.console_edit.OnTextEntered = function() self:OnTextEntered() end
    self.console_edit:SetFocusedImage( self.edit_bg, "images/ui.xml", "textbox_long_over.tex", "textbox_long.tex" )
    self.console_edit:SetCharacterFilter( VALID_CHARS )
    self.console_edit:SetTextLengthLimit(1024)
    self.console_edit:SetString("")

    self.console_edit:SetAllowClipboardPaste( true )

    self.editroot:Hide()
    self.inst:AddComponent("wallupdater")
    self.inst.components.wallupdater:StartWallUpdating(function(_self, dt) self:OnWallUpdate(dt) end)
end)

function BugReportScreen:OnBecomeActive()
	self:AddChild(TheFrontEnd.helptext)
    BugReportScreen._base.OnBecomeActive(self)
end

function BugReportScreen:OnBecomeInactive()
	self:RemoveChild(TheFrontEnd.helptext)
	BugReportScreen._base.OnBecomeInactive(self)
end

function BugReportScreen:OnWallUpdate(dt)
     if self.waitFn then
         self.waitTime = self.waitTime - dt
         if self.waitTime <= 0 then
             self.waitFn()
             self.waitFn = nil
         end
     end

	if self.editroot:IsVisible() and not self.console_edit.editing then
		-- hack, canceling on controller while editing doesn't hide the editroot
		self:OnTextEntered()
	end
end

function BugReportScreen:UnPauseIfNeeded()
    if self.needsUnPause then
        SetPause(false)
    end
end

-- Hack, since this screen can run after an error is thrown there's no update and thus no DoTaskInTime
function BugReportScreen:DoTaskInTime_Hack(time, func)
	self.waitTime = time
	self.waitFn = func	
end

function BugReportScreen:OnTextEntered()
    local str = TrimString(self.console_edit:GetString())
    if str == "" then
        self.description_text:SetColour(1,1,1,1)
        self.description_text:SetString(STRINGS.UI.BUGREPORTSCREEN.PLEASE_ENTER_BUG_DESCRIPTION)
        self.edit_button:SetText(STRINGS.UI.BUGREPORTSCREEN.ENTER_BUG_DESCRIPTION)
        self.submit_button:Disable()
    else
        self.description_text:SetColour(0.7,0.7,0.7,1)
        self.description_text:SetString(str)
        self.edit_button:SetText(STRINGS.UI.BUGREPORTSCREEN.CHANGE_BUG_DESCRIPTION)
        self.submit_button:Enable()
    end

    self.editroot:Hide()

    TheInputProxy:FlushInput()
    self.edit_button:Enable()
    self:DoTaskInTime_Hack(0.1, function() 
									TheFrontEnd:LockFocus(false) 
									self:SetFocus()
								end)
end

function BugReportScreen:EditDescription()
    self.edit_button:Disable()

    local str = TrimString(self.description_text:GetString())
    self.editroot:Show()

    self.console_edit:SetFocus()
    self.console_edit:SetEditing(true)
    TheFrontEnd:LockFocus(true)
end

function BugReportScreen:CancelButton()
    local str = TrimString(self.description_text:GetString())
    if str ~= "" then
 	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.BUGREPORTSCREEN.CANCEL_SUBMIT_HEADER, STRINGS.UI.BUGREPORTSCREEN.CANCEL_SUBMIT_BODY,
 	{
 		{text=STRINGS.UI.BUGREPORTSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end},
 		{text=STRINGS.UI.BUGREPORTSCREEN.YES, cb = function() self:UnPauseIfNeeded() TheFrontEnd:PopScreen() TheFrontEnd:PopScreen() end },
	}), true)
    else
	self:UnPauseIfNeeded()
	TheFrontEnd:PopScreen(self)
    end	
end

function BugReportScreen:FileBugReportButton()
    local popup = BigPopupDialogScreen(STRINGS.UI.BUGREPORTSCREEN.SUBMIT_DIALOG_HEADER, STRINGS.UI.BUGREPORTSCREEN.SUBMIT_DIALOG_BODY,
                 {
	                {text=STRINGS.UI.BUGREPORTSCREEN.SUBMIT, cb = function() TheFrontEnd:PopScreen() self:FileBugReport() end},
	                {text=STRINGS.UI.MAINSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end}  
	            }
	        )
    TheFrontEnd:PushScreen(popup, true)    
end

function BugReportScreen:FileBugReport()
    TheSim:FileBugReport(self.description_text:GetString())
    TheFrontEnd:PushScreen(SubmittingBugReportPopup(self.needsUnPause), true)
end

function BugReportScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()

	local str = TrimString(self.description_text:GetString())
	self.description_text:SetString(str)

	local haveString = (str ~= "")

	if not haveString then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.BUGREPORTSCREEN.ENTER_BUG_DESCRIPTION)
	else
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.BUGREPORTSCREEN.CHANGE_BUG_DESCRIPTION)
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION) .. " " .. STRINGS.UI.BUGREPORTSCREEN.SUBMIT)
	end
	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	return table.concat(t, "  ")
end

function BugReportScreen:OnControl(control, down)
	if BugReportScreen._base.OnControl(self, control, down) then return true end
	
	if not down and control == CONTROL_CANCEL then
		local str = TrimString(self.description_text:GetString())
		if str ~= "" then
		 	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.BUGREPORTSCREEN.CANCEL_SUBMIT_HEADER, STRINGS.UI.BUGREPORTSCREEN.CANCEL_SUBMIT_BODY,
		 	{
		 		{text=STRINGS.UI.BUGREPORTSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end},
		 		{text=STRINGS.UI.BUGREPORTSCREEN.YES, cb = function() self:UnPauseIfNeeded() TheFrontEnd:PopScreen() TheFrontEnd:PopScreen() end },
			}), true)
		else
			TheFrontEnd:PopScreen(self)
		end	
	end
	if not down and control == CONTROL_CONTROLLER_ACTION then
	        local popup = BigPopupDialogScreen(STRINGS.UI.BUGREPORTSCREEN.SUBMIT_DIALOG_HEADER, STRINGS.UI.BUGREPORTSCREEN.SUBMIT_DIALOG_BODY,
        	    {
	                {text=STRINGS.UI.BUGREPORTSCREEN.SUBMIT, cb = function() TheFrontEnd:PopScreen() self:FileBugReport() end},
	                {text=STRINGS.UI.MAINSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end}  
	            }
	        )
	        TheFrontEnd:PushScreen(popup, true)    
	end
	if not down and control == CONTROL_CONTROLLER_ATTACK then
		self:EditDescription()
	end
end

return BugReportScreen
