local Sleeper = Class(function(self, inst)
    self.inst = inst
    self.isasleep = false
    self.testperiod = 4
    self.lasttransitiontime = GetTime()
    self.lasttesttime = GetTime()
    self.sleeptestfn = DefaultSleepTest
    self.waketestfn = DefaultWakeTest
    self:StartTesting()
    self.resistance = 1
    self.sleepiness = 0
    self.wearofftime = 10
    self.hibernate = false
    self.nocturnal = false

    self.inst:ListenForEvent("onignite", function(inst, data)
        self:WakeUp()
    end)
    self.inst:ListenForEvent("attacked", function(inst, data)
        self:WakeUp()
    end)
    self.inst:ListenForEvent("newcombattarget", function(inst, data)
        if data.target then
            self:StartTesting()
        end
    end)
end)

function Sleeper:SetDefaultTests()
    self.sleeptestfn = DefaultSleepTest
    self.waketestfn = DefaultWakeTest
end

function Sleeper:StopTesting()
    if self.testtask then
        self.testtask:Cancel()
    end
    self.testtask = nil
end

function DefaultSleepTest(inst)

    local near_home_dist = 40
    local has_home_near = inst.components.homeseeker and
            inst.components.homeseeker.home and
            inst.components.homeseeker.home:IsValid() and
            inst:GetDistanceSqToInst(inst.components.homeseeker.home) < near_home_dist * near_home_dist

    if not inst.components.sleeper.nocturnal then
        return GetClock():IsNight()
                and not (inst.components.combat and inst.components.combat.target)
                and not (inst.components.burnable and inst.components.burnable:IsBurning())
                and not (inst.components.freezable and inst.components.freezable:IsFrozen())
                and not (inst.components.teamattacker and inst.components.teamattacker.inteam)
                and not has_home_near
    else
        return GetClock():IsDay()
                and not (inst.components.combat and inst.components.combat.target)
                and not (inst.components.burnable and inst.components.burnable:IsBurning())
                and not (inst.components.freezable and inst.components.freezable:IsFrozen())
                and not (inst.components.teamattacker and inst.components.teamattacker.inteam)
                and not has_home_near
    end
end

function DefaultWakeTest(inst)
    if not inst.components.sleeper.nocturnal then
        return GetClock():IsDay()
                or (inst.components.combat and inst.components.combat.target)
                or (inst.components.burnable and inst.components.burnable:IsBurning())
                or (inst.components.freezable and inst.components.freezable:IsFrozen())
                or (inst.components.teamattacker and inst.components.teamattacker.inteam)
                or (inst.components.health and inst.components.health.takingfiredamage)
    else
        return GetClock():IsDusk() or GetClock():IsNight()
                or (inst.components.combat and inst.components.combat.target)
                or (inst.components.burnable and inst.components.burnable:IsBurning())
                or (inst.components.freezable and inst.components.freezable:IsFrozen())
                or (inst.components.teamattacker and inst.components.teamattacker.inteam)
                or (inst.components.health and inst.components.health.takingfiredamage)

    end
end

function Sleeper:SetNocturnal(b)
    self.nocturnal = b or true
end

local function ShouldSleep(inst)
    local sleeper = inst.components.sleeper
    if sleeper then
        sleeper.lasttesttime = GetTime()
        if sleeper.sleeptestfn and sleeper.sleeptestfn(inst) then
            sleeper:GoToSleep()
        end
    end
end

local function ShouldWakeUp(inst)
    local sleeper = inst.components.sleeper
    if sleeper and sleeper.hibernate then
        sleeper:StopTesting()
        return
    end

    if sleeper then
        sleeper.lasttesttime = GetTime()
        if sleeper.waketestfn and sleeper.waketestfn(inst) then
            sleeper:WakeUp()
        end
    end
end

local function WearOff(inst)
    local sleeper = inst.components.sleeper
    if sleeper and sleeper.sleepiness > 0 then
        sleeper.sleepiness = sleeper.sleepiness - 1
        if sleeper.sleepiness <= 0 then
            sleeper.sleepiness = 0
            if sleeper.wearofftask then
                sleeper.wearofftask:Cancel()
                sleeper.wearofftask = nil
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------


