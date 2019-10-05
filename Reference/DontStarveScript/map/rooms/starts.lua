
AddRoom("BurntForestStart", {
					colour={r=.010,g=.010,b=.010,a=.50},
					value = GROUND.FOREST,
					contents =  {
									countprefabs= {
										firepit=1,
									},	
									distributepercent = 0.6,
									distributeprefabs= {
										evergreen = 3 + math.random(4),
										charcoal = 0.2,
									},
									prefabdata={
										evergreen = {burnt=true},
									}
								}
					})
AddRoom("SafeSwamp", {
					colour={r=0.2,g=0.0,b=0.2,a=0.3},
					value = GROUND.MARSH,
					contents =  {
					                countprefabs= {
					                    mandrake = math.random(1,2),
					                },
					                distributepercent = 0.2,
									distributeprefabs = {
										marsh_tree=1,
										marsh_bush=1,
										--TODO: Traps need to be not "owned" by player
					                }
					            }
					})

