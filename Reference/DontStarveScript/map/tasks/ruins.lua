
------------------------------------------------------------
-- Caves Ruins Level
------------------------------------------------------------
-- AddTask("CityInRuins", {
-- 		locks={LOCKS.RUINS},
-- 		keys_given=KEYS.RUINS,
-- 		entrance_room="RuinedCityEntrance",
-- 		room_choices={
-- 			["BGMaze"] = 10+math.random(SIZE_VARIATION), 
-- 		},
-- 		room_bg=GROUND.TILES,
-- 		maze_tiles = {rooms={"default", "hallway_shop", "hallway_residential", "room_residential" }, bosses={"room_residential"}},
-- 		background_room="BGMaze",
-- 		colour={r=1,g=0,b=0.6,a=1},
-- 	})
-- AddTask("AlterAhead", {
-- 		locks={LOCKS.RUINS},
-- 		keys_given=KEYS.RUINS,
-- 		entrance_room="LabyrinthCityEntrance",
-- 		room_choices={
-- 			["BGMaze"] = 6+math.random(SIZE_VARIATION), 
-- 		},
-- 		room_bg=GROUND.TILES,
-- 		maze_tiles = {rooms={"default", "hallway", "hallway_armoury", "room_armoury" }, bosses={"room_armoury"}} ,
-- 		background_room="BGMaze",
-- 		colour={r=1,g=0,b=0.6,a=1},
-- 	})
-- AddTask("TownSquare", {
-- 		locks = {LOCKS.LABYRINTH},
-- 		keys_given = KEYS.NONE,
-- 		entrance_room = "RuinedCityEntrance",
-- 		room_choices =
-- 		{
-- 			["BGMaze"] = 6+math.random(SIZE_VARIATION),
-- 		},
-- 		room_bg = GROUND.TILES,
-- 		maze_tiles = {"room_open"},
-- 		background_room="BGMaze",
-- 		colour={r=1,g=0,b=0.6,a=1},
-- 	})
AddTask("RuinsStart", {
		locks={LOCKS.NONE},
		keys_given= {KEYS.LABYRINTH, KEYS.RUINS},
		room_choices={
			["PondWilds"] = math.random(1,3),
			["SlurperWilds"] = math.random(1,3),
			["LushWilds"] = math.random(1,2),
			["LightWilds"] = math.random(1,3),
		},
		room_bg=GROUND.MUD,
		background_room="BGWilds",
		colour={r=1,g=0,b=0.6,a=1},
	})
AddTask("TheLabyrinth", {
		locks={LOCKS.LABYRINTH},
		keys_given= {KEYS.SACRED},
		entrance_room="LabyrinthEntrance",
		room_choices={
			["BGLabyrinth"] = 3+math.random(SIZE_VARIATION), 
			["LabyrinthGuarden"] = 1, 
		},
		room_bg=GROUND.BRICK,
		background_room="BGLabyrinth",
		colour={r=1,g=0,b=0.6,a=1},
	})

AddTask("Residential", {
		locks = {LOCKS.RUINS},
		keys_given = KEYS.NONE,
		entrance_room = "RuinedCityEntrance",
		room_choices =
		{
			["Vacant"] = math.random(SIZE_VARIATION),
			["BGMonkeyWilds"] = 4 + math.random(SIZE_VARIATION),
		},
		room_bg = GROUND.TILES,
		maze_tiles = {rooms = {"room_residential", "room_residential_two", "hallway_residential", "hallway_residential_two"}, bosses = {"room_residential"}},
		background_room="BGMonkeyWilds",
		colour={r=1,g=0,b=0.6,a=1},
	})


