

---SCRIPTING
local Scripts = {}

function LoadScript(filename)
    if not Scripts[filename] then
        local scriptfn = loadfile("scripts/" .. filename)
        assert(type(scriptfn) == "function", scriptfn)
        Scripts[filename] = scriptfn()
    end
    return Scripts[filename]
end

function RunScript(filename)
    local fn = LoadScript(filename)
    if fn then
        fn()
    end
end

function GetEntityString(guid)
    local ent = Ents[guid]

    if ent then
        return ent:GetDebugString()
    end

    return ""
end

function OnEntitySleep(guid)
    local inst = Ents[guid]
    if inst then

        if inst.OnEntitySleep then
            inst:OnEntitySleep()
        end

        inst:StopBrain()

        if inst.sg then
            SGManager:Hibernate(inst.sg)
        end

        if inst.emitter then
            EmitterManager:Hibernate(inst.emitter)
        end

        for k, v in pairs(inst.components) do

            if v.OnEntitySleep then
                v:OnEntitySleep()
            end
        end

    end
end

function OnEntityWake(guid)
    local inst = Ents[guid]
    if inst then

        if inst.OnEntityWake then
            inst:OnEntityWake()
        end

        if not inst:IsInLimbo() then
            inst:RestartBrain()
            if inst.sg then
                SGManager:Wake(inst.sg)
            end
        end

        if inst.emitter then
            EmitterManager:Wake(inst.emitter)
        end

        for k, v in pairs(inst.components) do
            if v.OnEntityWake then
                v:OnEntityWake()
            end
        end
    end
end

------------------------------

function PlayNIS(nisname, lines)
    local nis = require("nis/" .. nisname)
    local inst = CreateEntity()

    inst:AddComponent("nis")
    inst.components.nis:SetName(nisname)
    inst.components.nis:SetInit(nis.init)
    inst.components.nis:SetScript(nis.script)
    inst.components.nis:SetCancel(nis.cancel)
    inst.entity:CallPrefabConstructionComplete()
    inst.components.nis:Play(lines)
    return inst
end

local paused = false
local default_time_scale = 1

function IsPaused()
    return paused
end

global("PlayerPauseCheck")  -- function not defined when this file included


function SetDefaultTimeScale(scale)
    default_time_scale = scale
    if not paused then
        TheSim:SetTimeScale(default_time_scale)
    end
end

function SetPause(val, reason)
    if val ~= paused then
        if val then
            paused = true
            TheSim:SetTimeScale(0)
            TheMixer:PushMix("pause")
        else
            paused = false
            TheSim:SetTimeScale(default_time_scale)
            TheMixer:PopMix("pause")
            --ShowHUD(true)
        end
        if GetWorld() then
            GetWorld():PushEvent("pause", val)
        end
        if PlayerPauseCheck then
            -- probably don't need this check
            PlayerPauseCheck(val, reason)  -- must be done after SetTimeScale
        end
    end
end

function IsPaused()
    return paused
end

