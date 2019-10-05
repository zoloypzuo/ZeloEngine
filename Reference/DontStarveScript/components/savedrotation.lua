local SavedRotation = Class(function(self, inst)
    self.inst = inst
end)

function SavedRotation:OnSave()
    local rot = self.inst.Transform:GetRotation()
    return rot ~= 0 and { rotation = rot } or nil
end

function SavedRotation:OnLoad(data)
    self.inst.Transform:SetRotation(data.rotation or 0)
end

return SavedRotation
