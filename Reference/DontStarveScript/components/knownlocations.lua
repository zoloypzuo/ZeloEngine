local KnownLocations = Class(function(self, inst)
    self.inst = inst
    self.locations = {}
end)

function KnownLocations:GetDebugString()
    local str = ""
    for k,v in pairs(self.locations) do
        str = str..string.format("%s: %s ", k, tostring(v))
    end
    return str
end

function KnownLocations:SerializeLocations()
    local locs = {}
        for k,v in pairs(self.locations) do
            table.insert(locs, {name = k, x = v.x, y = v.y, z = v.z})
        end
    return locs
end

function KnownLocations:DeserializeLocations(data)
    for k,v in pairs(data) do
        self:RememberLocation(v.name, Vector3(v.x, v.y, v.z))
    end
end

function KnownLocations:OnSave()
    local data = {}

    data.locations = self:SerializeLocations()

    return data
end

function KnownLocations:OnLoad(data)
    if data then
        if data.locations then
            self:DeserializeLocations(data.locations)
        end
    end
end

function KnownLocations:RememberLocation(name, pos, dont_overwrite)
    if not self.locations[name] or not dont_overwrite then
        self.locations[name] = pos
    end
end

function KnownLocations:GetLocation(name)
    return self.locations[name] 
end

function KnownLocations:ForgetLocation(name)
    self.locations[name] = nil
end

return KnownLocations
