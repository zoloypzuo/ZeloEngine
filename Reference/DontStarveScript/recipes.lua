require "recipe"
require "tuning"

--Note: If you want to add a new tech tree you must also add it into the "TECH.NONE" constant in constants.lua


--LIGHT
Recipe("campfire", {Ingredient("cutgrass", 3),Ingredient("log", 2)}, RECIPETABS.LIGHT, TECH.NONE, "campfire_placer")
Recipe("firepit", {Ingredient("log", 2),Ingredient("rocks", 12)}, RECIPETABS.LIGHT, TECH.NONE, "firepit_placer")
Recipe("torch", {Ingredient("cutgrass", 2),Ingredient("twigs", 2)}, RECIPETABS.LIGHT, TECH.NONE)

Recipe("minerhat", {Ingredient("strawhat", 1),Ingredient("goldnugget", 1),Ingredient("fireflies", 1)}, RECIPETABS.LIGHT, TECH.SCIENCE_TWO)
Recipe("pumpkin_lantern", {Ingredient("pumpkin", 1), Ingredient("fireflies", 1)}, RECIPETABS.LIGHT, TECH.SCIENCE_TWO)
Recipe("lantern", {Ingredient("twigs", 3), Ingredient("rope", 2), Ingredient("lightbulb", 2)}, RECIPETABS.LIGHT, TECH.SCIENCE_TWO)

