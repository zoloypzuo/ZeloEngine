
------------------------------------------------------------------------------------
-- Caves -----------------------------------------------------------------------
------------------------------------------------------------------------------------
AddRoom("FungusRoom", {
					colour={r=.36,g=.32,b=.38,a=.50},
					value = GROUND.FUNGUS,
					custom_tiles={
						GeneratorFunction = RUNCA.GeneratorFunction,
						data = {iterations=8, seed_mode=CA_SEED_MODE.SEED_RANDOM, num_random_points=2,
									translate={	{tile=GROUND.FUNGUSRED, items={"mushtree_medium"}, item_count=4},
												{tile=GROUND.FUNGUSGREEN,  items={"mushtree_small"},	item_count=4},
												{tile=GROUND.FUNGUS, items={"mushtree_tall"}, item_count=4},
--												{tile=GROUND.FUNGUSRED, items={"red_mushroom"}, item_count=7},
												{tile=GROUND.FUNGUSGREEN,  items={"green_mushroom"},	item_count=7},
												{tile=GROUND.FUNGUS, items={"blue_mushroom"}, item_count=7},
											},
						},
					},

					contents =  {
									countstaticlayouts={["MushroomRingMedium"] = function()  
																				if math.random(0,200) > 185 then 
																					return 1 
																				end
																				return 0 
																			   end},
					                distributepercent = .15,
					                distributeprefabs=
					                {
					                    mushtree_tall = 0.5,
										mushtree_medium = 0.5,
										mushtree_small = 0.5,
					                    spiderhole=.025,
										fireflies=0.01,
										flower_cave=0.05,
										rabbithouse=0.01,
					                    blue_mushroom = .01,
					                    cave_fern=0.2,
					                },
					            }
					})
AddRoom("CaveRoom", {
					colour={r=.25,g=.28,b=.25,a=.50},
					value = GROUND.CAVE,
					custom_tiles={
						GeneratorFunction = RUNCA.GeneratorFunction,
						data = {iterations=6, seed_mode=CA_SEED_MODE.SEED_WALLS, num_random_points=1,
									translate={	{tile=GROUND.DIRT, items={"red_mushroom"}, 		item_count=3},
												{tile=GROUND.UNDERROCK, items={"spiderhole"}, 	item_count=5},
												{tile=GROUND.WALL_ROCKY, items={"green_mushroom"}, 	item_count=0},
												{tile=GROUND.CAVE,  items={"slurtlehole","red_mushroom"},	item_count=6},
												{tile=GROUND.CAVE,items={"fireflies"}, 				item_count=6},
											   },
						},
					},
					contents =  {
					                distributepercent = .175,
					                distributeprefabs=
					                {
					                	stalagmite = .025,
					                	stalagmite_med = .025,
					                	stalagmite_low = .025,

					                    spiderhole= .025,
										fireflies=0.01,
					                    blue_mushroom = .005,
					                    green_mushroom = .003,
					                    red_mushroom = .004,
										cave_fern=0.08,
										pillar_cave = 0.003,

										fissure = 0.002,			                    
					                },
					            }
					})
AddRoom("SinkholeRoom", {
					colour={r=.15,g=.18,b=.15,a=.50},
					value = GROUND.SINKHOLE,
					custom_tiles={
						GeneratorFunction = RUNCA.GeneratorFunction,
						data = {iterations=3, seed_mode=CA_SEED_MODE.SEED_CENTROID, num_random_points=1,
									translate={	{tile=GROUND.GRASS, items={"grass"}, 		item_count=3},
												{tile=GROUND.GRASS, items={"sapling","berrybush"}, 	item_count=5},
												{tile=GROUND.FOREST, items={"evergreen_short"}, 	item_count=17},
												{tile=GROUND.FOREST,  items={"evergreen_normal"},	item_count=16},
												{tile=GROUND.FOREST,items={"evergreen_tall"}, 		item_count=16},
										},
								centroid= 	{tile=GROUND.FOREST, 	items={"cavelight"},			item_count=1},
						},
					},
					contents =  {
					                distributepercent = .175,
					                distributeprefabs =
					                {
										cavelight = 25,
										
										spiderden = .1,
										rabbithouse = 1,
					                    
										fireflies = 1,
										sapling = 15,
										evergreen = .25,
										berrybush = .5,
					                    blue_mushroom = .5,
					                    green_mushroom = .3,
					                    red_mushroom = .4,
										grass = .25,
										cave_fern = 20,										
					                },
									prefabdata = {
										spiderden = function() if math.random() < 0.1 then
																	return { growable={stage=3}}
																else
																	return { growable={stage=2}}
																end
															end,
									},
					            }
					})

		-- Rock Lobster Plains
