local function AnnounceMountHealth(inst, self)
    self._mountannouncetask = nil
    local mount = self:GetMount()
    if mount ~= nil and mount.components.health ~= nil and mount.components.health:GetPercent() < 0.2 then
        inst:PushEvent("mountwounded")
    end
end

local Rider = Class(function(self, inst)
    self.inst = inst
    self.mount = nil
    self.saddle = nil

    self._mountannouncetask = nil

    self._onSaddleChanged = function(mount, data)
        self.saddle = data.saddle
    end
end)

function Rider:OnRemoveFromEntity()
    if self._mountannouncetask ~= nil then
        self._mountannouncetask:Cancel()
        self._mountannouncetask = nil
    end
    self:StopTracking(self.mount)
end

function Rider:StartTracking(mount)
    self:StopTracking(self.mount)
    if mount ~= nil then
        self.inst:ListenForEvent("saddlechanged", self._onSaddleChanged, mount)
        self.saddle = mount.components.rideable ~= nil and mount.components.rideable.saddle or nil
    end
end

function Rider:StopTracking(mount)
    if mount ~= nil then
        self.inst:RemoveEventCallback("saddlechanged", self._onSaddleChanged, mount)
        self.saddle = nil
    end
end

function Rider:GetSaddle()
    return self.saddle
end

function Rider:Mount(target, instant)
    if self.riding or target.components.rideable == nil or target.components.rideable:IsBeingRidden() then
        print("RIDER EXIT 1")
        return
    end

    if not target.components.rideable:TestObedience() then
        self.inst:PushEvent("refusedmount", {rider=self.inst,rideable=target})
        target:PushEvent("refusedrider", {rider=self.inst,rideable=target})
        print("RIDER EXIT 2")
        return
    end

    local rideable = target.components.rideable
    local saddler = rideable.saddle.components.saddler

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local tx, ty, tz = target.Transform:GetWorldPosition()

    self.riding = true

    self.inst.AnimState:SetBank("wilsonbeefalo")
    if target.ApplyBuildOverrides ~= nil then
        target:ApplyBuildOverrides(self.inst.AnimState)
    end
    self.inst.AnimState:OverrideSymbol("swap_saddle", saddler.swapbuild, saddler.swapsymbol)
    self.inst.Transform:SetSixFaced()

    self.inst.sg:GoToState(instant and "idle" or "mount")

    self.inst.DynamicShadow:SetSize(6, 2)

    if self.inst.components.sheltered ~= nil then
        self.inst.components.sheltered:Stop()
    end

    if target.components.combat ~= nil then
        self.inst.components.combat.redirectdamagefn =
            function(inst, attacker, damage, weapon, stimuli)
                return target:IsValid()
                    and not (target.components.health ~= nil and target.components.health:IsDead())
                    and not (weapon ~= nil and (weapon.components.projectile ~= nil or weapon.components.weapon:CanRangedAttack()))
                    and stimuli ~= "electric"
                    and stimuli ~= "darkness"
                    and target
                    or nil
            end
    end

    --self.inst.components.pinnable.canbepinned = false

    self.inst:AddChild(target)
    target.Transform:SetPosition(0, 0, 0) -- make sure we're centered, so poop lands in the right spot!
    target.Transform:SetRotation(0)
    target:RemoveFromScene()
    if target.components.brain ~= nil then
        BrainManager:Hibernate(target)
    end
    if target.SoundEmitter ~= nil then
        target.SoundEmitter:KillAllSounds()
    end

    self:StartTracking(target)
    self.mount = target
    target.components.rideable:SetRider(self.inst)

    self.inst.Physics:Teleport(tx, ty, tz)
    self.inst:FacePoint(x, y, z)

    self._mountannouncetask = self.inst:DoTaskInTime(2 + math.random() * 2, AnnounceMountHealth, self)

    self.inst:PushEvent("mounted", { target = target })
    self.inst:PushEvent("mounthurt")    
end

function Rider:Dismount()
    self.inst:PushEvent("dismount")
end

-- This is not to be called during normal gameplay, call Dismount() instead.
-- This one is for the SG to call, or cleanup code.
function Rider:ActualDismount()
    if not self.riding then
        return
    end

    self.riding = false

    if self._mountannouncetask ~= nil then
        self._mountannouncetask:Cancel()
        self._mountannouncetask = nil
    end

    self.inst.AnimState:SetBank("wilson")
    if self.mount.ClearBuildOverrides ~= nil then
        self.mount:ClearBuildOverrides(self.inst.AnimState)
    end
    self.inst.AnimState:ClearOverrideSymbol("swap_saddle")
    self.inst.Transform:SetFourFaced()

    self.inst.DynamicShadow:SetSize(1.3, .6)

    if self.inst.components.sheltered ~= nil then
        self.inst.components.sheltered:Start()
    end

    if self.mount.components.combat ~= nil then
        self.inst.components.combat.redirectdamagefn = nil
    end

    --self.inst.components.pinnable.canbepinned = true

    self.mount.components.rideable:SetRider(nil)

    self.inst:RemoveChild(self.mount)
    self.mount:ReturnToScene()

    if self.mount.Physics ~= nil then
        self.mount.Physics:Teleport(self.inst.Transform:GetWorldPosition())
    else
        self.mount.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
    end
    self.mount.Transform:SetRotation(self.inst.Transform:GetRotation())

    if self.mount.components.brain ~= nil then
        BrainManager:Wake(self.mount)
    end
    if not self.mount.components.health:IsDead() then
        self.mount.sg:GoToState("idle")
    end

    local ex_mount = self.mount
    self:StopTracking(ex_mount)
    self.mount = nil

    self.inst:PushEvent("dismounted", { target = ex_mount })
    self.inst:PushEvent("mounthurt")

    return ex_mount
end

function Rider:IsRiding()
    return self.riding
end

function Rider:GetMount()
    return self.mount
end

-- This needs to save because of autosave, but in the standard quit/load flow, players will be removed from their beefalo. ~gjans
function Rider:OnSave()
    local data = {}
    if self.mount ~= nil then
        data.mount = self.mount:GetSaveRecord()
    end
    return data
end

function Rider:OnLoad(data)
    if data and data.mount ~= nil then
        local mount = SpawnSaveRecord(data.mount)
        self:Mount(mount, true)
    end
end

function Rider:CollectSceneActions(doer, actions, right)
    if right and self.inst == doer and doer.components.rider:IsRiding() then
        table.insert(actions, ACTIONS.DISMOUNT)
    end
end

function Rider:IsMountHurt()
    return self.mount and self.mount.components.health and self.mount.components.health:GetPercent() < 0.2
end

return Rider
