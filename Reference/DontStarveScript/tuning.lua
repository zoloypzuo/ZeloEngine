TUNING = {}


function Tune(overrides)
	if overrides == nil then
		overrides = {}
	end
	
	local seg_time = 30
	local total_day_time = seg_time*16
	
	local day_segs = 10
	local dusk_segs = 4
	local night_segs = 2
	
	--default day composition. changes in winter, etc
	local day_time = seg_time * day_segs
	local dusk_time = seg_time * dusk_segs
	local night_time = seg_time * night_segs
	
	local wilson_attack = 34
	local wilson_health = 150
	local calories_per_day = 75
	
	local wilson_attack_period = .5
	-----------------------
	
	local perish_warp = 1--/200
	
	TUNING =
	{
		DEMO_TIME = total_day_time * 2 + day_time*.2,
		AUTOSAVE_INTERVAL = total_day_time,
	    SEG_TIME = seg_time,
	    TOTAL_DAY_TIME = total_day_time,
		DAY_SEGS_DEFAULT = day_segs,
		DUSK_SEGS_DEFAULT = dusk_segs, 
		NIGHT_SEGS_DEFAULT = night_segs,
		
		STACK_SIZE_LARGEITEM = 10,
		STACK_SIZE_MEDITEM = 20,
		STACK_SIZE_SMALLITEM = 40,
		
		GOLDENTOOLFACTOR = 4,
	
	    DARK_CUTOFF = 0,
	    DARK_SPAWNCUTOFF = 0.1,
	    WILSON_HEALTH = wilson_health,
	    WILSON_ATTACK_PERIOD = .5,
	    WILSON_HUNGER = 150, --stomach size
	    WILSON_HUNGER_RATE = calories_per_day/total_day_time, --calories burnt per day
	    
	    WX78_MIN_HEALTH = 100,
	    WX78_MIN_HUNGER = 100,
	    WX78_MIN_SANITY = 100,

	    WX78_MAX_HEALTH = 400,
	    WX78_MAX_HUNGER = 200,
	    WX78_MAX_SANITY = 300,
	    
	    WILSON_SANITY = 200,
	    WILLOW_SANITY = 120,
	    
	    HAMMER_LOOT_PERCENT = .5,
	    AXE_USES = 100,
	    HAMMER_USES = 75,
	    SHOVEL_USES = 25,
	    PITCHFORK_USES = 25,
	    PICKAXE_USES = 33,
	    BUGNET_USES = 10,
	    SPEAR_USES = 150,
	    SPIKE_USES = 100,
	    FISHINGROD_USES = 9,
	    TRAP_USES = 8,
	    BOOMERANG_USES = 10,
	    BOOMERANG_DISTANCE = 12,
	    NIGHTSWORD_USES = 100,
	    ICESTAFF_USES = 20,
	    FIRESTAFF_USES = 20,
	    TELESTAFF_USES = 5,
	    HAMBAT_USES = 100,
	    BATBAT_USES = 75,
	    MULTITOOL_AXE_PICKAXE_USES = 400,
	    RUINS_BAT_USES = 150,

		
	    REDAMULET_USES = 20,
	    REDAMULET_CONVERSION = 5,

	    BLUEAMULET_FUEL = total_day_time * 0.75,
	    BLUEGEM_COOLER = -20,

		PURPLEAMULET_FUEL = total_day_time * 0.4,
	    
		YELLOWAMULET_FUEL = total_day_time,
		YELLOWSTAFF_USES = 20,

		ORANGEAMULET_USES = 225,
		ORANGEAMULET_RANGE = 4,
		ORANGEAMULET_ICD = 0.33,
		ORANGESTAFF_USES = 20,

		GREENAMULET_USES = 5,
		GREENAMULET_INGREDIENTMOD = 0.5,
		GREENSTAFF_USES = 5,

		BRUSH_USES = 75,

	    FISHING_MINWAIT = 2,
	    FISHING_MAXWAIT = 20,
	    
		RESEARCH_MACHINE_DIST = 4,
	    
	    UNARMED_DAMAGE = 10,
	    NIGHTSWORD_DAMAGE = wilson_attack*2,
	    -------
	    BATBAT_DAMAGE = wilson_attack * 1.25,
	    BATBAT_DRAIN = wilson_attack * 0.2,
		-------
	    SPIKE_DAMAGE = wilson_attack*1.5,
		HAMBAT_DAMAGE = wilson_attack*1.75,
	    SPEAR_DAMAGE = wilson_attack,
	    AXE_DAMAGE = wilson_attack*.8,
	    PICK_DAMAGE = wilson_attack*.8,
	    BOOMERANG_DAMAGE = wilson_attack*.8,
	    TORCH_DAMAGE = wilson_attack*.5,
	    HAMMER_DAMAGE = wilson_attack*.5,
	    SHOVEL_DAMAGE = wilson_attack*.5,
	    PITCHFORK_DAMAGE = wilson_attack*.5,
	    BUGNET_DAMAGE = wilson_attack*.125,
	    FISHINGROD_DAMAGE = wilson_attack*.125,
	    UMBRELLA_DAMAGE = wilson_attack*.5,
	    CANE_DAMAGE = wilson_attack*.5,
	    BEAVER_DAMAGE = wilson_attack*1.5,
	    MULTITOOL_DAMAGE = wilson_attack*.9,
	    RUINS_BAT_DAMAGE = wilson_attack * 1.75,

		CANE_SPEED_MULT = 1.25,
		PIGGYBACK_SPEED_MULT = 0.8,
		RUINS_BAT_SPEED_MULT = 1.1,

	    TORCH_ATTACK_IGNITE_PERCENT = 1,

	    PIG_DAMAGE = 33,
	    PIG_HEALTH = 250,
	    PIG_ATTACK_PERIOD = 3,
	    PIG_TARGET_DIST = 16,
	    PIG_LOYALTY_MAXTIME = 2.5*total_day_time,
	    PIG_LOYALTY_PER_HUNGER = total_day_time/25,
	    PIG_MIN_POOP_PERIOD = seg_time * .5,
	    
	    WEREPIG_DAMAGE = 40,
	    WEREPIG_HEALTH = 350,
	    WEREPIG_ATTACK_PERIOD = 2,
	    
	    PIG_GUARD_DAMAGE = 33,
	    PIG_GUARD_HEALTH = 300,
	    PIG_GUARD_ATTACK_PERIOD = 1.5,
	    PIG_GUARD_TARGET_DIST = 8,
	    PIG_GUARD_DEFEND_DIST = 20,
	    
	    PIG_RUN_SPEED = 5,
	    PIG_WALK_SPEED = 3,
	    
	    WEREPIG_RUN_SPEED = 7,
	    WEREPIG_WALK_SPEED = 3,
	    
	    WILSON_WALK_SPEED = 4,
	    WILSON_RUN_SPEED = 6,
	    
	    PERD_SPAWNCHANCE = 0.1,
	    PERD_DAMAGE = 20,
	    PERD_HEALTH = 50,
	    PERD_ATTACK_PERIOD = 3,
	    PERD_RUN_SPEED = 8,
	    PERD_WALK_SPEED = 3,
	    
	    MERM_DAMAGE = 30,
	    MERM_HEALTH = 250,
	    MERM_ATTACK_PERIOD = 3,
	    MERM_RUN_SPEED = 8,
	    MERM_WALK_SPEED = 3,
	    MERM_TARGET_DIST = 10,
	    MERM_DEFEND_DIST = 30,
	    
	    WALRUS_DAMAGE = 33,
	    WALRUS_HEALTH = 150,
	    WALRUS_ATTACK_PERIOD = 3,
	    WALRUS_ATTACK_DIST = 15,
	    WALRUS_DART_RANGE = 25,
        WALRUS_MELEE_RANGE = 5,
        WALRUS_TARGET_DIST = 10,
        WALRUS_LOSETARGET_DIST = 30,
        WALRUS_REGEN_PERIOD = total_day_time*2.5,

        LITTLE_WALRUS_DAMAGE = 22,
        LITTLE_WALRUS_HEALTH = 100,
        LITTLE_WALRUS_ATTACK_PERIOD = 3 * 1.7,
        LITTLE_WALRUS_ATTACK_DIST = 15,

        PIPE_DART_DAMAGE = 100,

	    PENGUIN_DAMAGE = 33,
	    PENGUIN_HEALTH = 150,
	    PENGUIN_ATTACK_PERIOD = 3,
	    PENGUIN_ATTACK_DIST = 2.5,
	    PENGUIN_MATING_SEASON_LENGTH = 6,
	    PENGUIN_MATING_SEASON_WAIT = 1,
	    PENGUIN_MATING_SEASON_BABYDELAY = total_day_time*1.5,
	    PENGUIN_MATING_SEASON_BABYDELAY_VARIANCE = 0.5*total_day_time,
	    PENGUIN_TARGET_DIST = 15,
	    PENGUIN_CHASE_DIST = 30,
	    PENGUIN_FOLLOW_TIME = 10,
	    PENGUIN_HUNGER = total_day_time * 12,  -- takes all winter to starve
	    PENGUIN_STARVE_TIME = total_day_time * 12,
	    PENGUIN_STARVE_KILL_TIME = 20,
	    
	    KNIGHT_DAMAGE = 40,
	    KNIGHT_HEALTH = 300,
	    KNIGHT_ATTACK_PERIOD = 2,
	    KNIGHT_WALK_SPEED = 5,
	    KNIGHT_TARGET_DIST = 10,
	    
	    BISHOP_DAMAGE = 40,
	    BISHOP_HEALTH = 300,
	    BISHOP_ATTACK_PERIOD = 4,
	    BISHOP_ATTACK_DIST = 6,
	    BISHOP_WALK_SPEED = 5,
	    BISHOP_TARGET_DIST = 12,

	    ROOK_DAMAGE = 45,
	    ROOK_HEALTH = 300,
	    ROOK_ATTACK_PERIOD = 2,
	    ROOK_WALK_SPEED = 5,
	    ROOK_RUN_SPEED = 16,
	    ROOK_TARGET_DIST = 12,
	    
	    MINOTAUR_DAMAGE = 100,
	    MINOTAUR_HEALTH = 2500,
	    MINOTAUR_ATTACK_PERIOD = 2,
	    MINOTAUR_WALK_SPEED = 5,
	    MINOTAUR_RUN_SPEED = 17,
	    MINOTAUR_TARGET_DIST = 25,
	    
	    SLURTLE_DAMAGE = 25,
	    SLURTLE_HEALTH = 600,
	    SLURTLE_ATTACK_PERIOD = 4,
	    SLURTLE_ATTACK_DIST = 2.5,
	    SLURTLE_WALK_SPEED = 3,
	    SLURTLE_TARGET_DIST = 10,
	    SLURTLE_SHELL_ABSORB = 0.95,
	    SLURTLE_DAMAGE_UNTIL_SHIELD = 150,

	    SLURTLE_EXPLODE_DAMAGE = 300,
	    SLURTLESLIME_EXPLODE_DAMAGE = 50,

	   	SNURTLE_WALK_SPEED = 4,
	    SNURTLE_DAMAGE = 5,
	    SNURTLE_HEALTH = 200,
	    SNURTLE_SHELL_ABSORB = 0.8,
	    SNURTLE_DAMAGE_UNTIL_SHIELD = 10,
	    SNURTLE_EXPLODE_DAMAGE = 300,
	    
	    LIGHTNING_DAMAGE = 20,

	    FREEZING_KILL_TIME = 120,
	    STARVE_KILL_TIME = 120,
	    HUNGRY_THRESH = .333,
	    
	    GRUEDAMAGE = wilson_health*.667,
	    
	    MARSHBUSH_DAMAGE = wilson_health*.02,
	    
	    GHOST_SPEED = 2,
	    GHOST_HEALTH = 200,
	    GHOST_RADIUS = 1.5,
	    GHOST_DAMAGE = wilson_health*0.1,
	    GHOST_DMG_PERIOD = 1.2,
	    GHOST_DMG_PLAYER_PERCENT = 1,

	    ABIGAIL_SPEED = 5,
	    ABIGAIL_HEALTH = wilson_health*4,
	    ABIGAIL_DAMAGE_PER_SECOND = 20,
	    ABIGAIL_DMG_PERIOD = 1.5,
	    ABIGAIL_DMG_PLAYER_PERCENT = 0.25,
	
		EVERGREEN_GROW_TIME =
	    {
	        {base=1.5*day_time, random=0.5*day_time},   --short
	        {base=5*day_time, random=2*day_time},   --normal
	        {base=5*day_time, random=2*day_time},   --tall
	        {base=1*day_time, random=0.5*day_time}   --old
	    },
	    
	    PINECONE_GROWTIME = {base=0.75*day_time, random=0.25*day_time},
	    
	    EVERGREEN_CHOPS_SMALL = 5,
	    EVERGREEN_CHOPS_NORMAL = 10,
	    EVERGREEN_CHOPS_TALL = 15,
	
	    MUSHTREE_CHOPS_SMALL = 10,
	    MUSHTREE_CHOPS_MEDIUM = 10,
	    MUSHTREE_CHOPS_TALL = 15,
	    
	    ROCKS_MINE = 6,
	    ROCKS_MINE_MED = 4,
	    ROCKS_MINE_LOW = 2,
	    SPILAGMITE_SPAWNER = 2,
	    SPILAGMITE_ROCK = 4,
	    MARBLEPILLAR_MINE = 10,
	    MARBLETREE_MINE = 8,

	    SPIDER_APE_HEALTH = 500,
	    SPIDER_APE_DAMAGE = 34,
	    SPIDER_APE_MATING_SEASON_LENGTH = 3,
	    SPIDER_APE_MATING_SEASON_WAIT = 12,
	    SPIDER_APE_MATING_SEASON_BABYDELAY = total_day_time*1.5,
	    SPIDER_APE_MATING_SEASON_BABYDELAY_VARIANCE = 0.5*total_day_time,
	    SPIDER_APE_TARGET_DIST = 5,
	    SPIDER_APE_CHASE_DIST = 30,
	    SPIDER_APE_FOLLOW_TIME = 30,
	    SPIDER_APE_HERD_RANGE = 40,
	    SPIDER_APE_HERD_MAX_IN_RANGE = 16,
	    
		BRUSH_DAMAGE = wilson_attack*.8,
	    
	    BEEFALO_HEALTH = 500,
 		BEEFALO_DAMAGE =
        {
            DEFAULT = 34,
            RIDER = 25,
            ORNERY = 50,
            PUDGY = 20,
        },        
        BEEFALO_HEALTH_REGEN_PERIOD = 10,
        BEEFALO_HEALTH_REGEN = (500*2)/(total_day_time*3)*10,
	    BEEFALO_MATING_SEASON_LENGTH = 3,
	    BEEFALO_MATING_SEASON_WAIT = 12,
	    BEEFALO_MATING_SEASON_BABYDELAY = total_day_time*1.5,
	    BEEFALO_MATING_SEASON_BABYDELAY_VARIANCE = 0.5*total_day_time,
	    BEEFALO_TARGET_DIST = 5,
	    BEEFALO_CHASE_DIST = 30,
	    BEEFALO_FOLLOW_TIME = 30,
	    BEEFALOHERD_RANGE = 40,
	    BEEFALOHERD_MAX_IN_RANGE = 16,

		BEEFALO_HUNGER = (calories_per_day*4)/0.8, -- so a 0.8 fullness lasts a day
        BEEFALO_HUNGER_RATE = (calories_per_day*4)/total_day_time,
        BEEFALO_WALK_SPEED = 1.0,
        BEEFALO_RUN_SPEED =
        {
            DEFAULT = 7,
            RIDER = 8.0,
            ORNERY = 7.0,
            PUDGY = 6.5,
        },
        BEEFALO_HAIR_GROWTH_DAYS = 3,
        BEEFALO_SADDLEABLE_OBEDIENCE = 0.1,
        BEEFALO_KEEP_SADDLE_OBEDIENCE = 0.4,
        BEEFALO_MIN_BUCK_OBEDIENCE = 0.5,
        BEEFALO_MIN_BUCK_TIME = 50,
        BEEFALO_MAX_BUCK_TIME = 800,
        BEEFALO_BUCK_TIME_VARIANCE = 3,
        BEEFALO_MIN_DOMESTICATED_OBEDIENCE =
        {
            DEFAULT = 0.8,
            ORNERY = 0.45,
            RIDER = 0.95,
            PUDGY = 0.6,
        },
        BEEFALO_BUCK_TIME_MOOD_MULT = 0.2,
        BEEFALO_BUCK_TIME_UNDOMESTICATED_MULT = 0.3,
        BEEFALO_BUCK_TIME_NUDE_MULT = 0.2,

        BEEFALO_BEG_HUNGER_PERCENT = 0.45,

        BEEFALO_DOMESTICATION_STARVE_OBEDIENCE = -1/(total_day_time*1),
        BEEFALO_DOMESTICATION_FEED_OBEDIENCE = 0.1,
        BEEFALO_DOMESTICATION_OVERFEED_OBEDIENCE = -0.3,
        BEEFALO_DOMESTICATION_ATTACKED_BY_PLAYER_OBEDIENCE = -1,
        BEEFALO_DOMESTICATION_BRUSHED_OBEDIENCE = 0.4,
        BEEFALO_DOMESTICATION_SHAVED_OBEDIENCE = -1,

        BEEFALO_DOMESTICATION_LOSE_DOMESTICATION = -1/(total_day_time*4),
        BEEFALO_DOMESTICATION_GAIN_DOMESTICATION = 1/(total_day_time*20),
        BEEFALO_DOMESTICATION_MAX_LOSS_DAYS = 10, -- days
        BEEFALO_DOMESTICATION_OVERFEED_DOMESTICATION = -0.01,
        BEEFALO_DOMESTICATION_ATTACKED_DOMESTICATION = 0,
        BEEFALO_DOMESTICATION_ATTACKED_OBEDIENCE = -0.01,
        BEEFALO_DOMESTICATION_ATTACKED_BY_PLAYER_DOMESTICATION = -0.3,
        BEEFALO_DOMESTICATION_BRUSHED_DOMESTICATION = (1-(15/20))/15, -- (1-(targetdays/basedays))/targetdays

        BEEFALO_PUDGY_WELLFED = 1/(total_day_time*5),
        BEEFALO_PUDGY_OVERFEED = 0.02,
        BEEFALO_RIDER_RIDDEN = 1/(total_day_time*5),
        BEEFALO_ORNERY_DOATTACK = 0.004,
        BEEFALO_ORNERY_ATTACKED = 0.004,	    
	    
	    BABYBEEFALO_HEALTH = 300,
	    BABYBEEFALO_GROW_TIME = {base=3*day_time, random=2*day_time},
	    
	    KOALEFANT_HEALTH = 500,
	    KOALEFANT_DAMAGE = 50,
	    KOALEFANT_TARGET_DIST = 5,
	    KOALEFANT_CHASE_DIST = 30,
	    KOALEFANT_FOLLOW_TIME = 30,


	    HUNT_ALTERNATE_BEAST_CHANCE_MIN = 0.05/2,  -- divided by 2 cause we only have the ewecus
	    HUNT_ALTERNATE_BEAST_CHANCE_MAX = 0.33/2,  -- divided by 2 cause we only have the ewecus
	    
	    HUNT_SPAWN_DIST = 40,
	    HUNT_COOLDOWN = total_day_time*1.2,
	    HUNT_COOLDOWNDEVIATION = total_day_time*.3,

	    HUNT_RESET_TIME = 5,
	    HUNT_SPRING_RESET_TIME = total_day_time * 3,

	    TRACK_ANGLE_DEVIATION = 30,
	    MIN_HUNT_DISTANCE = 300, -- you can't find a new beast without being at least this far from the last one
	    MAX_DIRT_DISTANCE = 200, -- if you get this far away from your dirt pile, you probably aren't going to see it any time soon, so remove it and place a new one
	
	   	BAT_DAMAGE = 20,
	    BAT_HEALTH = 50,
	    BAT_ATTACK_PERIOD = 1,
	    BAT_ATTACK_DIST = 1.5,
	    BAT_WALK_SPEED = 8,
	    BAT_TARGET_DIST = 12,

	    SPIDER_HEALTH = 100,
	    SPIDER_DAMAGE = 20,
	    SPIDER_ATTACK_PERIOD = 3,
	    SPIDER_TARGET_DIST = 4,
	    SPIDER_INVESTIGATETARGET_DIST = 6,
	    SPIDER_WAKE_RADIUS = 4,
	    SPIDER_FLAMMABILITY = .33,
		SPIDER_SUMMON_WARRIORS_RADIUS = 12,
	    
	    SPIDER_WALK_SPEED = 3,
	    SPIDER_RUN_SPEED = 5,
	    
	    SPIDER_WARRIOR_HEALTH = 200,
	    SPIDER_WARRIOR_DAMAGE = 20,
	    SPIDER_WARRIOR_ATTACK_PERIOD = 4,
	    SPIDER_WARRIOR_ATTACK_RANGE = 6,
	    SPIDER_WARRIOR_HIT_RANGE = 3,
	    SPIDER_WARRIOR_MELEE_RANGE = 3,
	    SPIDER_WARRIOR_TARGET_DIST = 10,
	    SPIDER_WARRIOR_WAKE_RADIUS = 6,
	    
	    SPIDER_WARRIOR_WALK_SPEED = 4,
	    SPIDER_WARRIOR_RUN_SPEED = 5,

	    SPIDER_HIDER_HEALTH = 150,
	    SPIDER_HIDER_DAMAGE = 20,
	    SPIDER_HIDER_ATTACK_PERIOD = 3,
	    SPIDER_HIDER_WALK_SPEED = 3,
	    SPIDER_HIDER_RUN_SPEED = 5,
	    SPIDER_HIDER_SHELL_ABSORB = 0.75,

	    SPIDER_SPITTER_HEALTH = 175,
	    SPIDER_SPITTER_DAMAGE_MELEE = 20,
	    SPIDER_SPITTER_DAMAGE_RANGED = 20,
	    SPIDER_SPITTER_ATTACK_PERIOD = 5,
	    SPIDER_SPITTER_ATTACK_RANGE = 5,
	    SPIDER_SPITTER_MELEE_RANGE = 2,
	    SPIDER_SPITTER_HIT_RANGE = 3,
	    SPIDER_SPITTER_WALK_SPEED = 4,
	    SPIDER_SPITTER_RUN_SPEED = 5,
	
	    LEIF_HEALTH = 2000,
	    LEIF_DAMAGE = 150,
	    LEIF_ATTACK_PERIOD = 3,
	    LEIF_FLAMMABILITY = .333,
	    
	    LEIF_MIN_DAY = 3,
	    LEIF_PERCENT_CHANCE = 1/75,
	    LEIF_MAXSPAWNDIST = 15,
	    
	    LEIF_PINECONE_CHILL_CHANCE_CLOSE = .33,
	    LEIF_PINECONE_CHILL_CHANCE_FAR = .15,
	    LEIF_PINECONE_CHILL_CLOSE_RADIUS = 5,
	    LEIF_PINECONE_CHILL_RADIUS = 16,
	    LEIF_REAWAKEN_RADIUS = 20,
	    
	    LEIF_BURN_TIME = 10,
	    LEIF_BURN_DAMAGE_PERCENT = 1/8,
	    
	    DEERCLOPS_HEALTH = 2000,
	    DEERCLOPS_DAMAGE = 150,
	    DEERCLOPS_ATTACK_PERIOD = 3,
	    
	    BIRD_SPAWN_MAX = 4,
	    BIRD_SPAWN_DELAY = {min=5, max=15},
	    BIRD_SPAWN_MAX_FEATHERHAT = 7,
	    BIRD_SPAWN_DELAY_FEATHERHAT = {min=2, max=10},

		FROG_RAIN_DELAY = {min=0.1, max=2},
		FROG_RAIN_SPAWN_RADIUS = 60,
		FROG_RAIN_MAX = 300,
		FROG_RAIN_LOCAL_MAX = 25,
		FROG_RAIN_MAX_RADIUS = 50,
		FROG_RAIN_PRECIPITATION = 0.8, -- 0-1, 0.8 by default (old "often" setting for Adventure)
		FROG_RAIN_MOISTURE = 2500, -- 0-4000ish, 2500 by default (old "often" setting for Adventure)
		SURVIVAL_FROG_RAIN_PRECIPITATION = 0.67,
		FROG_RAIN_CHANCE = .16,

	    BEE_HEALTH = 100,
	    BEE_DAMAGE = 10,
	    BEE_ATTACK_PERIOD = 2,
	    BEE_TARGET_DIST = 8,
	    
	    BEEMINE_BEES = 4,
	    BEEMINE_RADIUS = 3,
	    
	    SPIDERDEN_GROW_TIME = {day_time*8, day_time*8, day_time*20},
	    SPIDERDEN_HEALTH = {50*5, 50*10, 50*20},
	    SPIDERDEN_SPIDERS = {3, 6, 9},
	    SPIDERDEN_WARRIORS = {0, 1, 3},  -- every hit, release up to this many warriors, and fill remainder with regular spiders
	    SPIDERDEN_SPIDER_TYPE = {"spider", "spider_warrior", "spider_warrior"},
		SPIDERDEN_REGEN_TIME = 3*seg_time,
		SPIDERDEN_RELEASE_TIME = 5,
		
		HOUNDMOUND_HOUNDS = 3,
		HOUNDMOUND_REGEN_TIME = seg_time,
		HOUNDMOUND_RELEASE_TIME = 5,
	    
		POND_FROGS = 4,
		POND_REGEN_TIME = day_time/2,
		POND_SPAWN_TIME = day_time/4,
		POND_RETURN_TIME = day_time*3/4,
	    FISH_RESPAWN_TIME = day_time/3,
	    
	    BEEHIVE_BEES = 6,
	    BEEHIVE_RELEASE_TIME = day_time/6,
	    BEEHIVE_REGEN_TIME = seg_time,
	    BEEBOX_BEES = 4,
	    WASPHIVE_WASPS = 6,	    
	    BEEBOX_RELEASE_TIME = (0.5*day_time)/4,
	    BEEBOX_HONEY_TIME = day_time,
	    BEEBOX_REGEN_TIME = seg_time*4,
	    
	    WORM_DAMAGE = 75,
	    WORM_ATTACK_PERIOD = 4,
	    WORM_ATTACK_DIST = 3,
	    WORM_HEALTH = 900,
	    WORM_CHASE_TIME = 20,
	    WORM_LURE_TIME = 20,
	    WORM_LURE_VARIANCE = 10,
	    WORM_FOOD_DIST = 15,
	    WORM_CHASE_DIST = 50,
	    WORM_WANDER_DIST = 30,
	    WORM_TARGET_DIST = 20,
	    WORM_LURE_COOLDOWN = 30,
	    WORM_EATING_COOLDOWN = 30,

	    WORMLIGHT_RADIUS = 3,
	    WORMLIGHT_DURATION = 90,

	    TENTACLE_DAMAGE = 34,
	    TENTACLE_ATTACK_PERIOD = 2,
	    TENTACLE_ATTACK_DIST = 4,
	    TENTACLE_STOPATTACK_DIST = 6,
	    TENTACLE_HEALTH = 500,

	    TENTACLE_PILLAR_HEALTH = 500,
        TENTACLE_PILLAR_ARMS = 12,   -- max spawned at a time
        TENTACLE_PILLAR_ARMS_TOTAL = 25,  -- max simultaneous arms
	    TENTACLE_PILLAR_ARM_DAMAGE = 5,
	    TENTACLE_PILLAR_ARM_ATTACK_PERIOD = 3,
	    TENTACLE_PILLAR_ARM_ATTACK_DIST = 3,
	    TENTACLE_PILLAR_ARM_STOPATTACK_DIST = 5,
	    TENTACLE_PILLAR_ARM_HEALTH = 20,
	    TENTACLE_PILLAR_ARM_EMERGE_TIME = 200,
	    
	    EYEPLANT_DAMAGE = 20,
	    EYEPLANT_HEALTH = 30,
	    EYEPLANT_ATTACK_PERIOD = 1,
	    EYEPLANT_ATTACK_DIST = 2.5,
	    EYEPLANT_STOPATTACK_DIST = 4,
	    
	    LUREPLANT_HIBERNATE_TIME = total_day_time * 2,
	    LUREPLANT_GROWTHCHANCE = 0.02,
	    
	    TALLBIRD_HEALTH = 400,
	    TALLBIRD_DAMAGE = 50,
	    TALLBIRD_ATTACK_PERIOD = 2,
	    TALLBIRD_HATEPIGS_DIST = 16,
	    TALLBIRD_TARGET_DIST = 8,
	    TALLBIRD_DEFEND_DIST = 12,
	    TALLBIRD_ATTACK_RANGE = 3,
	
	    TEENBIRD_HEALTH = 400*.75,
	    TEENBIRD_DAMAGE = 50*.75,
	    TEENBIRD_ATTACK_PERIOD = 2,
	    TEENBIRD_ATTACK_RANGE = 3,
	    TEENBIRD_DAMAGE_PECK = 2,
	    TEENBIRD_PECK_PERIOD = 4,
	    TEENBIRD_HUNGER = 60,
	    TEENBIRD_STARVE_TIME = total_day_time * 1,
	    TEENBIRD_STARVE_KILL_TIME = 240,
	    TEENBIRD_GROW_TIME = total_day_time*18,
	    TEENBIRD_TARGET_DIST = 8,
	
	    SMALLBIRD_HEALTH = 50,
	    SMALLBIRD_DAMAGE = 10,
	    SMALLBIRD_ATTACK_PERIOD = 1,
	    SMALLBIRD_ATTACK_RANGE = 3,
	    SMALLBIRD_HUNGER = 20,
	    SMALLBIRD_STARVE_TIME = total_day_time * 1,
	    SMALLBIRD_STARVE_KILL_TIME = 120,
	    SMALLBIRD_GROW_TIME = total_day_time*10,
	    
	    SMALLBIRD_HATCH_CRACK_TIME = 10, -- set by fire for this much time to start hatching progress
	    SMALLBIRD_HATCH_TIME = total_day_time * 3, -- must be content for this amount of cumulative time to hatch
	    SMALLBIRD_HATCH_FAIL_TIME = night_time * .5, -- being too hot or too cold this long will kill the egg

	    HATCH_UPDATE_PERIOD = 3,
	    HATCH_CAMPFIRE_RADIUS = 4,
	   
	    CHESTER_HEALTH = wilson_health*3,
	    CHESTER_RESPAWN_TIME = total_day_time * 1,
	    CHESTER_HEALTH_REGEN_AMOUNT = (wilson_health*3) * 3/60,
	    CHESTER_HEALTH_REGEN_PERIOD = 3,
	
		PROTOTYPER_TREES = {
		    SCIENCEMACHINE =
		    {
		    	SCIENCE = 1,
		    	MAGIC = 1, 
		    	ANCIENT = 0,
				LOST = 0,
			},

			ALCHEMYMACHINE =
			{
				SCIENCE = 2,
				MAGIC = 1,
				ANCIENT = 0,
				LOST = 0,
			},

			PRESTIHATITATOR =
			{
				SCIENCE = 0,
				MAGIC = 2,
				ANCIENT = 0,			
				LOST = 0,
			},

			SHADOWMANIPULATOR =
			{
				SCIENCE = 0,
				MAGIC = 3,
				ANCIENT = 0,				
				LOST = 0,
			},

			ANCIENTALTAR_LOW =
			{
				SCIENCE = 0,
				MAGIC = 0,
				ANCIENT = 2,
				LOST = 0,
			},

			ANCIENTALTAR_HIGH =
			{
				SCIENCE = 0,
				MAGIC = 0,
				ANCIENT = 4,
				LOST = 0,
			},
		},

	 
	    RABBIT_HEALTH = 25,
	    
	    FROG_HEALTH = 100,
	    FROG_DAMAGE = 10,
	    FROG_ATTACK_PERIOD = 1,
	    FROG_TARGET_DIST = 4,
	        
	    HOUND_SPECIAL_CHANCE = 
	    {
	        {minday=0, chance=0},
	        {minday=15, chance=.1},
	        {minday=30, chance=.2},
	        {minday=50, chance=.333},
	        {minday=75, chance=.5},
	    },
	
	    HOUND_HEALTH = 150,
	    HOUND_DAMAGE = 20,
	    HOUND_ATTACK_PERIOD = 2,
	    HOUND_TARGET_DIST = 20,
	    HOUND_SPEED = 10,

        HOUND_FOLLOWER_TARGET_DIST = 10,
        HOUND_FOLLOWER_TARGET_KEEP = 20,
	
	    FIREHOUND_HEALTH = 100,
	    FIREHOUND_DAMAGE = 30,
	    FIREHOUND_ATTACK_PERIOD = 2,
	    FIREHOUND_SPEED = 10,
	    
	    ICEHOUND_HEALTH = 100,
	    ICEHOUND_DAMAGE = 30,
	    ICEHOUND_ATTACK_PERIOD = 2,
	    ICEHOUND_SPEED = 10,
	    
		MOSQUITO_WALKSPEED = 8,
		MOSQUITO_RUNSPEED = 12,
		MOSQUITO_DAMAGE = 3,
		MOSQUITO_HEALTH = 100,
		MOSQUITO_ATTACK_PERIOD = 7,
		MOSQUITO_MAX_DRINKS = 4,
		MOSQUITO_BURST_DAMAGE = 34,
		MOSQUITO_BURST_RANGE = 4,
	
	    KRAMPUS_HEALTH = 200,
	    KRAMPUS_DAMAGE = 50,
	    KRAMPUS_ATTACK_PERIOD = 1.2,
	    KRAMPUS_SPEED = 7,
	    KRAMPUS_THRESHOLD = 30,
	    KRAMPUS_THRESHOLD_VARIANCE = 20,
	    KRAMPUS_INCREASE_LVL1 = 50,
	    KRAMPUS_INCREASE_LVL2 = 100,
	    KRAMPUS_INCREASE_RAMP = 2,
	    KRAMPUS_NAUGHTINESS_DECAY_PERIOD = 60,
	
	    TERRORBEAK_SPEED = 7,
	    TERRORBEAK_HEALTH = 400,
	    TERRORBEAK_DAMAGE = 50,
	    TERRORBEAK_ATTACK_PERIOD= 1.5,
	
	    CRAWLINGHORROR_SPEED = 3,
	    CRAWLINGHORROR_HEALTH = 300,
	    CRAWLINGHORROR_DAMAGE = 20,
	    CRAWLINGHORROR_ATTACK_PERIOD= 2.5,
	    
	    SHADOWCREATURE_TARGET_DIST = 20,
	    
		FROSTY_BREATH = -5,
	    
	    SEEDS_GROW_TIME = day_time*6,
	    FARM1_GROW_BONUS = 1,
	    FARM2_GROW_BONUS = .6667,
	    FARM3_GROW_BONUS = .333,
	    POOP_FERTILIZE = day_time,
	    POOP_SOILCYCLES = 10,
	    POOP_WITHEREDCYCLES = 1,
	    GUANO_FERTILIZE = day_time * 1.5,
	    GUANO_SOILCYCLES = 12,
	    GUANO_WITHEREDCYCLES = 1,
	
	    SPOILEDFOOD_FERTILIZE = day_time/4,
	    SPOILEDFOOD_SOILCYCLES = 2,
	    SPOILEDFOOD_WITHEREDCYCLES = 0.5,
	    
	    
	    
	    FISHING_CATCH_CHANCE = 0.4,
	    FISHING_LOSEROD_CHANCE = 0.4,
	
	    TINY_FUEL = seg_time*.25,
	    SMALL_FUEL = seg_time * .5,
	    MED_FUEL = seg_time * 1.5,
	    MED_LARGE_FUEL = seg_time * 3,
	    LARGE_FUEL = seg_time * 6,
	    
	    TINY_BURNTIME = seg_time*.1,
	    SMALL_BURNTIME = seg_time*.25,
	    MED_BURNTIME = seg_time*0.5,
	    LARGE_BURNTIME = seg_time,
	    
	    CAMPFIRE_RAIN_RATE = 2.5,
	    CAMPFIRE_FUEL_MAX = (night_time+dusk_time)*1.5,
	    CAMPFIRE_FUEL_START = (night_time+dusk_time)*.75,

        ROCKLIGHT_FUEL_MAX = (night_time+dusk_time)*1.5,
	
		FIREPIT_RAIN_RATE = 2,
	    FIREPIT_FUEL_MAX = (night_time+dusk_time)*2,
	    FIREPIT_FUEL_START = night_time+dusk_time,
	    FIREPIT_BONUS_MULT = 2,

	    PIGTORCH_RAIN_RATE = 2,
	    PIGTORCH_FUEL_MAX = night_time,
	    
	    NIGHTLIGHT_FUEL_MAX = (night_time+dusk_time)*3,
	    NIGHTLIGHT_FUEL_START = (night_time+dusk_time),
	    
	    TORCH_RAIN_RATE = 1.5,
	    TORCH_FUEL = night_time*1.25,

	    MINERHAT_LIGHTTIME = (night_time+dusk_time)*2.6,
	    LANTERN_LIGHTTIME = (night_time+dusk_time)*2.6,
	    SPIDERHAT_PERISHTIME = 4*seg_time,
	    SPIDERHAT_RANGE = 12,
	    ONEMANBAND_PERISHTIME = 6*seg_time,
	    ONEMANBAND_RANGE = 12,
	    
	    GRASS_UMBRELLA_PERISHTIME = 2*total_day_time*perish_warp,
	    UMBRELLA_PERISHTIME = total_day_time*6,

		EARMUFF_PERISHTIME = total_day_time*5,
		WINTERHAT_PERISHTIME = total_day_time*10,
		BEEFALOHAT_PERISHTIME = total_day_time*10,
		
		TRUNKVEST_PERISHTIME = total_day_time*15,
		SWEATERVEST_PERISHTIME = total_day_time*10,
		HUNGERBELT_PERISHTIME = total_day_time*8,

		WALRUSHAT_PERISHTIME = total_day_time*25,
		FEATHERHAT_PERISHTIME = total_day_time*8,
		TOPHAT_PERISHTIME = total_day_time*8,
	    
	    GRASS_REGROW_TIME = total_day_time*3,
	    SAPLING_REGROW_TIME = total_day_time*4,
	    MARSHBUSH_REGROW_TIME = total_day_time*4,
	    FLOWER_CAVE_REGROW_TIME = total_day_time*3,
	    LICHEN_REGROW_TIME = total_day_time*5,
	    
	    BERRY_REGROW_TIME = total_day_time*3,
	    BERRY_REGROW_INCREASE = total_day_time*.5,
	    BERRY_REGROW_VARIANCE = total_day_time*2,
	    BERRYBUSH_CYCLES = 3,
	    
	    REEDS_REGROW_TIME = total_day_time*3,
	    
	    CROW_LEAVINGS_CHANCE = .3333,
	    BIRD_TRAP_CHANCE = 0.025,
	    BIRD_HEALTH = 25,
	    
	    RABBIT_RESPAWN_TIME = day_time*4,
	    
	    FULL_ABSORPTION = 1,
	    ARMORGRASS = wilson_health*1.5,
		ARMORGRASS_ABSORPTION = .6,
	    ARMORWOOD = wilson_health*3,
		ARMORWOOD_ABSORPTION = .8,
		ARMORMARBLE = wilson_health*7,
		ARMORMARBLE_ABSORPTION = .95,
		ARMORSNURTLESHELL_ABSORPTION = 0.6,
		ARMORSNURTLESHELL = wilson_health*7,
		ARMORMARBLE_SLOW = 0.7,
		ARMORRUINS_ABSORPTION = 0.9,
		ARMORRUINS = wilson_health * 12,
		ARMORSLURPER_ABSORPTION = 0.6,
		ARMORSLURPER_SLOW_HUNGER = 0.6,
		ARMORSLURPER = wilson_health * 4,
	    ARMOR_FOOTBALLHAT = wilson_health*3,
		ARMOR_FOOTBALLHAT_ABSORPTION = .8,

		ARMOR_RUINSHAT = wilson_health*8,
		ARMOR_RUINSHAT_ABSORPTION = 0.9,
		ARMOR_RUINSHAT_PROC_CHANCE = 0.33,
		ARMOR_RUINSHAT_COOLDOWN = 5,
		ARMOR_RUINSHAT_DURATION = 4,
		ARMOR_RUINSHAT_DMG_AS_SANITY = 0.05,

		ARMOR_SLURTLEHAT = wilson_health*5,
		ARMOR_SLURTLEHAT_ABSORPTION = 0.9,
	    ARMOR_BEEHAT = wilson_health*5,
		ARMOR_BEEHAT_ABSORPTION = .8,
		ARMOR_SANITY = wilson_health * 5,
		ARMOR_SANITY_ABSORPTION = .95,
		ARMOR_SANITY_DMG_AS_SANITY = 0.10,

	    
	    PANFLUTE_SLEEPTIME = 20,
	    PANFLUTE_SLEEPRANGE = 15,
	    PANFLUTE_USES = 10,
	    HORN_RANGE = 25,
	    HORN_USES = 10,
	    HORN_EFFECTIVE_TIME = 20,
	    HORN_MAX_FOLLOWERS = 5,
	    MANDRAKE_SLEEP_TIME = 10,
	    MANDRAKE_SLEEP_RANGE = 15,
	    MANDRAKE_SLEEP_RANGE_COOKED = 25,
	    
	    GOLD_VALUES=
	    {
	        MEAT = 1,
	        RAREMEAT = 5,
	        TRINKETS=
	        {
	            4,6,4,5,4,5,4,8,7,2,5,8,
	        },
	        SUNKEN_BOAT_TRINKETS =
	        { 2, 2, 7, 1, 4 },
	    },
	
		RESEARCH_COST_CHEAP = 30,
		RESEARCH_COST_MEDIUM = 100,
		RESEARCH_COST_EXPENSIVE = 200,
		    
	    SPIDERQUEEN_WALKSPEED = 1.75,
	    SPIDERQUEEN_HEALTH = 1250,
	    SPIDERQUEEN_DAMAGE = 80,
	    SPIDERQUEEN_ATTACKPERIOD = 3,
	    SPIDERQUEEN_ATTACKRANGE = 5,
	    SPIDERQUEEN_FOLLOWERS = 16,
	    SPIDERQUEEN_GIVEBIRTHPERIOD = 20,
	    SPIDERQUEEN_MINWANDERTIME = total_day_time * 1.5,
	    SPIDERQUEEN_MINDENSPACING = 20,
	    
	    TRAP_TEETH_USES = 10,
	    TRAP_TEETH_DAMAGE = 60,
	    TRAP_TEETH_RADIUS = 1.5,
	    
	    
	    HEALING_TINY = 1,
	    HEALING_SMALL = 3,
	    HEALING_MEDSMALL = 8,
	    HEALING_MED = 20,
	    HEALING_MEDLARGE = 30,
	    HEALING_LARGE = 40,
	    HEALING_HUGE = 60,
	    HEALING_SUPERHUGE = 100,
	    
	    SANITY_SUPERTINY = 1,
	    SANITY_TINY = 5,
	    SANITY_SMALL = 10,
	    SANITY_MED = 15,
	    SANITY_MEDLARGE = 20,
	    SANITY_LARGE = 33,
	    SANITY_HUGE = 50,
	    
		PERISH_ONE_DAY = 1*total_day_time*perish_warp,
		PERISH_TWO_DAY = 2*total_day_time*perish_warp,
		PERISH_SUPERFAST = 3*total_day_time*perish_warp,
		PERISH_FAST = 6*total_day_time*perish_warp,
		PERISH_MED = 10*total_day_time*perish_warp,
		PERISH_SLOW = 15*total_day_time*perish_warp,
		PERISH_PRESERVED = 20*total_day_time*perish_warp,
		PERISH_SUPERSLOW = 40*total_day_time*perish_warp,
		
		DRY_FAST = total_day_time,
		DRY_MED = 2*total_day_time,
	
		CALORIES_TINY = calories_per_day/8, -- berries
		CALORIES_SMALL = calories_per_day/6, -- veggies
		CALORIES_MEDSMALL = calories_per_day/4,
		CALORIES_MED = calories_per_day/3, -- meat
		CALORIES_LARGE = calories_per_day/2, -- cooked meat
		CALORIES_HUGE = calories_per_day, -- crockpot foods?
		CALORIES_SUPERHUGE = calories_per_day*2, -- crockpot foods?
		
	    SPOILED_HEALTH = -1,
	    SPOILED_HUNGER = -10,
	    PERISH_FRIDGE_MULT = .5,
	    PERISH_GROUND_MULT = 1.5,
	    PERISH_GLOBAL_MULT = 1,
	    PERISH_WINTER_MULT = .75,
	    PERISH_SUMMER_MULT = 1.25,
	    
	    STALE_FOOD_HUNGER = .667,
	    SPOILED_FOOD_HUNGER = .5,
	    
	    STALE_FOOD_HEALTH = .333,
	    SPOILED_FOOD_HEALTH = 0,
	    
		BASE_COOK_TIME = night_time*.3333,
		
	    TALLBIRDEGG_HEALTH = 15;
	    TALLBIRDEGG_HUNGER = 15,
	    TALLBIRDEGG_COOKED_HEALTH = 25;
	    TALLBIRDEGG_COOKED_HUNGER = 30,
		
		REPAIR_CUTSTONE_HEALTH = 50,
		REPAIR_ROCKS_HEALTH = 50/3,
		REPAIR_GEMS_WORK = 1,
		REPAIR_GEARS_WORK = 1,

		REPAIR_THULECITE_WORK = 1.5,
		REPAIR_THULECITE_HEALTH = 100,

		REPAIR_THULECITE_PIECES_WORK = 1.5/6,
		REPAIR_THULECITE_PIECES_HEALTH = 100/6,
	
		REPAIR_BOARDS_HEALTH = 25,
		REPAIR_LOGS_HEALTH = 25/4,
		REPAIR_STICK_HEALTH = 13,
		REPAIR_CUTGRASS_HEALTH = 13,
		
		HAYWALL_HEALTH = 100,
		WOODWALL_HEALTH = 200,
		STONEWALL_HEALTH = 400,
		RUINSWALL_HEALTH = 800,
	
		EFFIGY_HEALTH_PENALTY = 30,
		
		SANITY_HIGH_LIGHT = .6,
		SANITY_LOW_LIGHT =  0.1,
	
		SANITY_DAPPERNESS = 1,
		
		SANITY_BECOME_SANE_THRESH = 35/200,
		SANITY_BECOME_INSANE_THRESH = 30/200,
		
		SANITY_DAY_GAIN = 0,--100/(day_time*32),
		
		SANITY_NIGHT_LIGHT = -100/(night_time*20),
		SANITY_NIGHT_MID = -100/(night_time*20),
		SANITY_NIGHT_DARK = -100/(night_time*2),
		
		SANITYAURA_TINY = 100/(seg_time*32),
		SANITYAURA_SMALL = 100/(seg_time*8),
		SANITYAURA_MED = 100/(seg_time*5),
		SANITYAURA_LARGE = 100/(seg_time*2),
		SANITYAURA_HUGE = 100/(seg_time*.5),
		
		DAPPERNESS_TINY = 100/(day_time*15),
		DAPPERNESS_SMALL = 100/(day_time*10),
		DAPPERNESS_MED = 100/(day_time*6),
		DAPPERNESS_LARGE = 100/(day_time*3),
		DAPPERNESS_HUGE = 100/(day_time),


		MOISTURE_SANITY_PENALTY_MAX = 100/(day_time*15),
		
		
		CRAZINESS_SMALL = -100/(day_time*2),
		CRAZINESS_MED = -100/(day_time),
		
		RABBIT_RUN_SPEED = 5,
		SANITY_EFFECT_RANGE	= 10,
		WINTER_LENGTH = 15,
		SUMMER_LENGTH = 20,
		
		CREEPY_EYES = 
		{
		    {maxsanity=.8, maxeyes=0},
		    {maxsanity=.6, maxeyes=2},
		    {maxsanity=.4, maxeyes=4},
		    {maxsanity=.2, maxeyes=6},
		},
		
		DIVINING_DISTANCES = 
		{
		    {maxdist=50, describe="hot", pingtime=1},
		    {maxdist=100, describe="warmer", pingtime=2},
		    {maxdist=200, describe="warm", pingtime=4},
		    {maxdist=400, describe="cold", pingtime=8},
		},
		DIVINING_MAXDIST = 300,
		DIVINING_DEFAULTPING = 8,
		
		--expressed in 'additional time before you freeze to death'
		INSULATION_TINY = seg_time,
		INSULATION_SMALL = seg_time*2,
		INSULATION_MED = seg_time*4,
		INSULATION_LARGE = seg_time*8,
		INSULATION_PER_BEARD_BIT = seg_time*.5,
		
		CROP_BONUS_TEMP = 28,
		MIN_CROP_GROW_TEMP = 5,
		CROP_HEAT_BONUS = 1,
		CROP_RAIN_BONUS = 3,

		WARM_DEGREES_PER_SEC = 1,
		THAW_DEGREES_PER_SEC = 5,

		TENT_USES = 6,

		BEARDLING_SANITY = .4,
		UMBRELLA_USES = 20,
		
		GUNPOWDER_RANGE = 3,
		GUNPOWDER_DAMAGE = 200,
		BIRD_RAIN_FACTOR = .25,
		
		RESURRECT_HEALTH = 50,
		
		SEWINGKIT_USES = 5,
		SEWINGKIT_REPAIR_VALUE = total_day_time*5,

		
		RABBIT_CARROT_LOYALTY = seg_time*8,
	    BUNNYMAN_DAMAGE = 40,
	    BEARDLORD_DAMAGE = 60,
	    BUNNYMAN_HEALTH = 200,
	    BUNNYMAN_ATTACK_PERIOD = 2,
	    BEARDLORD_ATTACK_PERIOD = 1,
	    BUNNYMAN_RUN_SPEED = 6,
	    BUNNYMAN_WALK_SPEED = 3,
		BUNNYMAN_PANIC_THRESH = .333,
		BEARDLORD_PANIC_THRESH = .25,
		BUNNYMAN_HEALTH_REGEN_PERIOD = 5,
		BUNNYMAN_HEALTH_REGEN_AMOUNT = (200/120)*5,
		BUNNYMAN_SEE_MEAT_DIST = 8,

		CAVE_BANANA_GROW_TIME = 4*total_day_time,
		ROCKY_SPAWN_DELAY = 4*total_day_time,
		ROCKY_SPAWN_VAR = 0,

		ROCKY_DAMAGE = 75,	
		ROCKY_HEALTH = 1500,
		ROCKY_WALK_SPEED = 2,
		ROCKY_MAX_SCALE = 1.2,
		ROCKY_MIN_SCALE = .75,
		ROCKY_GROW_RATE = (1.2-.75) / (total_day_time*40),
		ROCKY_LOYALTY = seg_time*6,
		ROCKY_ABSORB = 0.95,
		ROCKY_REGEN_AMOUNT = 10,
		ROCKY_REGEN_PERIOD = 1,
		ROCKYHERD_RANGE = 40,
		ROCKYHERD_MAX_IN_RANGE = 12,

		MONKEY_MELEE_DAMAGE = 20,
		MONKEY_HEALTH = 125,
		MONKEY_ATTACK_PERIOD = 2,
		MONKEY_MELEE_RANGE = 3,
		MONKEY_RANGED_RANGE = 17,
		MONKEY_MOVE_SPEED = 7,
		MONKEY_NIGHTMARE_CHASE_DIST = 40,

	    LIGHTER_ATTACK_IGNITE_PERCENT = .5,
	    LIGHTER_DAMAGE = wilson_attack*.5,
		WILLOW_LIGHTFIRE_SANITY_THRESH = .5,
		WX78_RAIN_HURT_RATE = 1,


		WOLFGANG_HUNGER = 300,
		WOLFGANG_START_HUNGER = 200,
		WOLFGANG_START_MIGHTY_THRESH = 225,
		WOLFGANG_END_MIGHTY_THRESH = 220,
		WOLFGANG_START_WIMPY_THRESH = 100,
		WOLFGANG_END_WIMPY_THRESH = 105,

		WOLFGANG_HUNGER_RATE_MULT_MIGHTY = 3,
		WOLFGANG_HUNGER_RATE_MULT_NORMAL = 1.5,
		WOLFGANG_HUNGER_RATE_MULT_WIMPY = 1,
		
		WOLFGANG_HEALTH_MIGHTY = 300,
		WOLFGANG_HEALTH_NORMAL = 200,
		WOLFGANG_HEALTH_WIMPY = 150,

		WOLFGANG_ATTACKMULT_MIGHTY_MAX = 2,
		WOLFGANG_ATTACKMULT_MIGHTY_MIN = 1.25,
		WOLFGANG_ATTACKMULT_NORMAL = 1,
		WOLFGANG_ATTACKMULT_WIMPY_MAX = .75,
		WOLFGANG_ATTACKMULT_WIMPY_MIN = .5,

		WENDY_DAMAGE_MULT = .75,
		WENDY_SANITY_MULT = .75,

		WICKERBOTTOM_SANITY = 250,
	    WICKERBOTTOM_STALE_FOOD_HUNGER = .333,
	    WICKERBOTTOM_SPOILED_FOOD_HUNGER = .167,
	    
	    WICKERBOTTOM_STALE_FOOD_HEALTH = .25,
	    WICKERBOTTOM_SPOILED_FOOD_HEALTH = 0,

	    FISSURE_CALMTIME_MIN = 600,
	    FISSURE_CALMTIME_MAX = 1200,
	    FISSURE_WARNTIME_MIN = 20,
	    FISSURE_WARNTIME_MAX = 30,
	    FISSURE_NIGHTMARETIME_MIN = 160,
	    FISSURE_NIGHTMARETIME_MAX = 260,
	    FISSURE_DAWNTIME_MIN = 30,
	    FISSURE_DAWNTIME_MAX = 45,


	    EYETURRET_DAMAGE = 65,
	    EYETURRET_HEALTH = 1000,
	    EYETURRET_REGEN = 12,
	    EYETURRET_RANGE = 15,
	    EYETURRET_ATTACK_PERIOD = 3,


	    TRANSITIONTIME =
	    {
	    	CALM = 2,
	    	WARN = 2,
	    	NIGHTMARE = 2,
	    	DAWN = 2,
		},

		SHADOWWAXWELL_LIFETIME = total_day_time * 2.5,
		SHADOWWAXWELL_SPEED = 6,
		SHADOWWAXWELL_DAMAGE = 40,
		SHADOWWAXWELL_LIFE = 75,
		SHADOWWAXWELL_ATTACK_PERIOD = 2,
		SHADOWWAXWELL_SANITY_PENALTY = 55,
		SHADOWWAXWELL_HEALTH_COST = 15,
		SHADOWWAXWELL_FUEL_COST = 2,

		LIVINGTREE_CHANCE = 0.55,

        FLOTSAM_REBATCH_TIME = total_day_time * 15,
        FLOTSAM_INDIVIDUAL_TIME = total_day_time * 0.2,
        FLOTSAM_BATCH_SIZE = { min = 2, max = 5 },
        FLOTSAM_SPAWN_RADIUS = 35,
        FLOTSAM_DRIFT_SPEED = 1,
        FLOTSAM_DECAY_TIME = total_day_time * 2,

        SALTLICK_CHECK_DIST = 20,
        SALTLICK_USE_DIST = 4,
        SALTLICK_DURATION = total_day_time / 8,
        SALTLICK_MAX_LICKS = 240, -- 15 days @ 8 beefalo licks per day
        SALTLICK_BEEFALO_USES = 2,
        SALTLICK_KOALEFANT_USES = 4,
        SALTLICK_LIGHTNINGGOAT_USES = 1,
        SALTLICK_DEER_USES = 1,	

        SADDLE_BASIC_BONUS_DAMAGE = 0,
        SADDLE_WAR_BONUS_DAMAGE = 16,
        SADDLE_RACE_BONUS_DAMAGE = 0,

        SADDLE_BASIC_USES = 5,
        SADDLE_WAR_USES = 8,
        SADDLE_RACE_USES = 8,

        SADDLE_BASIC_SPEEDMULT = 1.4,
        SADDLE_WAR_SPEEDMULT = 1.25,
        SADDLE_RACE_SPEEDMULT = 1.55,

        SADDLEHORN_DAMAGE = wilson_attack*.5,
        SADDLEHORN_USES = 10,	    

        SPAT_HEALTH = 500, -- lower than DST
        SPAT_PHLEGM_DAMAGE = 5,
        SPAT_PHLEGM_ATTACKRANGE = 12,
        SPAT_PHLEGM_RADIUS = 4,
        SPAT_MELEE_DAMAGE = 40, -- lower that DST
        SPAT_MELEE_ATTACKRANGE = 0.5,
        SPAT_TARGET_DIST = 10,
        SPAT_CHASE_DIST = 30,
        SPAT_FOLLOW_TIME = 30,

        PINNABLE_WEAR_OFF_TIME = 10,
        PINNABLE_ATTACK_WEAR_OFF = 2.0,
        PINNABLE_RECOVERY_LEEWAY = 1.5,    
        
		GOGGLES_NORMAL_PERISHTIME = 10*total_day_time,
		GOGGLES_HEAT_PERISHTIME = 2*total_day_time,   
		
		GOGGLES_ARMOR_ARMOR = wilson_health*4,	
		GOGGLES_ARMOR_ABSORPTION = 0.85,

		GOGGLES_SHOOT_USES = 10,

		NEARSIGHTED_BLUR_START_RADIUS = 0.0,
		NEARSIGHTED_BLUR_STRENGTH = 3.0,
	
		GOGGLES_HEAT=
		{
			HOT=
			{
				BLOOM = true,
				DESATURATION = 1.0,
				MULT_COLOUR = {0.3, 0.0, 0.0, 1.0},
				ADD_COLOUR  = {0.3, 0.1, 0.1, 1.0},
			},
			COLD=
			{
				BLOOM = false,
				DESATURATION = 1.0,
				MULT_COLOUR = {0.0, 0.0, 0.3, 1.0},
				ADD_COLOUR  = {0.1, 0.1, 0.6, 1.0},
			},
			GROUND=
			{
				MULT_COLOUR = {0.0, 0.0, 0.3, 1.0},
				ADD_COLOUR  = {0.1, 0.1, 0.6, 1.0},
			},
			WAVES=
			{
				MULT_COLOUR = {0.0, 0.0, 0.3, 1.0},
				ADD_COLOUR  = {0.1, 0.1, 0.6, 1.0},
			},
			BLUR=
			{
				ENABLED = true,
				START_RADIUS = -5.0,
				STRENGTH = 0.12,
			},
	 	},

	 	TELEBRELLA_USES = 10,	 	

	 	NEARSIGHTED_ACTION_RANGE = 4,
	}
end

Tune()
