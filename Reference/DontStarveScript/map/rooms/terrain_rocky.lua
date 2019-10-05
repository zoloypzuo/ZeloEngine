AddRoom("BGChessRocky", {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = GROUND.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
									countstaticlayouts = {
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

AddRoom("BGRocky", {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = GROUND.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
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
	-- No trees, lots of rocks, rare tallbird nest, very rare spiderden
AddRoom("Rocky", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.DIRT,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    rock1 = 2,
					                    rock2 = 2,
					                    tallbirdnest=.1,
					                    spiderden=.01,
					                    blue_mushroom = .002,
					                },
					            }
					})
