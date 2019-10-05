------------------------------------------------------------------------------------------
---------             SAMPLE TASKS                   --------------------------------------
------------------------------------------------------------------------------------------
require("map/task")
require("map/lockandkey")
require("map/terrain")

local blockersets = require("map/blockersets")

SIZE_VARIATION = 3

local tasklist = {}
function AddTask(name, data)
	table.insert(tasklist, Task(name, data))
end

local function GetTaskByName(name, tasks)
	for i,task in ipairs(tasks) do 
		if task.id == name then
			return task
		end
	end

	return nil
end



-- A set of tasks to be performed 
local everything_sample2 = {
	Task("One of everything", {
		locks=LOCKS.NONE,
		keys_given=KEYS.PICKAXE,
		room_choices={
			["DenseRocks"] = 1,
			["DenseForest"] = 1,
			["SpiderCon"] = 3,
			["Forest"] = 1, 
		 }, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}) 
}
local everything_sample = {
	Task("One of everything", {
		locks=LOCKS.NONE, 
		keys_given=KEYS.PICKAXE, 
		room_choices={
			["Graveyard"] = 1, 
			["BeefalowPlain"] = 1, 		
			["SpiderVillage"] = 1, 
			["PigKingdom"] = 1, 
			["PigVillage"] = 1, 
			["MandrakeHome"] = 1,
			["BeeClearing"] = 1,
			["DenseRocks"] = 1,
			["DenseForest"] = 1,
			["Rockpile"] = 1,
			["Woodpile"] = 1,
			["Trapfield"] = 1,
			["Minefield"] = 1,
			["SpiderCon"] = 1,
			["Forest"] = 1, 
			["Rocky"] = 1, 
			["BarePlain"] = 1, 
			["Plain"] = 1, 
			["Marsh"] = 1, 
			["DeepForest"] = 1, 
			["Clearing"] = 1,
			["BurntForest"] = 1,
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}) 
}


-- The standard tasks

AddTask("Make a pick", {
		locks=LOCKS.NONE,
		keys_given={KEYS.PICKAXE,KEYS.AXE,KEYS.GRASS,KEYS.WOOD,KEYS.TIER1},
		room_choices={
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["BarePlain"] = 1, 
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 1,
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}) 
AddTask("Resource-rich Tier2", {
		locks=LOCKS.NONE, -- Special story starting node
		keys_given={KEYS.PICKAXE,KEYS.AXE,KEYS.GRASS,KEYS.WOOD,KEYS.TIER1,KEYS.TIER2},
		room_choices={
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["BarePlain"] = 1, 
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 1,
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}) 
AddTask("Resource-Rich", {
		locks=LOCKS.NONE,
		keys_given={KEYS.TIER1}, -- Special story node has only one key
		room_choices={
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["BarePlain"] = 1, 
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 1,
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}) 
AddTask("Wasps and Frogs and bugs", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER3},
		keys_given={KEYS.MEAT,KEYS.GRASS,KEYS.HONEY,KEYS.TIER2},
		entrance_room=blockersets.all_bees,
		room_choices={
			["Pondopolis"] = 1,
			["BeeClearing"] = 1,
			["EvilFlowerPatch"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 2,
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}) 
AddTask("Frogs and bugs", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER1},
		keys_given={KEYS.MEAT,KEYS.GRASS,KEYS.HONEY,KEYS.TIER2},
		room_choices={
			["Pondopolis"] = 1,
			["BeeClearing"] = 1,
			["FlowerPatch"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 2,
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}) 
AddTask("Hounded Magic meadow", {
		locks={LOCKS.TIER4},
		keys_given={KEYS.MEAT,KEYS.WOOD,KEYS.HOUNDS,KEYS.TIER2},
		entrance_room_chance=0.7,
		entrance_room=blockersets.all_hounds,
		room_choices={
			["Pondopolis"] = 2,
			["Clearing"] = 2, -- have to have at least a few rooms for tagging
		}, 
		room_bg=GROUND.FOREST,
		background_room="Clearing",
		colour={r=0,g=1,b=0,a=1}
	}) 
AddTask("Magic meadow", {
		locks={LOCKS.TIER1},
		keys_given={KEYS.GRASS,KEYS.MEAT,KEYS.TIER1},
		room_choices={
			["Pondopolis"] = 2,
			["Clearing"] = 2, -- have to have at least a few rooms for tagging
		}, 
		room_bg=GROUND.FOREST,
		background_room="Clearing",
		colour={r=0,g=1,b=0,a=1}
	}) 
AddTask("Waspy The hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.WALRUS,KEYS.TIER5},
		entrance_room=blockersets.all_bees,
		room_choices={
			["WalrusHut_Plains"] = 1,
			["WalrusHut_Grassy"] = 1,
			["WalrusHut_Rocky"] = 1,
			["Clearing"] = 2,
			["BGGrass"] = 2,
			["BGRocky"] = 2,
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=0,a=1}
	}) 
AddTask("The hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.WALRUS,KEYS.TIER5},
		room_choices={
			["WalrusHut_Plains"] = 1,
			["WalrusHut_Grassy"] = 1,
			["WalrusHut_Rocky"] = 1,
			["Clearing"] = 2,
			["BGGrass"] = 2,
			["BGRocky"] = 2,
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=0,a=1}
	}) 
AddTask("Guarded Walrus Desolate", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.HARD_WALRUS,KEYS.TIER5},
		entrance_room=ArrayUnion(blockersets.rocky_hard, blockersets.all_walls),
		room_choices={
			["WalrusHut_Plains"] = 1,
			["WalrusHut_Grassy"] = 1,
			["WalrusHut_Rocky"] = 1,
			["BGRocky"] = 2,
		}, 
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=0,g=1,b=0,a=1}
	}) 
