
AddRoom("BGNoisyFungus", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.FUNGUS_NOISE, 
					--tags = {"ForceConnected"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {

										flower_cave = .5,
										flower_cave_double = .4,
										flower_cave_triple = .33,
										
	                    				blue_mushroom = .33,
					                    green_mushroom = .33,
					                    red_mushroom = .33,

					                    mushtree_tall = 1,
										mushtree_medium = 1,
										mushtree_small = 1,

										cave_fern = .1,
										fireflies = .1,
					                    slurtlehole = .1,
					                    carrot = .1,
					                    tentacle = .1,
					                }
					            }
					})
AddRoom("BGFungusRoom", {
					colour={r=.36,g=.32,b=.38,a=.50},
					value = GROUND.FUNGUS,
					--tags = {"ForceConnected"},
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
										fireflies = .1,
										tentacle = .1,
					                    slurtlehole = .33,		
										cave_fern = .1,

										flower_cave = .5,
										flower_cave_double = .4,
										flower_cave_triple = .33,
										
					                    -- blue_mushroom = .33,
					                    -- green_mushroom = .33,
					                    -- red_mushroom = .33,
					                    
					     --                mushtree_tall = .66,
   							-- 			mushtree_medium = .66,
										-- mushtree_small = .66,
					                },
					            }
					})
