local Widget = require "widgets/widget"
local Text = require "widgets/text"
local CHAT_QUEUE_SIZE = 10
local CHAT_EXPIRE_TIME = 10.0
local CHAT_FADE_TIME = 2.0

local ChatQueue = Class(Widget, function(self)
	Widget._ctor(self, "ChatQueue")
	self.messages = {}
	self.users = {}
	self.timestamp = {}
		
	for i = 1,CHAT_QUEUE_SIZE do
		local message_widget = self:AddChild(Text(UIFONT, 22))
		message_widget:SetPosition(-135, -300 - i * 23)
		message_widget:SetRegionSize( 450, 24 )
		message_widget:SetHAlign(ANCHOR_LEFT)
		message_widget:SetVAlign(ANCHOR_MIDDLE)
		message_widget:SetString("")
		self.messages[i] = message_widget	
		
		local user_widget = self:AddChild(Text(UIFONT, 22))
		user_widget:SetPosition(-400, -300 - i * 23)
		user_widget:SetRegionSize( 75, 24 )
		user_widget:SetHAlign(ANCHOR_RIGHT)
		user_widget:SetVAlign(ANCHOR_MIDDLE)
		user_widget:SetString("")
		user_widget:SetColour(0.3,0.3,1,1)
		self.users[i] = user_widget	
		
		self.timestamp[i] = 0.0
	end	
	
	self:StartUpdating()
end)

function ChatQueue:GetChatAlpha( current_time, chat_time )
	local time_past_expiring = current_time - ( chat_time + CHAT_EXPIRE_TIME ) 
	if time_past_expiring > 0.0 then
		if time_past_expiring < CHAT_FADE_TIME then
			local alpha_fade = ( CHAT_FADE_TIME - time_past_expiring ) / CHAT_FADE_TIME
			return alpha_fade
		end
		return 0.0
	end
	return 1.0			
end

function ChatQueue:OnUpdate()
	local current_time = GetTime()
	
	for i = 1,CHAT_QUEUE_SIZE do
		local chat_time = self.timestamp[i]
			
		if chat_time > 0.0 then
			local time_past_expiring = current_time - ( chat_time + CHAT_EXPIRE_TIME ) 
			if time_past_expiring > 0.0 then
				local alpha_fade = self:GetChatAlpha( current_time, chat_time )
				self.messages[i]:SetColour(1,1,1,alpha_fade)
				self.users[i]:SetColour(0.3,0.3,1,alpha_fade)
				if alpha_fade <= 0.0 then
					-- Get out of here!
					self.timestamp[i] = 0.0
				end
			else
				-- No need to keep processing, nothing else past this point will be expired or fading
				return
			end
		end
	end
end

function ChatQueue:OnMessageReceived( username, message )
	-- Shuffle upwards
	for i = 1,CHAT_QUEUE_SIZE-1 do
		local older_message = self.messages[i]
		local newer_message = self.messages[i+1]
		older_message:SetString( newer_message:GetString() )
		local older_user = self.users[i]
		local newer_user = self.users[i+1]
		older_user:SetString( newer_user:GetString() )
		self.timestamp[i] = self.timestamp[i+1]
		
		local current_time = GetTime()
		local alpha_fade = self:GetChatAlpha( current_time, self.timestamp[i] )
		older_message:SetColour(1,1,1,alpha_fade)
		older_user:SetColour(0.3,0.3,1,alpha_fade)
	end
	-- Add our new entry
	self.messages[CHAT_QUEUE_SIZE]:SetString(message)
	self.users[CHAT_QUEUE_SIZE]:SetString(username)
	self.timestamp[CHAT_QUEUE_SIZE] = GetTime()
	self.messages[CHAT_QUEUE_SIZE]:SetColour(1,1,1,1)
	self.users[CHAT_QUEUE_SIZE]:SetColour(0.3,0.3,1,1)
end 

return ChatQueue