AddTask("Walrus Desolate", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.HARD_WALRUS,KEYS.TIER5},
		room_choices={
			["WalrusHut_Plains"] = 1,
			["WalrusHut_Grassy"] = 1,
			["WalrusHut_Rocky"] = 1,
			["BGRocky"] = 2,
		}, 
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=0,g=1,b=0,a=1}
	}) 
AddTask("Insanity-Blocked Necronomicon", {
		locks={LOCKS.TIER3},
		keys_given={KEYS.TRINKETS,KEYS.WOOD,KEYS.TIER3},
		entrance_room=blockersets.all_walls,
		room_choices={
			["Graveyard"] = 3,
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["DeepForest"] = 2,
		}, 
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=0,g=1,b=0,a=1}
	}) 
AddTask("Necronomicon", {
		locks={LOCKS.ROCKS,LOCKS.TIER2},
		keys_given={KEYS.TRINKETS,KEYS.WOOD,KEYS.TIER3},
		room_choices={
			["Graveyard"] = 3,
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["DeepForest"] = 2,
		}, 
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=0,g=1,b=0,a=1}
	}) 
																  
AddTask("Easy Blocked Dig that rock", {
		locks={LOCKS.ROCKS,LOCKS.TIER1},
		keys_given={KEYS.TRINKETS,KEYS.STONE,KEYS.WOOD,KEYS.TIER1},
		entrance_room_chance=0.5,
		entrance_room=blockersets.all_easy,
		room_choices={
			["Graveyard"] = 1,
			--["Wormhole"] = 1,
			["Rocky"] = 1 + math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
			["Clearing"] = math.random(SIZE_VARIATION)
		},
		room_bg=GROUND.ROCKY,
		background_room="BGNoise",
		colour={r=0,g=0,b=1,a=1}
	}) 
																  
AddTask("Dig that rock", {
		locks={LOCKS.ROCKS},
		keys_given={KEYS.TRINKETS,KEYS.STONE,KEYS.WOOD,KEYS.TIER1},
		room_choices={
			["Graveyard"] = 1,
			["Sinkhole"] = 1,
			["Rocky"] = 1 + math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
			["Clearing"] = math.random(SIZE_VARIATION)
		},
		room_bg=GROUND.ROCKY,
		background_room="BGNoise",
		colour={r=0,g=0,b=1,a=1}
	}) 
																  
