local easing = require "easing"

local Mix = Class(function(self, name)
    self.name = name or ""
    self.levels = {}
    self.priority = 0
    self.fadeintime = 1
end)

function Mix:__tostring()
    local t = {}
    
    for k,v in pairs(self.levels) do
        table.insert(t, string.format("%s:%2.2f", k, v))
    end
    return string.format("%s = pri:%2.2f, fade:%2.2f, levels:[%s]", self.name, self.priority, self.fadeintime, table.concat(t, ",") or "")
    
end

function Mix:Apply()
    for k,v in pairs(self.levels) do
        TheSim:SetSoundVolume(k, v)
    end
end

function Mix:SetLevel(channel, level)
    self.levels[channel] = level
end

function Mix:GetLevel(channel)
	local val = self.levels[channel] or 0
    return val
end

local Mixer = Class(function(self)
    self.mixes = {}
    self.stack = {}
    
    self.lowpassfilters = {}
    self.highpassfilters = {}
end)

function Mixer:AddNewMix(name, fadetime, priority, levels)
    local mix = Mix(name)
    mix.fadeintime = fadetime or 1
    mix.priority = priority or 0
    
    self.mixes[name] = mix
    for k,v in pairs(levels) do
        mix:SetLevel(k, v)
    end
    
    return mix
end

function Mixer:CreateSnapshot()
    
    local top = self.stack[1]
    if top then
        local snap = Mix()
        for k,v in pairs(top.levels) do
            snap:SetLevel(k, TheSim:GetSoundVolume(k))
        end
        return snap
    end
end

function Mixer:Blend()
    self.snapshot = self:CreateSnapshot()
    self.fadetimer = 0
end

function Mixer:GetLevel(lev)
	local val = TheSim:GetSoundVolume(lev)
    return val
end

function Mixer:SetLevel(name, lev)
    TheSim:SetSoundVolume(name, lev)
end

function Mixer:Update(dt)
    
    local top = self.stack[1]
    if self.snapshot and top then
        self.fadetimer = self.fadetimer + dt
        local lerp = self.fadetimer / top.fadeintime
        
        if lerp > 1 then
            self.snapshot = nil
            top:Apply()
        else
            for k,v in pairs(self.snapshot.levels) do
                local lev = easing.linear(self.fadetimer, v, top:GetLevel(k) - v, top.fadeintime)
                TheSim:SetSoundVolume(k, lev)
            end
        end
    end
    
    self:UpdateFilters(dt)
end

function Mixer:PopMix(mixname)
    local top = self.stack[1]
    for k, v in ipairs(self.stack) do
        
        
        if mixname == v.name then
            table.remove(self.stack, k)
            if top ~= self.stack[1] then
                self:Blend()
            end
            break
        end
    end
end


function Mixer:PushMix(mixname)
    
    local mix = self.mixes[mixname]
    
    local current = self.stack[1]
    
    if mix then
        table.insert(self.stack, mix)
        table.sort(self.stack, function(l, r) return l.priority > r.priority end)
        
        if current and current ~= self.stack[1] then
            self:Blend()
        elseif not current then
            mix:Apply()
        end
        
    end
end

local top_val = 25000
local bottom_val = 0
-- These suffix variables were added June 17th, 2014 in revision 104246 to "finally"
-- fix a dsp problem with setting the high and low pass filters, yet it seems to do
-- the exact opposite. I'm removing it for now, but if this removal causes issues,
-- then we may need to uncomment them again. Essentially, the problem is that the
-- suffixes cause the categories to not match in the FMOD::EventSystem and therefore
-- none of the dsp objects are added to categories.
local low_pass_category_suffix = ""-- "_low"
local high_pass_category_suffix = ""-- "_high"