AddRoom("RockLobsterPlains", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.CAVE_NOISE, 
					contents =  {
					                distributepercent = .15,
					                distributeprefabs=
					                {
					                	rocky = .25,
										goldnugget=.05,
										rocks=.1,
										flint=0.05,
					                	rock_flintless = 0.2,
					                	rock_flintless_med = 0.2,
					                	rock_flintless_low = 0.2,										
										pillar_cave = 0.02,
										fissure = 0.02,
					                }
					            }
					})
		-- Misty Sinkhole
AddRoom("MistyCavern", {
					colour={r=.15,g=.18,b=.15,a=.50},
					value = GROUND.MUD,
					custom_tiles={
						GeneratorFunction = RUNCA.GeneratorFunction,
						data = {iterations=5, seed_mode=CA_SEED_MODE.SEED_CENTROID, num_random_points=1,
									translate={	{tile=GROUND.GRASS, items={"grass"}, 		item_count=3},
												{tile=GROUND.GRASS, items={"berrybush"}, 	item_count=5},
												{tile=GROUND.FOREST, items={"evergreen_short"}, 	item_count=17},
												{tile=GROUND.FOREST,  items={"evergreen_normal"},	item_count=16},
												{tile=GROUND.FOREST,items={"evergreen_tall"}, 		item_count=16},
											   },
								centroid= 	{tile=GROUND.FOREST, 	items={"cavelight"},			item_count=1},
						},
					},
					contents =  {
					                distributepercent = .175,
					                distributeprefabs=
					                {
										grass=0.0025,
										sapling=0.15,
										evergreen=0.0025,
					                    blue_mushroom = .005,
					                    green_mushroom = .003,
										berrybush = 0.2,
					                    red_mushroom = .004,
					                	cave_fern=0.2,

					                },
					            }
					})
AddRoom("TentacleCave", {
					colour={r=.45,g=.75,b=.45,a=.50},
					value = GROUND.MARSH,
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                    tentacle_garden = 0.25,
					                    tentacle = .25,
					                    
					                    flower_cave= .8,
					                    flower_cave_double = .5,
					                    flower_cave_triple = .2,
					                },
					            }
					})

AddRoom("SunkenMarsh",{
					colour={r=.45,g=.75,b=.45,a=.50},
					value = GROUND.MARSH,
					contents = {
									distributepercent = .3,
									distributeprefabs =
									{
										cavelight = .2,
										tentacle = 1,
										reeds = 1,
										marsh_bush = .8,
										spiderden = .2,
									},
									prefabdata = {
										spiderden = function() if math.random() < 0.1 then
																	return { growable={stage=3}}
																else
																	return { growable={stage=2}}
																end
															end,
									},

								}
					})

AddRoom("RabitFungusRoom", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.FUNGUS, 
					--tags = {"ForceConnected"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                	flower_cave = 0.5,
					                	flower_cave_triple = 0.15,
					                	flower_cave_double = 0.1,
					                	carrot_planted = 1,

					                	green_mushroom = 0.5,
					                	blue_mushroom = 0.5,
					                	red_mushroom = 0.5,

					     --                mushtree_tall = 0.5,
										-- mushtree_medium = 0.5,
										-- mushtree_small = 0.5,

					                    rabbithouse = 0.51,
					                	cave_fern=0.5,
					                }
					            }
					})

AddRoom("GreenMush", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.FUNGUSGREEN, 
					--tags = {"ForceConnected"},
					contents =  {
					                distributepercent = .175,
					                distributeprefabs=
					                {
					                	slurtlehole = 0.05,
					                    worm = 0.05,

					                	cave_fern=0.5,
					                	flower_cave = 0.5,
					                	flower_cave_triple = 0.15,
					                	flower_cave_double = 0.1,

					                	green_mushroom = 0.9,					                	
										mushtree_small = 0.5,

					                }
					            }
					})

AddRoom("RedMush", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.FUNGUSRED, 
					--tags = {"ForceConnected"},
					contents =  {
					                distributepercent = .175,
					                distributeprefabs=
					                {
					                	slurtlehole = 0.05,
					                    worm = 0.05,

					                	cave_fern=0.5,
					                	flower_cave = 0.5,
					                	flower_cave_triple = 0.15,
					                	flower_cave_double = 0.1,

					                	red_mushroom = 0.9,					                	
										mushtree_medium = 0.5,

					                }
					            }
					})