AddTask("Tentacle-Blocked The Deep Forest", {
		locks={LOCKS.TREES,LOCKS.TIER3},
		keys_given={KEYS.TENTACLES,KEYS.PIGS,KEYS.WOOD,KEYS.MEAT,KEYS.TIER3},
		entrance_room=blockersets.all_tentacles,
		room_choices={
			--["Wormhole"] = 1,
			["PigVillage"] = 1,
			["BGForest"] = 1 + math.random(SIZE_VARIATION), 
			["Marsh"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = 1+math.random(SIZE_VARIATION), 
			["Clearing"] = 1
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGDeepForest",
		colour={r=1,g=0,b=0,a=1}
	}) 
AddTask("The Deep Forest", {
		locks={LOCKS.TREES,LOCKS.TIER2},
		keys_given={KEYS.PIGS,KEYS.WOOD,KEYS.MEAT,KEYS.TIER2},
		room_choices={
			--["Wormhole"] = 1,
			["PigVillage"] = 1,
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["Marsh"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = 1+math.random(SIZE_VARIATION), 
			["Clearing"] = 1,
			["Sinkhole"] = 1
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGDeepForest",
		colour={r=1,g=0,b=0,a=1}
	}) 
--------------------------------------------------------------------------------
-- Pigs 
--------------------------------------------------------------------------------
AddTask("Trapped Befriend the pigs", {
		locks={LOCKS.PIGGIFTS,LOCKS.TIER2},
		keys_given={KEYS.PIGS,KEYS.MEAT,KEYS.GRASS,KEYS.WOOD,KEYS.TIER2},
		entrance_room="Trapfield",
		room_choices={
			["PigVillage"] = 1, 
			--["Wormhole"] = 1,
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["Marsh"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = math.random(SIZE_VARIATION), 
			["Clearing"] = 1
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=0,b=0,a=1}
	}) 
AddTask("Befriend the pigs", {
		locks={LOCKS.PIGGIFTS,LOCKS.TIER1},
		keys_given={KEYS.PIGS,KEYS.MEAT,KEYS.GRASS,KEYS.WOOD,KEYS.TIER2},
		room_choices={
			["PigVillage"] = 1, 
			--["Wormhole"] = 1,
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["Marsh"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = math.random(SIZE_VARIATION), 
			["Clearing"] = 1
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=0,b=0,a=1}
	}) 
AddTask("Pigs in the city", {
		locks=LOCKS.PIGGIFTS,
		keys_given=KEYS.PIGS,
		room_choices={
			["PigCity"] = 1, 
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 1 + math.random(SIZE_VARIATION), 
			["DeepForest"] = 1, 
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=1,g=0,b=0,a=1}
	}) 
AddTask("The Pigs are back in town", {
		locks=LOCKS.PIGGIFTS,
		keys_given=KEYS.PIGS,
		room_choices={
			["PigTown"] = 1, 
			["Forest"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 1 + math.random(SIZE_VARIATION), 
			["DeepForest"] = 1, 
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGForest",
		colour={r=1,g=0,b=0,a=1}
	}) 
 AddTask("Guarded King and Spiders", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.PIGS,
		entrance_room="PigGuardpost",
		room_choices={
			["PigKingdom"] = 1, 
			--["Wormhole"] = 1,
			["Graveyard"] = 1,
			["CrappyDeepForest"] = 1,
			["SpiderForest"] = 3,
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGCrappyForest",
		colour={r=1,g=1,b=0,a=1}
	}) 
 AddTask("Guarded Speak to the king", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.PIGS,
		entrance_room=blockersets.all_pigs,
		room_choices={
			["PigKingdom"] = 1, 
			--["Wormhole"] = 1,
			["DeepForest"] = 3 + math.random(SIZE_VARIATION), 
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=1,b=0,a=1}
	}) 
 AddTask("King and Spiders", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.PIGS,
		room_choices={
			["PigKingdom"] = 1, 
			--["Wormhole"] = 1,
			["Graveyard"] = 1,
			["CrappyDeepForest"] = 1,
			["SpiderForest"] = 3,
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGCrappyForest",
		colour={r=1,g=1,b=0,a=1}
	}) 
 AddTask("Speak to the king", {
		locks={LOCKS.PIGKING,LOCKS.TIER2},
		keys_given={KEYS.PIGS,KEYS.GOLD,KEYS.TIER3},
		room_choices={
			["PigKingdom"] = 1,
			["Sinkhole"] = 1,
			--["Wormhole"] = 1,
			["DeepForest"] = 3 + math.random(SIZE_VARIATION), 
		}, 
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=1,b=0,a=1}
	}) 
--------------------------------------------------------------------------------
-- Beefalo 
--------------------------------------------------------------------------------
AddTask("Hounded Greater Plains", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.TIER4},
		keys_given={KEYS.MEAT,KEYS.WOOL,KEYS.POOP,KEYS.HOUNDS,KEYS.WALRUS,KEYS.TIER4},
		entrance_room=blockersets.all_hounds,
		room_choices={
			["BeefalowPlain"] = 3 + math.random(SIZE_VARIATION), 		
			--["Wormhole_Plains"] = 1,
			["WalrusHut_Plains"] = 1,
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=1,a=1}
	}) 
AddTask("Greater Plains", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.TIER3},
		keys_given={KEYS.MEAT,KEYS.WOOL,KEYS.POOP,KEYS.WALRUS,KEYS.TIER4},
		room_choices={
			["BeefalowPlain"] = 3 + math.random(SIZE_VARIATION), 		
			--["Wormhole_Plains"] = 1,
			["WalrusHut_Plains"] = 1,
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=1,a=1}
	}) 
AddTask("Sanity-Blocked Great Plains", {
		locks={LOCKS.ROCKS,LOCKS.BASIC_COMBAT,LOCKS.TIER4},
		keys_given={KEYS.MEAT,KEYS.POOP,KEYS.WOOL,KEYS.GRASS,KEYS.TIER2},
		entrance_room="SanityWall",
		room_choices={
			["BeefalowPlain"] = 1 + math.random(SIZE_VARIATION), 		
			--["Wormhole_Plains"] = 1,
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 2,
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=1,a=1}
	}) 
AddTask("Great Plains", {
		locks={LOCKS.ROCKS,LOCKS.BASIC_COMBAT,LOCKS.TIER1},
		keys_given={KEYS.MEAT,KEYS.POOP,KEYS.WOOL,KEYS.GRASS,KEYS.TIER2},
		room_choices={
			["BeefalowPlain"] = 1 + math.random(SIZE_VARIATION), 		
			--["Wormhole_Plains"] = 1,
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			["Clearing"] = 2,
		}, 
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=1,a=1}
	}) 
--------------------------------------------------------------------------------
-- Hounds 
--------------------------------------------------------------------------------
AddTask("Rock-Blocked HoundFields", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room="DenseRocks",
		room_choices={
			["Moundfield"] = 1 + math.random(SIZE_VARIATION), 		
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			}, 
		room_bg=GROUND.FOREST,
		background_room="BGRocky",
		colour={r=0,g=1,b=1,a=1}
	}) 
