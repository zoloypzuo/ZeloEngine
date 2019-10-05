
--------------------------------------------------------------------------------
-- Walrus 
--------------------------------------------------------------------------------
AddRoom("WalrusHut_Plains", {
					colour={r=.30,g=.20,b=.50,a=.50},
					value = GROUND.SAVANNA,
					contents =  {
					                countprefabs= {
										walrus_camp = 1
					                },
					                distributepercent = .1,
					                distributeprefabs=
					                {
										grass=0.09,
										flower=0.003,
					                },
					            }
					})
AddRoom("WalrusHut_Grassy", {
					colour={r=.30,g=.20,b=.50,a=.50},
					value = GROUND.GRASS,
					contents =  {
					                countprefabs= {
										walrus_camp = 1
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
AddRoom("WalrusHut_Rocky", {
					colour={r=.30,g=.20,b=.50,a=.50},
					value = GROUND.ROCKY,
					contents =  {
					                countprefabs= {
										walrus_camp = 1
					                },
					                distributepercent = .1,
					                distributeprefabs=
					                {
										flint=0.5,
										rock1=1,
										rock2=1,
										tallbirdnest=0.3,
					                },
					            }
					})

