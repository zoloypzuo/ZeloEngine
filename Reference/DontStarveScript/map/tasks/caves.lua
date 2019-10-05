


------------------------------------------------------------
-- Caves Initial Level
------------------------------------------------------------
AddTask("CavesStart", {
		locks=LOCKS.NONE,
		keys_given=KEYS.LIGHT,
		room_choices={
			["MistyCavern"] = math.random(2),
			["PitCave"] = (math.random() > 0.5 and 1) or 0,
			["RockLobsterPlains"] = 1,
			--["BGCaveRoom"] = 4+math.random(2),
		},
		room_bg=GROUND.WALL_ROCKY,
		background_room="PitRoom",--"BGCaveRoom",
		colour={r=1,g=0.7,b=1,a=1},
	})

AddTask("CavesAlternateStart", {
		locks=LOCKS.NONE,
		keys_given=KEYS.LIGHT,
		room_choices={
			["SinkholeRoom"] = 3+math.random(2),
			["MistyCavern"] = 1,
			["RockLobsterPlains"] = 1+math.random(2),
		},
		room_bg=GROUND.SINKHOLE,
		background_room="PitRoom",--"BGCaveRoom",
		colour={r=1,g=0.5,b=1,a=1},
	})

AddTask("BatCaves", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.CAVE,
		entrance_room = "BatCaveRoomAntichamber",
		room_choices={
			--["CaveRoom"] = 2+math.random(2),
			["BatCaveRoom"] = 2+math.random(2),
		},
		room_bg=GROUND.CAVE,
		background_room="PitRoom",--"BGCaveRoom",
		colour={r=1,g=0.6,b=1,a=1},
	})

AddTask("FungalBatCave", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.FUNGUS,
		room_choices={
			["FungusRoom"] = 2+math.random(2),
			["SunkenMarsh"] = 2+math.random(2),
			["BatCaveRoom"] = 1+math.random(2),
		},
		room_bg=GROUND.FUNGUS,
		background_room="PitRoom",--"BGFungusRoom",
		colour={r=1,g=0,b=0.5,a=1},
	})

AddTask("TentacledCave", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.NONE,
		room_choices={
			["PitRoom"] = 1+math.random(2),
			["TentacleCave"] = 1+math.random(4),
		},
		room_bg=GROUND.MARSH,
		background_room="PitRoom",--"BGFungusRoom",
		colour={r=0.5,g=0,b=1,a=1},
	})

AddTask("LargeFungalComplex", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.CAVE,
		room_choices={
			["BatCaveRoom"] = 3+math.random(4),
			["PitRoom"] = 10+math.random(7),	
			},
		room_bg=GROUND.WALL_ROCKY,
		background_room="BGFungusRoom",
		colour={r=0.6,g=0,b=1,a=1},
	})

----------

AddTask("RedFungalComplex", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.CAVE,
		room_choices={
			["BatCaveRoom"] = math.random(4),
			["PitRoom"] = 2+math.random(5),	
			},
		room_bg=GROUND.WALL_ROCKY,
		background_room="RedMush",
		colour={r=0.6,g=0,b=1,a=1},
	})

AddTask("GreenFungalComplex", {
	locks=LOCKS.LIGHT,
	keys_given=KEYS.CAVE,
	room_choices={
		["BatCaveRoom"] = math.random(4),
		["PitRoom"] = 2+math.random(5),	
		},
	room_bg=GROUND.WALL_ROCKY,
	background_room="GreenMush",
	colour={r=0.6,g=0,b=1,a=1},
})

AddTask("BlueFungalComplex", {
	locks=LOCKS.LIGHT,
	keys_given=KEYS.CAVE,
	room_choices={
		["BatCaveRoom"] = math.random(4),
		["PitRoom"] = 2+math.random(5),	
		},
	room_bg=GROUND.WALL_ROCKY,
	background_room="BlueMush",
	colour={r=0.6,g=0,b=1,a=1},
})

------------

