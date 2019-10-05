local Widget = Class(function(self, name)
    self.children = {}
    self.callbacks = {}
    self.name = name or "widget"
    self.inst = CreateEntity()
    self.inst.widget = self
    
    self.inst:AddTag("widget")
    self.inst:AddTag("UI")
    self.inst.entity:SetName(name)
    self.inst.entity:AddUITransform()
	self.inst.entity:CallPrefabConstructionComplete()
    
    self.inst:AddComponent("uianim")
    
    self.enabled = true
    self.shown = true
    self.focus = false
    self.focus_target = false

    self.focus_flow = {}
    self.focus_flow_args = {}
end)


function Widget:IsDeepestFocus()
    if self.focus then
        for k,v in pairs(self.children) do
            if v.focus then return false end
        end
    end

    return true
end

function Widget:OnMouseButton(button, down, x, y)
    if not self.focus then return false end

    for k,v in pairs (self.children) do
        if v.focus and v:OnMouseButton(button, down, x, y) then return true end
    end 

end


function Widget:MoveToBack()
    self.inst.entity:MoveToBack()
end

function Widget:MoveToFront()
    self.inst.entity:MoveToFront()
end

function Widget:OnFocusMove(dir, down)
	--print ("OnFocusMove", self.name or "?", self.focus, dir, down)
    if not self.focus then return false end

    for k,v in pairs (self.children) do
        if v.focus and v:OnFocusMove(dir, down) then return true end
    end 

    if down and self.focus_flow[dir] then
		
		local dest = self.focus_flow[dir]
        if dest and type(dest) == "function" then dest = dest() end
        
        -- Can we pass the focus down the chain if we are disabled/hidden?
        if dest and dest:IsVisible() and dest.enabled then
			if self.focus_flow_args[dir] then
				dest:SetFocus(unpack(self.focus_flow_args[dir]))
			else
				dest:SetFocus()
			end
            return true
        end
    end

    return false
end

function Widget:IsVisible()
	if not self.shown then return false end

	if self.parent then
		return self.parent:IsVisible()
	end

	return true	
end

function Widget:OnRawKey(key, down)
    if not self.focus then return false end
    for k,v in pairs (self.children) do
        if v.focus and v:OnRawKey(key, down) then return true end
    end 
end

function Widget:OnTextInput(text)
	--print ("text", self, text)
    if not self.focus then return false end
    for k,v in pairs (self.children) do
        if v.focus and v:OnTextInput(text) then return true end
    end 
end

function Widget:OnControl(control, down)
--    print("oncontrol", self, control, down, self.focus)

    if not self.focus then return false end

    for k,v in pairs (self.children) do
        if v.focus and v:OnControl(control, down) then return true end
    end 

    return false
end

function Widget:Shake(duration, speed, scale)
    if not self.inst.components.uianim then
        self.inst:AddComponent("uianim")
    end
    self.inst.components.uianim:Shake(duration, speed, scale)
end

function Widget:ScaleTo(from, to, time, fn)
    
    if not self.inst.components.uianim then
        self.inst:AddComponent("uianim")
    end
    self.inst.components.uianim:ScaleTo(from, to, time, fn)
end

function Widget:MoveTo(from, to, time, fn)
    if not self.inst.components.uianim then
        self.inst:AddComponent("uianim")
    end
    self.inst.components.uianim:MoveTo(from, to, time, fn)
end

function Widget:ForceStartWallUpdating()
    if not self.inst.components.uianim then
        self.inst:AddComponent("uianim")
    end
    self.inst.components.uianim:ForceStartWallUpdating(self)
end

function Widget:ForceStopWallUpdating()
    if not self.inst.components.uianim then
        self.inst:AddComponent("uianim")
    end
    self.inst.components.uianim:ForceStopWallUpdating(self)
end

function Widget:IsEnabled()
    if not self.enabled then return false end

    if self.parent then
        return self.parent:IsEnabled()
    end

    return true
end

function Widget:GetParent()
    return self.parent
end

function Widget:GetChildren()
    return self.children
end


function Widget:SetEnabled(enabled)
    if enabled then
        self:Enable()
    else
        self:Disable()
    end
end

function Widget:Enable()
    self.enabled = true
	self:OnEnable()
end

function Widget:Disable()
    self.enabled = false
	self:OnDisable()
end

function Widget:OnEnable()
end

function Widget:OnDisable()
end

function Widget:RemoveChild(child)
    if child then
        self.children[child] = nil
        child.parent = nil
        child.inst.entity:SetParent(nil)
    end

end

function Widget:KillAllChildren()
    for k,v in pairs(self.children) do
        self:RemoveChild(k)
        k:Kill()
    end
end


function Widget:AddChild(child)
    if child.parent then
        child.parent.children[child] = nil
    end

    self.children[child] = child
    child.parent = self
    child.inst.entity:SetParent(self.inst.entity)
    return child
end

function Widget:Hide()
    self.inst.entity:Hide(false)
    self.shown = false
	self:OnHide()
end

function Widget:Show()
    self.inst.entity:Show(false)
    self.shown = true
	self:OnShow()
end

function Widget:Kill()
	self:StopUpdating()	
	self:KillAllChildren()
    if self.parent then
        self.parent.children[self] = nil
    end
    self.inst.widget = nil
    self:StopFollowMouse()
    self.inst:Remove()
end

function Widget:GetWorldPosition()
    return Vector3(self.inst.UITransform:GetWorldPosition())
end

function Widget:GetPosition()
    return Vector3(self.inst.UITransform:GetLocalPosition())
end

function Widget:Nudge(offset)
    local o_pos = self:GetLocalPosition()
    local n_pos = o_pos + offset
    self:SetPosition(n_pos)
end

