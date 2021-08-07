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
local loopingSounds = {}
local soundCount = 0
local listenerPos = nil
 
TheSim:LoadPrefabs({"sounddebugicon"})

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
            local soundInfo = {event=event, owner=ent, guid=ent.GUID, prefab=ent.prefab or "", position=pos, dist=dist, volume=volume or 1, icon=soundIcon}
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
scheduler:ExecutePeriodic(1, DoUpdate)

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
    for i = soundCount-maxRecentSounds+1, soundCount do
        local index = (i % maxRecentSounds)+1
        if nearbySounds[index] then
            local soundInfo = nearbySounds[index]
            table.insert(lines, string.format("[%d] %s owner:%d %s pos:%s dist:%2.2f volume:%d",
                soundInfo.count, soundInfo.event, soundInfo.guid, soundInfo.prefab, tostring(soundInfo.pos), soundInfo.dist, soundInfo.volume) )
        end
    end
    return table.concat(lines, "\n")
end