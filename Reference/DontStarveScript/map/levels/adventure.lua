require("map/level")

CAMPAIGN_LENGTH = 5

----------------------------------
-- Adventure levels
----------------------------------


local function GetRandomSubstituteList( substitutes, num_choices )	
	local subs = {}
	local list = {}

	for k,v in pairs(substitutes) do 
		list[k] = v.weight
	end

	for i=1,num_choices do
		local choice = weighted_random_choice(list)
		list[choice] = nil
		subs[choice] = substitutes[choice]
	end

	return subs
end

local SUBS_1= {
			["evergreen"] = 		{perstory=0.5, 	pertask=1, 		weight=1},
			["evergreen_short"] = 	{perstory=1, 	pertask=1, 		weight=1},
			["evergreen_normal"] = 	{perstory=1, 	pertask=1, 		weight=1},
			["evergreen_tall"] = 	{perstory=1, 	pertask=1, 		weight=1},
			["sapling"] = 			{perstory=0.6, 	pertask=0.95,	weight=1},
			["beefalo"] = 			{perstory=1, 	pertask=1, 		weight=1},
			["rabbithole"] = 		{perstory=1, 	pertask=1, 		weight=1},
			["rock1"] = 			{perstory=0.3, 	pertask=1, 		weight=1},
			["rock2"] = 			{perstory=0.5, 	pertask=0.8, 	weight=1},
			["grass"] = 			{perstory=0.5, 	pertask=0.9, 	weight=1},
			["flint"] = 			{perstory=0.5, 	pertask=1,		weight=1},
			["spiderden"] =			{perstory=1, 	pertask=1, 		weight=1},
		}

AddLevel(LEVELTYPE.ADVENTURE, {
		id="RAINY", -- A Cold Reception
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[1],
		min_playlist_position=1,
		max_playlist_position=3,
		overrides={
			{"world_size", 		"default"},
			{"day", 			"longdusk"}, 
			{"weather", 		"squall"},		
			{"weather_start", 	"wet"},		
			{"frograin",		"often"},
			
			{"start_setpeice", 	"WinterStartEasy"},	
			{"start_node", 		"Forest"},	

			{"season", 			"autumn"}, 
			{"season_start", 	"summer"},
			
			{"deerclops", 		"never"},
			{"hounds", 			"never"},
			{"mactusk", 		"always"},
			{"leifs",			"always"},
			
			{"trees", 			"often"},
			{"carrot", 			"default"},
			{"berrybush", 		"never"},
		},
		substitutes = GetRandomSubstituteList(SUBS_1, 3),
		tasks = {
				"Make a pick",
				"Easy Blocked Dig that rock",
				"Great Plains",
				"Guarded Speak to the king",
		},
		numoptionaltasks = 4,
		optionaltasks = {
				"Waspy Beeeees!",
				"Guarded Squeltch",
				"Guarded Forest hunters",
				"Befriend the pigs",
				"Guarded For a nice walk",
				"Walled Kill the spiders",
				"Killer bees!",
				"Make a Beehat",
				"Waspy The hunters",
				"Hounded Magic meadow",
				"Wasps and Frogs and bugs",
				"Guarded Walrus Desolate",
		},
		set_pieces = {
			["WesUnlock"] = { restrict_to="background", tasks={
														"Easy Blocked Dig that rock",
														"Great Plains",
														"Guarded Speak to the king",
														"Waspy Beeeees!",
														"Guarded Squeltch",
														"Guarded Forest hunters",
														"Befriend the pigs",
														"Guarded For a nice walk",
														"Walled Kill the spiders",
														"Killer bees!",
														"Make a Beehat",
														"Waspy The hunters",
														"Hounded Magic meadow",
														"Wasps and Frogs and bugs",
														"Guarded Walrus Desolate"} },
			["ResurrectionStoneWinter"] = { count=1, tasks={"Make a pick",
														"Easy Blocked Dig that rock",
														"Great Plains",
														"Guarded Speak to the king",
														"Waspy Beeeees!",
														"Guarded Squeltch",
														"Guarded Forest hunters",
														"Befriend the pigs",
														"Guarded For a nice walk",
														"Walled Kill the spiders",
														"Killer bees!",
														"Make a Beehat",
														"Waspy The hunters",
														"Hounded Magic meadow",
														"Wasps and Frogs and bugs",
														"Guarded Walrus Desolate"} },
		},
		ordered_story_setpieces = {
			"TeleportatoRingLayout",
			"TeleportatoBoxLayout",
			"TeleportatoCrankLayout",
			"TeleportatoPotatoLayout",
			"TeleportatoBaseAdventureLayout",
		},
		required_prefabs = {
			"teleportato_ring",  "teleportato_box",  "teleportato_crank", "teleportato_potato", "teleportato_base", "chester_eyebone"
		},
	})
