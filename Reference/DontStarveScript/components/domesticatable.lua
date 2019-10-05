local easing = require("easing")

local DECAY_TASK_PERIOD = 10
-- TODO: Make these configurable from the prefab
local OBEDIENCE_DECAY_RATE = -1/(TUNING.TOTAL_DAY_TIME * 2)
local FEEDBACK_DECAY_RATE = -1/(TUNING.TOTAL_DAY_TIME * 45)


local Domesticatable = Class(function(self, inst)
    self.inst = inst

    -- I feel like it would be much cleaner to break domestication and obedience into two components, but they
    -- use a lot of the same hooks so I'm keeping them together for now.
    self.domesticated = false

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("domesticatable")

    self.domestication = 0
    self.domestication_latch = false
    self.lastdomesticationgain = 0
    self.domestication_triggerfn = nil

    self.obedience = 0
    self.minobedience = 0
    self.maxobedience = 1

    self.domesticationdecaypaused = false

    self.tendencies = {}

    self.decaytask = nil
end)

function Domesticatable:OnRemoveFromEntity()
    self:CancelTask()
    self.inst:RemoveTag("domesticatable")
end

function Domesticatable:SetDomesticationTrigger(fn)
    self.domestication_triggerfn = fn
end

function Domesticatable:GetObedience()
    return self.obedience
end

function Domesticatable:GetDomestication()
    return self.domestication
end

function Domesticatable:Validate()
    if self.obedience <= self.minobedience
        and self.inst.components.hunger:GetPercent() <= 0
        and self.domestication <= 0 then
        self:CancelTask()
        return false
    end
    return true
end

function Domesticatable:CheckForChanges()
    if not self.domesticated and self.domestication >= 1.0 then
        self.domestication_latch = true
        self.domestication = 1.0
    elseif self.domestication < 0.95 then
        self.domestication_latch = false
    end

    if self.inst.components.hunger:GetPercent() <= 0 and self.domestication <= 0 then
        self.tendencies = {}
        self.inst:PushEvent("goneferal", {domesticated = self.domesticated})
        if self.domesticated then
            self:SetDomesticated(false)
        end
    end
end

function Domesticatable:BecomeDomesticated()
    self.domestication_latch = false
    self:SetDomesticated(true)
    self.inst:PushEvent("domesticated", {tendencies=self.tendencies})
end

local function CalculateLoss(currenttime, lastgaintime)
    -- you don't lose full domestication right away, only after ignoring the critter for a while
    local delta = currenttime-lastgaintime
    local ratio = math.min(delta/(TUNING.BEEFALO_DOMESTICATION_MAX_LOSS_DAYS*TUNING.TOTAL_DAY_TIME), 1.0)
    return TUNING.BEEFALO_DOMESTICATION_LOSE_DOMESTICATION * ratio
end

local function DoDeltaObedience(self, delta)
    local old = self.obedience
    self.obedience = math.max(math.min(self.obedience + delta, self.maxobedience), self.minobedience)
    if old ~= self.obedience then
        self.inst:PushEvent("obediencedelta", { old = old, new = self.obedience })
        return true
    end
end

local function DoDeltaDomestication(self, delta)
    local old = self.domestication
    self.domestication = math.max(math.min(self.domestication + delta, 1), 0)
    self.maxobedience = 1
    if old ~= self.domestication then
        self.inst:PushEvent("domesticationdelta", { old = old, new = self.domestication })
        return true
    end
end

local function UpdateDomestication(inst, self)
    if not self.domesticationdecaypaused then
        for k,v in pairs(self.tendencies) do
            self.tendencies[k] = math.max(v + FEEDBACK_DECAY_RATE * DECAY_TASK_PERIOD, 0)
        end
    end

    -- obedience still decays even if domestication decay is paused
    DoDeltaObedience(self, OBEDIENCE_DECAY_RATE * DECAY_TASK_PERIOD)

    if self.domestication_triggerfn(inst) then
        self.lastdomesticationgain = GetTime()
        DoDeltaDomestication(self, TUNING.BEEFALO_DOMESTICATION_GAIN_DOMESTICATION * DECAY_TASK_PERIOD)
    elseif not self.domesticationdecaypaused then
        DoDeltaDomestication(self, CalculateLoss(GetTime(), self.lastdomesticationgain) * DECAY_TASK_PERIOD)
    end

    self:CheckForChanges()
    self:Validate()