AddTask("RabbitsAndFungs", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.CAVE,
		room_choices={
			["RabitFungusRoom"] = 1+math.random(2),
			["SunkenMarsh"] = (math.random() > 0.5 and 1) or 2,
			["Stairs"] = 1,
			["BGCaveRoom"] = 2+math.random(2),	
		},
		room_bg=GROUND.WALL_ROCKY,
		background_room="PitRoom",--"BGFungusRoom",
		colour={r=0.8,g=0,b=1,a=1},
	})
AddTask("SingleBatCaveTask", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.CAVE,
		room_choices={
			["BatCaveRoom"] = 1,
		},
		room_bg=GROUND.CAVE,
		background_room="BGCaveRoom",
		colour={r=1,g=1,b=1,a=1},
	})

AddTask("FungalPlain", {
		locks={LOCKS.CAVE, LOCKS.FUNGUS},
		keys_given=KEYS.NONE,
		room_choices={
			--["NoisyFungus"] = 3+math.random(2),

			["GreenMush"] = (math.random() > 0.5 and  math.random(5)) or 0,
			["RedMush"] = (math.random() > 0.5 and  math.random(5)) or 0,
			["BlueMush"] = (math.random() > 0.5 and  math.random(5)) or 0,

			["RabitFungusRoom"] = 1+math.random(2),
			["RockLobsterPlains"] = 1+math.random(2),
		},
		room_bg=GROUND.WALL_ROCKY,
		background_room="PitRoom",--(math.random() > 1 and "BGFungusRoom") or "BGNoisyFungus",
		colour={r=1,g=0,b=0.6,a=1},
	})

AddTask("Cavern", {
		locks={LOCKS.LIGHT, LOCKS.FUNGUS},
		keys_given=KEYS.NONE,
		room_choices={
			["NoisyCave"] = 5+math.random(6),
			["RockLobsterPlains"] = 1,
		},
		room_bg=GROUND.CAVE_NOISE,
		background_room="PitRoom",--"BGNoisyCave",
		colour={r=1,g=0,b=0.7,a=1},
	})

AddTask("FungalRabitCityPlain", {
		locks={LOCKS.CAVE, LOCKS.FUNGUS},
		keys_given=KEYS.NONE,
		room_choices={
			["GreenMush"] = (math.random() > 0.5 and  math.random(5)) or 0,
			["RedMush"] = (math.random() > 0.5 and  math.random(5)) or 0,
			["BlueMush"] = (math.random() > 0.5 and  math.random(5)) or 0,

			["RabitFungusRoom"] = 1+math.random(2),
			["RockLobsterPlains"] = 1+math.random(2),
			["RabbitCity"] = 4+math.random(2),
		},
		room_bg=GROUND.UNDERROCK,
		background_room="PitRoom",--(math.random() > 1 and "BGFungusRoom") or "BGNoisyFungus",
		colour={r=1,g=0,b=0.6,a=1},
	})










------------------------------------------------------------
-- CAVE "BASE" TASKS
------------------------------------------------------------

AddTask("CaveBase",
	{
		locks={LOCKS.CAVE},
		keys_given=KEYS.NONE,
		room_choices={
			["CaveBase"] = 1,
		},
		room_bg=GROUND.CAVE,
		background_room="BGNoisyCave",
		colour={r=1,g=0,b=0.7,a=1},
	})

AddTask("MushBase",
	{
		locks={LOCKS.FUNGUS},
		keys_given=KEYS.NONE,
		room_choices={
			["MushBase"] = 1,
		},
		room_bg=GROUND.FUNGUS,
		background_room="BGFungusRoom",
		colour={r=1,g=0,b=0.6,a=1},
	})

AddTask("SinkBase",
	{
		locks={LOCKS.LIGHT},
		keys_given=KEYS.NONE,
		room_choices={
			["SinkBase"] = 1,
		},
		room_bg=GROUND.SINKHOLE,
		background_room="BGSinkholeRoom",
		colour={r=1,g=0,b=0.7,a=1},
	})

AddTask("RabbitTown",
	{
		locks={LOCKS.LIGHT},
		keys_given=KEYS.NONE,
		room_choices={
			["RabbitTown"] = 1,
		},
		room_bg=GROUND.SINKHOLE,
		background_room="BGSinkholeRoom",
		colour={r=1,g=0,b=0.7,a=1},
	})