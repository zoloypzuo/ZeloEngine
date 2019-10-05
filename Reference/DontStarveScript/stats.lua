-- require "stats_schema"    -- for when we actually organize 

STATS_ENABLE = false
-- NOTE: There is also a call to 'anon/start' in dontstarve/main.cpp which has to be un/commented

--- non-user-facing Tracking stats  ---
TrackingEventsStats = {}
TrackingTimingStats = {}
local GameStats = {}
GameStats.StatsLastTrodCount = 0
local OnLoadGameInfo = {}

function IncTrackingStat(stat, subtable)

	if not STATS_ENABLE then
		return
	end

    local t = TrackingEventsStats
    if subtable then
        t = TrackingEventsStats[subtable]

        if not t then
            t = {}
            TrackingEventsStats[subtable] = t
        end
    end

    t[stat] = 1 + (t[stat] or 0)
end

function SetTimingStat(subtable, stat, value)

	if not STATS_ENABLE then
		return
	end

    local t = TrackingTimingStats
    if subtable then
        t = TrackingTimingStats[subtable]

        if not t then
            t = {}
            TrackingTimingStats[subtable] = t
        end
    end

    t[stat] = math.floor(value/1000)
end


function SendTrackingStats()

	if not STATS_ENABLE then
		return
	end

	if GetTableSize(TrackingEventsStats) then
    	local stats = json.encode_compliant({events=TrackingEventsStats, timings=TrackingTimingStats})
    	TheSim:LogBulkMetric(stats)
    end
end


function BuildContextTable()
	local sendstats = {}

	sendstats.user = TheSim:GetUserID()
	if sendstats.user == nil then
		if BRANCH == "release" then
			sendstats.user = "unknown"
		else
			sendstats.user = "testing"
		end
	end
	sendstats.testgroup = GetTestGroup()

	if BRANCH ~= "release" then
		sendstats.user = sendstats.user
	end

	sendstats.branch = BRANCH

	local modnames = KnownModIndex:GetModNames()
	for i, name in ipairs(modnames) do
		if KnownModIndex:IsModEnabled(name) then
			sendstats.branch = sendstats.branch .. "_modded"
			break
		end
	end

	sendstats.build = APP_VERSION
	sendstats.platform = PLATFORM

	if GetSeasonManager() then
		sendstats.season = GetSeasonManager():GetSeasonString()
	end

	if GetClock() then
		sendstats.day = GetClock().numcycles
	end

	if GetWorld() then
		-- we don't want everything in meta, ony things which are stats-relevant
		sendstats.map_meta = {}
		sendstats.map_meta.level_id =  GetWorld().meta and GetWorld().meta.level_id or "UNKNOWN"
		sendstats.map_meta.seed = GetWorld().meta and GetWorld().meta.seed or "UNKNOWN"
		sendstats.map_meta.build_version =  GetWorld().meta and GetWorld().meta.build_version or "UNKNOWN"

		sendstats.mode = GetWorld().topology and GetWorld().topology.level_type or "UNKNOWN"
        sendstats.map_trod = GetMap() and GetMap():GetNumVisitedTiles()
	end

	sendstats.save_id = SaveGameIndex:GetSaveID()
    sendstats.starts = Profile:GetValue("starts")
    sendstats.super = GameStats.super
    if GetPlayer() then
        sendstats.hunger = math.floor(GetPlayer().components.hunger:GetPercent()*100)
        sendstats.sanity = math.floor(GetPlayer().components.sanity:GetPercent()*100)
        sendstats.health = math.floor(GetPlayer().components.health:GetPercent()*100)
    end

	return sendstats
end


--- GAME Stats and details to be sent to server on game complete ---
ProfileStats = {}
MainMenuStats = {}

function SuUsed(item,value)
    GameStats.super = true
    ProfileStatsSet(item, value)
end

function SetSuper(value)
    dprint("Setting SUPER", value)
    OnLoadGameInfo.super = value
end

function SuUsedAdd(item,value)
    GameStats.super = true
    ProfileStatsAdd(item, value)
end

function WasSuUsed()
    return GameStats.super
end

function GetProfileStats(wipe)
	if GetTableSize(ProfileStats) == 0 then
		return json.encode_compliant( {} )
	end

	wipe = wipe or false
	local jsonstats = ''
	local sendstats = BuildContextTable()

	sendstats.stats = ProfileStats
	dprint("_________________++++++ Sending Accumulated profile stats...\n")
	ddump(sendstats)

	jsonstats = json.encode_compliant( sendstats )

	if wipe then
		ProfileStats = {}
    end
    return jsonstats
end


function RecordEndOfDayStats()
	if not STATS_ENABLE then
		return
	end

    -- Do local analysis of game session so far
    dprint("RecordEndOfDayStats")
end

function RecordQuitStats()
	if not STATS_ENABLE then
		return
	end

    -- Do local analysis of game session
    dprint("RecordQuitStats")
end

function RecordPauseStats()         -- Run some analysis and save stats when player pauses
	if not STATS_ENABLE or not IsPaused() then
		return
	end
    dprint("RecordPauseStats")