--STRUCTURES
Recipe("treasurechest", {Ingredient("boards", 3)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, "treasurechest_placer",1)
Recipe("homesign", {Ingredient("boards", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, "homesign_placer")
Recipe("minisign_item", {Ingredient("boards", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, nil, nil, nil, 4)

Recipe("fence_gate_item", {Ingredient("boards", 2), Ingredient("rope", 1) }, RECIPETABS.TOWN, TECH.SCIENCE_TWO,nil,nil,nil,1)
Recipe("fence_item", {Ingredient("twigs", 3), Ingredient("rope", 1) }, RECIPETABS.TOWN, TECH.SCIENCE_ONE, nil,nil,nil,6)

Recipe("wall_hay_item", {Ingredient("cutgrass", 4), Ingredient("twigs", 2) }, RECIPETABS.TOWN, TECH.SCIENCE_ONE,nil,nil,nil,4)
Recipe("wall_wood_item", {Ingredient("boards", 2),Ingredient("rope", 1)}, RECIPETABS.TOWN,  TECH.SCIENCE_ONE,nil,nil,nil,8)
Recipe("wall_stone_item", {Ingredient("cutstone", 2)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO,nil,nil,nil,6)

Recipe("pighouse", {Ingredient("boards", 4), Ingredient("cutstone", 3), Ingredient("pigskin", 4)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "pighouse_placer")
Recipe("rabbithouse", {Ingredient("boards", 4), Ingredient("carrot", 10), Ingredient("manrabbit_tail", 4)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "rabbithouse_placer")
Recipe("birdcage", {Ingredient("papyrus", 2), Ingredient("goldnugget", 6), Ingredient("seeds", 2)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "birdcage_placer")

Recipe("turf_road", {Ingredient("turf_rocky", 1), Ingredient("boards", 1)}, RECIPETABS.TOWN,  TECH.SCIENCE_TWO)
Recipe("turf_woodfloor", {Ingredient("boards", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO)
Recipe("turf_checkerfloor", {Ingredient("marble", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO)
Recipe("turf_carpetfloor", {Ingredient("boards", 1), Ingredient("beefalowool", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO)

Recipe("pottedfern", {Ingredient("foliage", 5), Ingredient("slurtle_shellpieces",1 )}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "pottedfern_placer", 0.9)

--FARM
Recipe("slow_farmplot", {Ingredient("cutgrass", 8),Ingredient("poop", 4),Ingredient("log", 4)}, RECIPETABS.FARM,  TECH.SCIENCE_ONE, "farmplot_placer")
Recipe("fast_farmplot", {Ingredient("cutgrass", 10),Ingredient("poop", 6),Ingredient("rocks", 4)}, RECIPETABS.FARM,  TECH.SCIENCE_TWO, "farmplot_placer")
Recipe("beebox", {Ingredient("boards", 2),Ingredient("honeycomb", 1),Ingredient("bee", 4)}, RECIPETABS.FARM, TECH.SCIENCE_ONE, "beebox_placer")
Recipe("meatrack", {Ingredient("twigs", 3),Ingredient("charcoal", 2), Ingredient("rope", 3)}, RECIPETABS.FARM, TECH.SCIENCE_ONE, "meatrack_placer")
Recipe("cookpot", {Ingredient("cutstone", 3),Ingredient("charcoal", 6), Ingredient("twigs", 6)}, RECIPETABS.FARM,  TECH.SCIENCE_ONE, "cookpot_placer")
Recipe("icebox", {Ingredient("goldnugget", 2), Ingredient("gears", 1), Ingredient("boards", 1)}, RECIPETABS.FARM,  TECH.SCIENCE_TWO, "icebox_placer", 1.5)

--SURVIVAL
Recipe("trap", {Ingredient("twigs", 2),Ingredient("cutgrass", 6)}, RECIPETABS.SURVIVAL, TECH.NONE)
Recipe("birdtrap", {Ingredient("twigs", 3),Ingredient("silk", 4)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("compass", {Ingredient("goldnugget", 1), Ingredient("papyrus", 1)}, RECIPETABS.SURVIVAL,  TECH.SCIENCE_ONE)
Recipe("backpack", {Ingredient("cutgrass", 4), Ingredient("twigs", 4)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("piggyback", {Ingredient("pigskin", 4), Ingredient("silk", 6), Ingredient("rope", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO)
Recipe("healingsalve", {Ingredient("ash", 2), Ingredient("rocks", 1), Ingredient("spidergland",1)}, RECIPETABS.SURVIVAL,  TECH.SCIENCE_ONE)
Recipe("bandage", {Ingredient("papyrus", 1), Ingredient("honey", 2)}, RECIPETABS.SURVIVAL,  TECH.SCIENCE_TWO)
Recipe("bedroll_straw", {Ingredient("cutgrass", 6), Ingredient("rope", 1)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("bedroll_furry", {Ingredient("bedroll_straw", 1), Ingredient("manrabbit_tail", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO)
Recipe("tent", {Ingredient("silk", 6),Ingredient("twigs", 4),Ingredient("rope", 3)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, "tent_placer")
Recipe("grass_umbrella", {Ingredient("twigs", 4) ,Ingredient("cutgrass", 3), Ingredient("petals", 6)}, RECIPETABS.SURVIVAL, TECH.NONE)
Recipe("umbrella", {Ingredient("twigs", 6) ,Ingredient("pigskin", 1), Ingredient("silk",2 )}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("bugnet", {Ingredient("twigs", 4), Ingredient("silk", 2), Ingredient("rope", 1)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("fishingrod", {Ingredient("twigs", 2),Ingredient("silk", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("heatrock", {Ingredient("rocks", 10),Ingredient("pickaxe", 1),Ingredient("flint", 3)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO)

Recipe("bundlewrap", {Ingredient("waxpaper", 1), Ingredient("rope", 1)}, RECIPETABS.SURVIVAL, TECH.LOST)

--TOOLS
Recipe("axe", {Ingredient("twigs", 1),Ingredient("flint", 1)}, RECIPETABS.TOOLS, TECH.NONE)
Recipe("goldenaxe", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)
Recipe("pickaxe", {Ingredient("twigs", 2),Ingredient("flint", 2)}, RECIPETABS.TOOLS, TECH.NONE)
Recipe("goldenpickaxe", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)
Recipe("shovel", {Ingredient("twigs", 2),Ingredient("flint", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_ONE)
Recipe("goldenshovel", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)

Recipe("hammer", {Ingredient("twigs", 3),Ingredient("rocks", 3), Ingredient("rope", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_ONE)
Recipe("pitchfork", {Ingredient("twigs", 2),Ingredient("flint", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_ONE)
Recipe("razor", {Ingredient("twigs", 2), Ingredient("flint", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_ONE)
Recipe("featherpencil", {Ingredient("twigs", 1), Ingredient("charcoal", 1), Ingredient("feather_crow", 1)}, RECIPETABS.TOOLS,  TECH.SCIENCE_ONE)

Recipe("saddlehorn", {Ingredient("twigs", 2), Ingredient("boneshard", 2), Ingredient("feather_crow", 1)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)
Recipe("saddle_basic", {Ingredient("beefalowool", 4), Ingredient("pigskin", 4), Ingredient("goldnugget", 4)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)
Recipe("saddle_war", {Ingredient("rabbit", 4), Ingredient("steelwool", 4), Ingredient("log", 10)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO) 
Recipe("saddle_race", {Ingredient("livinglog", 2), Ingredient("silk", 4), Ingredient("butterflywings", 68)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)
Recipe("brush", {Ingredient("walrus_tusk", 1), Ingredient("steelwool", 1), Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO) 
Recipe("saltlick", {Ingredient("boards", 2), Ingredient("nitre", 4)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO, "saltlick_placer")



--SCIENCE
Recipe("researchlab", {Ingredient("goldnugget", 1),Ingredient("log", 4),Ingredient("rocks", 4)}, RECIPETABS.SCIENCE, TECH.NONE, "researchlab_placer")
Recipe("researchlab2", {Ingredient("boards", 4),Ingredient("cutstone", 2), Ingredient("goldnugget", 6)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_ONE, "researchlab2_placer")
Recipe("diviningrod", {Ingredient("twigs", 1), Ingredient("nightmarefuel", 4), Ingredient("gears", 1)}, RECIPETABS.SCIENCE, TECH.SCIENCE_TWO)
Recipe("winterometer", {Ingredient("boards", 2), Ingredient("goldnugget", 2)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_ONE, "winterometer_placer")
Recipe("rainometer", {Ingredient("boards", 2), Ingredient("goldnugget", 2), Ingredient("rope",2)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_ONE, "rainometer_placer")
Recipe("gunpowder", {Ingredient("rottenegg", 1), Ingredient("charcoal", 1), Ingredient("nitre", 1)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_TWO)
Recipe("lightning_rod", {Ingredient("goldnugget", 3), Ingredient("cutstone", 1)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_ONE, "lightning_rod_placer")

--MAGIC
Recipe("researchlab4", {Ingredient("rabbit", 4), Ingredient("boards", 4), Ingredient("tophat", 1)}, RECIPETABS.MAGIC, TECH.SCIENCE_ONE, "researchlab4_placer")
Recipe("researchlab3", {Ingredient("livinglog", 3), Ingredient("purplegem", 1), Ingredient("nightmarefuel", 7)}, RECIPETABS.MAGIC, TECH.MAGIC_TWO, "researchlab3_placer")
Recipe("resurrectionstatue", {Ingredient("boards", 4),Ingredient("cookedmeat", 4),Ingredient("beardhair", 4)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO, "resurrectionstatue_placer")
Recipe("panflute", {Ingredient("cutreeds", 5), Ingredient("mandrake", 1), Ingredient("rope", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO)
Recipe("onemanband", {Ingredient("goldnugget", 2),Ingredient("nightmarefuel", 4),Ingredient("pigskin", 2)}, RECIPETABS.MAGIC, TECH.MAGIC_TWO)
Recipe("nightlight", {Ingredient("goldnugget", 8), Ingredient("nightmarefuel", 2),Ingredient("redgem", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO, "nightlight_placer")
Recipe("armor_sanity", {Ingredient("nightmarefuel", 5),Ingredient("papyrus", 3)}, RECIPETABS.MAGIC,  TECH.MAGIC_THREE)
Recipe("nightsword", {Ingredient("nightmarefuel", 5),Ingredient("livinglog", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_THREE)
Recipe("batbat", {Ingredient("batwing", 5), Ingredient("livinglog", 2), Ingredient("purplegem", 1)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE)
Recipe("armorslurper", {Ingredient("slurper_pelt", 6),Ingredient("rope", 2),Ingredient("nightmarefuel", 2)}, RECIPETABS.MAGIC,  TECH.MAGIC_THREE)

Recipe("amulet", {Ingredient("goldnugget", 3), Ingredient("nightmarefuel", 2),Ingredient("redgem", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO)
Recipe("blueamulet", {Ingredient("goldnugget", 3), Ingredient("bluegem", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO)
Recipe("purpleamulet", {Ingredient("goldnugget", 6), Ingredient("nightmarefuel", 4),Ingredient("purplegem", 2)}, RECIPETABS.MAGIC,  TECH.MAGIC_THREE)
Recipe("firestaff", {Ingredient("nightmarefuel", 2), Ingredient("spear", 1), Ingredient("redgem", 1)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE)
Recipe("icestaff", {Ingredient("spear", 1),Ingredient("bluegem", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO)
Recipe("telestaff", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("purplegem", 2)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE)
Recipe("telebase", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("goldnugget", 8)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE, "telebase_placer")

--REFINE
Recipe("rope", {Ingredient("cutgrass", 3)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
Recipe("boards", {Ingredient("log", 4)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
Recipe("cutstone", {Ingredient("rocks", 3)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
Recipe("papyrus", {Ingredient("cutreeds", 4)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
Recipe("nightmarefuel", {Ingredient("petals_evil", 4)}, RECIPETABS.REFINE, TECH.MAGIC_TWO)
Recipe("purplegem", {Ingredient("redgem",1), Ingredient("bluegem", 1)}, RECIPETABS.REFINE, TECH.MAGIC_TWO)

Recipe("beeswax", {Ingredient("honeycomb", 1)}, RECIPETABS.REFINE, TECH.SCIENCE_ONE)
Recipe("waxpaper", {Ingredient("beeswax", 1), Ingredient("papyrus", 1)}, RECIPETABS.REFINE, TECH.SCIENCE_ONE)


--WAR
Recipe("spear", {Ingredient("twigs", 2),Ingredient("rope", 1),Ingredient("flint", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("hambat", {Ingredient("pigskin", 1), Ingredient("twigs", 2), Ingredient("meat", 2)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("armorgrass", {Ingredient("cutgrass", 10), Ingredient("twigs", 2)}, RECIPETABS.WAR,  TECH.NONE)
Recipe("armorwood", {Ingredient("log", 8),Ingredient("rope", 2)}, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("armormarble", {Ingredient("marble", 12),Ingredient("rope", 4)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("footballhat", {Ingredient("pigskin", 1), Ingredient("rope", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("blowdart_sleep", {Ingredient("cutreeds", 2),Ingredient("stinger", 1),Ingredient("feather_crow", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("blowdart_fire", {Ingredient("cutreeds", 2),Ingredient("charcoal", 1),Ingredient("feather_robin", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("blowdart_pipe", {Ingredient("cutreeds", 2),Ingredient("houndstooth", 1),Ingredient("feather_robin_winter", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("boomerang", {Ingredient("boards", 1),Ingredient("silk", 1),Ingredient("charcoal", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("beemine", {Ingredient("boards", 1),Ingredient("bee", 4),Ingredient("flint", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("trap_teeth", {Ingredient("log", 1),Ingredient("rope", 1),Ingredient("houndstooth", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)

--DRESSUP

Recipe("sewing_kit", {Ingredient("log", 1), Ingredient("silk", 8), Ingredient("houndstooth", 2)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO)

Recipe("flowerhat", {Ingredient("petals", 12)}, RECIPETABS.DRESS, TECH.NONE)
Recipe("earmuffshat", {Ingredient("rabbit", 2), Ingredient("twigs",1)}, RECIPETABS.DRESS, TECH.SCIENCE_ONE)
Recipe("strawhat", {Ingredient("cutgrass", 12)}, RECIPETABS.DRESS,  TECH.SCIENCE_ONE)
Recipe("beefalohat", {Ingredient("beefalowool", 8),Ingredient("horn", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_ONE)
Recipe("beehat", {Ingredient("silk", 8), Ingredient("rope", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("featherhat", {Ingredient("feather_crow", 3),Ingredient("feather_robin", 2), Ingredient("tentaclespots", 2)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)

Recipe("bushhat", {Ingredient("strawhat", 1),Ingredient("rope", 1),Ingredient("dug_berrybush", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("winterhat", {Ingredient("beefalowool", 4),Ingredient("silk", 4)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("tophat", {Ingredient("silk", 6)}, RECIPETABS.DRESS,  TECH.SCIENCE_ONE)
Recipe("cane", {Ingredient("goldnugget", 2), Ingredient("walrus_tusk", 1), Ingredient("twigs", 4)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("sweatervest", {Ingredient("houndstooth", 8),Ingredient("silk", 6)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("trunkvest_summer", {Ingredient("trunk_summer", 1),Ingredient("silk", 8)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("trunkvest_winter", {Ingredient("trunk_winter", 1),Ingredient("silk", 8), Ingredient("beefalowool", 2)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)

----GEMS----




----ANCIENT----
Recipe("thulecite", {Ingredient("thulecite_pieces", 6)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, nil, nil, true)

Recipe("wall_ruins_item", {Ingredient("thulecite", 1)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, nil, nil, true, 6)

Recipe("nightmare_timepiece", {Ingredient("thulecite", 2), Ingredient("nightmarefuel", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, nil, nil, true)

Recipe("orangeamulet", {Ingredient("thulecite", 2), Ingredient("nightmarefuel", 3),Ingredient("orangegem", 1)}, RECIPETABS.ANCIENT,  TECH.ANCIENT_FOUR, nil, nil, true)
Recipe("yellowamulet", {Ingredient("thulecite", 2), Ingredient("nightmarefuel", 3),Ingredient("yellowgem", 1)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, nil, nil, true)
Recipe("greenamulet", {Ingredient("thulecite", 2), Ingredient("nightmarefuel", 3),Ingredient("greengem", 1)}, RECIPETABS.ANCIENT,  TECH.ANCIENT_TWO, nil, nil, true)

Recipe("orangestaff", {Ingredient("nightmarefuel", 2), Ingredient("cane", 1), Ingredient("orangegem", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, nil, nil, true)
Recipe("yellowstaff", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("yellowgem", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, nil, nil, true)
Recipe("greenstaff", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("greengem", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, nil, nil, true)

Recipe("multitool_axe_pickaxe", {Ingredient("goldenaxe", 1),Ingredient("goldenpickaxe", 1), Ingredient("thulecite", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, nil, nil, true)

Recipe("ruinshat", {Ingredient("thulecite", 4), Ingredient("nightmarefuel", 4)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, nil, nil, true)
Recipe("armorruins", {Ingredient("thulecite", 6), Ingredient("nightmarefuel", 4)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, nil, nil, true)
Recipe("ruins_bat", {Ingredient("livinglog", 3), Ingredient("thulecite", 4), Ingredient("nightmarefuel", 4)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, nil, nil, true)
Recipe("eyeturret_item", {Ingredient("deerclops_eyeball", 1), Ingredient("minotaurhorn", 1), Ingredient("thulecite", 5)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, nil, nil, true)

if ACCOMPLISHMENTS_ENABLED then
	Recipe("accomplishment_shrine", {Ingredient("goldnugget", 10), Ingredient("cutstone", 1), Ingredient("gears", 6)}, RECIPETABS.SCIENCE, TECH.SCIENCE_TWO, "accomplishment_shrine_placer")
end
