local function OnDayComplete(self)
    if self.daystomoodchange and self.daystomoodchange > 0 then
        self.daystomoodchange = self.daystomoodchange - 1
        self:CheckForMoodChange()
    end
end

local Mood = Class(function(self, inst)
    self.inst = inst

    self.enabled = true

    self.moodtimeindays = {length = nil, wait = nil}
    self.isinmood = false
    self.daystomoodchange = nil
    self.onentermood = nil
    self.onleavemood = nil
    self.moodseasons = {}
    self.firstseasonadded = false

    inst:ListenForEvent("daycomplete", function(inst, data)
        if self.daystomoodchange and self.daystomoodchange > 0 then
            self.daystomoodchange = self.daystomoodchange - 1
            self:CheckForMoodChange()
        end
    end, GetWorld())
end)

function Mood:GetDebugString()
    return string.format("inmood:%s, days till change:%s %s", self.enabled and tostring(self.isinmood) or "DISABLED", tostring(self.daystomoodchange), self.seasonmood and "SEASONMOOD" or "" )
end

function Mood:Enable(enabled)
    self.enabled = enabled
    self:SetIsInMood(false, false)
end

function Mood:SetMoodTimeInDays(length, wait)
    self.moodtimeindays.length = length
    self.moodtimeindays.wait = wait
    self.daystomoodchange = wait
    self.isinmood = false
end

local function OnSeasonChange(inst, season)
    if not inst.components.mood or not inst.components.mood.enabled then
        return
    end

    local active = false
    if inst.components.mood.moodseasons then 
        for i, s in pairs(inst.components.mood.moodseasons) do
            if s == season then
                active = true
                break
            end
        end
    end
    if active then
        inst.components.mood:SetIsInMood(true, true)
    else
        inst.components.mood:ResetMood()
    end        
end

-- Use this to set the mood correctly (used for making sure the beefalo are mating when the start season is spring)
function Mood:ValidateMood()
    OnSeasonChange(self.inst, GetSeasonManager().current_season)
end

function Mood:SetMoodSeason(activeseason)
    table.insert(self.moodseasons, activeseason)
    if not self.firstseasonadded then

         self.inst:ListenForEvent("seasonChange", OnSeasonChange, GetWorld())
        self.firstseasonadded = true
    end
end

function Mood:CheckForMoodChange()
    if self.daystomoodchange == 0 then
        self:SetIsInMood(not self:IsInMood() )
    end
end

function Mood:SetInMoodFn(fn)
    self.onentermood = fn
end

function Mood:SetLeaveMoodFn(fn)
    self.onleavemood = fn
end

function Mood:ResetMood()
    if self.seasonmood then
        self.seasonmood = false
        self.isinmood = false
        self.daystomoodchange = self.moodtimeindays.wait
        if self.onleavemood then
            self.onleavemood(self.inst)
        end
    end
end

local function GetSeasonLength()
    return GetSeasonManager()[GetSeasonManager().current_season.."length"]
end

function Mood:SetIsInMood(inmood, entireseason)
    if inmood and (not self.enabled or self.moodtimeindays.length == 0) then
        return
    end

    if self.isinmood ~= inmood or entireseason then
    
        self.isinmood = inmood
        if self.isinmood then
            if entireseason then
                self.seasonmood = true
                self.daystomoodchange = GetSeasonLength() or self.moodtimeindays.length
            else
                self.seasonmood = false
                self.daystomoodchange = self.moodtimeindays.length
            end
            if self.onentermood then
                self.onentermood(self.inst)
            end
        else
            if not entireseason then
                self.seasonmood = false
                self.daystomoodchange = self.moodtimeindays.wait
            end
            if self.onleavemood then
                self.onleavemood(self.inst)
            end
        end
    end
end

function Mood:IsInMood()
    return self.isinmood
end

function Mood:OnSave()
    return {inmood = self.isinmood, daysleft = self.daystomoodchange, moodseasons = self.moodseasons }
end

function Mood:OnLoad(data)
    self.moodseasons = data.moodseasons or self.moodseasons
    self.isinmood = not data.inmood
    local active = false
    local season = GetSeasonManager().current_season
    if self.moodseasons then 
        for i, s in pairs(self.moodseasons) do
            if season and s == season then
                active = true
                break
            end
        end
    end
    self:SetIsInMood(data.inmood, active)
    self.daystomoodchange = data.daysleft
end

return Mood