AddLevel(LEVELTYPE.ADVENTURE, {
		id="WINTER",
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[2],
		min_playlist_position=1,
		max_playlist_position=4,
		overrides={
			--{"world_size", 		"medium"},
			{"day", 			"longdusk"}, 
			
			{"start_setpeice", 	"WinterStartMedium"},		
			{"start_node",		"Clearing"},

			{"loop",			"never"},
			{"branching",		"least"},
			
			{"season", 			"onlywinter"},
			{"season_start", 	"winter"},
			{"weather", 		{"always", "often"}},		
			
			{"deerclops", 		"often"},
			{"hounds", 			"never"},
			{"mactusk", 		"always"},
			
			{{"carrot","berrybush"},{"never","rare"}},
		},
		substitutes = GetRandomSubstituteList(SUBS_1, 1),
		tasks = {
			"Resource-rich Tier2",
			"Sanity-Blocked Great Plains",
			"Hounded Greater Plains",
			"Insanity-Blocked Necronomicon",
		},
		numoptionaltasks = 2,
		optionaltasks = {
			"Walrus Desolate",
			"Walled Kill the spiders",
			"The Deep Forest",
			"Forest hunters",
		},
		set_pieces = {
			["WesUnlock"] = { restrict_to="background", tasks={ "Hounded Greater Plains", "Walrus Desolate", "Walled Kill the spiders",
																"The Deep Forest", "Forest hunters" }},
			["MacTuskTown"] = { tasks={"Insanity-Blocked Necronomicon", "Hounded Greater Plains", "Sanity-Blocked Great Plains"} },
			["ResurrectionStoneWinter"] = { count=1, tasks={"Resource-rich Tier2",
														"Sanity-Blocked Great Plains",
														"Hounded Greater Plains",
														"Insanity-Blocked Necronomicon", 
														"Walrus Desolate",
														"Walled Kill the spiders",
														"The Deep Forest",
														"Forest hunters"} },
		},
		ordered_story_setpieces = {
			"TeleportatoRingLayout",
			"TeleportatoBoxLayout",
			"TeleportatoCrankLayout",
			"TeleportatoPotatoLayout",
			"TeleportatoBaseAdventureLayout",
		},
		required_prefabs = {
			"teleportato_ring",  "teleportato_box",  "teleportato_crank", "teleportato_potato", "teleportato_base", "chester_eyebone"
		},
	})
	-- Weather: start with very short winter, then endless summer.
AddLevel(LEVELTYPE.ADVENTURE, {
		id="HUB",
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[3],
		min_playlist_position=1,
		max_playlist_position=4,
		overrides={
			--{"world_size", 		"medium"},
			{"day",			 	"longdusk"}, 
			
			{"start_setpeice", 	"PreSummerStart"},
			{"start_node",		"Clearing"},
					
			{"season", 			"preonlysummer"}, 
			{"season_start", 	"winter"},
			{"spiders",			"often"},

			{"branching",		"default"},
			{"loop",			"never"},
		},
		substitutes = GetRandomSubstituteList(SUBS_1, 3),
	-- Enemies: Lots of hound mounds and maxwell traps everywhere. Frequent hound invasions.
		tasks = {
			"Resource-Rich",
			"Lots-o-Spiders",
			"Lots-o-Tentacles",
			"Lots-o-Tallbirds",
			"Lots-o-Chessmonsters",
		},
		numoptionaltasks = 4,
		optionaltasks = {
			"The hunters",
			"Trapped Forest hunters",
			"Wasps and Frogs and bugs",
			"Tentacle-Blocked The Deep Forest",
			"Hounded Greater Plains",
			"Merms ahoy",
		},
		set_pieces = {
			["SimpleBase"] = { tasks={"Lots-o-Spiders", "Lots-o-Tentacles", "Lots-o-Tallbirds", "Lots-o-Chessmonsters"}},
			["WesUnlock"] = { restrict_to="background", tasks={ "The hunters", "Trapped Forest hunters", "Wasps and Frogs and bugs", "Tentacle-Blocked The Deep Forest", "Hounded Greater Plains", "Merms ahoy" }},
			["ResurrectionStone"] = { count=1, tasks={"Resource-Rich",
														"Lots-o-Spiders",
														"Lots-o-Tentacles",
														"Lots-o-Tallbirds",
														"Lots-o-Chessmonsters", "The hunters",
														"Trapped Forest hunters",
														"Wasps and Frogs and bugs",
														"Tentacle-Blocked The Deep Forest",
														"Hounded Greater Plains",
														"Merms ahoy"} },
		},
		ordered_story_setpieces = {
			"TeleportatoRingLayout",
			"TeleportatoBoxLayout",
			"TeleportatoCrankLayout",
			"TeleportatoPotatoLayout",
			"TeleportatoBaseAdventureLayout",
		},
		required_prefabs = {
			"teleportato_ring",  "teleportato_box",  "teleportato_crank", "teleportato_potato", "teleportato_base", "chester_eyebone"
		},
	})
