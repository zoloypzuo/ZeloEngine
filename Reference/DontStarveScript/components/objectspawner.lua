local ObjectSpawner = Class(function(self, inst)
	self.inst = inst
	self.objects = {}
	self.onnewobjectfn = nil
end)

function ObjectSpawner:OnSave()
	local data = {}
	local references = {}
	for k,v in pairs(self.objects) do
		if not data.objects then
			data.objects = {v.GUID}
		else
			table.insert(data.objects, v.GUID)
		end
		table.insert(references, v.GUID)
	end

	return data, references
end

function ObjectSpawner:LoadPostPass(newents, data)
	if data.objects then
		for k,v in pairs(data.objects) do
			local child = newents[v]
			if child then
				child = child.entity
				self:TakeOwnership(child)
			end
		end
	end
end

function ObjectSpawner:TakeOwnership(obj)
	table.insert(self.objects, obj)
	if self.onnewobjectfn then
		self.onnewobjectfn(self.inst, obj)
	end
end

function ObjectSpawner:SpawnObject(obj)
	obj = SpawnPrefab(obj)
	table.insert(self.objects, obj)
	if self.onnewobjectfn then
		self.onnewobjectfn(self.inst, obj)
	end
	return obj
end

return ObjectSpawner