function Widget:GetLocalPosition()
    return Vector3(self.inst.UITransform:GetLocalPosition())
end

function Widget:SetPosition(pos, y, z)
    if type(pos) == "number" then
        self.inst.UITransform:SetPosition(pos,y,z or 0)
    else
        if not self.inst:IsValid() then
			print (debugstack())
        end
        self.inst.UITransform:SetPosition(pos.x,pos.y,pos.z)
    end
end

function Widget:SetRotation(angle)
    self.inst.UITransform:SetRotation(angle)
end

	
function Widget:SetMaxPropUpscale(val)
	self.inst.UITransform:SetMaxPropUpscale(val)
end

function Widget:SetScaleMode(mode)
	self.inst.UITransform:SetScaleMode(mode)
end

function Widget:SetScale(pos, y, z)
    if type(pos) == "number" then
        self.inst.UITransform:SetScale(pos, y or pos, z or pos)
    else
        self.inst.UITransform:SetScale(pos.x,pos.y,pos.z)
    end
end

function Widget:HookCallback(event, fn)
    if self.callbacks[event] then
        self.inst:RemoveEventCallback(event, self.callbacks[event])
    end
    self.callbacks[event] = fn
    self.inst:ListenForEvent(event, fn)
end

function Widget:SetVAnchor(anchor)
    self.inst.UITransform:SetVAnchor(anchor)
end

function Widget:SetHAnchor(anchor)
    self.inst.UITransform:SetHAnchor(anchor)
end

function Widget:OnShow()
end

function Widget:OnHide()
end

function Widget:SetTooltip(str)
    self.tooltip = str
end

function Widget:SetTooltipColour(r,g,b,a)
    self.tooltipcolour = {r, g, b, a}
end

function Widget:GetTooltipColour()
    if self.focus then
        for k,v in pairs(self.children) do
            local col = k:GetTooltipColour()
            if col then
                return col
            end
        end
        return self.tooltipcolour
    end
end

function Widget:GetTooltip()
    if self.focus then
        for k,v in pairs(self.children) do
            local str = k:GetTooltip()
            if str then
                return str
            end
        end
        return self.tooltip
    end
end

function Widget:StartUpdating()
	TheFrontEnd:StartUpdatingWidget(self)
end

function Widget:StopUpdating()
	TheFrontEnd:StopUpdatingWidget(self)
end

--[[function Widget:Update(dt)
    if not self.enabled then return end
    if self.OnUpdate then
        self:OnUpdate(dt)
    end

    for k,v in pairs(self.children) do
		if v.OnUpdate or #v.children > 0 then
			v:Update(dt)        
		end
    end
end--]]


function Widget:SetClickable(val)
    self.inst.entity:SetClickable(val)
end

function Widget:UpdatePosition(x,y)
    self:SetPosition(x,y,0)
end

function Widget:FollowMouse()
    if not self.followhandler then
        self.followhandler = TheInput:AddMoveHandler(function(x,y) self:UpdatePosition(x,y) end)
        self:SetPosition(TheInput:GetScreenPosition())
    end
end

function Widget:StopFollowMouse()
    if self.followhandler then
        self.followhandler:Remove()
    end
    self.followhandler = nil
end


function Widget:GetScale()

	local sx, sy, sz = self.inst.UITransform:GetScale()

	if self.parent then
		local scale = self.parent:GetScale()
		sx = sx*scale.x
		sy = sy*scale.y
		sz = sz*scale.z
	end
	
	return Vector3(sx,sy,sz)
end


---------------------------focus management


function Widget:OnGainFocus()
end

function Widget:OnLoseFocus()
end

function Widget:ClearFocusDirs()
    self.focus_flow = {}
end

function Widget:SetFocusChangeDir(dir, widget, ...)
    
    if not next(self.focus_flow) then
        self.next_in_tab_order = widget
    end

    self.focus_flow[dir] = widget
    
    if ... then
		self.focus_flow_args[dir] = {...}
	end
end

function Widget:GetDeepestFocus()
    if self.focus then
        for k,v in pairs(self.children) do
            if v.focus then
                return v:GetDeepestFocus()
            end
        end

        return self
    end
end

function Widget:ClearFocus()
    if self.focus then
        self.focus = false
        if self.OnLoseFocus then
            self:OnLoseFocus()
        end
    for k,v in pairs(self.children) do
            if v.focus then 
                v:ClearFocus()
            end
        end
    end    
end

function Widget:SetFocusFromChild(from_child)
    for k,v in pairs(self.children) do
        if v ~= from_child and v.focus then
            v:ClearFocus()
        end
    end

    if not self.focus then
        self.focus = true
        if self.OnGainFocus then
            self:OnGainFocus()
        end

        if self.parent then
            self.parent:SetFocusFromChild(self)
        end
    end
end

function Widget:SetFocus()
    --print ("SET FOCUS, ", self)
    if self.focus_forward then
        self.focus_forward:SetFocus()
        return
    end

    if not self.focus then
        self.focus = true

        if self.OnGainFocus then
            self:OnGainFocus()
        end

        if self.parent then
            self.parent:SetFocusFromChild(self)
        end
    end

    for k,v in pairs(self.children) do
        v:ClearFocus()
    end

    --print(debugstack())

end



function Widget:GetStr(indent)
    indent = indent or 0
    local indent_str = string.rep("\t",indent)

    local str = {}
    table.insert(str, string.format("%s%s%s%s\n", indent_str, tostring(self), self.focus and " (FOCUS) " or "", self.enable and " (ENABLE) " or "" ))
    
    for k,v in pairs(self.children) do
        table.insert(str, v:GetStr(indent + 1))
    end

    return table.concat(str)

end

function Widget:__tostring()
    return tostring(self.name)
end

return Widget