end

function RecordOverseerStats(data)

	if not STATS_ENABLE or GetTableSize(data.foeList) <= 0 then
        dprint("^^^^^^^^^^^^^^^^^^^^ NO FOES!")
		return
	end

    local player = GetPlayer()
    dprint("FoeList-----------------------")
    ddump(data.foeList)

    if GetTableSize(data.eluded) == 0 then
        data.eluded = nil
    end


	local sendstats = BuildContextTable()
	sendstats.fight = {
        duration       = data.duration,
        dmg_taken      = data.damage_taken,
        dmg_given      = data.damage_given,
        wield          = data.wield,
        wear           = data.wear,
        head           = data.head,
        sanity         = data.sanity_start,
        hunger         = data.hunger_start,
        health_lvl     = data.health_start,
        health_start   = data.health_abs,
        health_end     = data.health_end_abs,
        health_end_lvl = data.health_end,
        died           = data.died,
        trod           = data.trod,
        attacked_by    = data.attacked_by,
        targeted_by    = data.targeted_by,
        foes_total     = data.foes_total,
        eluded_total   = data.eluded_total,
        eluded         = data.eluded,
        kill_total     = data.kill_total,
        armor_broken   = data.armor_broken,
        caught_total   = data.caught_total,
        kills          = data.kills,
        absorbed       = data.armor_absorbed,
        AFK            = data.AFK,
        used           = data.used,
        minions        = data.minions,
        minion_kill    = data.minion_kills,
        minions_lost   = data.minions_lost,
        minion_dmg     = data.minion_hits,
        trap_sprung    = data.traps_sprung,
        trap_dmg       = data.trap_damage,
        trap_kill      = data.trap_kills,
        heal           = data.heal,
        --fight          = data.fight,
	}
    
    FightStat_EndFight()

	dprint("_________________________________________________________________Sending fight stats...")
	ddump(sendstats.fight)
	dprint("_________________________________________________________________<END>")
	local jsonstats = json.encode_compliant( sendstats )
	TheSim:SendProfileStats( jsonstats )
end

function RecordDeathStats(killed_by, time_of_day, sanity, hunger, will_resurrect)
	if not STATS_ENABLE then
		return
	end

	local sendstats = BuildContextTable()
	sendstats.death = {
		killed_by=killed_by,
		time_of_day=time_of_day,
		sanity=math.floor(sanity*100),
		hunger=math.floor(hunger*100),
		will_resurrect=will_resurrect,
        AFK = IsAwayFromKeyBoard(),
        trod = GetMap() and GetMap():GetNumVisitedTiles(),
        tiles = GetMap() and GetMap():GetNumWalkableTiles(),
        last_armor = ProfileStatsGet("armor"),
        armor_absorbed = ProfileStatsGet("armor_absorb"),
	}

	dprint("_________________________________________________________________Sending death stats...")
	ddump(sendstats)
	local jsonstats = json.encode_compliant( sendstats )
	TheSim:SendProfileStats( jsonstats )
end

function RecordSessionStartStats()
	if not STATS_ENABLE then
		return
	end

	-- TODO: This should actually just write the specific start stats, and it will eventually
	-- be rolled into the "quit" stats and sent off all at once.
	local sendstats = BuildContextTable()
	sendstats.Session = {
		Loads = {
			Mods = { 
				mod = false,
				list = {},
				
			},
		}
	}

	for i,name in ipairs(ModManager:GetEnabledModNames()) do
		sendstats.Session.Loads.Mods.mod = true
		table.insert(sendstats.Session.Loads.Mods.list, name)
	end

	if IsDLCInstalled(REIGN_OF_GIANTS) and not IsDLCEnabled(REIGN_OF_GIANTS) then
		sendstats.Session.Loads.Mods.mod = true
		table.insert(sendstats.Session.Loads.Mods.list, "RoG-NotPlaying")
	end
	if IsDLCEnabled(REIGN_OF_GIANTS) then
		sendstats.Session.Loads.Mods.mod = true
		table.insert(sendstats.Session.Loads.Mods.list, "RoG-Playing")
	end
	
	if IsDLCInstalled(CAPY_DLC) and not IsDLCEnabled(CAPY_DLC) then
		sendstats.Session.Loads.Mods.mod = true
		table.insert(sendstats.Session.Loads.Mods.list, "SW-NotPlaying")
	end
	if IsDLCEnabled(CAPY_DLC) then
		sendstats.Session.Loads.Mods.mod = true
		table.insert(sendstats.Session.Loads.Mods.list, "SW-Playing")
	end

    sendstats.Session.map_trod = (GetMap() and GetMap():GetNumVisitedTiles()) or 0
	sendstats.Session.character = GetPlayer().prefab

    GameStats = {}
    GameStats.StatsLastTrodCount = (GetMap() and GetMap():GetNumVisitedTiles()) or 0
    GameStats.super = OnLoadGameInfo.super
    OnLoadGameInfo.super = nil
	
	dprint("_________________++++++ Sending sessions start stats...\n")
	ddump(sendstats)
	local jsonstats = json.encode_compliant( sendstats )
	TheSim:SendProfileStats( jsonstats )

