
BufferedAction = Class(function(self, doer, target, action, invobject, pos, recipe, distance)
    self.doer = doer
    self.target = target
    self.initialtargetowner = self.target and self.target.components.inventoryitem and self.target.components.inventoryitem.owner
    self.action = action
    self.invobject = invobject
    self.pos = pos
    self.onsuccess = {}
    self.onfail = {}
    self.recipe = recipe
    self.options = {}
    self.distance = distance or action.distance 
end)

function BufferedAction:Do()
    if self:IsValid() then
        
        local success, reason = self.action.fn(self)
        if success then
            if self.invobject and self.invobject:IsValid() then
                self.invobject:OnUsedAsItem(self.action)
            end
            self:Succeed()
            
        else
            self:Fail()
        end
        
        return success, reason
    end
end

function BufferedAction:TestForStart()
    if self:IsValid() then
        if self.action.testfn then
            local pass, reason = self.action.testfn(self)
            return pass, reason
        else
            return true
        end
    end
end

function BufferedAction:IsValid()
    
    return (not self.invobject or self.invobject:IsValid()) and
           (not self.doer or self.doer:IsValid()) and
           (not self.target or self.target:IsValid()) and
           (not (self.validfn and not self.validfn())) and
           (self.initialtargetowner == (self.target and self.target.components.inventoryitem and self.target.components.inventoryitem.owner))
end

function BufferedAction:GetActionString()

    if self.doer and self.doer.ActionStringOverride then
        local str = self.doer.ActionStringOverride(self.doer, self)
        if str then
            return str
        end
    end

    local modifier = nil
    if self.action.strfn then
		modifier = self.action.strfn(self)
    end
    return GetActionString(self.action.id, modifier)
end

function BufferedAction:__tostring()
    local str= self:GetActionString() .. " " .. tostring(self.target)
    
    if self.invobject then
        str = str.." With Inv:" .. tostring(self.invobject)
    end
    
    if self.recipe then
        str = str .. " Recipe:" ..self.recipe
    end
    return str
end

function BufferedAction:AddFailAction(fn)
    table.insert(self.onfail, fn)
end

function BufferedAction:AddSuccessAction(fn)
    table.insert(self.onsuccess, fn)
end

function BufferedAction:Succeed()
    for k,v in pairs(self.onsuccess) do
        v()
    end
    
    self.onsuccess = {}
    self.onfail = {}
    
end

function BufferedAction:Fail()
    for k,v in pairs(self.onfail) do
        v()
    end
    
    self.onsuccess = {}
    self.onfail = {}
end
