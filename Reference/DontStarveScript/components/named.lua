
local possiblenames = {}

local Named = Class(function(self, inst)
    self.inst = inst
    self.possiblenames = possiblenames
	self.nameformat = nil
end)

function Named:_DoSetName()
	if self.nameformat then
		self.inst.name = string.format(self.nameformat, self.name)
	else
		self.inst.name = self.name
	end
end

function Named:PickNewName()
	if #self.possiblenames > 0 then
		self.name = self.possiblenames[math.random(#self.possiblenames)]
		self:_DoSetName()
	end
end

function Named:SetName(name)
	if name == nil then
		self.name = nil
		self.inst.name = STRINGS.NAMES[string.upper(self.inst.prefab)]
	else
		self.name = name
		self:_DoSetName()
	end
end

function Named:OnSave()
    if self.name then
		local data = 
		{
			name = self.name,
			nameformat = self.nameformat
		}
		return data
	end
end   
   

function Named:OnLoad(data)
    if data and data.name then    
		self.nameformat = data.nameformat
        self.name = data.name
		self:_DoSetName()
    end
    
end



return Named
