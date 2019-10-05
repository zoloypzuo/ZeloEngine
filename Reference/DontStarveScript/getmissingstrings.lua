package.path = "DLC0002\\scripts\\?.lua;DLC0002\\scripts\\prefabs\\?.lua;scripts\\?.lua;scripts\\prefabs\\?.lua;"..package.path


local IGNORED_KEYWORDS = 
{
	"BLUEPRINTS",
	"PUPPET",
	"PLACER",
	"FX",
	"PILLAR",
	"HERD",
	"HUD",
	"CHARACTERS",
	"FISSURE",
	"DEBUG",
	"_MED",
	"_NORMAL",
	"_SHORT",
	"_TALL",
	"_LOW",
	"WORLDS",
	"BROKENWALL_",
	"PROJECTILE",
	"_STUMP",
	"OCEANSPAWNER",
	"LANDSPAWNER",
	"WALLYINTRO",
	"FLUPSPAWNER",
}

local IGNORE_PREFABS =
{
	-- "acorn",
	"FIRERAIN",
	"LOBSTERHOLE",
	"BERRYBUSH2_SNAKE",
 	"BERRYBUSH_SNAKE",
	"BALLPHINPOD",
	"QUAD_MAXWELLLIGHT",
	"BURNTFENCEPOST",
	"BURNTSTICKLEFT",
	"PORTABLECOOKPOT_ITEM",
	"TORNADO",
	"HARPOON",
	"SPIDERDEN_3",
	"BERRYBUSH2",
	"GLOBAL",
	"BURNTFENCEPOSTRIGHT",
	"BONFIRE",
	"PHONOGRAPH_COMPLETE",
	"BLOWDART_WALRUS",
	"FAST_FARMPLOT",
	"DECIDUOUS_ROOT",
	"OCEANSPAWNER",
	"PIGTORCH_FUEL",
	"PORTAL_HOME",
	"DRAGOON",
	"FLIES",
	"EYETURRET_BASE",
	"ANIM_TEST",
	"SHADOWTENTACLE",
	"RUINS_RUBBLE_TABLE",
	"TELEPORTATO_CHECKMATE",
	"VERTICAL_MAXWELLLIGHT",
	"TELEPORTLOCATION",
	"SHADOWHAND",
	"EYE_CHARGE",
	"CIRCLINGBUZZARD",
	"SHADOWWATCHER",
	"FARMROCKFLAT",
	"DREWPIN",
	"PHONOGRAPH_CRANK",
	"FENCEPOSTRIGHT",
	"PENGUIN_ICE",
	"STAFF_CASTINGLIGHT",
	"DROPPERWEB",
	"CIRCLINGSEAGULL",
	"RUINS_STATUE_HEAD_NOGEM",
	"BUTTERFLY_AREASPAWNER",
	"DAVEPIN",
	"HOUNDFIRE",
	"STUNGRAY_SPAWNER",
	"SINKHOLE",
	"RUINS_BOWL",
	"RUINS_STATUE_HEAD",
	"RUINS_TABLE",
	"RETICULE",
	"LIMPETS_COOKED",
	"PALMTREE_BURNT",
	"BIGFOOTPRINT",
	"MARBLETREE_3",
	"MARBLETREE_2",
	"LAVA_ERUPT",
	"GRAVESTONE",
	"BURNTSTICKRIGHT",
	"SIGNRIGHT",
	"BALLPHIN_SPAWNER",
	"NIGHTMAREBEAK",
	"RUINS_STATUE_MAGE_NOGEM",
	"MAXWELLLIGHT_AREA",
	"MISTAREA",
	"SLOW_FARMPLOT",
	"PHONOGRAPH_GEARS",
	"MATTPIN",
	"SPAWNPOINT",
	"TIGERSHARKSHADOW",
	"JONPIN",
	"STICKLEFT",
	"SHADOWSKITTISH",
	"SHADOWHAND_ARM",
	"OCEANSPAWNER_LOG",
	"SEAGULLSPAWNER",
	"CAVELIGHT",
	"BIGFOOTSHADOW",
	"SHADOWWAXWELL",
	"SIGNLEFT",
	"JUNGLETREE_BURNT",
	"WORMHOLE_LIMITED_1",
	"WILLOWFIRE",
	"STICKRIGHT",
	"ROCK_FLINTLESS",
	"FLOODSOURCE",
	"MARBLETREE_4",
	"MAXWELLHEAD_TRIGGER",
	"EVERGREEN_BURNT",
	"FIRERAINSHADOW",
	"RUINS_RUBBLE_CHAIR",
	"HORIZONTAL_MAXWELLLIGHT",
	"TREEGUARD",
	"BUZZARDSPAWNER",
	"RUINS_CHAIR",
	"FRONTEND",
	"WORNPIRATEHAT",
	"TUMBLEWEEDSPAWNER",
	"BOOK_TENTACLES",
	"DLC0001",
	"FENCEPOST",
	"OCEANSPAWNER_SEAWEED",
	"TEAMLEADER",
	"PHONOGRAPH_CONE",
	"ROCK2",
	"CHRISTIANPIN",
	"FARMROCKTALL",
	"SPIDERDEN_2",
	"DUG_BERRYBUSH2",
	"SPIDER_WEB_SPIT_CREEP",
	"PHONOGRAPH_BOX",
	"RUINS_VASE",
	"BALLOONICORN_LOLLIPOP",
	"DRAGOONEGG",
	"RUINS_RUBBLE_VASE",
	"RUINS_STATUE_MAGE",
	"BIOLUMINESCENCE_SPAWNER",
	"OCEANSPAWNER_COCONUT",
	"BURNTSTICK",
	"BALLOONICORN",
	"CREEPYEYES",
	"EXITCAVELIGHT",
	"SPIDER_WEB_SPIT",
	"BROKENTOOL",
	"FARMROCK",
	"DRAGOONEGG_FALLING",
	"VOLLEYBALL",
	"LIGHTNING",
	"ROCK1",
	"MARBLETREE_1",
	"RUINS_CHIPBOWL",
	"BISHOP_CHARGE",
	"CAVE_STAIRS",
	"CRAWLINGNIGHTMARE",
	"WORMLIGHT_LIGHT",
	"MAXWELLKEY",
	"POISONMISTAREA",
	"LAVA_BUBBLING",
	"STICK",
	"NEEDLE_DART_FIRE",
	"VOLCANO_ALTAR_METER",
	"BOAT_INDICATOR",
	"POND_MOS",
	"POND_CAVE",
	"DECIDUOUSTREE_BURNT",
	"BATCAVE",
	"RUINS_PLATE",
	"NEEDLE_DART",
	"PORTAL_LEVEL",
	"CRAWLINGHORROR",
	"TERRORBEAK",
	"BEACHRESURRECTOR",
	"FLOTSAM_ROWBOAT",
	"FLOTSAM_LOGRAFT",
	"FLOTSAM_CARGO",
	"FLOTSAM_BAMBOO",
	"FLOODTILE",
	"CANNONSHOT",
	"WILBUR_UNLOCK_MARKER",
	"TREE_CREAK_EMITTER",
	"TREEGUARD_COCONUT",
	"SUNKEN_BOAT_BIRD",
	"SUNKEN_BOAT_DEBRIS",
	"SUNKENPREFAB",
	"SWORDFISH_SPAWNER",
	"SUNKENPREFAB",
	"SUNKEN_BOAT_BIRD",
	"SUNKEN_BOAT_DEBRIS",
	"PALMLEAF_HUT_SHADOW",
	"KRAKEN_INKPATCH",
	"KNIGHTBOAT_CANNONSHOT",
	"JELLYFISH_SPAWNER",
	"INVENTORYWATERYGRAVE",
	"FLOTSAM_ARMOURED",
	"FLOTSAM_DEBRIS",
	"FLOTSAM_SURFBOARD",
	"DRAGOONHEART_LIGHT",
	"DRAGOONFIRE",
	"CHESS_NAVY_SPAWNER",
	"BOATSPAWNPOINT",

	--Character specific items
	"BALLOON",
	"BOOK_BRIMSTONE",
	"BOOK_GARDENING",
	"LUCY",
	"SPEAR_WATHGRITHR",
	"LIGHTER",
	"WAXWELLJOURNAL",
	"ABIGAIL_FLOWER",
	"BALLOONS_EMPTY",
	"SURFBOARD",
	"WATHGRITHRHAT",
	"BOOK_BIRDS",
	"SURFBOARD_ITEM",
	"MAILPACK",
	"BOOK_SLEEP",
	"SPICEPACK",
	"WOODLEGS_BOATCANNON",
	"WOODLEGS_CANNONSHOT",
	"WOODLEGS_UNLOCK",
	"PORTABLECOOKPOT",
	"SHADOWWAXWELL_BOAT",
	"RAWLING",
	-- /end
}

