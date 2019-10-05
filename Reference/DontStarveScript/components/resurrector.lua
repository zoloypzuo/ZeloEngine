local Resurrector = Class(function(self, inst)
    self.inst = inst
	self.penalty = 0
end)



--this is a bit presentationally-specific for component land but whatever.
function Resurrector:Resurrect(dude)
	
    if self.doresurrect then
        self.doresurrect(self.inst, dude)
    end	
    self.used = true
    self.active = false
    self.penalty = 0
     
    if SaveGameIndex:CanUseExternalResurector()  then
        print("Resurrector:Resurrect", self.inst)
        SaveGameIndex:DeregisterResurrector(self.inst)
    end
end

function Resurrector:CanBeUsed()
    return not self.used and self.active
end

function Resurrector:OnBuilt(builder)
    if SaveGameIndex:CanUseExternalResurector() and (self.used == nil or self.used == false) and self.active == true then
        print ("OnBuilt Saving resurrector", self.inst)
        SaveGameIndex:RegisterResurrector(self.inst, self.penalty)
    end
    
    if builder and builder.components.health then
        builder.components.health:RecalculatePenalty()
    end
end


function Resurrector:OnSave()
    if SaveGameIndex:CanUseExternalResurector()  then
        print ("Resurrector:OnSave", self.inst, "used:"..tostring(self.used) , "active:"..tostring(self.active))
        if (self.used == nil or self.used == false) and self.active == true then
            print ("Saving resurrector", self.inst)
            SaveGameIndex:RegisterResurrector(self.inst, self.penalty)
        else
            SaveGameIndex:DeregisterResurrector(self.inst)
        end
    end

    return {used = self.used, active = self.active, penalty = self.penalty}
end

function Resurrector:OnLoad(data)
    self.used = data.used or self.used
    if self.used == nil then
        self.used = false
    end

    self.active = data.active or self.active
    if self.active == nil then
        self.active = false
    end

	self.penalty = data.penalty or self.penalty
	
    if self.used and self.makeusedfn then 
        self.makeusedfn(self.inst)
    elseif self.active and self.makeactivefn then 
        self.makeactivefn(self.inst)
    end
    if SaveGameIndex:CanUseExternalResurector() then
        if (self.used == true or self.active == false) then
            SaveGameIndex:DeregisterResurrector(self.inst)
        else
            print ("Registering resurrector", self.inst)
            SaveGameIndex:RegisterResurrector(self.inst, self.penalty)
        end
    end
end

return Resurrector
