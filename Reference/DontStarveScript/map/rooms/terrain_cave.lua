
AddRoom("BGNoisyCave", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.CAVE_NOISE, 
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					              	{
										stalagmite = 0.5,
										stalagmite_med = 0.5,
										stalagmite_low = 0.5,

					                }
					            }
					})
AddRoom("BGCaveRoom", {
					colour={r=.25,g=.28,b=.25,a=.50},
					value = GROUND.CAVE_NOISE,
					--tags = {"ForceConnected"},
					contents =  {
					                distributepercent = .175,
					                distributeprefabs=
					                {
										--spiderhole=0.001,
										flint = .5,
										rocks = .5,
										--fireflies = 0.1,
										
										-- stalagmite=0.03,
										stalagmite_tall = 0.2,
										stalagmite_tall_med = .8,
										stalagmite_tall_low = 1,

										--stalagmite_gold=0.02,
										pillar_cave = .15,	
										pillar_stalactite = .15,
					                    --blue_mushroom = .5,
					                    --slurtlehole = 0.001,
					                },
					            }
					})