AddTask("HoundFields", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		room_choices={
			["Moundfield"] = 1 + math.random(SIZE_VARIATION), 		
			["Plain"] = 1 + math.random(SIZE_VARIATION), 
			}, 
		room_bg=GROUND.FOREST,
		background_room="BGRocky",
		colour={r=0,g=1,b=1,a=1}
	}) 
--------------------------------------------------------------------------------
-- Merms 
--------------------------------------------------------------------------------
AddTask("Merms ahoy", {
		locks={LOCKS.SPIDERDENS,LOCKS.BASIC_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER3},
		keys_given={KEYS.MERMS,KEYS.MEAT,KEYS.SPIDERS,KEYS.SILK,KEYS.TIER4},
		room_choices={
			["MermTown"] = 1+math.random(SIZE_VARIATION), 
			["SpiderMarsh"] = 3+math.random(SIZE_VARIATION), 
			["Marsh"] = 3+math.random(SIZE_VARIATION), 
			["DeepForest"] = 2+math.random(SIZE_VARIATION), 
		}, 
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=1,g=0,b=0,a=1}
	}) 
AddTask("Sane-Blocked Swamp", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER4},
		keys_given={KEYS.TENTACLES,KEYS.WOOD,KEYS.TIER2},
		entrance_room="SanityWall",
		room_choices={
			--["Wormhole"] = 1,
			["Marsh"] = 2+math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = 1+math.random(SIZE_VARIATION),
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	}) 
AddTask("Guarded Squeltch", {
		locks={LOCKS.SPIDERDENS,LOCKS.TIER2},
		keys_given={KEYS.MEAT,KEYS.SILK,KEYS.SPIDERS,KEYS.TIER2},
		entrance_room_chance=0.7,
		entrance_room=blockersets.all_marsh,
		room_choices={
			--["Wormhole"] = 1,
			["Marsh"] = 2+math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = 1+math.random(SIZE_VARIATION),
			["SlightlyMermySwamp"]=1,
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	}) 
AddTask("Squeltch", {
		locks={LOCKS.SPIDERDENS,LOCKS.TIER1},
		keys_given={KEYS.MEAT,KEYS.SILK,KEYS.SPIDERS,KEYS.TIER2},
		room_choices={
			["Sinkhole"] = 1,
			["Marsh"] = 2+math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
			["DeepForest"] = 1+math.random(SIZE_VARIATION),
			["SlightlyMermySwamp"]=1,
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	}) 
AddTask("Swamp start", {
		locks=LOCKS.NONE,
		keys_given={KEYS.MERMS,KEYS.TIER2,KEYS.TIER3},
		room_choices={
			["SafeSwamp"] = 2,
			--["Wormhole_Swamp"] = 1,
			["Marsh"] = 2+math.random(SIZE_VARIATION), 
			["SlightlyMermySwamp"]=1,
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.5,b=.5,a=1}
	}) 
AddTask("Tentacle-Blocked Spider Swamp", {
		locks={LOCKS.SPIDERDENS,LOCKS.BASIC_COMBAT,LOCKS.TIER3},
		keys_given={KEYS.MEAT,KEYS.TENTACLES,KEYS.SPIDERS,KEYS.TIER3,KEYS.GOLD},
		entrance_room=blockersets.all_tentacles,
		room_choices={
			["SpiderVillageSwamp"] = 1,
			["SpiderMarsh"] = 2+math.random(SIZE_VARIATION), 
			["Forest"] = 2,
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.5,g=.05,b=.05,a=1}
	}) 
AddTask("Lots-o-Spiders", {
		locks={LOCKS.ONLYTIER1}, -- note: adventure level, tier1 lock and abundant keys is to control world shape
		keys_given={KEYS.SPIDERS,KEYS.TIER3,KEYS.AXE},
		entrance_room=blockersets.all_spiders,
		room_choices={
			["SpiderCity"] = 1,
			["SpiderVillage"] = 2,
			["SpiderMarsh"] = 2+math.random(SIZE_VARIATION), 
			["CrappyForest"] = 2,
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.5,b=.05,a=1}
	}) 
AddTask("Lots-o-Tentacles", {
		locks={LOCKS.ONLYTIER1}, -- note: adventure level, tier1 lock and abundant keys is to control world shape
		keys_given={KEYS.TENTACLES,KEYS.TIER3,KEYS.AXE},
		entrance_room="TentaclelandA",
		room_choices={
			["MermTown"] = 1,
			["Marsh"] = 1+math.random(SIZE_VARIATION), 
			["SlightlyMermySwamp"] = 1+math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.5,a=1}
	}) 
AddTask("Lots-o-Tallbirds", {
		locks={LOCKS.ONLYTIER1}, -- note: adventure level, tier1 lock and abundant keys is to control world shape
		keys_given={KEYS.TALLBIRDS,KEYS.MEAT,KEYS.WOOL,KEYS.POOP,KEYS.TIER3,KEYS.TIER4,KEYS.GOLD,KEYS.AXE},
		entrance_room=blockersets.all_tallbirds,
		room_choices={
			["WalrusHut_Rocky"] = 1,
			["WalrusHut_Plains"] = 1,
			["BeefalowPlain"] = 1+math.random(SIZE_VARIATION), 
			["TallbirdNests"] = 1+math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=.5,g=.3,b=.05,a=1}
	}) 
AddTask("Lots-o-Chessmonsters", {
		locks={LOCKS.ONLYTIER1}, -- note: adventure level, tier1 lock and abundant keys is to control world shape
		keys_given={KEYS.CHESSMEN,KEYS.GEARS,KEYS.WOOL,KEYS.POOP,KEYS.TIER3,KEYS.TIER4,KEYS.GOLD},
		entrance_room=blockersets.all_chess,
		room_choices={
			["ChessForest"] = 1+math.random(SIZE_VARIATION),
			["ChessBarrens"] = 1+math.random(SIZE_VARIATION),
			["ChessMarsh"] = 1+math.random(SIZE_VARIATION),
		},
		room_bg=GROUND.ROCKY,
		background_room="BGChessRocky",
		colour={r=.8,g=.08,b=.05,a=1}
	}) 
AddTask("Spider swamp", {
		locks={LOCKS.SPIDERDENS,LOCKS.BASIC_COMBAT,LOCKS.TIER3},
		keys_given={KEYS.MEAT,KEYS.SPIDERS,KEYS.TIER3,KEYS.GOLD},
		room_choices={
			--["Wormhole_Swamp"] = 1,
			["SpiderVillageSwamp"] = 1,
			["SpiderMarsh"] = 2+math.random(SIZE_VARIATION), 
			["Forest"] = 2,
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.15,g=.05,b=.7,a=1}
	}) 
	--Task("Into the Nothing small", {
		--lock,LOCKS.ROCKS,
		--keys_given=KEYS.MEAT,
		--room_choices={
		--},
		--room_choices={
			--["Forest"] = 1, 
			--["Nothing"] = 1+math.random(SIZE_VARIATION)
		--},  
		--room_bg=GROUND.IMPASSABLE,
		--colour={r=.05,g=.05,b=.05,a=1}
	--}),
 AddTask("Sanity-Blocked Spider Queendom", {
		locks={LOCKS.PIGKING,LOCKS.SPIDERDENS,LOCKS.ADVANCED_COMBAT,LOCKS.TIER5},
		keys_given={KEYS.SPIDERS,KEYS.HARD_SPIDERS,KEYS.TIER5,KEYS.TRINKETS},
		entrance_room=blockersets.all_walls,
		room_choices={
			["SpiderCity"] = 4, 
			["Graveyard"] = 1,
			["CrappyDeepForest"] = 2,
		}, 
		room_bg=GROUND.FOREST,
		background_room="SpiderForest",
		colour={r=1,g=1,b=0,a=1}
	}) 
 AddTask("Spider Queendom", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.PIGS,
		room_choices={
			["SpiderCity"] = 4, 
			--["Wormhole_Plains"] = 1,
			["Graveyard"] = 1,
			["CrappyDeepForest"] = 2,
		}, 
		room_bg=GROUND.FOREST,
		background_room="SpiderForest",
		colour={r=1,g=1,b=0.2,a=1}
	}) 
																  
AddTask("Guarded For a nice walk", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER2},
		keys_given={KEYS.POOP,KEYS.WOOL,KEYS.WOOD,KEYS.GRASS,KEYS.TIER2},
		entrance_room_chance=0.3,
		entrance_room=ArrayUnion(blockersets.forest_easy, blockersets.all_grass, blockersets.walls_easy),
		room_choices={
			["BeefalowPlain"] = 1,
			["MandrakeHome"] = 1 + math.random(SIZE_VARIATION),
			--["Wormhole"] = 1,
			["DeepForest"] = 1 + math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=0,b=1,a=1}
	}) 
