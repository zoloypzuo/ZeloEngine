

------------------------------------------------------------------------------------
-- TEST ROOMS -----------------------------------------------------------------------
------------------------------------------------------------------------------------
AddRoom("MaxPuzzle1", {
					colour={r=0.3,g=.8,b=.5,a=.50},
					value = GROUND.MARSH,
					contents =  {
									countstaticlayouts={
										["MaxPuzzle1"]=1,
									},
					                distributepercent = 0.2,
									distributeprefabs = {
										spider_nest=0.02,
										spider=0.5,
										spider_warrior=0.2,
										--TODO: Right now the warrior wanders off from his starting location; not good enough.
										marsh_tree=6,
										marsh_bush=4,
					                }
					            }
				   })
AddRoom("MaxPuzzle2", {
					colour={r=0.3,g=.8,b=.5,a=.50},
					value = GROUND.MARSH,
					contents =  {
									countstaticlayouts={
										["MaxPuzzle2"]=1,
									},
					                distributepercent = 0.5,
									distributeprefabs = {
										trap_teeth_maxwell = 20,
										spider_nest=0.02,
										--TODO: Right now the warrior wanders off from his starting location; not good enough.
										marsh_tree=6,
										marsh_bush=4,
					                }
					            }
					})
AddRoom("MaxPuzzle3", {
					colour={r=0.3,g=.8,b=.5,a=.50},
					value = GROUND.MARSH,
					contents =  {
									countstaticlayouts={
										["MaxPuzzle3"]=1,
									},
					                distributepercent = 0.3,
									distributeprefabs = {
										beemine_maxwell = 12,
										spider_nest=0.02,
										--TODO: Right now the warrior wanders off from his starting location; not good enough.
										marsh_tree=6,
										marsh_bush=4,
					                }
					            }
					})
AddRoom("SymmetryRoom", {
					colour={r=0.3,g=.8,b=.5,a=.50},
					value = GROUND.GRASS,
					contents =  {
									countstaticlayouts={
										["SymmetryTest"]=2,
										["SymmetryTest2"]=2,
									},
					            }
					})
AddRoom("TEST_ROOM", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.FUNGUS, 
					contents =  {
									countstaticlayouts={
										["test"]=1,
									},
					                countprefabs= {
					                    flower = function () return 4 + math.random(4) end,
					                    adventure_portal = 1,
					                },
									distributepercent=0.01,
									distributeprefabs={
										grass=1,
									},
					            }
					})
AddRoom("MaxHome", {
					colour={r=0.3,g=.8,b=.5,a=.50},
					value = GROUND.IMPASSABLE,
					contents =  {
									countstaticlayouts={
										["MaxwellHome"]=1,
									},
					            }
					})
AddRoom("TestMixedForest", {
					colour={r=0.3,g=.8,b=.5,a=.50},
					value = GROUND.FOREST,
					contents =  {
									distributepercent=0.8,
									distributeprefabs={
										evergreen=1,
										evergreen_sparse=1,
									}
					            }
					})
AddRoom("TestSparseForest", {
					colour={r=0.3,g=.8,b=.5,a=.50},
					value = GROUND.FOREST,
					contents =  {
									distributepercent=0.8,
									distributeprefabs={
										evergreen_sparse=1,
									}
					            }
					})
AddRoom("TestPineForest", {
					colour={r=0.3,g=.8,b=.5,a=.50},
					value = GROUND.FOREST,
					contents =  {
									distributepercent=0.8,
									distributeprefabs={
										evergreen=1,
									}
					            }
					})