--- EXTERNALLY SET GAME SETTINGS ---
function SaveGame(savename, cb)
    local callback = function()
        SaveGameIndex:Save(cb)
    end

    local save = {}
    save.ents = {}

    --print("Saving...")

    --save the entities
    local nument = 0
    local saved_ents = {}
    local references = {}
    for k, v in pairs(Ents) do
        if v.persists and v.prefab and v.Transform and v.entity:GetParent() == nil and v:IsValid() then
            local x, y, z = v.Transform:GetWorldPosition()
            local record, new_references = v:GetSaveRecord()
            record.prefab = nil

            if new_references then
                references[v.GUID] = true
                for k, v in pairs(new_references) do
                    references[v] = true
                end
            end

            saved_ents[v.GUID] = record

            if save.ents[v.prefab] == nil then
                save.ents[v.prefab] = {}
            end
            table.insert(save.ents[v.prefab], record)
            record.prefab = nil
            nument = nument + 1
        end
    end


    --save out the map
    save.map = {
        revealed = "",
        tiles = "",
        roads = Roads,
    }

    local new_refs = nil
    local ground = GetWorld()
    assert(ground, "Cant save world without ground entity")
    if ground then
        save.map.prefab = ground.prefab
        save.map.tiles = ground.Map:GetStringEncode()
        save.map.nav = ground.Map:GetNavStringEncode()
        save.map.width, save.map.height = ground.Map:GetSize()
        save.map.topology = ground.topology
        save.map.persistdata, new_refs = ground:GetPersistData()
        save.meta = ground.meta
        save.map.hideminimap = ground.hideminimap

        if new_refs then
            for k, v in pairs(new_refs) do
                references[v] = true
            end
        end
    end

    local player = GetPlayer()
    assert(player, "Cant save world without player entity")
    if player then
        save.playerinfo = {}
        save.playerinfo, new_refs = player:GetSaveRecord()
        save.playerinfo.id = player.GUID --force this for the player
        if new_refs then
            for k, v in pairs(new_refs) do
                references[v] = true
            end
        end
    end

    for k, v in pairs(references) do
        if saved_ents[k] then
            saved_ents[k].id = k
        else
            print("Can't find", k, Ents[k])
        end
    end

    save.mods = ModManager:GetModRecords()
    save.super = WasSuUsed()

    assert(save.map, "Map missing from savedata on save")
    assert(save.map.prefab, "Map prefab missing from savedata on save")
    assert(save.map.tiles, "Map tiles missing from savedata on save")
    assert(save.map.width, "Map width missing from savedata on save")
    assert(save.map.height, "Map height missing from savedata on save")
    --assert(save.map.topology, "Map topology missing from savedata on save")

    assert(save.playerinfo, "Playerinfo missing from savedata on save")
    assert(save.playerinfo.x, "Playerinfo.x missing from savedata on save")
    --assert(save.playerinfo.y, "Playerinfo.y missing from savedata on save")   --y is often omitted for space, don't check for it
    assert(save.playerinfo.z, "Playerinfo.z missing from savedata on save")
    --assert(save.playerinfo.day, "Playerinfo day missing from savedata on save")

    assert(save.ents, "Entites missing from savedata on save")
    assert(save.mods, "Mod records missing from savedata on save")

    local data = DataDumper(save, nil, BRANCH ~= "dev")
    --[[
    if GetClock() ~= nil then
        local day_number = GetClock().numcycles + 1
        SavePersistentString(string.format("%s_day%03d", savename, day_number), data, ENCODE_SAVES, nil)
    end
    ]]
    local insz, outsz = SavePersistentString(savename, data, ENCODE_SAVES, callback)
    print("Saved", savename, outsz)

    if player.HUD then
        player:PushEvent("ontriggersave")
    end

end

function LoadFonts()
    for k, v in pairs(FONTS) do
        TheSim:LoadFont(v.filename, v.alias)
    end
end

function UnloadFonts()
    for k, v in pairs(FONTS) do
        TheSim:UnloadFont(v.alias)
    end
end

function Start()
    if SOUNDDEBUG_ENABLED then
        require "debugsounds"
    end

    ---The screen manager
    TheFrontEnd = FrontEnd()
    require("gamelogic")

    if PLATFORM == "PS4" then
        Check_Mods()
    else
        CheckControllers()
    end
end

--------------------------

exiting_game = false

-- Gets called ONCE when the sim first gets created. Does not get called on subsequent sim recreations!
function GlobalInit()
    TheSim:LoadPrefabs({ "global" })
    LoadFonts()
    if PLATFORM == "PS4" then
        PreloadSounds()
    end
    TheSim:SendHardwareStats()
end

function StartNextInstance(in_params, send_stats)
    local params = in_params or {}
    params.last_reset_action = Settings.reset_action

    if send_stats then
        SendAccumulatedProfileStats()
    end

    if LOADED_CHARACTER then
        if GetPlayer() and GetPlayer().components.talker then
            -- Make sure talker shuts down before we unload the character
            GetPlayer().components.talker:ShutUp()
        end
        TheSim:UnloadPrefabs(LOADED_CHARACTER)
    end

    SimReset(params)
end

function SimReset(instanceparameters)

    ModManager:UnloadPrefabs()

    if not instanceparameters then
        instanceparameters = {}
    end
    instanceparameters.last_asset_set = Settings.current_asset_set
    local params = json.encode(instanceparameters)
    TheSim:SetInstanceParameters(params)
    TheSim:Reset()
end


function Shutdown()
    print('Ending the sim now!')
    SubmitQuitStats()

    UnloadFonts()

    for i, file in ipairs(PREFABFILES) do
        -- required from prefablist.lua
        LoadPrefabFile("prefabs/" .. file)
    end

    TheSim:UnloadAllPrefabs()

    TheSim:Quit()
end

function InGamePlay()
    return inGamePlay
end