AddTask("For a nice walk", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER2},
		keys_given={KEYS.POOP,KEYS.WOOL,KEYS.WOOD,KEYS.GRASS,KEYS.TIER2},
		room_choices={
			["BeefalowPlain"] = 1,
			["MandrakeHome"] = 1 + math.random(SIZE_VARIATION),
			--["Wormhole"] = 1,
			["DeepForest"] = 1 + math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=0,b=1,a=1}
	}) 
AddTask("Mine Forest", {
		locks=LOCKS.SPIDERDENS,
		keys_given=KEYS.MEAT,
		room_choices={
			["Trapfield"] = 4,
			["Clearing"] = 2
		},  
		room_bg=GROUND.FOREST,
		background_room="BGCrappyForest",
		colour={r=.05,g=.5,b=.05,a=1}
	}) 
AddTask("Battlefield", {
		locks={LOCKS.SPIDERDEN,LOCKS.BASIC_COMBAT,LOCKS.TIER4},
		keys_given={KEYS.SPIDERS,KEYS.PIGS,KEYS.SILK,KEYS.TIER5},
		entrance_room="Trapfield",
		room_choices={
			["Trapfield"] = 1,
			["SpiderVillage"] = 2, 
			--["Wormhole"] = 1,
			["PigCamp"] = 2,
			["BGForest"] = 1,
			["DeepForest"] = 1,
			["Clearing"] = 1,
		},  
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=.05,g=.8,b=.05,a=1}
	}) 
