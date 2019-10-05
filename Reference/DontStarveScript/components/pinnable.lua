local pinsymbols =
{
    "swap_goo6",
    "swap_goo5",
    "swap_goo4",
    "swap_goo3",
    "swap_goo2",
    "swap_goo1",
}

local splashprefabs =
{
    "spat_splash_fx_melted",
    "spat_splash_fx_low",
    "spat_splash_fx_med",
    "spat_splash_fx_full",
}

local function WearOff(inst, self)
    self:UpdateStuckStatus()
end

local function onstuck(self, stuck)
    if stuck then
        self.inst:AddTag("pinned")
    else
        self.inst:RemoveTag("pinned")
    end
end

local function OnUnpinned(inst)
    if inst.components.pinnable:IsStuck() then
        inst.components.pinnable:Unstick()
    end
end

local function OnAttacked(inst)
    local self = inst.components.pinnable
    if self:IsStuck() then
        self.attacks_since_pinned = self.attacks_since_pinned + 1
        --print("attacks since pinned", self.attacks_since_pinned)
        self:SpawnShatterFX()
        self:UpdateStuckStatus()
    end
end

local function OnDied(inst)
    local self = inst.components.pinnable
    if self.wearofftask ~= nil then
        self.wearofftask:Cancel()
        self.wearofftask = nil
    end
end

-----------------------------------------------------------------------------------------------------

local Pinnable = Class(function(self, inst)
    self.inst = inst

    self.canbepinned = true
    self.stuck = false
    self.wearofftime = TUNING.PINNABLE_WEAR_OFF_TIME
    self.wearofftask = nil
    self.attacks_since_pinned = 0
    self.last_unstuck_time = 0
    self.last_stuck_time = 0

    self.fxlevel = 1
    self.fxdata = {}

    inst:ListenForEvent("unpinned", OnUnpinned)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("playerdied", OnDied)
end,
nil,
{
    stuck = onstuck,
})

function Pinnable:OnRemoveFromEntity()
    if self.wearofftask ~= nil then
        self.wearofftask:Cancel()
        self.wearofftask = nil
    end
    self.inst:RemoveEventCallback("unpinned", OnUnpinned)
    self.inst:RemoveEventCallback("attacked", OnAttacked)
    self.inst:RemoveEventCallback("playerdied", OnDied)
end

function Pinnable:SetDefaultWearOffTime(wearofftime)
    self.wearofftime = wearofftime
end

function Pinnable:SpawnShatterFX(ratio)
    local ratio = self:RemainingRatio()
    local index = math.clamp(math.floor(#splashprefabs*ratio)+1, 1, #splashprefabs)
    local fx = SpawnPrefab(splashprefabs[index])
    if fx ~= nil then
        self.inst:AddChild(fx)
    end
end

function Pinnable:IsStuck()
    return self.stuck
end

function Pinnable:IsValidPinTarget()
    return self.canbepinned and not self.stuck and (GetTime() > self.last_unstuck_time + TUNING.PINNABLE_RECOVERY_LEEWAY)
end

function Pinnable:StartWearingOff(wearofftime)
    if self.wearofftask ~= nil then
        self.wearofftask:Cancel()
        self.wearofftask = nil
    end
    local mintime = wearofftime < 1 and wearofftime or 1
    self.wearofftask = self.inst:DoTaskInTime(mintime, WearOff, self)
end

function Pinnable:Stick()
    if self.canbepinned and self.inst.entity:IsVisible() and (self.inst.components.health == nil or not self.inst.components.health:IsDead()) and ( not self.inst.components.rider or not self.inst.components.rider:IsRiding()) then
       
        local prevState = self.stuck
        self.stuck = true

        if self.inst.brain ~= nil then
            self.inst.brain:Stop()
        end

        if self.inst.components.combat ~= nil then
            self.inst.components.combat:SetTarget(nil)
        end

        if self.inst.components.locomotor ~= nil then
            self.inst.components.locomotor:Stop()
        end

        if self.stuck ~= prevState then
            self.attacks_since_pinned = 0
            self.last_stuck_time = GetTime()
            self:UpdateStuckStatus()

            self.inst:PushEvent("pinned")
        end
    end
end

function Pinnable:UpdateStuckStatus()
    if self:IsStuck() then
        local remaining = self:RemainingRatio()
        -- print("remaining:", remaining)
        if remaining <= 0 then
            self:Unstick()
        else
            local index = math.clamp(math.floor(#pinsymbols*remaining)+1, 1, #pinsymbols)
            self.inst.AnimState:OverrideSymbol("swap_goo", "goo", pinsymbols[index])

            self:StartWearingOff(remaining)
        end
    end
end

function Pinnable:RemainingRatio()
    local remaining = self.wearofftime - ( GetTime() - self.last_stuck_time )
    remaining = remaining - self.attacks_since_pinned * TUNING.PINNABLE_ATTACK_WEAR_OFF
    return remaining / self.wearofftime
end

function Pinnable:Unstick()
    if (self.inst.components.health == nil or not self.inst.components.health:IsDead()) and self:IsStuck() then
        self.stuck = false

        self:SpawnShatterFX()

        if self.inst.brain ~= nil then
            self.inst.brain:Start()
        end

        if self.wearofftask ~= nil then
            self.wearofftask:Cancel()
            self.wearofftask = nil
        end

        self.last_unstuck_time = GetTime()

        self.inst.AnimState:ClearOverrideSymbol("swap_goo")

        self.inst:PushEvent("onunpin")
    end
end

return Pinnable