AddRoom("BlueMush", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.FUNGUS, 
					--tags = {"ForceConnected"},
					contents =  {
					                distributepercent = .175,
					                distributeprefabs=
					                {
					                	slurtlehole = 0.05,
					                    worm = 0.05,
					                	
					                	cave_fern=0.5,
					                	flower_cave = 0.5,
					                	flower_cave_triple = 0.15,
					                	flower_cave_double = 0.1,

					                	blue_mushroom = 0.9,					                	
										mushtree_tall = 0.5,

					                }
					            }
					})

AddRoom("NoisyFungus", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.FUNGUS_NOISE, 
					--tags = {"ForceConnected"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {

					                    flower_cave = 1,
					                    flower_cave_double = .6,
					                    flower_cave_triple = .4,

					                    mushtree_tall = 0.5,
										mushtree_medium = 0.5,
										mushtree_small = 0.5,
					                	
					                	cave_fern=0.02,
					                    goldnugget=.05,

					                    slurtlehole = 0.1,
					                    worm = 0.1,

					                }
					            }
					})
AddRoom("NoisyCave", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.CAVE_NOISE,
					contents =  {
					                distributepercent = .15,
					                distributeprefabs=
					                {
					                	stalagmite = 0.15,
					                	stalagmite_med = 0.15,
					                	stalagmite_low = 0.15,
					                
										--stalagmite_tall=0.5,
					                	--stalagmite_gold = 0.05,
					                    spiderhole= .125,
					                    --slurtlehole = 0.01,
					                    pillar_cave = 0.08,
					                    fissure = 0.05,
					                }
					            }
					})
AddRoom("BatCaveRoom", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.CAVE, 
					contents =  {
					                distributepercent = .15,
					                distributeprefabs=
					                {
					                    bat = 0.25,
					                    guano = 0.27,
										goldnugget=.05,
										flint=0.05,
										stalagmite_tall=0.4,
										stalagmite_tall_med=0.4,
										stalagmite_tall_low=0.4,
										pillar_cave = 0.08,
										fissure = 0.05,
					                }
					            }
					})
		-- Bat Cave antichamber (warn of impending bats)
AddRoom("BatCaveRoomAntichamber", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.CAVE, 
					contents =  {
					                distributepercent = .3,
					                distributeprefabs=
					                {
					                    guano = 1.0,
										stalagmite_tall=0.4,
										stalagmite_tall_med=0.4,
										stalagmite_tall_low=0.4,

										pillar_cave = 0.03,
										fissure = 0.03,
					                }
					            }
					})
AddRoom("PitRoom", {
					colour={r=.25,g=.28,b=.25,a=.50},
					value = GROUND.IMPASSABLE,
					internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
					contents = {},
				})
AddRoom("PitEdgeCave", {
					colour={r=.25,g=.28,b=.25,a=.50},
					value = GROUND.IMPASSABLE,
					internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeEdgeRight,
					custom_tiles={
						GeneratorFunction = RUNCA.GeneratorFunction,
						data = {iterations=2, seed_mode=CA_SEED_MODE.SEED_WALLS, num_random_points=1, 
								translate={	{tile=GROUND.IMPASSABLE, items={"stalagmite"}, 	item_count=0},
											{tile=GROUND.IMPASSABLE, items={"stalagmite"}, 	item_count=0},
											{tile=GROUND.CAVE, items={"stalagmite"}, 	item_count=0},
											{tile=GROUND.CAVE,  items={"stalagmite"},	item_count=0},
											{tile=GROUND.CAVE,  items={"stalagmite"},	item_count=0},
										},
							},
						},
					})
AddRoom("PitCave", {--
					colour={r=.25,g=.28,b=.25,a=.50},
					value = GROUND.CAVE_NOISE,
					tags = {"ForceConnected"},
					internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
					custom_tiles={
						GeneratorFunction = RUNCA.GeneratorFunction,
						data = {iterations=3, seed_mode=CA_SEED_MODE.SEED_CENTROID, num_random_points=1, 
								translate={	{tile=GROUND.IMPASSABLE, items={"stalagmite"}, 	item_count=0},
											{tile=GROUND.IMPASSABLE, items={"stalagmite"}, 	item_count=0},
											{tile=GROUND.IMPASSABLE, items={"stalagmite"}, 	item_count=0},
											{tile=GROUND.WALL_CAVE,  items={"stalagmite"},	item_count=0},
											{tile=GROUND.WALL_CAVE,  items={"stalagmite"},	item_count=0},
										},
							},
						},
					contents =  {
					                distributepercent = .15,
					                distributeprefabs=
					                {
										stalagmite_tall_med= 1,
										stalagmite_tall_low= 1,
										pillar_cave = 0.2,
										pillar_stalactite = 0.2,
					                }
					            }

					})
