
AddRoom("BGGrassBurnt", {
					colour={r=.5,g=.8,b=.5,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .275,
					                distributeprefabs=
					                {
										rock1=0.01,
										rock2=0.01,
										spiderden=0.001,
										beehive=0.003,
										flower=0.112,
										grass=0.2,
										rabbithole=0.02,
										flint=0.05,
										sapling=0.2,
										evergreen=0.3,
					                },
									prefabdata={
										evergreen = {burnt=true},
									}
					            }
					})
AddRoom("BGGrass", {
					colour={r=.5,g=.8,b=.5,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .275,
					                distributeprefabs=
					                {
										spiderden=0.001,
										beehive=0.003,
										flower=0.112,
										grass=0.2,
										rabbithole=0.02,
										carrot_planted=0.05,
										flint=0.05,
										berrybush=0.05,
										sapling=0.2,
										evergreen=0.3,
										pond=.001,
					                    blue_mushroom = .005,
					                    green_mushroom = .003,
					                    red_mushroom = .004,
					                },
					            }
					})
AddRoom("FlowerPatch", {
					colour={r=.5, g=1,b=.8,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
                                        fireflies = 1,
					                    flower=2,
					                    beehive=1,
					                },
					            }
					})
AddRoom("EvilFlowerPatch", {
					colour={r=.8,g=1,b=.4,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
                                        fireflies = 1,
					                    flower_evil=2,
					                    wasphive=0.5,
					                },
					            }
					})