end

-- value is optional, 1 if nil
function ProfileStatsAdd(item, value)
    --print ("ProfileStatsAdd", item)
    if value == nil then
        value = 1
    end

    if ProfileStats[item] then
    	ProfileStats[item] = ProfileStats[item] + value
    else
    	ProfileStats[item] = value
    end
end

function ProfileStatsAddItemChunk(item, chunk)
    if ProfileStats[item] == nil then
    	ProfileStats[item] = {}
    end

    if ProfileStats[item][chunk] then
    	ProfileStats[item][chunk] =ProfileStats[item][chunk] +1
    else
    	ProfileStats[item][chunk] = 1
    end
end

function ProfileStatsSet(item, value)
	ProfileStats[item] = value
end

function ProfileStatsGet(item)
	return ProfileStats[item]
end

-- The following takes advantage of table.setfield (util.lua) which
-- takes a string representation of a table field (e.g. "foo.bar.bleah.eeek")
-- and creates all the intermediary tables if they do not exist

function ProfileStatsAddToField(field, value)
    --print ("ProfileStatsAdd", item)
    if value == nil then
        value = 1
    end

    local oldvalue = table.getfield(ProfileStats, field)
    if oldvalue then
    	table.setfield(ProfileStats, field, oldvalue + value)
    else
    	table.setfield(ProfileStats, field, value)
    end
end

function ProfileStatsSetField(field, value)
    if type(field) ~= "string" then
        return nil
    end
    table.setfield(ProfileStats, field, value)
    return value
end

function ProfileStatsAppendToField(field, value)
    if type(field) ~= "string" then
        return nil
    end
    -- If the field name ends with ".", setfield adds the value to the end of the array
    table.setfield(ProfileStats, field .. ".", value)
end


function SendAccumulatedProfileStats()
	if not STATS_ENABLE then
		return
	end

    ProfileStatsSet("trod", GetMap():GetNumVisitedTiles() - GameStats.StatsLastTrodCount)
    dprint(":::::::::::::::::::::::: TROD!", GetMap():GetNumVisitedTiles() - GameStats.StatsLastTrodCount)
    GameStats.StatsLastTrodCount = GetMap():GetNumVisitedTiles()
    
	local stats = GetProfileStats(true)
	TheSim:SendProfileStats( stats )
end

--Periodically upload and refresh the player stats, so we always
--have up-to-date stats even if they close/crash the game.
StatsHeartbeatRemaining = 30

function AccumulatedStatsHeartbeat(dt)
    -- only fire this while in-game
    local player = GetPlayer()
    if player then
        ProfileStatsAdd("time_played", math.floor(dt*1000))
        StatsHeartbeatRemaining = StatsHeartbeatRemaining - dt
        if StatsHeartbeatRemaining < 0 then
            SendAccumulatedProfileStats()
            StatsHeartbeatRemaining = 120
        end
    end
end

function SubmitCompletedLevel()
	SendAccumulatedProfileStats()
end

function SubmitStartStats(playercharacter)
	if not STATS_ENABLE then
		return
	end
	
	-- At the moment there are no special start stats.
end

function SubmitExitStats()
	if not STATS_ENABLE then
	    Shutdown()
		return
	end

	-- At the moment there are no special exit stats.
	Shutdown()
end

function SubmitQuitStats()
	if not STATS_ENABLE then
		return
	end

	-- At the moment there are no special quit stats.
end

function GetTestGroup()
	local id = TheSim:GetSteamIDNumber()

	local groupid = id%2 -- group 0 must always be default, because GetSteamIDNumber returns 0 for non-steam users
	return groupid
end


function MainMenuStatsAdd(item, value)
    if value == nil then
        value = 1
    end

    if MainMenuStats[item] then
    	MainMenuStats[item] = MainMenuStats[item] + value
    else
    	MainMenuStats[item] = value
    end
end

function GetMainMenuStats(wipe)
	if GetTableSize(MainMenuStats) == 0 then
		return json.encode_compliant( {} )
	end

	wipe = wipe or false
	local jsonstats = ''
	local sendstats = BuildContextTable()

	sendstats.stats = MainMenuStats
	dprint("_________________++++++ Sending Accumulated main menu stats...\n")
	ddump(sendstats)

	jsonstats = json.encode_compliant( sendstats )

	if wipe then
		MainMenuStats = {}
    end

    return jsonstats
end

function SendMainMenuStats()
	if not STATS_ENABLE then
		return
	end
   
	local stats = GetMainMenuStats(true)
	TheSim:SendProfileStats(stats)
end



function PushMetricsEvent(data)

    local sendstats = BuildContextTable()
    sendstats.event = data.event

    if data.values then
        for k,v in pairs(data.values) do
            sendstats[k] = v
        end
    end

    --print("PUSH METRICS EVENT")
    --dumptable(sendstats)
    --print("^^^^^^^^^^^^^^^^^^")
    local jsonstats = json.encode_compliant(sendstats)
    TheSim:SendProfileStats(jsonstats)
end
