
AddRoom("BGSavanna", {
					colour={r=.8,g=.8,b=.2,a=.50},
					value = GROUND.SAVANNA,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
										spiderden=0.001,
										grass=0.09,
										rabbithole=0.025,
										flower=0.003,
					                },
					            }
					})
	-- Very few Trees, very few rocks, rabbit holes, some beefalow, some grass
AddRoom("Plain", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.SAVANNA,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                    rock1 = 0.05,
					                    grass = .5,
					                    rabbithole=.25, 
					                    green_mushroom = .005,
					                },
					            }
					})
	-- Rabbit holes, Beefalow hurds if bigger
AddRoom("BarePlain", {					colour={r=.5,g=.5,b=.45,a=.50},
					value = GROUND.SAVANNA,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    grass = .8,
					                    rabbithole=.4,
--					                    beefalo=0.2
					                },
					            }
					})
