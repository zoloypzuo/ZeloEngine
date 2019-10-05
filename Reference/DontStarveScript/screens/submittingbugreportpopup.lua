local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local PopupDialogScreen = require "screens/popupdialog"
local ScriptErrorScreen = require "screens/scripterrorscreen"

local SubmittingBugReportPopup = Class(Screen, function(self, needsUnPause)
    Screen._ctor(self, "SubmittingBugReportPopup")

    self.needsUnPause = needsUnPause
    --darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0,0,0,.75)

    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    --throw up the background
    self.bg = self.proot:AddChild(Image("images/globalpanels.xml", "small_dialog.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(1.2,1.2,1.2)

    --text
    self.text = self.proot:AddChild(Text(BUTTONFONT, 55))
    local text = STRINGS.UI.BUGREPORTSCREEN.SUBMITTING_TEXT
    self.text:SetPosition(0, 5, 0)
    self.text:SetSize(35)
    self.text:SetString(text)
    -- self.text:SetRegionSize(140, 100)
    self.text:SetHAlign(ANCHOR_LEFT)
    self.text:SetColour(1,1,1,1)

    self.time = 0
    self.progress = 0

    self.step_time = 0
    self.elipse_state = 0

    -- Hack, we can be showing with the bugreportscreen, there is no OnUpdate then
    self.inst:AddComponent("wallupdater")
    self.inst.components.wallupdater:StartWallUpdating(function(_self, dt) self:OnWallUpdate(dt) end)

end)

function SubmittingBugReportPopup:OnWallUpdate( dt )
    local NEXT_STATE = 1
    self.step_time = self.step_time + dt
    if self.step_time > NEXT_STATE then
	if self.elipse_state == 0 then 
	    self.text:SetString(STRINGS.UI.BUGREPORTSCREEN.SUBMITTING_TEXT.."..")   
	    self.elipse_state = self.elipse_state + 1 
	elseif self.elipse_state == 1 then 
	    self.text:SetString(STRINGS.UI.BUGREPORTSCREEN.SUBMITTING_TEXT.."...")  
	    self.elipse_state = self.elipse_state + 1 
	else                               
	    self.text:SetString(STRINGS.UI.BUGREPORTSCREEN.SUBMITTING_TEXT..".")    
	    self.elipse_state = 0 
	end
	self.step_time = 0
    end		

    -- did we finish?
    if not TheSim:IsBugReportRunning() then
	local title = STRINGS.UI.BUGREPORTSCREEN.SUBMIT_FAILURE_TITLE
	local text = STRINGS.UI.BUGREPORTSCREEN.SUBMIT_FAILURE_TEXT

	local succeeded = TheSim:DidBugReportSucceed()

        if succeeded then
	    title = STRINGS.UI.BUGREPORTSCREEN.SUBMIT_SUCCESS_TITLE
	    text = string.format(STRINGS.UI.BUGREPORTSCREEN.SUBMIT_SUCCESS)
        end

        local popup = PopupDialogScreen(title, text,
            {
                {text=STRINGS.UI.BUGREPORTSCREEN.OK, cb = 
                    function() 
		        TheFrontEnd:PopScreen()
			if self.needsUnPause then
				SetPause(false)
			end
			if succeeded then
			    -- if the error screen is visible, disable the "submit bug" button
                            TheFrontEnd:PopScreen()
  			    if TheFrontEnd:IsDisplayingError() then
				local screen = TheFrontEnd:GetActiveScreen()
				if screen:is_a(ScriptErrorScreen) then
					screen:DisableSubmitButton()
				end
			    end
                        end
                    end
                },
            }
        )

        TheFrontEnd:PopScreen()
        TheFrontEnd:PushScreen(popup, true)
    end
end

return SubmittingBugReportPopup
