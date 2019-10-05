
------------------------------------------------------------------------------------
-- CHESS CORRUPTION ----------------------------------------------------------------
------------------------------------------------------------------------------------
AddRoom("ChessArea", {
					colour={r=0.5,g=0.7,b=0.5,a=0.3},
					value = GROUND.CHECKER,
					contents =  {
									countstaticlayouts={
										["Maxwell1"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell2"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell3"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell4"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell6"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell7"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["ChessSpot1"] = function() return math.random(0,3) end,
										["ChessSpot2"] = function() return math.random(0,3) end,
										["ChessSpot3"] = function() return math.random(0,3) end,
									},
					                distributepercent = 0.25,
									distributeprefabs = {
										marbletree = 1,
										flower_evil = 1,
										marblepillar = 0.1,
										knight = 0.1,
										bishop = 0.05,
										rook = 0.01,
					                }
					            }
					})
AddRoom("MarbleForest", {
					colour={r=0.5,g=0.7,b=0.5,a=0.3},
					value = GROUND.CHECKER,
					contents =  {
									countstaticlayouts={
										["Maxwell1"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell2"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell3"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell4"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell6"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell7"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["ChessSpot1"] = function() return math.random(0,3) end,
										["ChessSpot2"] = function() return math.random(0,3) end,
										["ChessSpot3"] = function() return math.random(0,3) end,
									},
					                distributepercent = 0.75,
									distributeprefabs = {
										marbletree = 5,
										flower_evil = 1,
										marblepillar = 0.1,
										knight = 0.1,
										bishop = 0.15,
										rook = 0.01,
					                }
					            }
					})

AddRoom("ChessMarsh", {
					colour={r=0.5,g=0.7,b=0.5,a=0.3},
					value = GROUND.MARSH,
					contents =  {
									countstaticlayouts={
										["Maxwell1"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell2"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell3"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["ChessSpot1"] = function() return math.random(0,3) end,
										["ChessSpot2"] = function() return math.random(0,3) end,
										["ChessSpot3"] = function() return math.random(0,3) end,
									},
					                distributepercent = 0.2,
									distributeprefabs = {
										marsh_tree=6,
										marsh_bush=4,
										pond_mos=0.3,
										tentacle=1,
					                }
					            }
					})
AddRoom("ChessForest", {
					colour={r=0.2,g=0.0,b=0.2,a=0.3},
					value = GROUND.FOREST,
					contents =  {
									countstaticlayouts = {
										["Maxwell2"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell3"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell5"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["ChessSpot1"] = function() return math.random(0,3) end,
										["ChessSpot2"] = function() return math.random(0,3) end,
										["ChessSpot3"] = function() return math.random(0,3) end,
									},
					                distributepercent = .3,
					                distributeprefabs=
					                {
										gravestone=0.01,
										pighouse=0.015,
										spiderden=0.02,
										grass=0.0025,
										sapling=0.15,
										berrybush=0.005,
										rock1=0.004,
										rock2=0.004,
										evergreen_sparse=1.5,
										flower=0.05,
										pond=.001,
					                    blue_mushroom = .02,
					                    green_mushroom = .02,
					                    red_mushroom = .02,
					                },
					            }
					})
AddRoom("ChessBarrens", {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = GROUND.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
									countstaticlayouts = {
										["Maxwell1"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell3"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["Maxwell5"] = function() return math.random(0,3) < 1 and 1 or 0 end,
										["ChessSpot1"] = function() return math.random(0,3) end,
										["ChessSpot2"] = function() return math.random(0,3) end,
										["ChessSpot3"] = function() return math.random(0,3) end,
									},
					                distributepercent = .1,
					                distributeprefabs=
					                {
										flint=0.5,
										rock1=1,
										rock2=1,
										tallbirdnest=0.008,
					                },
					            }
					})