AddLevel(LEVELTYPE.ADVENTURE, {
		id="ISLANDHOP",
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[4],
		min_playlist_position=1,
		max_playlist_position=4,
		overrides={
			{"islands", 		"always"},	
			{"roads", 			"never"},	
			{"start_node",		"BGGrass"},
			{"start_setpeice", 	"ThisMeansWarStart"},
			{"weather", 		{"rare", "default", "often"}},
		},
		substitutes = GetRandomSubstituteList(SUBS_1, 3),
		tasks = {
			"IslandHop_Start",
			"IslandHop_Hounds",
			"IslandHop_Forest",
			"IslandHop_Savanna",
			"IslandHop_Rocky",
			"IslandHop_Merm",
		},
		numoptionaltasks = 0,
		optionaltasks = {
		},
		set_pieces = {
			["WesUnlock"] = { restrict_to="background", tasks={ "IslandHop_Start", "IslandHop_Hounds", "IslandHop_Forest", "IslandHop_Savanna", "IslandHop_Rocky", "IslandHop_Merm" } },
		},
		ordered_story_setpieces = {
			"TeleportatoRingLayout",
			"TeleportatoBoxLayout",
			"TeleportatoCrankLayout",
			"TeleportatoPotatoLayout",
			"TeleportatoBaseAdventureLayout",
		},
		required_prefabs = {
			"teleportato_ring",  "teleportato_box",  "teleportato_crank", "teleportato_potato", "teleportato_base", "chester_eyebone"
		},
	})
AddLevel(LEVELTYPE.ADVENTURE, {
		id="TWOLANDS",
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[5],
		override_level_string=true,
		min_playlist_position=3,
		max_playlist_position=4,
		overrides={
			--{"world_size", 		"medium"},
			{"day", 			"longday"}, 
			{"season", 			"onlysummer"},
			{"season_start",	"summer"},
			
			{"islands", 		"always"},	
			{"roads", 			"never"},	
				
			{"start_setpeice", 	"BargainStart"},		
			{"start_node",		"Clearing"},
		},
		substitutes = GetRandomSubstituteList(SUBS_1, 3),
		tasks = {
			-- Part 1 - Easy peasy - lots of stuff
			"Land of Plenty",
			
			-- Part 2 - Lets kill them off
			"The other side",	
		},
		override_triggers = {
			["START"] = {	-- Quick (localised) fix for area-aware bug #677
									{"weather", "never"}, 
									{"day", "longday"},
							 	},
			["Land of Plenty"] = {	
									{"weather", "never"}, 
									{"day", "longday"},
							 	},
			["The other side"] = {	
									{"weather", "often"}, 
									{"day", "longdusk"},
							 	},
		},
		set_pieces = {
			["MaxPigShrine"] = {tasks={"Land of Plenty"}},
			["MaxMermShrine"] = {tasks={"The other side"}},
			["ResurrectionStone"] = { count=2, tasks={"Land of Plenty", "The other side" } },
		},
		ordered_story_setpieces = {
			"TeleportatoRingLayout",
			"TeleportatoBoxLayout",
			"TeleportatoCrankLayout",
			"TeleportatoPotatoLayout",
			"TeleportatoBaseAdventureLayout",
		},
		required_prefabs = {
			"teleportato_ring",  "teleportato_box",  "teleportato_crank", "teleportato_potato", "teleportato_base", "chester_eyebone"
		},
	})