AddRoom("MistyPitRoom", {
					colour={r=.25,g=.28,b=.25,a=.50},
					value = GROUND.IMPASSABLE,
				})
AddRoom("WaterFilledAbyss", {
					colour={r=.25,g=.28,b=.25,a=.50},
					value = GROUND.IMPASSABLE,
				})


AddRoom("Stairs", { -- This room is used to tag for the next level of caves - it will be removed later
					colour={r=0,g=0,b=0,a=0.9},
					value = GROUND.CAVE_NOISE,
					contents =  {
									countprefabs = {
										cave_stairs = 1,
									},
									distributepercent=0.3,
					                distributeprefabs= {
					                    bat = 0.15,
					                    spiderhole= 0.15,

					                	stalagmite = 0.04,
										stalagmite_med = .04,
										stalagmite_low = .04,


										stalagmite_tall=0.04,
										stalagmite_tall_med=0.04,
										stalagmite_tall_low=0.04,
										
										pillar_cave = 0.01,
										pillar_stalactite = 0.01,
										fissure = 0.01,
					                }
					            }
					})
AddRoom("EmptyCave", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.CAVE, 
					contents =  {
					            }
					})

AddRoom("CaveBase", {
					colour={r=0,g=0,b=0,a=0.9},
					value = GROUND.CAVE,
					contents =  {
									countstaticlayouts={
										["CaveBase"]=1,
									},
					                distributepercent = .15,
					                distributeprefabs=
					                {
										fireflies = 0.3,
					                    
					                    bat = 0.15,
					                    guano = 0.05,

					                    stalagmite_tall_low = 1,
					                    stalagmite_tall_med = 0.6,
					                    stalagmite_tall = 0.2,

					                    pillar_cave = .05,
					                    pillar_stalactite = .05,
					                },

					            }
					})

AddRoom("SinkBase", {
					colour={r=0,g=0,b=0,a=0.9},
					value = GROUND.SINKHOLE,
					contents =  {
									countstaticlayouts={
										["SinkBase"]=1,
									},
					                distributepercent = .15,
					                distributeprefabs=
					                {

										grass = 1,
										sapling = .8,
										evergreen = .3,
					                	cave_fern = .75,
										berrybush = .2,
										fireflies = .1,										
										cavelight = 0.01,

					                },
					            }
					})

AddRoom("MushBase", {
					colour={r=0,g=0,b=0,a=0.9},
					value = GROUND.FUNGUS,
					contents =  {
									countstaticlayouts={
										["MushBase"]=1,
									},
					                distributepercent = .15,
					                distributeprefabs=
					                {
					                    mushtree_tall = 1,
										mushtree_medium = 1,
										mushtree_small = 1,

					                	cave_fern = .5,
										fireflies = 0.1,
										tentacle = 0.8,

										flower_cave = 0.1,
										flower_cave_double = 0.05,
										flower_cave_triple = 0.01,
					                },
					            }
					})

AddRoom("RabbitTown", {
					colour={r=0,g=0,b=0,a=0.9},
					value = GROUND.FUNGUS,
					contents =  {
									countstaticlayouts={
										["RabbitTown"]=1,
									},
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                	mushtree_tall = .5,
					                	mushtree_medium = .5,
										mushtree_small = .5,
					                	flower_cave=0.75,
					                	carrot_planted = 1,
					                	cave_fern=0.75,
					                    rabbithouse = 0.51,
					                }
					            }
					})
AddRoom("RabbitCity", {
					colour={r=0.9,g=.9,b=.2,a=.50},
					value = GROUND.UNDERROCK,
					tags = {"Town"},
					contents =  {
									countstaticlayouts=
									{
										["RabbitCity"]=function () return 1 + math.random(2) end,
										["TorchRabbitking"]=function () return 1 + math.random(2) end,
									},
									countprefabs={
										mermhead = function () return math.random(3) end,
									},
					            }
					})

