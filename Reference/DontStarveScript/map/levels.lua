require("map/level")


local levellist = {}
levellist[LEVELTYPE.SURVIVAL] = {}
levellist[LEVELTYPE.CAVE] = {}
levellist[LEVELTYPE.ADVENTURE] = {}
levellist[LEVELTYPE.TEST] = {}
levellist[LEVELTYPE.CUSTOM] = {}

function AddLevel(type, data)
	table.insert(levellist[type], Level(data))
end

require("map/levels/adventure")
require("map/levels/caves")
require("map/levels/survival")

function GetTypeForLevelID(id)
	if id == nil or id:lower() == "unknown" then
		return LEVELTYPE.UNKNOWN
	end

	id = id:lower()

	for type, levels in pairs(levellist) do
		for idx, level in ipairs(levels) do
			if level.id:lower() == id then
				return type
			end
		end
	end

	return LEVELTYPE.UNKNOWN
end


AddLevel(LEVELTYPE.TEST, {
	name="TEST_LEVEL",
	id="TEST",
		overrides={
			{"world_size", 		"tiny"},
			{"day", 			"onlynight"}, 
			{"waves", 			"off"},
			{"location",		"cave"},
			{"boons", 			"never"},
			{"poi", 			"never"},
			{"traps", 			"never"},
			{"protected", 		"never"},
			{"start_setpeice", 	"CaveStart"},
			{"start_node",		"BGSinkholeRoom"},
		},
		tasks={
			"CavesStart",
			"CavesAlternateStart",
			"FungalBatCave",
			"BatCaves",
			"TentacledCave",
			"LargeFungalComplex",
			"SingleBatCaveTask",
			"RabbitsAndFungs",
			"FungalPlain",
			"Cavern",
		},
		numoptionaltasks = 1,
		optionaltasks = {
			"CaveBase",
			"MushBase",
			"SinkBase",
			"RabbitTown",
		},
		override_triggers = {
			-- ["RuinsStart"] = {	
			-- 	{"SeasonColourCube", "caves"}, 
			-- 	-- {"SeasonColourCube", SEASONS.CAVES}, 
			-- },
			-- ["TheLabyrinth"] = {	
			-- 	{"SeasonColourCube", "caves_ruins"}, 
			-- 	-- {"SeasonColourCube", 	{	DAY = "images/colour_cubes/ruins_light_cc.tex",
			-- 	-- 							DUSK = "images/colour_cubes/ruins_dim_cc.tex",
			-- 	-- 							NIGHT = "images/colour_cubes/ruins_dark_cc.tex",
			-- 	-- 						},
			-- 					-- }, 
			-- },
			-- ["CityInRuins"] = {	
			-- 	{"SeasonColourCube", "caves_ruins"}, 
			-- 	-- {"SeasonColourCube", 	{	DAY = "images/colour_cubes/ruins_light_cc.tex",
			-- 	-- 							DUSK = "images/colour_cubes/ruins_dim_cc.tex",
			-- 	-- 							NIGHT = "images/colour_cubes/ruins_dark_cc.tex",
			-- 	-- 						},
			-- 	-- 				},
			-- },
		},
	})


return { story_levels=levellist[LEVELTYPE.ADVENTURE],
			sandbox_levels=levellist[LEVELTYPE.SURVIVAL],
			cave_levels = levellist[LEVELTYPE.CAVE],
			--free_level=levellist[LEVELTYPE.SURVIVAL][1],
			test_level=levellist[LEVELTYPE.TEST][1],
			custom_levels = levellist[LEVELTYPE.CUSTOM],
			CAMPAIGN_LENGTH=CAMPAIGN_LENGTH,
			GetTypeForLevelID = GetTypeForLevelID
		}
