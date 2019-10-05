
AddRoom("BGSinkholeRoom", {
					colour={r=.15,g=.18,b=.15,a=.50},
					value = GROUND.SINKHOLE,
					--tags = {"ForceConnected"},
					contents =  {
					                distributepercent = .175,
					                distributeprefabs=
					                {
										grass=0.0025,
										sapling=0.15,
										evergreen=0.0025,
										berrybush=0.005,
										spiderden=0.01,
										fireflies=0.01,
					                    blue_mushroom = .005,
					                    green_mushroom = .003,
					                    red_mushroom = .004,
					                    mandrake=0.001,
					                    slurtlehole = 0.001,
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
