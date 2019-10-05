
--------------------------------------------------------------------------------
-- Pigs 
--------------------------------------------------------------------------------
AddRoom("PigTown", {
					colour={r=0.3,g=.8,b=.5,a=.50},
					value = GROUND.GRASS,
					tags = {"Town"},
					contents =  {
									countstaticlayouts={
										["PigTown"]=1, 
									},
									distributepercent = .1,
									distributeprefabs= {
					                    grass = .05,
					                    berrybush=.05,
									},
					            }
					})
AddRoom("PigVillage", {
					colour={r=0.3,g=.8,b=.5,a=.50},
					value = GROUND.GRASS,
					tags = {"Town"},
					contents =  {
									countstaticlayouts={
										["Farmplot"]=function() return math.random(2,5) end,
										["VillageSquare"]= function()	
																		if math.random() > 0.97 then 
																			return 1 
																	  	end 
																	  	return 0 
															end,
									},
					                countprefabs= {
					                    --bonfire = 1,
					                    pighouse = function () return 3 + math.random(4) end,
										mermhead = function () return math.random(3) end,
					                },
									distributepercent = .1,
									distributeprefabs= {
					                    grass = .05,
					                    berrybush=.05,
									},
					            }
					})
AddRoom("PigKingdom", {
					colour={r=0.8,g=.8,b=.1,a=.50},
					value = GROUND.GRASS,
					tags = {"Town"},
					contents =  {
									countstaticlayouts=
									{
										["DefaultPigking"]=1,
										["CropCircle"]=function() return math.random(0,1) end,
										["TreeFarm"]= 	function()
																		if math.random() > 0.97 then 
																			return math.random(1,2) 
																	  	end 
																	  	return 0 
										 				end,
									},
					                countprefabs= {
					                    pighouse = function () return 5 + math.random(4) end,
					                }
					            }
					})
AddRoom("PigCity", {
					colour={r=0.9,g=.9,b=.2,a=.50},
					value = GROUND.ROCKY,
					tags = {"Town"},
					contents =  {
									countstaticlayouts=
									{
										["PigTown"]=function () return 1 + math.random(2) end,
										["TorchPigking"]=1,
									},
									countprefabs={
										mermhead = function () return math.random(3) end,
									},
					            }
					})
AddRoom("PigCamp", {
					colour={r=1,g=.8,b=.8,a=.50},
					value = GROUND.GRASS,
					tags = {"Town"},
					contents =  {
					                countprefabs= {
					                    pighouse = function () return 4 + math.random(4) end,
										mermhead = function () return math.random(3) end,
					                },
									distributepercent = 0.1,
									distributeprefabs = {
										poop = 0.01,
										wall_hay = 0.01,
					                    grass = .15,
					                    berrybush=.05,
									},
					                }
					})
AddRoom("PigShrine", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.FOREST, 
					contents =  {
									countstaticlayouts={
										["MaxPigShrine"]=1,
									},
					                countprefabs= {
					                    flower = function () return 8 + math.random(4) end,
					                },
									distributepercent=0.4,
									distributeprefabs={
					                    evergreen_normal = 1,
										evergreen_tall=1,
									},
					            }
					})
AddRoom("Pondopolis", {
					colour={r=.30,g=.20,b=.50,a=.50},
					value = GROUND.GRASS,
					contents =  {
					                countprefabs= {
					                    pond = function () return 5 + math.random(3) end
					                },
									distributepercent = 0.1,
									distributeprefabs = {
					                    grass = 8,
					                    flower = 6,
					                    sapling = 1,
									},
					            }
					})
