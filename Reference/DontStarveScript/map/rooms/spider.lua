
--------------------------------------------------------------------------------
-- Spider 
--------------------------------------------------------------------------------
AddRoom("SpiderCity", {
					colour={r=.30,g=.20,b=.50,a=.50},
					value = GROUND.FOREST,
					contents =  {
					                countprefabs= {
                                        goldnugget = function() return 3 + math.random(3) end,
					                },
									distributepercent = 0.3,
					                distributeprefabs = {
					                    evergreen_sparse = 3,
					                    spiderden = 0.3,
					                },
									prefabdata = {
										spiderden = function() if math.random() < 0.2 then
																	return { growable={stage=3}}
																else
																	return { growable={stage=2}}
																end
															end,
									},
					            }
					})

AddRoom("SpiderVillage", {
					colour={r=.30,g=.20,b=.50,a=.50},
					value = GROUND.ROCKY,
					contents =  {
					                countprefabs= {
                                        goldnugget = function() return 3 + math.random(3) end,
					                    spiderden = function () return 5 + math.random(3) end
					                },
									distributepercent = 0.1,
									distributeprefabs = {
					                    rock1 = 1,
					                    rock2 = 1,
					                    rocks = 1,
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
AddRoom("SpiderVillageSwamp", {
					colour={r=.30,g=.20,b=.50,a=.50},
					value = GROUND.MARSH,
					contents =  {
					                countprefabs= {
                                        goldnugget = function() return 3 + math.random(3) end,
					                    spiderden = function () return 5 + math.random(3) end
					                },
									distributepercent = 0.1,
									distributeprefabs = {
					                    marsh_tree = 1,
					                    marsh_bush = 1,
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