AddLevel(LEVELTYPE.ADVENTURE, {
		id="DARKNESS",
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[6],
		min_playlist_position=CAMPAIGN_LENGTH,
		max_playlist_position=CAMPAIGN_LENGTH,
		overrides={
			{"branching",		"never"},
			{"day", 			"onlynight"}, 
			{"season_start", 	"summer"},
			{"season", 			"onlysummer"},
			{"weather", 		"often"}, -- always

			{"boons",			"always"},
			
			{"roads", 			"never"},
			--{"carrot", 			"rare"},
			{"berrybush", 		"never"},
			{"spiders", 		"often"},

			{"fireflies",		"always"},
			
			{"start_setpeice", 	"NightmareStart"},--ThisMeansWarStart"},
			{"start_node",		"BGGrass"},

			{"maxwelllight_area",	"always"},
		},
		substitutes = MergeMaps( {["pighouse"] = {perstory=1,weight=1,pertask=1}},
								 GetRandomSubstituteList(SUBS_1, 3) ),
		tasks = {
			"Swamp start",
			"Battlefield",
			"Walled Kill the spiders",
			"Sanity-Blocked Spider Queendom",
		},
		numoptionaltasks = 2,
		optionaltasks = {
			"Killer Bees!",
			"Chessworld",
			"Tentacle-Blocked The Deep Forest",
			"Tentacle-Blocked Spider Swamp",
			"Trapped Forest hunters",
			"Waspy The hunters",
			"Hounded Magic meadow",
		},
		-- override_triggers = {
		-- 	[5] = {	
		-- 		{"season", 		"onlywinter"},
		-- 		{"season_start","winter"}, 
		-- 		{"weather", 	"always"},
		-- 		{"day", 		"onlynight"}, 
		-- 		--{"start_setpeice", 	"PermaWinterNight"},
		-- 	},
		--},	
		set_pieces = {
			["RuinedBase"] = {tasks={"Swamp start", "Battlefield", "Walled Kill the spiders", "Killer Bees!"}},
			["ResurrectionStoneLit"] = { count=4, tasks={"Swamp start", "Battlefield", "Walled Kill the spiders", "Sanity-Blocked Spider Queendom","Killer Bees!",
														"Chessworld",
														"Tentacle-Blocked The Deep Forest",
														"Tentacle-Blocked Spider Swamp",
														"Trapped Forest hunters",
														"Waspy The hunters",
														"Hounded Magic meadow", } },
		},
		ordered_story_setpieces = {
			"TeleportatoRingLayout",
			"TeleportatoBoxLayout",
			"TeleportatoCrankLayout",
			"TeleportatoPotatoLayout",
			"TeleportatoBaseAdventureLayout",
		},
		required_prefabs = {
			"teleportato_ring",  "teleportato_box",  "teleportato_crank", "teleportato_potato", "teleportato_base", "chester_eyebone"
		},
	})
AddLevel(LEVELTYPE.ADVENTURE, {
		id="ENDING",
		name=STRINGS.UI.SANDBOXMENU.ADVENTURELEVELS[7],
		nomaxwell=true,
		min_playlist_position=CAMPAIGN_LENGTH+1, -- IMPORTANT! This should be the only level allowed to play after the campaign
		max_playlist_position=CAMPAIGN_LENGTH+1,
		overrides={
			{"day", 			"onlynight"}, 
			{"season", 			"onlysummer"},
			{"weather", 		"never"},
			{"creepyeyes", 		"always"},
			{"waves", 			"off"},
			{"boons",			"never"},
		},	
		tasks = {
			"MaxHome",
		},
		numoptionaltasks =0,
		hideminimap = true,
		teleportaction = "restart",
		teleportmaxwell = "ADVENTURE_6_TELEPORTFAIL",
		
		optionaltasks = {
		},
		override_triggers = {
			["MaxHome"] = {	
				{"areaambient", "VOID"}, 
			},
		},
	})
