local CHECK_OFFSETS = {
    Vector3(1, 0, 0),
    Vector3(1, 0, 1),
    Vector3(0, 0, 1),
    Vector3(-1, 0, 1),
    Vector3(-1, 0, 0),
    Vector3(-1, 0, -1),
    Vector3(0, 0, -1),
    Vector3(1, 0, -1),
}

local Drifter = Class(function(self, inst)
    self.inst = inst
    self.drifttarget = nil
    self.lastdrifttime = nil

    self.lastcheckidx = 0
end)

function Drifter:SetDriftTarget(pos)
    self.drifttarget = pos
    self.inst:StartUpdatingComponent(self)
end

function Drifter:OnUpdate(dt)
    if self.drifttarget then
        self.lastdrifttime = GetTime()
        local pos = Vector3(self.inst.Transform:GetWorldPosition())
        local offset = self.drifttarget - pos
        offset:Normalize()

        local r = self.radius or 1
        local index = self.lastcheckidx + 1
        self.lastcheckidx = (self.lastcheckidx + 1) % #CHECK_OFFSETS
        if GetGroundTypeAtPosition(pos + CHECK_OFFSETS[index] * r) ~= GROUND.IMPASSABLE then
            self.drifttarget = nil
            self.inst:StopUpdatingComponent(self)
            return
        end

        local movement = offset * dt * TUNING.FLOTSAM_DRIFT_SPEED
        self.inst.Transform:SetPosition((pos + movement):Get())
    end
end

function Drifter:OnSave()
    if self.drifttarget then
        return {
            drifttarget = {
                x = self.drifttarget.x,
                y = self.drifttarget.y,
                z = self.drifttarget.z,
            }
        }
    end
end

function Drifter:OnLoad(data)
    if data.drifttarget then
        self:SetDriftTarget( Vector3(data.drifttarget.x, data.drifttarget.y, data.drifttarget.z) )
    end
end

return Drifter
