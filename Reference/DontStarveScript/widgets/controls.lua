local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Inv = require "widgets/inventorybar"
local Widget = require "widgets/widget"
local CraftTabs = require "widgets/crafttabs"
local HoverText = require "widgets/hoverer"
local MapControls = require "widgets/mapcontrols"
local ContainerWidget = require("widgets/containerwidget")
local DemoTimer = require "widgets/demotimer"
local SavingIndicator = require "widgets/savingindicator"
local UIClock = require "widgets/uiclock"
local MapScreen = require "screens/mapscreen"
local FollowText = require "widgets/followtext"
local StatusDisplays = require "widgets/statusdisplays"
local ChatQueue = require "widgets/chatqueue"

local easing = require("easing")


local MAX_HUD_SCALE = 1.25


local Controls = Class(Widget, function(self, owner)
    Widget._ctor(self, "Controls")
    self.owner = owner


    self.playeractionhint = self:AddChild(FollowText(TALKINGFONT, 28))
    self.playeractionhint:SetOffset(Vector3(0, 100, 0))
    self.playeractionhint:Hide()

    self.attackhint = self:AddChild(FollowText(TALKINGFONT, 28))
    self.attackhint:SetOffset(Vector3(0, 100, 0))
    self.attackhint:Hide()

    self.groundactionhint = self:AddChild(FollowText(TALKINGFONT, 28))
    self.groundactionhint:SetOffset(Vector3(0, 100, 0))
    self.groundactionhint:Hide()


    self.blackoverlay = self:AddChild(Image("images/global.xml", "square.tex"))
    self.blackoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.blackoverlay:SetClickable(false)
	self.blackoverlay:SetTint(0,0,0,.5)
	self.blackoverlay:Hide()


    self.containerroot = self:AddChild(Widget(""))
	self:MakeScalingNodes()
    
    self.saving = self:AddChild(SavingIndicator(self.owner))
    self.saving:SetHAnchor(ANCHOR_MIDDLE)
    self.saving:SetVAnchor(ANCHOR_TOP)
    self.saving:SetPosition(Vector3(200,0,0))
    
    self.inv = self.bottom_root:AddChild(Inv(self.owner))

	self.sidepanel = self.topright_root:AddChild(Widget("sidepanel"))
	self.sidepanel:SetScale(1,1,1)
	self.sidepanel:SetPosition(-80, -60, 0)

    self.status = self.sidepanel:AddChild(StatusDisplays(self.owner))
    self.status:SetPosition(0,-110,0)
    
    self.clock = self.sidepanel:AddChild(UIClock(self.owner))

    local broadcasting_options = TheFrontEnd:GetBroadcastingOptions()
    if broadcasting_options ~= nil and broadcasting_options:SupportedByPlatform() then
        if broadcasting_options:IsInitialized() and broadcasting_options:GetBroadcastingEnabled() and broadcasting_options:GetVisibleChatEnabled() then
            self.chatqueue = self.sidepanel:AddChild(ChatQueue(self.owner))
        end
    end
	
    if GetWorld() and GetWorld():IsCave() then
    	self.clock:Hide()
    	self.status:SetPosition(-10,-20,0)
    end

	self.containers = {}

	self.mapcontrols = self.bottomright_root:AddChild(MapControls())
	self.mapcontrols:SetPosition(-60,70,0)
	
    if false and not IsGamePurchased() then
		self.demotimer = self.top_root:AddChild(DemoTimer(self.owner))
		self.demotimer:SetPosition(320, -25, 0)
	end
	
    self.containerroot:SetHAnchor(ANCHOR_MIDDLE)
    self.containerroot:SetVAnchor(ANCHOR_MIDDLE)
	self.containerroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.containerroot:SetMaxPropUpscale(MAX_HUD_SCALE)
	self.containerroot = self.containerroot:AddChild(Widget(""))
	
	self.containerroot_side = self:AddChild(Widget(""))
    self.containerroot_side:SetHAnchor(ANCHOR_RIGHT)
    self.containerroot_side:SetVAnchor(ANCHOR_MIDDLE)
	self.containerroot_side:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.containerroot_side:SetMaxPropUpscale(MAX_HUD_SCALE)
	self.containerroot_side = self.containerroot_side:AddChild(Widget("contaierroot_side"))
	
    self.mousefollow = self:AddChild(Widget("follower"))
    self.mousefollow:FollowMouse(true)
    self.mousefollow:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.hover = self:AddChild(HoverText(self.owner))
    self.hover:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.crafttabs = self.left_root:AddChild(CraftTabs(self.owner, self.top_root))

    self:SetHUDSize()

	self:StartUpdating()
end)

function Controls:OnMessageReceived( username, message )
    local player = GetPlayer()
    if player ~= nil then
        if self.chatqueue ~= nil and ( PLATFORM == "WIN32_STEAM" or PLATFORM == "WIN32") then
            self.chatqueue:OnMessageReceived(username,message)
        end
    end