function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do
    	table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
    	i = i + 1
    	if a[i] == nil then
    		return nil
    	else
    		return a[i], t[a[i]]
    	end
    end
    return iter
end

local function GenerateFile(missingStrings)
	local outfile = io.open("MISSINGSTRINGS.lua", "w")
	if outfile then
		outfile:write(missingStrings)
		outfile:close()
	end
end

local function GenIndentString(num)
	local str = ""
	for i = 1, num or 0 do
		str = str.."\t"
	end
	return str
end

local function TableToString(key, tbl, numIndent)
    local table_sorted = {}
    for title, value in pairsByKeys(tbl) do
    	table.insert(table_sorted, {title = title, value = value})
    end

	local indt = GenIndentString(numIndent)
	local str = ""
	str = str..GenIndentString(numIndent - 1)..key..' ='..'\n'..GenIndentString(numIndent - 1)..'{\n'
	for k,v in ipairs(table_sorted) do
		if type(v.value) == "string" then
			str = str..GenIndentString(numIndent)..v.title..' = '..'"'..v.value..'",\n'
		elseif type(v) == "table" then
			str = str..TableToString(v.title, v.value, numIndent + 1)
		end
	end
	str = str..GenIndentString(numIndent - 1)..'},\n'

	return str
end

function GetPrefabsFromFile( fileName )
    local fn, r = loadfile(fileName)
    assert(fn, "Could not load file ".. fileName)
	if type(fn) == "string" then
		assert(false, "Error loading file "..fileName.."\n"..fn)
	end
    assert( type(fn) == "function", "Prefab file doesn't return a callable chunk: "..fileName)
	local ret = {fn()}
	return ret
