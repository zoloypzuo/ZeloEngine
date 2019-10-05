
AddRoom("LabyrinthGuarden", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.BRICK, 
					tags = {"LabyrinthEntrance"},
					contents =  {
									countstaticlayouts = 
									{
										["WalledGarden"] = 1,
									},          
					        	},
					})

AddRoom("BGLabyrinth", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.CAVE_NOISE, 
					tags = {"Labyrinth"},
					contents =  {
					                distributepercent = .04,
					                distributeprefabs=
					                {

					                	nightmarelight = .45,
					                    dropperweb = 1,
					                }
					            }
					})
AddRoom("BGMaze", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.MUD, 
					tags = {"Maze"},
					contents =  {
									distributepercent = 0.15,
					                distributeprefabs= 
					                {
					                	lichen = .001,
					                	cave_fern = .0015,
					                	--pond_cave = .002,
					                    pillar_algae = .0001,
					                    slurper = .0002,
					                }
					            }
					})


