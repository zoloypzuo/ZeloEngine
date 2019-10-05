require("class")
require("util")

--tweakable parameters
local maxRecentSounds = 30  --max number of recent sounds to list in the debug output
local maxDistance = 30     --max distance to show 

local playsound = SoundEmitter.PlaySound
local killsound = SoundEmitter.KillSound
local killallsounds = SoundEmitter.KillAllSounds
local setparameter = SoundEmitter.SetParameter
local setvolume = SoundEmitter.SetVolume
local setlistener = Sim.SetListener

local nearbySounds = {}
local filtered_sounds = {}
local loopingSounds = {}
local soundCount = 0
local listenerPos = nil

local event_filter  = nil
local prefab_filter = nil
local entity_filter = nil

local update_periodic = nil
 
TheSim:LoadPrefabs({"sounddebugicon"})

local function FilterSound(soundInfo)

    local filter = false

    if entity_filter then
        filter = entity_filter == soundInfo.guid
    elseif prefab_filter then
        filter = string.match (soundInfo.prefab, prefab_filter)
    end

    if event_filter then
        filter = filter and string.match (soundInfo.event, event_filter)
    end

    if filter then
        table.insert(filtered_sounds, soundInfo)
    end
end

local function FilterSounds()
    for _, soundInfo in pairs(nearbySounds) do
        FilterSound(soundInfo)
    end
end

local function SortFilteredSounds()
    if next(filtered_sounds) == nil then
        return
    end

    table.sort(filtered_sounds, function(a,b) return a.count < b.count end )
end


local function OverrideSoundEmitter()
    SoundEmitter.PlaySound = function(emitter, event, name, volume, ...)
        local ent = emitter:GetEntity()
        if ent and ent.Transform and listenerPos then
            local pos = Vector3(ent.Transform:GetWorldPosition() )
            local dist = math.sqrt(distsq(pos, listenerPos) )
            if dist < maxDistance or name then
                local soundIcon = nil
                if name and loopingSounds[ent] and loopingSounds[ent][name] then
                    soundIcon = loopingSounds[ent][name].icon
                else
                    soundIcon = SpawnPrefab("sounddebugicon")
                end
                if soundIcon then
                    soundIcon.Transform:SetPosition(pos:Get() )
                end
                local soundInfo = {event=event, owner=ent, guid=ent.GUID, prefab=ent.prefab or "", position=pos, dist=dist, volume=volume or 1, icon=soundIcon, timestamp = GetTime()}
                if name then
                    --add to looping sounds list
                    soundInfo.params = {}
                    if not loopingSounds[ent] then
                        loopingSounds[ent] = {}
                    end
                    loopingSounds[ent][name] = soundInfo
                    if soundIcon then
                        if soundIcon.autokilltask then
                            soundIcon.autokilltask:Cancel()
                            soundIcon.autokilltask = nil
                        end
                        soundIcon.Label:SetText(name)
                    end
                else
                    --add to oneshot sound list
                    soundCount = soundCount + 1
                    local index = (soundCount % maxRecentSounds)+1
                    soundInfo.count = soundCount
                    nearbySounds[index] = soundInfo

                    if entity_filter or prefab_filter or event_filter then
                        FilterSound(soundInfo)
                    end

                    if soundIcon then
                        soundIcon.Label:SetText(tostring(soundCount) )
                    end
                end
            end
        end
        
        playsound(emitter, event, name, volume, ...)
    end

    SoundEmitter.KillSound = function(emitter, name, ...)
        local ent = emitter:GetEntity()
        if loopingSounds[ent] then
            if loopingSounds[ent][name] and loopingSounds[ent][name].icon then
                loopingSounds[ent][name].icon:Remove()
            end
            loopingSounds[ent][name] = nil
        end
        killsound(emitter, name, ...)
    end

    SoundEmitter.KillAllSounds = function(emitter, ...)
        local sounds = loopingSounds[emitter:GetEntity()]
        if sounds then
            for k,v in pairs(sounds) do
                if v.icon then
                    v.icon:Remove()
                end
                sounds[v] = nil
            end
            sounds = nil
        end
        killallsounds(emitter, ...)
    end

    SoundEmitter.SetParameter = function(emitter, name, parameter, value, ...)
        local ent = emitter:GetEntity()
        if loopingSounds[ent] and loopingSounds[ent][name] then
            loopingSounds[ent][name].params[name] = value
        end
        setparameter(emitter, name, parameter, value, ...)
    end

    SoundEmitter.SetVolume = function(emitter, name, volume, ...)
        local ent = emitter:GetEntity()
        if loopingSounds[ent] and loopingSounds[ent][name] then
            loopingSounds[ent][name].volume = volume
        end
        setvolume(emitter, name, volume, ...)
    end

    Sim.SetListener = function(sim, x, y, z, ...)
        listenerPos = Vector3(x, y, z)
        setlistener(sim, x, y, z, ...)
    end
