local Lock = Class(function(self, inst)
	self.inst = inst
	self.locktype = "door"
	self.onlocked = nil
	self.onunlocked = nil
	self.unlocktest = nil
	self.islocked = true
	self.isstuck = false
	self.key = nil
end)

function Lock:GetDebugString()
    return string.format("type:%s, locked:%s, isstuck:%s, key:%s", self.locktype, tostring(self.islocked), tostring(self.isstuck), tostring(self.key) )
end

function Lock:SetOnUnlockedFn(fn)
	self.onunlocked = fn
end

function Lock:SetOnLockedFn(fn)
	self.onlocked = fn
end

function Lock:CompatableKey(keytype)
	return not self:IsStuck() and keytype == self.locktype
end

function Lock:IsStuck()
    return self.isstuck
end

function Lock:IsLocked()
	return self.islocked
end

function Lock:Unlock(key, doer)
	if not self:IsStuck() and self.islocked then
		self.islocked = false
		if self.onunlocked then
			self.onunlocked(self.inst, key, doer)
		end
		if key then
		    key.components.key:OnUsed(self.inst)
		    if key.components.stackable and key.components.stackable.stacksize > 1 then
			    key = key.components.stackable:Get()
			else
			    key.components.inventoryitem:RemoveFromOwner()
		    end
		    self:SetKey(key)
		end
	end
end

function Lock:Lock(doer)
	if not self:IsStuck() and not self.islocked then
		self.islocked = true
		if self.onlocked then
			self.onlocked(self.inst, doer)
		end
		if self.key then
	        self.key.components.key:OnRemoved(self.inst, doer)
	        if doer.components.inventory then
                doer.components.inventory:GiveItem(self.key, nil, Vector3(TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition() ) ) )
	        end
		end
	    self:SetKey(nil)
	end
end

function Lock:SetKey(key)
	if self.key then
	    self.inst:RemoveChild(self.key)
	    self.key:ReturnToScene()
	end
	if key then
        self.inst:AddChild(key)
        key:RemoveFromScene()
    end
    self.key = key
end

function Lock:TestForUnlock(key)
	if self:IsStuck() then return false end
	if self.unlocktest then --manually do unlock in testforunlockfn
		self.unlocktest(key, self.inst)
	else
		self:Unlock(key)
	end
end

function Lock:SetLocked(locked)
    if locked ~= self.locked then
		if locked and self.onlocked then
			self.onlocked(self.inst)
		elseif self.onunlocked then
			self.onunlocked(self.inst)
		end
    end
	self.islocked = locked
end

function Lock:OnSave()
    local refs = nil
    if self.key then
		refs = {self.key.GUID}
    end
    return {locked = self.islocked, isstuck=self.isstuck, key=self.key and self.key.GUID}, refs
end

function Lock:OnLoad(data)
    if data then
        self.locked = nil
        self:SetLocked(data.locked)
        self.isstuck = data.isstuck
    end
end

function Lock:LoadPostPass(newents, data)
    if data and data.key then
        local key = newents[data.key]
        if key then
            self:SetKey(key.entity)
        end
    end
end

function Lock:CollectSceneActions(doer, actions)
    if not self:IsLocked() and self.key and not self:IsStuck() then
        table.insert(actions, ACTIONS.UNLOCK)
    end
end


return Lock