function Mixer:UpdateFilters(dt)
    -- First update the filters
    for k,v in pairs(self.lowpassfilters) do
        if v and v.totaltime and v.currenttime and v.totaltime > 0 and v.currenttime < v.totaltime then
            v.currenttime = v.currenttime + dt
            v.freq = easing.linear(v.currenttime, v.startfreq, v.endfreq - v.startfreq, v.totaltime)
            TheSim:SetLowPassFilter(k..low_pass_category_suffix, v.freq)    
        end
        -- Clamp
        if v.currenttime and v.totaltime and v.totaltime > 0 and v.currenttime >= v.totaltime and v.freq and v.endfreq and v.freq ~= v.endfreq then
            v.freq = v.endfreq
            TheSim:SetLowPassFilter(k..low_pass_category_suffix, v.freq)    
        end
    end
    for k,v in pairs(self.highpassfilters) do
        if v and v.totaltime and v.currenttime and v.totaltime > 0 and v.currenttime < v.totaltime then
            v.currenttime = v.currenttime + dt
            v.freq = easing.linear(v.currenttime, v.startfreq, v.endfreq - v.startfreq, v.totaltime)
            TheSim:SetHighPassFilter(k..high_pass_category_suffix, v.freq)
        end
        -- Clamp
        if v.currenttime and v.totaltime and v.totaltime > 0 and v.currenttime >= v.totaltime and v.freq and v.endfreq and v.freq ~= v.endfreq then
            v.freq = v.endfreq
            TheSim:SetHighPassFilter(k..high_pass_category_suffix, v.freq)
        end
    end

    -- Then clear high/low as appropriate
    for k,v in pairs(self.lowpassfilters) do
        if v and v.freq and v.freq >= top_val and v.totaltime and v.currenttime and v.totaltime > 0 and v.currenttime > v.totaltime then
            self.lowpassfilters[k] = {}
        end
    end
    for k,v in pairs(self.highpassfilters) do
        if v and v.freq and v.freq <= bottom_val and v.totaltime and v.currenttime and v.totaltime > 0 and v.currenttime > v.totaltime then
            self.highpassfilters[k] = {}
        end
    end

    -- Finally, actually clear the DSP if it's not engaged by high or low filter
    for k,v in pairs(self.lowpassfilters) do
        local x = self.highpassfilters[k]
        if (self.lowpassfilters[k] == nil or #self.lowpassfilters[k] == 0) and (self.highpassfilters[k] == nil or #self.highpassfilters[k] == 0) then
            -- Failsafe check for in-progress DSP changes
            if not ((v.freq and v.freq < top_val) or (v.totaltime and v.currenttime and v.currenttime < v.totaltime)) and
               not (x and ((x.freq and x.freq > bottom_val) or (x.totaltime and x.currenttime and x.currenttime < x.totaltime))) then
                TheSim:ClearDSP(k)
                self.lowpassfilters[k] = nil
                self.highpassfilters[k] = nil
            end
        end
    end
    for k,v in pairs(self.highpassfilters) do
        local x = self.lowpassfilters[k]
        if (v == nil or #v == 0) and (x == nil or #x == 0) then
            -- Failsafe check for in-progress DSP changes
            if not ((v.freq and v.freq > bottom_val) or (v.totaltime and v.currenttime and v.currenttime < v.totaltime)) and
               not (x and ((x.freq and x.freq < top_val) or (x.totaltime and x.currenttime and x.currenttime < x.totaltime))) then
                TheSim:ClearDSP(k)
                self.lowpassfilters[k] = nil
                self.highpassfilters[k] = nil
            end
        end
    end
end



function Mixer:SetLowPassFilter(category, cutoff, timetotake)
    -- print("----------------------------------------------------------------------------------------------------------------")
    -- print(debug.traceback())
    -- print("----------------------------------------------------------------------------------------------------------------")
	timetotake = timetotake or 3
	
	local startfreq = top_val
	if self.lowpassfilters[category] and self.lowpassfilters[category].freq then
		startfreq = self.lowpassfilters[category].freq
	end
	
	local freq_entry = {startfreq = startfreq, endfreq = cutoff, freq= startfreq, totaltime = timetotake, currenttime = 0}
	self.lowpassfilters[category] = freq_entry
	
	if timetotake <= 0 then
		freq_entry.freq = cutoff
		TheSim:SetLowPassFilter(category..low_pass_category_suffix, cutoff)
	end
end

function Mixer:SetHighPassFilter(category, cutoff, timetotake)
    -- print("----------------------------------------------------------------------------------------------------------------")
    -- print(debug.traceback())
    -- print("----------------------------------------------------------------------------------------------------------------")
    timetotake = timetotake or 3
    
    local startfreq = bottom_val
    if self.highpassfilters[category] and self.highpassfilters[category].freq then
        startfreq = self.highpassfilters[category].freq
    end
    
    local freq_entry = {startfreq = startfreq, endfreq = cutoff, freq= startfreq, totaltime = timetotake, currenttime = 0}
    self.highpassfilters[category] = freq_entry
    
    if timetotake <= 0 then
        freq_entry.freq = cutoff
        TheSim:SetHighPassFilter(category..high_pass_category_suffix, cutoff)
    end 
end

function Mixer:ClearLowPassFilter(category, timetotake)
	self:SetLowPassFilter(category, top_val, timetotake)	
end

function Mixer:ClearHighPassFilter(category, timetotake)
    self:SetHighPassFilter(category, bottom_val, timetotake)    
end

return { Mix = Mix, Mixer = Mixer}