AddTask("Guarded Forest hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.WALRUS,KEYS.TIER4},
		entrance_room=blockersets.all_forest,
		room_choices={
			["WalrusHut_Grassy"] = 1,
			--["Wormhole"] = 1,
			["BGForest"] = 2,
			["DeepForest"] = 1,
			["Clearing"] = 1,
		},  
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=.05,g=.5,b=.15,a=1}
	}) 
AddTask("Trapped Forest hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.WALRUS,KEYS.TIER4},
		entrance_room="Trapfield",
		room_choices={
			["WalrusHut_Grassy"] = 1,
			--["Wormhole"] = 1,
			["Forest"] = 2,
			["DeepForest"] = 1,
			["Clearing"] = 1,
		},  
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=.05,g=.5,b=.15,a=1}
	}) 
AddTask("Forest hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER3},
		keys_given={KEYS.WALRUS,KEYS.TIER4},
		room_choices={
			["WalrusHut_Grassy"] = 1,
			--["Wormhole"] = 1,
			["Forest"] = 2,
			["DeepForest"] = 1,
			["Clearing"] = 1,
		},  
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=.15,g=.5,b=.05,a=1}
	}) 
AddTask("Walled Kill the spiders", {
		locks={LOCKS.SPIDERDENS,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER3},
		keys_given={KEYS.SPIDERS,KEYS.TIER4},
		entrance_room_chance=0.4,
		entrance_room=blockersets.walls_easy,
		room_choices={
			["SpiderVillage"] = 2, 
			--["Wormhole"] = 1,
			["CrappyForest"] = math.random(SIZE_VARIATION), 
			["CrappyDeepForest"] = math.random(SIZE_VARIATION), 
			["Clearing"] = 1
		},  
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=.15,g=.5,b=.15,a=1}
	}) 
