require ("map/room_functions")

------------------------------------------------------------------------------------
-- BLOCKERS ------------------------------------------------------------------------
------------------------------------------------------------------------------------
AddRoom("Deerclopsfield", {
					colour={r=0.2,g=0.0,b=0.2,a=0.3},
					value = GROUND.FOREST,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
					                countprefabs= {
										deerclops = 1,
					                },
					                distributepercent = .6,
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
										evergreen=1.5,
										flower=0.05,
										pond=.001,
					                    blue_mushroom = .02,
					                    green_mushroom = .02,
					                    red_mushroom = .02,
					                },
					            }
					})
AddRoom("Walrusfield", {
					colour={r=0.2,g=0.0,b=0.2,a=0.3},
					value = GROUND.GRASS,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
					                countprefabs= {
										walrus_camp = 6,
					                },
					                distributepercent = .275,
					                distributeprefabs=
					                {
										flower=0.112,
										grass=0.2,
										carrot_planted=0.05,
										flint=0.05,
										sapling=0.2,
										evergreen=0.3,
										pond=.005,
					                },
					            }
					})
AddRoom("Chessfield", {
					colour={r=0.2,g=0.0,b=0.2,a=0.3},
					value = GROUND.CHECKER,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
									countstaticlayouts = {
										["ChessSpot1"] = function() return math.random(2,3) end,
										["ChessSpot2"] = function() return math.random(2,3) end,
									},
					                distributepercent = 0.4,
									distributeprefabs = {
					                    marblepillar=1,
					                    knight=0.8,
										bishop=0.5,
					                    rook  =0.05,
										marbletree=2,
										flower_evil=2,
					                }
					            }
					})
AddRoom("ChessfieldA", MakeSetpieceBlockerRoom("ChessBlocker"))
AddRoom("ChessfieldB", MakeSetpieceBlockerRoom("ChessBlockerB"))
AddRoom("ChessfieldC", MakeSetpieceBlockerRoom("ChessBlockerC"))
AddRoom("Tallbirdfield", {
					colour={r=0.2,g=0.0,b=0.2,a=0.3},
					value = GROUND.ROCKY,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
									countprefabs={
										tallbirdnest=1,
									},
					                distributepercent = 0.1,
									distributeprefabs = {
					                    rock1=1,
					                    rock2=1,
										tallbirdnest=1,
					                }
					            }
					})
AddRoom("TallbirdfieldSmallA", MakeSetpieceBlockerRoom("TallbirdBlockerSmall"))
AddRoom("TallbirdfieldA", MakeSetpieceBlockerRoom("TallbirdBlocker"))
AddRoom("TallbirdfieldB", MakeSetpieceBlockerRoom("TallbirdBlockerB"))
AddRoom("Mermfield", {
					colour={r=0.2,g=0.0,b=0.2,a=0.3},
					value = GROUND.MARSH,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
									countprefabs={
										pighead=function() return math.random(6) end,
									},
					                distributepercent = 0.3,
									distributeprefabs = {
					                    mermhouse = 1,
					                    reeds =  2,
					                    pond_mos=0.5,
										marsh_bush = 2,
					                }
					            }
					})
AddRoom("Moundfield", {
					colour={r=0.2,g=0.0,b=0.2,a=0.3},
					value = GROUND.DIRT,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
									countprefabs = {
										houndmound=1, -- sometimes zero spawn, so lets have at least one
									},
					                distributepercent = 0.2,
									distributeprefabs = {
										houndmound=0.4,
										houndbone=3,
										marsh_bush=1,
										marsh_tree=0.3,
										rock1=0.5,
										rock2=0.5,
										rocks=0.05,
					                }
					            }
					})
AddRoom("Minefield", {
			-- DO NOT USE -- it destroys performance, so many mosquitos!!
					colour={r=0.2,g=0.0,b=0.2,a=0.3},
					value = GROUND.MARSH,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
					                distributepercent = 0.5,
									distributeprefabs = {
										marsh_tree=1,
										beemine_maxwell=4,
					                }
					            }
					})
AddRoom("Trapfield", {
					colour={r=0.0,g=0.4,b=0.2,a=0.3},
					value = GROUND.DIRT,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
									countprefabs = {
										homesign = 2,
									},
					                distributepercent = .4,
									distributeprefabs = {
										houndbone=1,
										trap_teeth_maxwell=1,
					                }
					            }
					})
