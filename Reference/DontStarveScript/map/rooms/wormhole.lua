
------------------------------------------------------------------------------------
-- WORMHOLE ------------------------------------------------------------------------
------------------------------------------------------------------------------------

AddRoom("Wormhole_Swamp", {
					colour={r=1,g=0,b=0,a=0.3},
					value = GROUND.MARSH,
					contents =  {
									countprefabs = {
										wormhole_MARKER = 1,
									},
									distributepercent=0.3,
					                distributeprefabs= {
										marsh_tree = 2,
										marsh_bush = 4,
										rocks = 2,
									},
					            }
					})
AddRoom("Wormhole_Plains", {
					colour={r=1,g=0,b=0,a=0.3},
					value = GROUND.SAVANNA,
					contents =  {
									countprefabs = {
										wormhole_MARKER = 1,
									},
									distributepercent=0.3,
					                distributeprefabs= {
					                    grass = 3,
										rocks = 2,
										rock1 = 0.5,
										rock2 = 0.5,
									},
					            }
					})
AddRoom("Wormhole_Burnt", {
					colour={r=1,g=0,b=0,a=0.3},
					value = GROUND.FOREST,
					contents =  {
									countprefabs = {
										wormhole_MARKER = 1,
									},
									distributepercent=0.3,
					                distributeprefabs= {
					                    grass = 0.5,
										sapling = 0.5,
										rocks = 3,
										evergreen = 7,
									},
									prefabdata={
										evergreen = {burnt=true},
					                }
					            }
					})
AddRoom("Wormhole", {
					colour={r=1,g=0,b=0,a=0.3},
					value = GROUND.FOREST,
					contents =  {
									countprefabs = {
										wormhole_MARKER = 1,
									},
									distributepercent=0.3,
					                distributeprefabs= {
					                    grass = 1,
										sapling = 1,
										rocks = 3,
										evergreen_normal = 1,
										evergreen_short = 5,
										evergreen_tall = 1,
					                }
					            }
					})
AddRoom("Sinkhole", { -- This room is used to tag for the caves - it will be removed later
					colour={r=0,g=0,b=0,a=0.9},
					value = GROUND.FOREST,
					contents =  {
									countprefabs = {
										cave_entrance = 1,
									},
									distributepercent=0.3,
					                distributeprefabs= {
					                    grass = 1,
										sapling = 1,
										rocks = 3,
										evergreen_normal = 1,
										evergreen_short = 5,
										evergreen_tall = 1,
					                }
					            }
					})
