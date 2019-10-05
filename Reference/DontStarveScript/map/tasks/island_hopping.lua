------------------------------------------------------------
-- Island Hopping
------------------------------------------------------------

AddTask("IslandHop_Start", { -- Sweet starting node, horrid other than that (leave the island)
		locks=LOCKS.NONE,
		keys_given=KEYS.MEAT,
		room_choices={
			["SpiderMarsh"] = 1+math.random(2), 
		},
		room_bg=GROUND.DIRT,
		background_room="BGMarsh",
		colour={r=math.random(),g=math.random(),b=math.random(),a=math.random()},
	})

AddTask("IslandHop_Hounds", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["SpiderForest"] = 1+math.random(2), 
		},
		room_bg=GROUND.DIRT,
		background_room="BGBadlands",
		colour={r=math.random(),g=math.random(),b=math.random(),a=math.random()},
	})

AddTask("IslandHop_Forest", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["Waspnests"] = 1+math.random(2), 
		},
		-- room_choices={
		-- 	["DeepForest"] = 1+math.random(2), 
		-- },
		room_bg=GROUND.DIRT,
		background_room="BGDeepForest",
		colour={r=math.random(),g=math.random(),b=math.random(),a=math.random()},
	})

AddTask("IslandHop_Savanna", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["BeefalowPlain"] = 1+math.random(2), 
		},
		-- room_choices={
		-- 	["BeefalowPlain"] = 1+math.random(2), 
		-- },
		room_bg=GROUND.DIRT,
		background_room="BGSavanna",
		colour={r=math.random(),g=math.random(),b=math.random(),a=math.random()},
	})

AddTask("IslandHop_Rocky", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["Rocky"] = 1+math.random(2), 
		},
		room_bg=GROUND.DIRT,
		background_room="BGRocky",
		colour={r=math.random(),g=math.random(),b=math.random(),a=math.random()},
	})

AddTask("IslandHop_Merm", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["SlightlyMermySwamp"] = 1+math.random(2), 
		},
		room_bg=GROUND.DIRT,
		background_room="BGMarsh",
		colour={r=math.random(),g=math.random(),b=math.random(),a=math.random()},
	})