AddRoom("TrappedForest", {
					colour={r=0.0,g=0.4,b=0.2,a=0.3},
					value = GROUND.FOREST,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
--									countstaticlayouts={
--										["FisherPig"]=1--function() return math.random(0,1) end,
--										},
					                distributepercent = 1.0,
									distributeprefabs = {
										evergreen_sparse=1,
										trap_teeth_maxwell=1,
					                }
					            }
					})
AddRoom("SpiderfieldEasy", {
					colour={r=0.0,g=0.4,b=0.2,a=0.3},
					value = GROUND.FOREST,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
--									countstaticlayouts={
--										["FisherPig"]=1--function() return math.random(0,1) end,
--										},
					                distributepercent = .4,
									distributeprefabs = {
										evergreen_sparse=1,
										spiderden=0.1,
					                },
									prefabdata={
										spiderden={growable={stage=2}},
									},
					            }
					})
AddRoom("Spiderfield", {
					colour={r=0.0,g=0.4,b=0.2,a=0.3},
					value = GROUND.FOREST,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
--									countstaticlayouts={
--										["FisherPig"]=1--function() return math.random(0,1) end,
--										},
					                distributepercent = .4,
									distributeprefabs = {
										evergreen_sparse=1,
										spiderden=0.15,
					                },
									prefabdata={
										spiderden={growable={stage=3}},
									},
					            }
					})
AddRoom("SpiderfieldEasyA", MakeSetpieceBlockerRoom("SpiderBlockerEasy"))
AddRoom("SpiderfieldEasyB", MakeSetpieceBlockerRoom("SpiderBlockerEasyB"))
AddRoom("SpiderfieldA", MakeSetpieceBlockerRoom("SpiderBlocker"))
AddRoom("SpiderfieldB", MakeSetpieceBlockerRoom("SpiderBlockerB"))
AddRoom("SpiderfieldC", MakeSetpieceBlockerRoom("SpiderBlockerC"))
AddRoom("DenseForest", MakeSetpieceBlockerRoom("TreeBlocker")) -- DO NOT USE! The trees right now don't block...
AddRoom("DenseRocks", MakeSetpieceBlockerRoom("RockBlocker"))
AddRoom("InsanityWall", MakeSetpieceBlockerRoom("InsanityBlocker"))
AddRoom("SanityWall", MakeSetpieceBlockerRoom("SanityBlocker"))
AddRoom("PigGuardpostEasy", MakeSetpieceBlockerRoom("PigGuardsEasy"))
AddRoom("PigGuardpost", MakeSetpieceBlockerRoom("PigGuards"))
AddRoom("PigGuardpostB", MakeSetpieceBlockerRoom("PigGuardsB"))
AddRoom("SpiderCon", {
					colour={r=0.5,g=0.7,b=0.5,a=0.3},
					value = GROUND.MARSH,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
									countstaticlayouts={["StoneHenge"]=function() return math.random(0,1) end},
					                distributepercent = 0.2,
									distributeprefabs = {
										spider=0.5,
										spider_warrior=0.2,
										--TODO: Right now the warrior wanders off from his starting location; not good enough.
										marsh_tree=6,
										marsh_bush=4,
					                }
					            }
					})
AddRoom("Waspnests", {
					colour={r=0.9,g=0.1,b=0.1,a=0.3},
					value = GROUND.GRASS,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
					                distributepercent = 0.5,
									distributeprefabs = {
										flower=6,
										beehive=1,
										grass=2,
										wasphive=1,
					                }
					            }
					})

AddRoom("Tentacleland", {
					colour={r=.45,g=.75,b=.45,a=.50},
					value = GROUND.MARSH,
					tags = {"ForceConnected", "RoadPoison"},
					contents =  {
					                distributepercent = .3,
					                distributeprefabs=
					                {
					                    tentacle = 14,
					                    pond_mos = 0.1,
					                    reeds =  0.2,--function () return 3 + math.random(4) end,
					                    mandrake=0.0001,
										marsh_bush=1.5,
										marsh_tree=1.1,
					                },
					            }
					})
AddRoom("TentaclelandA", MakeSetpieceBlockerRoom("TentacleBlocker"))
AddRoom("TentaclelandSmallA", MakeSetpieceBlockerRoom("TentacleBlockerSmall"))

AddRoom("SanityWormholeBlocker", {
					colour={r=.45,g=.75,b=.45,a=.50},
					type = "blank",
					tags = {"OneshotWormhole", "ForceDisconnected"},
					value = GROUND.IMPASSABLE,
					contents = {},
			})
AddRoom("ForceDisconnectedRoom", {
					colour={r=.45,g=.75,b=.45,a=.50},
					type = "blank",
					tags = {"ForceDisconnected"},
					value = GROUND.IMPASSABLE,
					contents = {},
			})


