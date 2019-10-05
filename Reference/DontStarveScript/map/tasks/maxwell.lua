AddTask("MaxPuzzle1", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.WOOD,
		room_choices={
			["MaxPuzzle1"] = 1,
			["SpiderMarsh"] = 2+math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	}) 
AddTask("MaxPuzzle2", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.WOOD,
		room_choices={
			["MaxPuzzle2"] = 1,
			["SpiderMarsh"] = 2+math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	}) 
AddTask("MaxPuzzle3", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.WOOD,
		room_choices={
			["MaxPuzzle3"] = 1,
			["SpiderMarsh"] = 2+math.random(SIZE_VARIATION), 
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	}) 
	
AddTask("MaxHome", {
		lock=LOCKS.NONE,
		key_given=KEYS.NONE,
		room_choices={
			["MaxHome"] = 1,
		},
		room_bg=GROUND.IMPASSABLE,
		background_room="BGImpassable",
		colour={r=.05,g=.05,b=.05,a=1}
	}) 