AddTask("Kill the spiders", {
		locks={LOCKS.SPIDERDENS,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER3},
		keys_given={KEYS.SPIDERS,KEYS.TIER4},
		room_choices={
			["SpiderVillage"] = 2, 
			--["Wormhole"] = 1,
			["CrappyForest"] = math.random(SIZE_VARIATION), 
			["CrappyDeepForest"] = math.random(SIZE_VARIATION), 
			["Clearing"] = 1
		},  
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=.25,g=.4,b=.06,a=1}
	}) 
AddTask("Waspy Beeeees!", {
		locks={LOCKS.BEEHIVE,LOCKS.TIER1},
		keys_given={KEYS.HONEY,KEYS.TIER2},
		entrance_room_chance=0.8,
		entrance_room=blockersets.all_bees,
		room_choices={
			["BeeClearing"] = 1, 
			--["Wormhole"] = 1,
			["Forest"] = math.random(SIZE_VARIATION), 
			["FlowerPatch"] = math.random(SIZE_VARIATION), 
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0.3,a=1}
	}) 
AddTask("Beeeees!", {
		locks={LOCKS.BEEHIVE,LOCKS.TIER1},
		keys_given={KEYS.HONEY,KEYS.TIER2},
		room_choices={
			["BeeClearing"] = 1, 
			--["Wormhole"] = 1,
			["Forest"] = math.random(SIZE_VARIATION), 
			["FlowerPatch"] = math.random(SIZE_VARIATION), 
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0.3,a=1}
	}) 
AddTask("Killer Bees!", {
		locks={LOCKS.KILLERBEES,LOCKS.TIER3},
		keys_given={KEYS.HONEY,KEYS.TIER3},
		entrance_room= "Waspnests",
		room_choices={
			--["Wormhole"] = 1,
			["Waspnests"] = math.random(SIZE_VARIATION), 
			["Forest"] = math.random(SIZE_VARIATION), 
			["FlowerPatch"] = math.random(SIZE_VARIATION), 
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=1,g=0.1,b=0.1,a=1}
	}) 
