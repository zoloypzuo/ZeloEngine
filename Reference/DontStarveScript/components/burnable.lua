local function OnKilled(inst)
    if inst.components.burnable and inst.components.burnable:IsBurning() then
        inst.AnimState:SetMultColour(.2, .2, .2, 1)
    end
end

local function DoneBurning(inst)
    local burnable = inst.components.burnable
    if burnable then
        if burnable.onburnt then
            burnable.onburnt(inst)
        end

        if inst.components.explosive then
            --explosive explode
            inst.components.explosive:OnBurnt()
        end

        burnable:Extinguish()
    end
end

local Burnable = Class(function(self, inst)
    self.inst = inst

    self.flammability = 1

    self.fxdata = {}
    self.fxlevel = 1
    self.fxchildren = {}
    self.burning = false
    self.burntime = nil

    self.onignite = nil
    self.onextinguish = nil
    self.onburnt = nil
    self.canlight = true


end)

--- Set the function that will be called when the object starts burning
function Burnable:SetOnIgniteFn(fn)
    self.onignite = fn
end

--- Set the function that will be called when the object has burned completely
function Burnable:SetOnBurntFn(fn)
    self.onburnt = fn
end

--- Set the function that will be called when the object stops burning
function Burnable:SetOnExtinguishFn(fn)
    self.onextinguish = fn
end

--- Set the prefab to use for the burning effect. Overrides the default
function Burnable:SetBurningFX(name)
    self.fxprefab = name
end

function Burnable:SetBurnTime(time)
    self.burntime = time
end

--- Add an effect to be spawned when burning
-- @param prefab The prefab to spawn as the effect
-- @param offset The offset from the burning entity/symbol that the effect should appear at
-- @param followsymbol Optional symbol for the effect to follow
function Burnable:AddBurnFX(prefab, offset, followsymbol)
    table.insert(self.fxdata, { prefab = prefab, x = offset.x, y = offset.y, z = offset.z, follow = followsymbol })
end

--- Set the level of any current or future burning effects
function Burnable:SetFXLevel(level, percent)
    self.fxlevel = level

    for k, v in pairs(self.fxchildren) do
        if v.components.firefx then
            v.components.firefx:SetLevel(level)
            v.components.firefx:SetPercentInLevel(percent or 1)
        end
    end
end

function Burnable:GetLargestLightRadius()
    local largestRadius = nil
    for k, v in pairs(self.fxchildren) do
        if v.Light and v.Light:IsEnabled() then
            local radius = v.Light:GetCalculatedRadius()
            if not largestRadius or radius > largestRadius then
                largestRadius = radius
            end
        end
    end
    return largestRadius
end

function Burnable:IsBurning()
    return self.burning
end

function Burnable:GetDebugString()
    return string.format("%s ", self.burning and "BURNING" or "NOT BURNING")
end

function Burnable:OnRemoveEntity()
    self:KillFX()
end

function Burnable:Ignite(immediate)
    if not self.burning then
        self.inst:AddTag("fire")
        self.burning = true
        self.inst:ListenForEvent("death", OnKilled)

        self:SpawnFX(immediate)
        self.inst:PushEvent("onignite")
        if self.onignite then
            self.onignite(self.inst)
        end

        if self.inst.components.explosive then
            --explosive on ignite
            self.inst.components.explosive:OnIgnite()
        end

        if self.inst.components.fueled then
            self.inst.components.fueled:StartConsuming()
        end
        if self.inst.components.propagator then
            self.inst.components.propagator:StartSpreading()
        end

        if self.burntime and self.inst:IsValid() then
            if self.task then
                self.task:Cancel()
                self.task = nil
            end
            self.task = self.inst:DoTaskInTime(self.burntime, DoneBurning)
        end
    end
end

function Burnable:LongUpdate(dt)

    --kind of a coarse assumption...
    if self.burning then
        if self.task then
            self.task:Cancel()
            self.task = nil
        end
        DoneBurning(self.inst)
    end

end

function Burnable:Extinguish()
    if self.burning then

        if self.task then
            self.task:Cancel()
            self.task = nil
        end

        if self.inst.components.propagator then
            self.inst.components.propagator:StopSpreading()
        end

        self.inst:RemoveTag("fire")
        self.burning = false
        self:KillFX()
        if self.inst.components.fueled then
            self.inst.components.fueled:StopConsuming()
        end
        if self.onextinguish then
            self.onextinguish(self.inst)
        end
        self.inst:PushEvent("onextinguish")
    end
end

function Burnable:SpawnFX(immediate)
    self:KillFX()

    if not self.fxdata then
        self.fxdata = { x = 0, y = 0, z = 0, level = self:GetDefaultFXLevel() }
    end

    if self.fxdata then
        for k, v in pairs(self.fxdata) do
            local fx = SpawnPrefab(v.prefab)
            if fx then
                if v.follow then
                    local follower = fx.entity:AddFollower()
                    follower:FollowSymbol(self.inst.GUID, v.follow, v.x, v.y, v.z)
                else
                    self.inst:AddChild(fx)
                    fx.Transform:SetPosition(v.x, v.y, v.z)
                end
                table.insert(self.fxchildren, fx)
                if fx.components.firefx then
                    fx.components.firefx:SetLevel(self.fxlevel, immediate)
                end

            end
        end
    end
end

function Burnable:KillFX()
    for k, v in pairs(self.fxchildren) do
        if v.components.firefx and v.components.firefx:Extinguish() then
            v:ListenForEvent("animover", function(inst)
                inst:Remove()
            end)  --remove once the pst animation has finished
        else
            v:Remove()
        end
        self.fxchildren[k] = nil
    end
end

function Burnable:OnRemoveFromEntity()
    self:Extinguish()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

return Burnable