AddTask("Military", {
		locks = {LOCKS.RUINS},
		keys_given = KEYS.NONE,
		entrance_room = "MilitaryEntrance",
		room_choices =
		{
			["BGMilitary"] = 4+math.random(SIZE_VARIATION),
		},
		room_bg = GROUND.TILES,
		maze_tiles = {rooms = {"room_armoury", "hallway_armoury", "room_armoury_two"}, bosses = {"room_armoury_two"}},
		background_room="BGMilitary",
		colour={r=1,g=0,b=0.6,a=1},
	})

AddTask("Sacred", {
		locks = {LOCKS.SACRED},
		keys_given = {KEYS.SACRED},
		room_choices =
		{
			["Barracks"] = math.random(1,2),
			["Bishops"] = math.random(1,2),
			["Spiral"] = math.random(1,2),
			["BrokenAltar"] = math.random(1,2),
			["Altar"] = 1
		},
		room_bg = GROUND.TILES,
		background_room="BGSacredGround",
		colour={r=1,g=0,b=0.6,a=1},
	})




----Optional Ruins Tasks----



AddTask("MoreAltars", {
		locks = {LOCKS.SACRED},
		keys_given = {KEYS.SACRED},
		room_choices =
		{
			["BrokenAltar"] =  math.random(1,2),
			["Altar"] = math.random(1,2)
		},
		room_bg = GROUND.TILES,
		background_room="BGSacredGround",
		colour={r=1,g=0,b=0.6,a=1},
	})
AddTask("SacredDanger", {
		locks = {LOCKS.SACRED},
		keys_given = {KEYS.SACRED},
		room_choices =
		{
			["Barracks"] = math.random(1,2),
		},
		room_bg = GROUND.TILES,
		background_room="BGSacredGround",
		colour={r=1,g=0,b=0.6,a=1},
	})
AddTask("FailedCamp", {
		locks={LOCKS.RUINS},
		keys_given= {KEYS.NONE},
		room_choices={
			["RuinsCamp"] = 1,			
		},
		room_bg=GROUND.MUD,
		background_room="BGWilds",
		colour={r=1,g=0,b=0.6,a=1},
	})

AddTask("Military2", {
		locks = {LOCKS.RUINS},
		keys_given = KEYS.NONE,
		entrance_room = "MilitaryEntrance",
		room_choices =
		{
			["BGMilitary"] = 1+math.random(SIZE_VARIATION),
		},
		room_bg = GROUND.TILES,
		maze_tiles = {rooms = {"room_armoury", "hallway_armoury", "room_armoury_two"}, bosses = {"room_armoury_two"}},
		background_room="BGMilitary",
		colour={r=1,g=0,b=0.6,a=1},
	})
AddTask("Sacred2", {
		locks = {LOCKS.SACRED},
		keys_given = {KEYS.SACRED},
		room_choices =
		{
			["Barracks"] = math.random(1,2),
			["Bishops"] = math.random(1,2),
			["Spiral"] = math.random(1,2),
			["BrokenAltar"] = math.random(1,2),
		},
		room_bg = GROUND.TILES,
		background_room="BGSacredGround",
		colour={r=1,g=0,b=0.6,a=1},
	})

AddTask("Residential2", {
		locks = {LOCKS.RUINS},
		keys_given = KEYS.NONE,
		entrance_room = "RuinedCityEntrance",
		room_choices =
		{
			["BGMonkeyWilds"] = 1 + math.random(SIZE_VARIATION),
		},
		room_bg = GROUND.TILES,
		maze_tiles = {rooms = {"room_residential", "room_residential_two", "hallway_residential", "hallway_residential_two"}, bosses = {"room_residential"}},
		background_room="BGMonkeyWilds",
		colour={r=1,g=0,b=0.6,a=1},
	})

AddTask("Residential3", {
		locks = {LOCKS.RUINS},
		keys_given = KEYS.NONE,
		room_choices =
		{
			["Vacant"] = 1 + math.random(SIZE_VARIATION),
		},
		room_bg = GROUND.TILES,
		background_room="BGWilds",
		colour={r=1,g=0,b=0.6,a=1},
	})