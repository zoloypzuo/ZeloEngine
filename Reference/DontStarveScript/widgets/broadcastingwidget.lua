local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"

local BroadcastingWidget = Class(Widget, function(self)
	Widget._ctor(self, "BroadcastingWidget")
	self.initialized = false
	
	

	self:StartUpdating()
end)

function BroadcastingWidget:OnUpdate()
	local broadcasting_options = TheFrontEnd:GetBroadcastingOptions()
	if broadcasting_options ~= nil then
	
		if self.initialized == false then
			local local_message_widget_bg = self:AddChild( Image() )
			local_message_widget_bg:SetTexture( "images/ui.xml", "black.tex" )
			local_message_widget_bg:SetPosition( 85, -19)
			local_message_widget_bg:ScaleToSize( 140, 28)
			local_message_widget_bg:SetTint(1,1,1,0.0)
	
			local local_message_widget = self:AddChild(Text(UIFONT, 22))
			local_message_widget:SetPosition(90, -20)
			local_message_widget:SetRegionSize( 130, 24 )
			local_message_widget:SetHAlign(ANCHOR_MIDDLE)
			local_message_widget:SetVAlign(ANCHOR_BOTTOM)
			local_message_widget:SetString("")
	
			local local_webcam_widget = self:AddChild( Image() )
			local_webcam_widget:SetTint(1,1,1,0)
	
			self.message_widget = local_message_widget
			self.message_widget_bg = local_message_widget_bg
			self.webcam_widget = local_webcam_widget
			self.cached_string  = "" 
			self.last_toggle_time  = 0 
			self.last_toggle_release = true
			self.initialized = true
		end
		
		local time = GetTime()

		-- Toggle Streaming
		local TOGGLE_REPEAT = .25
		if time - self.last_toggle_time > TOGGLE_REPEAT then
			local control_press = TheInput:IsControlPressed(CONTROL_TOGGLE_BROADCASTING)
			if self.last_toggle_release and control_press then
				broadcasting_options:ToggleStreaming()
				self.last_toggle_time = time
				self.last_toggle_release = false
			elseif not self.last_toggle_release and not control_press then
				self.last_toggle_release = true
			end
		end

		-- Update display
		if broadcasting_options:GetBroadcastingEnabled() then
			local streaming_state = broadcasting_options:GetStreamingStateString()
			if self.cached_string ~= streaming_state then
				self.cached_string = streaming_state
				self.message_widget:SetString(streaming_state)
				self.message_widget_bg:SetTint(1,1,1,0.5)
			end
			
			-- Update webcam
			if  broadcasting_options:GetWebcamEnabled() and broadcasting_options:IsStreaming() and broadcasting_options:GetWebcamTextureAvailable() then
				local webcam_texture_handle = broadcasting_options:GetWebcamTextureHandle()
				local webcam_alpha = broadcasting_options:GetWebcamAlpha()
				self.webcam_widget.inst.ImageWidget:SetTextureHandle( webcam_texture_handle )
				self.webcam_widget:SetPosition( 280, -96)
				self.webcam_widget:ScaleToSize( 220, 180 )
				self.webcam_widget:SetTint(1,1,1,webcam_alpha)
			else
				self.webcam_widget:SetTint(1,1,1,0.0)
			end	
		else
			if self.cached_string ~= "" then
				self.cached_string = ""
				self.message_widget:SetString("")
				self.message_widget_bg:SetTint(1,1,1,0.0)
			end
			self.webcam_widget:SetTint(1,1,1,0.0)
		end
	end
end

return BroadcastingWidget
