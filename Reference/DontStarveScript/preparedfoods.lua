local foods=
{
	butterflymuffin =
	{
		test = function(cooker, names, tags) return names.butterflywings and not tags.meat and tags.veggie end,
		priority = 1,
		weight = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
	},
	
	frogglebunwich =
	{
		test = function(cooker, names, tags) return (names.froglegs or names.froglegs_cooked) and tags.veggie end,
		priority = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
	},
	
	taffy =
	{
		test = function(cooker, names, tags) return tags.sweetener and tags.sweetener >= 3 and not tags.meat end,
		priority = 10,
		foodtype = "VEGGIE",
		health = -TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL*2,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_MED,
		cooktime = 2,
	},
	
	pumpkincookie =
	{
		test = function(cooker, names, tags) return (names.pumpkin or names.pumpkin_cooked) and tags.sweetener and tags.sweetener >= 2 end,
		priority = 10,
		foodtype = "VEGGIE",
		health = 0,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_MED,
		cooktime = 2,
	},	
	
	stuffedeggplant =
	{
		test = function(cooker, names, tags) return (names.eggplant or names.eggplant_cooked) and tags.veggie and tags.veggie > 1 end,
		priority = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
	},
	
	fishsticks =
	{
		test = function(cooker, names, tags) return tags.fish and names.twigs and (tags.inedible and tags.inedible <= 1) end,
		priority = 10,
		foodtype = "MEAT",
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
	},
	
	honeynuggets =
	{
		test = function(cooker, names, tags)  return names.honey and tags.meat and tags.meat <= 1.5 and not tags.inedible end,
		priority = 2,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
	},
	
	honeyham =
	{
		test = function(cooker, names, tags)  return names.honey and tags.meat and tags.meat > 1.5 and not tags.inedible end,
		priority = 2,
		foodtype = "MEAT",
		health = TUNING.HEALING_MEDLARGE,
		hunger = TUNING.CALORIES_HUGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
	},

	dragonpie =
	{
		test = function(cooker, names, tags)  return (names.dragonfruit or names.dragonfruit_cooked) and not tags.meat end,
		priority = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_HUGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
	},

	kabobs =
	{
		test = function(cooker, names, tags) return tags.meat and names.twigs and (not tags.monster or tags.monster <= 1) and (tags.inedible and tags.inedible <= 1) end,
		priority = 5,
		foodtype = "MEAT",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
	},

	mandrakesoup =
	{
		test = function(cooker, names, tags) return names.mandrake end,
		priority = 10,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_SUPERHUGE,
		hunger = TUNING.CALORIES_SUPERHUGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = 3,
	},

	baconeggs =
	{
		test = function(cooker, names, tags) return tags.egg and tags.egg > 1 and tags.meat and tags.meat > 1 and not tags.veggie end,
		priority = 10,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_HUGE,
		perishtime = TUNING.PERISH_PRESERVED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
	},

	meatballs =
	{
		test = function(cooker, names, tags) return tags.meat and not tags.inedible end,
		priority = -1,
		foodtype = "MEAT",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL*5,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = .75,
	},

	bonestew =
	{
		test = function(cooker, names, tags) return tags.meat and tags.meat >= 3 and not tags.inedible end,
		priority = 0,
		foodtype = "MEAT",
		health = TUNING.HEALING_SMALL*4,
		hunger = TUNING.CALORIES_LARGE*4,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = .75,
	},

	perogies =
	{
		test = function(cooker, names, tags) return tags.egg and tags.meat and tags.veggie and not tags.inedible end,
		priority = 5,
		foodtype = "MEAT",
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_PRESERVED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 1,
	},

	turkeydinner =
	{
		test = function(cooker, names, tags) return names.drumstick and names.drumstick > 1 and tags.meat and tags.meat > 1 and (tags.veggie or tags.fruit) end,
		priority = 10,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_HUGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = 3,
	},

	ratatouille =
	{
		test = function(cooker, names, tags) return not tags.meat and tags.veggie and not tags.inedible end,
		priority = 0,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 1,
	},

	jammypreserves =
	{
		test = function(cooker, names, tags) return tags.fruit and not tags.meat and not tags.veggie and not tags.inedible end,
		priority = 0,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL*3,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
	},
	
	fruitmedley =
	{
		test = function(cooker, names, tags) return tags.fruit and tags.fruit >= 3 and not tags.meat and not tags.veggie end,
		priority = 0,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
	},

	fishtacos =
	{
		test = function(cooker, names, tags) return tags.fish and (names.corn or names.corn_cooked) end,
		priority = 10,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
	},

	waffles =
	{
		test = function(cooker, names, tags) return names.butter and (names.berries or names.berries_cooked) and tags.egg end,
		priority = 10,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_HUGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
	},	
	
	monsterlasagna =
	{
		test = function(cooker, names, tags) return tags.monster and tags.monster >= 2 and not tags.inedible end,
		priority = 10,
		foodtype = "MEAT",
		health = -TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = -TUNING.SANITY_MEDLARGE,
		cooktime = .5,
	},

	powcake =
	{
		test = function(cooker, names, tags) return names.twigs and names.honey and (names.corn or names.corn_cooked) end,
		priority = 10,
		foodtype = "VEGGIE",
		health = -TUNING.HEALING_SMALL,
		hunger = 0,
		perishtime = 9000000,
		sanity = 0,
		cooktime = 0.5,
	},

	unagi =
	{
		test = function(cooker, names, tags) return names.cutlichen and (names.eel or names.eel_cooked) end,
		priority = 20,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_MEDSMALL,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 0.5,
	},
	
	wetgoop =
	{
		test = function(cooker, names, tags) return true end,
		priority = -2,
		health=0,
		hunger=0,
		perishtime = TUNING.PERISH_FAST,
		sanity = 0,
		cooktime = .25,
	},

}
for k,v in pairs(foods) do
	v.name = k
	v.weight = v.weight or 1
	v.priority = v.priority or 0
end


return foods