function Sleeper:SetWakeTest(fn, time)
    self.waketestfn = fn
    self:StartTesting(time)
end

function Sleeper:SetSleepTest(fn)
    self.sleeptestfn = fn
    self:StartTesting()
end

function Sleeper:OnEntitySleep()
    self:StopTesting()
end

function Sleeper:OnEntityWake()
    self:StartTesting()
end

function Sleeper:SetResistance(resist)
    self.resistance = resist
end

function Sleeper:StartTesting(time)
    if self.isasleep then
        self:SetTest(ShouldWakeUp, time)
    else
        self:SetTest(ShouldSleep)
    end
end

function Sleeper:IsAsleep()
    return self.isasleep
end
function Sleeper:IsHibernating()
    return self.hibernate
end

--- Deep sleep means the sleeper was drugged, and shouldn't wake up to chase targets
function Sleeper:IsInDeepSleep()
    return self:IsAsleep() and self.sleepiness > 0
end

function Sleeper:GetTimeAwake()
    if self.isasleep then
        return 0
    else
        return GetTime() - self.lasttransitiontime
    end
end

function Sleeper:GetTimeAsleep()
    if self.isasleep then
        return GetTime() - self.lasttransitiontime
    else
        return 0
    end
end

function Sleeper:GetDebugString()
    local str = string.format("%s for %2.2f / %2.2f Sleepy: %d/%d",
            self.isasleep and "SLEEPING" or "AWAKE",
            self.isasleep and self:GetTimeAsleep() or self:GetTimeAwake(),
            self.lasttesttime + self.testtime - GetTime(),
            self.sleepiness, self.resistance)
    return str
end

function Sleeper:AddSleepiness(sleepiness, sleeptime)
    self.sleepiness = self.sleepiness + sleepiness
    if self.sleepiness > self.resistance or self.isasleep then
        self:GoToSleep(sleeptime)
    elseif self.sleepiness == self.resistance then
        self.inst:DoTaskInTime(self.resistance, function()
            self:GoToSleep(sleeptime)
        end)
    else
        if not self.wearofftask then
            self.wearofftask = self.inst:DoPeriodicTask(self.wearofftime, WearOff)
        end
    end
end

function Sleeper:GoToSleep(sleeptime)
    if self.inst.entity:IsVisible() and not (self.inst.components.health and self.inst.components.health:IsDead()) then
        local wasasleep = self.isasleep
        self.lasttransitiontime = GetTime()
        self.isasleep = true
        if self.wearofftask then
            self.wearofftask:Cancel()
            self.wearofftask = nil
        end

        if self.inst.brain then
            self.inst.brain:Stop()
        end

        if self.inst.components.combat then
            self.inst.components.combat:SetTarget(nil)
        end

        if self.inst.components.locomotor then
            self.inst.components.locomotor:Stop()
        end

        if not wasasleep then
            self.inst:PushEvent("gotosleep")
        end

        self:SetWakeTest(self.waketestfn, sleeptime)
    end
end

function Sleeper:SetTest(fn, time)
    if self.testtask then
        self.testtask:Cancel()
    end

    self.testtask = nil

    if fn and self.inst:IsValid() then
        self.testtime = math.max(0, self.testperiod + (math.random() - 0.5))    --some randomness on testing times
        self.testtask = self.inst:DoPeriodicTask(self.testtime, fn, time)
    end

end

function Sleeper:WakeUp()
    self.hibernate = false
    if (not self.inst.components.health or not self.inst.components.health:IsDead()) and self.isasleep and not self.hibernate then

        self.lasttransitiontime = GetTime()
        self.isasleep = false
        self.sleepiness = 0

        if self.inst.brain then
            self.inst.brain:Start()
        end

        self.inst:PushEvent("onwakeup")
        self:SetSleepTest(self.sleeptestfn)

    end


end

return Sleeper