end

local function DoUpdate()
    for ent,sounds in pairs(loopingSounds) do
        if not next(sounds) then
            loopingSounds[ent] = nil
        else
            for name,info in pairs(sounds) do
                if not ent:IsValid() or not ent.SoundEmitter or not ent.SoundEmitter:PlayingSound(name) then
                    if info.icon then
                        info.icon:Remove()
                    end
                    sounds[name] = nil
                else
                    local pos = Vector3(ent.Transform:GetWorldPosition() )
                    local dist = math.sqrt(distsq(pos, listenerPos) )
                    info.dist = dist
                    info.pos = pos
                    if info.icon then
                        info.icon.Transform:SetPosition(pos:Get() )
                    end
                end
            end
        end
    end
end

function SetEntitySoundFilter ( new_filter )
    entity_filter = new_filter
    filtered_sounds = {}

    if entity_filter then
        FilterSounds()
    end

    SortFilteredSounds()
end

function SetPrefabSoundFilter ( new_filter )
    prefab_filter = new_filter
    filtered_sounds = {}

    if prefab_filter then
        FilterSounds()
    end

    SortFilteredSounds()
end

function SetEventSoundFilter( new_filter )
    event_filter = new_filter
    filtered_sounds = {}

    if event_filter then
        FilterSounds()
    end

    SortFilteredSounds()
end

function SetDebugMaxSounds(max_sounds)
    maxRecentSounds = max_sounds or 30
end

function GetSoundDebugString()
    local lines = {}
    table.insert(lines, "-------SOUND DEBUG-------")
    table.insert(lines, "Looping Sounds")
    for ent,sounds in pairs(loopingSounds) do
        for name,info in pairs(sounds) do
            if info.dist < maxDistance then
                local params = ""
                for k,v in pairs(info.params) do
                    params = params.." "..k.."="..v
                end
                table.insert(lines, string.format("[%s] %s owner:%d %s pos:%s dist:%2.2f volume:%d params:{%s}",
                        name, info.event, info.guid, info.prefab, tostring(info.pos), info.dist, info.volume, params) )
            end
        end
    end

    table.insert(lines, "Recent Sounds")
    if entity_filter or prefab_filter or event_filter then
        local selected_count = 0
        for i = 1, #filtered_sounds do
            local soundInfo = filtered_sounds[i]
            local str = string.format("[%d] %s owner:%d %s pos:%s dist:%2.2f volume:%d",
                soundInfo.count, soundInfo.event, soundInfo.guid, soundInfo.prefab, tostring(soundInfo.pos), soundInfo.dist, soundInfo.volume)

            table.insert(lines,  str)

            selected_count = selected_count + 1
            if selected_count == maxRecentSounds then
                break
            end
        end
    else    
        for i = soundCount-maxRecentSounds+1, soundCount do
            local index = (i % maxRecentSounds)+1
            if nearbySounds[index] then
                local soundInfo = nearbySounds[index]
                local str = string.format("[%d] %s owner:%d %s pos:%s dist:%2.2f volume:%d",
                    soundInfo.count, soundInfo.event, soundInfo.guid, soundInfo.prefab, tostring(soundInfo.pos), soundInfo.dist, soundInfo.volume)

                table.insert(lines,  str)
            end
        end
    end
    return table.concat(lines, "\n")
end

function SetSoundDebug()
    playsound = SoundEmitter.PlaySound
    killsound = SoundEmitter.KillSound
    killallsounds = SoundEmitter.KillAllSounds
    setparameter = SoundEmitter.SetParameter
    setvolume = SoundEmitter.SetVolume
    setlistener = Sim.SetListener

    OverrideSoundEmitter()

    update_periodic = scheduler:ExecutePeriodic(1, DoUpdate)
end

function ResetSoundDebug()
    SoundEmitter.PlaySound = playsound
    SoundEmitter.KillSound = killsound
    SoundEmitter.KillAllSounds = killallsounds
    SoundEmitter.SetParameter = setparameter
    SoundEmitter.SetVolume = setvolume
    Sim.SetListener = setlistener

    loopingSounds = {}
    nearbySounds = {}
    filtered_sounds = {}

    soundCount = 0
    listenerPos = nil
    event_filter  = nil
    prefab_filter = nil
    entity_filter = nil

    update_periodic:Cancel()
    update_periodic = nil
end