local Stretcher = Class(function(self, inst)
    self.inst = inst
    self.target = nil
    self.restinglength = 1
    self.widthratio = 1
end)

function Stretcher:SetRestingLength(length)
    self.restinglength = length
end

function Stretcher:SetWidthRatio(ratio)
    self.widthratio = ratio
end

function Stretcher:SetStretchTarget(inst)
    self.target = inst
    if self.target then
        self.inst:StartUpdatingComponent(self)
    else
        self.inst:StopUpdatingComponent(self)
    end
end

function Stretcher:OnEntitySleep()
    self.inst:StopUpdatingComponent(self)
end

function Stretcher:OnEntityWake()
    if self.target then
        self.inst:StartUpdatingComponent(self)
    else
        self.inst:StopUpdatingComponent(self)
    end
end

function Stretcher:OnUpdate(dt)
    if not self.target or not self.target:IsValid() then
        self:SetStretchTarget(nil)
        return
    end
    
    local targetpos = Vector3(self.target.Transform:GetWorldPosition() )
    local mypos = Vector3(self.inst.Transform:GetWorldPosition() )
    local diff = targetpos - mypos
    
    self.inst:FacePoint(targetpos)
    local scale = diff:Length() / self.restinglength
    local widthscale = 1 + self.widthratio*(scale-1)
    self.inst.AnimState:SetScale(scale, widthscale)
end

return Stretcher
