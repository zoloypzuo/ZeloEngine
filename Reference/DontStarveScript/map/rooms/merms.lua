
--------------------------------------------------------------------------------
-- Merms 
--------------------------------------------------------------------------------
AddRoom("MermTown", {
					colour={r=0.5,g=.18,b=.35,a=.50},
					value = GROUND.MARSH,
					contents =  {
									countprefabs={
										pighead=function() return math.random(6) end,
									},
									distributepercent = .1,
									distributeprefabs= {
					                    --merm = 0.1,
					                    mermhouse = 1,
					                    tentacle =  1,
					                    reeds =  2,
					                    pond_mos=0.5,
									},
					            }
					})