end

function Controls:ShowStatusNumbers()
	self.status.brain.num:Show()
	self.status.stomach.num:Show()
	self.status.heart.num:Show()
end

function Controls:HideStatusNumbers()
	self.status.brain.num:Hide()
	self.status.stomach.num:Hide()
	self.status.heart.num:Hide()
end

function Controls:SetDark(val)
	if val then self.blackoverlay:Show() else self.blackoverlay:Hide() end
end


function Controls:MakeScalingNodes()

	--these are auto-scaling root nodes
	self.top_root = self:AddChild(Widget("top"))
    self.top_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.top_root:SetHAnchor(ANCHOR_MIDDLE)
    self.top_root:SetVAnchor(ANCHOR_TOP)
    self.top_root:SetMaxPropUpscale(MAX_HUD_SCALE)

    self.bottom_root = self:AddChild(Widget("bottom"))
    self.bottom_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.bottom_root:SetHAnchor(ANCHOR_MIDDLE)
    self.bottom_root:SetVAnchor(ANCHOR_BOTTOM)
    self.bottom_root:SetMaxPropUpscale(MAX_HUD_SCALE)

    self.topright_root = self:AddChild(Widget("side"))
    self.topright_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.topright_root:SetHAnchor(ANCHOR_RIGHT)
    self.topright_root:SetVAnchor(ANCHOR_TOP)
    self.topright_root:SetMaxPropUpscale(MAX_HUD_SCALE)

    
    self.bottomright_root = self:AddChild(Widget(""))
    self.bottomright_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.bottomright_root:SetHAnchor(ANCHOR_RIGHT)
    self.bottomright_root:SetVAnchor(ANCHOR_BOTTOM)
    self.bottomright_root:SetMaxPropUpscale(MAX_HUD_SCALE)

	self.left_root = self:AddChild(Widget("left_root"))
    self.left_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.left_root:SetHAnchor(ANCHOR_LEFT)
    self.left_root:SetVAnchor(ANCHOR_MIDDLE)
    self.left_root:SetMaxPropUpscale(MAX_HUD_SCALE)    


	
	--these are for introducing user-configurable hud scale
	self.topright_root = self.topright_root:AddChild(Widget("top_scale_root"))
	self.bottom_root = self.bottom_root:AddChild(Widget("bottom_scale_root"))
	self.top_root = self.top_root:AddChild(Widget("top_scale_root"))
	self.left_root = self.left_root:AddChild(Widget("left_scale_root"))
	self.bottomright_root = self.bottomright_root:AddChild(Widget("br_scale_root"))
	--
end

function Controls:SetHUDSize(  )
	local scale = TheFrontEnd:GetHUDScale()
	self.topright_root:SetScale(scale,scale,scale)
	self.bottom_root:SetScale(scale,scale,scale)
	self.top_root:SetScale(scale,scale,scale)
	self.bottomright_root:SetScale(scale,scale,scale)
	self.left_root:SetScale(scale,scale,scale)
	self.containerroot:SetScale(scale,scale,scale)
	self.containerroot_side:SetScale(scale,scale,scale)
	self.hover:SetScale(scale,scale,scale)
	
	self.mousefollow:SetScale(scale,scale,scale)
end


