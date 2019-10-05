
AddRoom("BGMarsh", {
					colour={r=.6,g=.2,b=.8,a=.50},
					value = GROUND.MARSH,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
									countstaticlayouts={["MushroomRingMedium"] = function()  
																				if math.random(0,1000) > 985 then 
																					return 1 
																				end
																				return 0 
																			   end},
					                distributepercent = .25,
					                distributeprefabs=
					                {
										spiderden=0.003,
										sapling=0.0001,
										pond_mos=0.005,
										reeds=0.005,
										tentacle=0.095,
										marsh_bush=0.05,
										marsh_tree=0.1,
					                    blue_mushroom = .01,
					                    mermhouse=0.004,
					                },
					            }
					})
	-- No trees, no rocks, very rare spiderden
AddRoom("Marsh", {
					colour={r=.45,g=.75,b=.45,a=.50},
					value = GROUND.MARSH,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
									countstaticlayouts={["MushroomRingMedium"]=function()  
																				if math.random(0,1000) > 985 then 
																					return 1 
																				end
																				return 0 
																			   end},
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    evergreen = 1.0,
					                    tentacle = 3,
					                    pond_mos = 1,
					                    reeds =  4,--function () return 3 + math.random(4) end,
					                    mandrake=0.0001,
					                    spiderden=.01,
					                    blue_mushroom = 0.01,
					                    green_mushroom = 2.02,
					                },
					            }
					})
AddRoom("SpiderMarsh", {
					colour={r=.45,g=.75,b=.45,a=.50},
					value = GROUND.MARSH,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    evergreen = 1.0,
					                    tentacle = 2,
					                    pond_mos = 0.1,
					                    blue_mushroom = 0.1,
					                    reeds =  4,--function () return 3 + math.random(4) end,
					                    mandrake=0.0001,
					                    spiderden=3.15,
					                },
									prefabdata = {
										spiderden = function() if math.random() < 0.2 then
																	return { growable={stage=2}}
																else
																	return { growable={stage=1}}
																end
															end,
									},
					            }
					})
AddRoom("SlightlyMermySwamp", {
					colour={r=0.5,g=.18,b=.35,a=.50},
					value = GROUND.MARSH,
					contents =  {

									distributepercent = .1,
									distributeprefabs= {
					                    --merm = 0.1,
					                    mermhouse = 0.1,
										pighead = 0.01,
					                    tentacle =  1,
					                    marsh_tree =  2,
					                    marsh_bush= 1.5,
									},
					            }
					 })