end

function Domesticatable:DeltaObedience(delta)
    if DoDeltaObedience(self, delta) then
        self:CheckAndStartTask()
    end
end

function Domesticatable:DeltaDomestication(delta)
    if DoDeltaDomestication(self, delta) then
        self:CheckForChanges()
        self:CheckAndStartTask()
    end
end

function Domesticatable:DeltaTendency(tendency, delta)
    self.tendencies[tendency] = (self.tendencies[tendency] or 0) + delta
end

function Domesticatable:PauseDomesticationDecay(pause)
    self.domesticationdecaypaused = pause
end

function Domesticatable:TryBecomeDomesticated()
    if self.domestication_latch then
        self:BecomeDomesticated()
    end
end

function Domesticatable:CancelTask()
    if self.decaytask ~= nil then
        self.decaytask:Cancel()
        self.decaytask = nil
    end
end

function Domesticatable:CheckAndStartTask()
    if self:Validate() and self.decaytask == nil then
        self.decaytask = self.inst:DoPeriodicTask(DECAY_TASK_PERIOD, UpdateDomestication, 0, self)
    end
end

function Domesticatable:SetDomesticated(domesticated)
    self.domesticated = domesticated
    self:Validate()
end

function Domesticatable:IsDomesticated()
    return self.domesticated
end

function Domesticatable:SetMinObedience(min)
    self.minobedience = min
    if self.obedience < min then
        self:DeltaObedience(min - self.obedience)
    end
    self:CheckAndStartTask()
end

function Domesticatable:OnSave()
    return {
        domestication = self.domestication,
        tendencies = self.tendencies,
        domestication_latch = self.domestication_latch,
        domesticated = self.domesticated,
        obedience = self.obedience,
        minobedience = self.minobedience,
        lastdomesticationgaindelta = GetTime() - self.lastdomesticationgain,
        --V2C: domesticatable MUST load b4 rideable, and we
        --     aren't using the usual OnLoadPostPass method
        --     so... we did this! lol...
        rideable = self.inst.components.rideable ~= nil and self.inst.components.rideable:OnSaveDomesticatable() or nil,
    }
end

function Domesticatable:OnLoad(data)
    if data ~= nil then
        self.domestication = data.domestication or self.domestication
        self.tendencies = data.tendencies or self.tendencies
        self.domestication_latch = data.domestication_latch or false
        self:SetDomesticated(data.domesticated or false)
        self.obedience = 0
        self.lastdomesticationgain = GetTime() - (data.lastdomesticationgaindelta or 0)
        self:DeltaObedience(data.obedience or 0)
        self:SetMinObedience(data.minobedience or 0)
        --V2C: see above comment in OnSave
        if self.inst.components.rideable ~= nil then
            self.inst.components.rideable:OnLoadDomesticatable(data.rideable)
        end
    end
    self:CheckAndStartTask()
end

function Domesticatable:GetDebugString()
    local s = string.format("%s%s %.3f%% %s obedience: %.2f/%.3f/%.2f ",
        self.domesticated and "DOMO" or "NORMAL",
        self.domesticationdecaypaused and "(nodecay)" or "",
        self.domestication * 100, self.decaytask ~= nil and (GetTime() % 2 < 1 and " ." or ". ") or "..",
        self.minobedience, self.obedience, self.maxobedience
        )
    for k,v in pairs(self.tendencies) do
        s = s .. string.format(" %s:%.2f", k, v)
    end
    s = s .. string.format(" latch: %s", self.domestication_latch and "true" or "false")
    return s
end

return Domesticatable