function Controls:OnUpdate(dt)
    
	local controller_mode = TheInput:ControllerAttached()
	local controller_id = TheInput:GetControllerID()
	
	if controller_mode then
		self.mapcontrols:Hide()
	else		
		self.mapcontrols:Show()
	end


    for k,v in pairs(self.containers) do
		if v.should_close_widget then
			self.containers[k] = nil
			v:Kill()
		end
	end
    
    if self.demotimer then
		if IsGamePurchased() then
			self.demotimer:Kill()
			self.demotimer = nil
		end
	end
	
	if controller_mode and not self.inv.open and not self.crafttabs.controllercraftingopen then

		local ground_l, ground_r = self.owner.components.playercontroller:GetGroundUseAction()
		local ground_cmds = {}
		if self.owner.components.playercontroller.deployplacer or self.owner.components.playercontroller.placer then
			local placer = self.terraformplacer

			if self.owner.components.playercontroller.deployplacer then
				self.groundactionhint:Show()
				self.groundactionhint:SetTarget(self.owner.components.playercontroller.deployplacer)
				
				if self.owner.components.playercontroller.deployplacer.components.placer.can_build then
					if TheInput:ControllerAttached() then
						self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION) .. " " .. self.owner.components.playercontroller.deployplacer.components.placer:GetDeployAction():GetActionString().."\n"..TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..STRINGS.UI.HUD.CANCEL)
					else
						self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION) .. " " .. self.owner.components.playercontroller.deployplacer.components.placer:GetDeployAction():GetActionString())
					end
						
				else
					self.groundactionhint.text:SetString("")	
				end
				
			elseif self.owner.components.playercontroller.placer then
				self.groundactionhint:Show()
				self.groundactionhint:SetTarget(self.owner)
				self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION) .. " " .. STRINGS.UI.HUD.BUILD.."\n" .. TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. STRINGS.UI.HUD.CANCEL.."\n")	
			end
		elseif ground_r then
			--local cmds = {}
			self.groundactionhint:Show()
			self.groundactionhint:SetTarget(self.owner)				
			table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. ground_r:GetActionString())
			self.groundactionhint.text:SetString(table.concat(ground_cmds, "\n"))
		elseif not ground_r then
			self.groundactionhint:Hide()
		end
		
		local attack_shown = false
		if self.owner.components.playercontroller.controller_target and self.owner.components.playercontroller.controller_target:IsValid() then

			local cmds = {}
			local textblock = self.playeractionhint.text
			if self.groundactionhint.shown and 
			distsq(GetPlayer():GetPosition(), self.owner.components.playercontroller.controller_target:GetPosition()) < 1.33 then
				--You're close to your target so we should combine the two text blocks.
				cmds = ground_cmds
				textblock = self.groundactionhint.text
				self.playeractionhint:Hide()
			else
				self.playeractionhint:Show()
				self.playeractionhint:SetTarget(self.owner.components.playercontroller.controller_target)
			end

			local l, r = self.owner.components.playercontroller:GetSceneItemControllerAction(self.owner.components.playercontroller.controller_target)
						
			local target = self.owner.components.playercontroller.controller_target
			
			table.insert(cmds, target:GetDisplayName())

			if target == self.owner.components.playercontroller.controller_attack_target then
				table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HUD.ATTACK)
				attack_shown = true
			end
			if GetPlayer():CanExamine() and target.components.inspectable then
				table.insert(cmds,TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. STRINGS.UI.HUD.INSPECT)
			end
			if l then
				table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION) .. " " .. l:GetActionString())
			end
			if r and not ground_r then
				table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. r:GetActionString())
			end

			textblock:SetString(table.concat(cmds, "\n"))
		elseif self.owner.components.rider and self.owner.components.rider:IsRiding() then
            self.playeractionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..STRINGS.ACTIONS.DISMOUNT.DISMOUNT)
            self.playeractionhint:Show()
            self.playeractionhint:SetTarget(self.owner)			
		else
			self.playeractionhint:Hide()
			self.playeractionhint:SetTarget(nil)
		end
		
		if self.owner.components.playercontroller.controller_attack_target and not attack_shown then
			self.attackhint:Show()
			self.attackhint:SetTarget(self.owner.components.playercontroller.controller_attack_target)
			self.attackhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HUD.ATTACK)
		else
			self.attackhint:Hide()
			self.attackhint:SetTarget(nil)
		end
		
	else
	
		self.attackhint:Hide()
		self.attackhint:SetTarget(nil)
		
		self.playeractionhint:Hide()
		self.playeractionhint:SetTarget(nil)
		
		self.groundactionhint:Hide()
		self.groundactionhint:SetTarget(nil)
	end
	

	--default offsets	
	self.playeractionhint:SetScreenOffset(0,0)
	self.attackhint:SetScreenOffset(0,0)
	
	--if we are showing both hints, make sure they don't overlap
	if self.attackhint.shown and self.playeractionhint.shown then
		
		local w1, h1 = self.attackhint.text:GetRegionSize()
		local x1, y1 = self.attackhint:GetPosition():Get()
		--print (w1, h1, x1, y1)
		
		local w2, h2 = self.playeractionhint.text:GetRegionSize()
		local x2, y2 = self.playeractionhint:GetPosition():Get()
		--print (w2, h2, x2, y2)
		
		local sep = (x1 + w1/2) < (x2 - w2/2) or
					(x1 - w1/2) > (x2 + w2/2) or
					(y1 + h1/2) < (y2 - h2/2) or					
					(y1 - h1/2) > (y2 + h2/2)
					
		if not sep then
			local a_l = x1 - w1/2
			local a_r = x1 + w1/2
			
			local p_l = x2 - w2/2
			local p_r = x2 + w2/2
			
			if math.abs(p_r - a_l) < math.abs(p_l - a_r) then
				local d = (p_r - a_l) + 20
				self.attackhint:SetScreenOffset(d/2,0)
				self.playeractionhint:SetScreenOffset(-d/2,0)
			else
				local d = (a_r - p_l) + 20
				self.attackhint:SetScreenOffset( -d/2,0)
				self.playeractionhint:SetScreenOffset(d/2,0)
			end
		end
	end
		
		
end

function Controls:ToggleMap()
	if GetWorld().minimap.MiniMap:IsVisible() then
		TheFrontEnd:PopScreen()
	else
		TheFrontEnd:PushScreen(MapScreen())
	end
end



return Controls