local WallUpdater = Class(function(self, inst)
    self.inst = inst
end)

function WallUpdater:SetWallUpdatingFunc()
    self.wallupdatefunc = func
end

function WallUpdater:StartWallUpdating(func)
    if func then
        self.wallupdatefunc = func
    end
    self.inst:StartWallUpdatingComponent(self)
end

function WallUpdater:StopWallUpdating()
    self.inst:StopWallUpdatingComponent()
end

function WallUpdater:OnWallUpdate(dt)
    if self.wallupdatefunc then
    	self.wallupdatefunc(self, dt)
    end
end

return WallUpdater