AddTask("Pretty Rocks Burnt", {
		locks=LOCKS.SPIDERDENS,
		keys_given=KEYS.BEEHAT,
		room_choices={
			--["Wormhole_Plains"] = 1,
			["Rocky"] = math.random(SIZE_VARIATION), 
			["FlowerPatch"] = math.random(SIZE_VARIATION), 
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrassBurnt",
		colour={r=1,g=1,b=0.5,a=1}
	})
AddTask("Make A Beehat", {
		locks={LOCKS.SPIDERS_DEFEATED,LOCKS.TIER1},
		keys_given={KEYS.BEEHAT,KEYS.GRASS,KEYS.TIER1},
		room_choices={
			--["Wormhole_Plains"] = 1,
			["Rocky"] = math.random(SIZE_VARIATION), 
			["FlowerPatch"] = math.random(SIZE_VARIATION), 
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=1,g=1,b=0.5,a=1}
	})
AddTask("The charcoal forest", {
		locks=LOCKS.NONE,
		keys_given=KEYS.NONE,
		room_choices={
			--["Wormhole_Burnt"] = 1,
			["BurntForestStart"] = 1,
			["BurntForest"] = math.random(SIZE_VARIATION), 
			["BurntClearing"] = math.random(SIZE_VARIATION), 
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrassBurnt",
		colour={r=1,g=1,b=0.5,a=1}
	})
AddTask("Land of Plenty", {
		locks=LOCKS.NONE,
		keys_given=KEYS.MEAT,
		room_choices={
			["PigCamp"] = 2,
			["PigTown"] = 2,
			["PigCity"] = 1,
			["BeeClearing"] = 1,
			["MandrakeHome"] = 2,
			["BeefalowPlain"] = 2,
			["Graveyard"] = 2,
			["Forest"] = 2,
			["DeepForest"] = 1,
			["BGRocky"] = 1,
		},  
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=.05,g=.5,b=.05,a=1}
	}) 
AddTask("The other side", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.NONE,
		entrance_room = "SanityWormholeBlocker",
		room_choices={
			["Graveyard"] = math.random(2),
			["SpiderCity"] = math.random(SIZE_VARIATION), 
			["Waspnests"] = 1, 
			["WalrusHut_Rocky"] = math.random(1),
			["Pondopolis"] = math.random(2),
			["Tentacleland"] = math.random(SIZE_VARIATION), 		
			["Moundfield"] = math.random(2), 		
			["MermTown"] = 1 + math.random(SIZE_VARIATION), 		
			["Trapfield"] = 1 + math.random(2), 		
			["ChessArea"] = math.random(2),
			["ChessMarsh"] = 1,
			["SpiderMarsh"] = 2+math.random(2), 
		},  
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.5,b=.05,a=1}
	}) 
AddTask("Chessworld", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER5},
		keys_given={KEYS.CHESSMEN,KEYS.TIER5},
		entrance_room=blockersets.all_chess,
		room_choices={
			["ChessArea"] = 2,
			["MarbleForest"] = 1+ math.random(SIZE_VARIATION),
			["ChessBarrens"] = 2,
		},  
		room_bg=GROUND.MARSH,
		background_room="BGChessRocky",
		colour={r=.05,g=.5,b=.05,a=1},
	})


require("map/tasks/maxwell")
require("map/tasks/island_hopping")

require("map/tasks/caves")
require("map/tasks/ruins")


------------------------------------------------------------
-- TEST TASKS
------------------------------------------------------------
AddTask("TEST_TASK", {
		locks=LOCKS.NONE,
		keys_given=KEYS.LIGHT,
		room_choices={
			["BGCaveRoom"] = 1,
		},
		room_bg=GROUND.SINKHOLE,
		background_room="BGSinkholeRoom",
		colour={r=1,g=0.7,b=1,a=1},
	})

AddTask("TEST_TASK1", {
		locks=LOCKS.LIGHT,
		keys_given=KEYS.CAVE,
		room_choices={
			["CaveRoom"] = 3,
			["BatCaveRoom"] = 1,
		},
		room_bg=GROUND.CAVE,
		background_room="BGCaveRoom",
		colour={r=1,g=0.6,b=1,a=1},
	})


tasks = {
	sampletasks = tasklist,
	oneofeverything = everything_sample,
	GetTaskByName = GetTaskByName,
}