end

local function GetCharacterSpeech(character)
    if character == "waxwell" then character = "maxwell" end
    print("GETTING SPEECH STRINGS FOR", character)
	local success, speechFile = pcall(require, "speech_"..character)

	if not success then
        print("\t\t WHOOPS didn't work!")
		return nil
	end

    return speechFile
end


local function GetMissingPrefabStrings(prefabs, speechFile)
	local missingStrings = {}

	for k,v in pairs(prefabs) do
        if v and speechFile.DESCRIBE[v] == nil or speechFile.DESCRIBE[v] == "" then
            missingStrings[v] = ""
        end
    end

    return missingStrings
end

local function GetMissingElementsFromTable(qTable, refTable)
    local missing_keys = {}

    for k,v in pairs(refTable) do
        if v ~= nil and v ~= "" then
            if type(v) == "table" then
                local missTable = GetMissingElementsFromTable(qTable and qTable[k] or nil, v)
                missing_keys[k] = missTable
            elseif qTable == nil or qTable[k] == nil or qTable[k] == "" then
                missing_keys[k] = ""
            end
        end
    end

    return next(missing_keys) and missing_keys or nil
end

local function GetMissingCharacterStrings(speechFile, refSpeechFile)
    return GetMissingElementsFromTable(speechFile, refSpeechFile)
end

local function LookForIgnoredKeywords(str)
	for k,v in pairs(IGNORED_KEYWORDS) do
		local IGNORED_KEYWORD, COUNT = string.gsub(string.upper(str), "("..string.upper(v)..")", "")
		if COUNT > 0 then
			return true
		end
	end	
end

local function MakePrefabsTable()
	local ret = {}

	for k,v in pairs(PREFABFILES) do
		local prefabs = GetPrefabsFromFile(v)
		for l,m in pairs(prefabs) do
			if type(m) == "table" then
				local name = m.name or nil
				if name then
					if not table.contains(IGNORE_PREFABS, string.upper(name)) then
						if not LookForIgnoredKeywords(m.path or "SAFEWORD") then
							name = string.upper(name)
							ret[name] = name
						end
					end
				else
					print("Prefab without name in file: "..v)
				end
			end
		end
	end

	-- for k,v in pairs(ret) do
	-- 	if LookForIgnoredKeywords(k) then
	-- 		ret[k] = nil
	-- 	end
	-- end

	return ret
end

local function DoCharacter(character, referenceStrings)
    local speech = GetCharacterSpeech(character)
    if speech then
        return GetMissingCharacterStrings(speech, referenceStrings)
    end
end

local function TestStrings()

	local str = ""

	local completePrefabList = MakePrefabsTable()

	local table = {}

    local wilsonStrings = GetCharacterSpeech("wilson")

    table["wilson"] = GetMissingPrefabStrings(completePrefabList, wilsonStrings)

	for k,v in pairs(MAIN_CHARACTERLIST) do
        if v ~= "wilson" then
            table[v] = DoCharacter(v, wilsonStrings)
        end
	end

	for k,v in pairs(ROG_CHARACTERLIST) do
        table[v] = DoCharacter(v, wilsonStrings)
	end

	for k,v in pairs(SHIPWRECKED_CHARACTERLIST) do
        table[v] = DoCharacter(v, wilsonStrings)
	end


	GenerateFile(TableToString("Missing Strings", table, 0))
end

TestStrings()
