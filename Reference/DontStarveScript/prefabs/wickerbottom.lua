
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
    Asset("ANIM", "anim/wickerbottom.zip"),
	Asset("SOUND", "sound/wickerbottom.fsb")    
}

local fn = function(inst)
	
	inst:AddComponent("reader")
	
	inst:AddTag("insomniac")
    inst.components.eater.stale_hunger = TUNING.WICKERBOTTOM_STALE_FOOD_HUNGER
    inst.components.eater.stale_health = TUNING.WICKERBOTTOM_STALE_FOOD_HEALTH
    inst.components.eater.spoiled_hunger = TUNING.WICKERBOTTOM_SPOILED_FOOD_HUNGER
    inst.components.eater.spoiled_health = TUNING.WICKERBOTTOM_SPOILED_FOOD_HEALTH



	inst.components.sanity:SetMax(TUNING.WICKERBOTTOM_SANITY)
	inst.components.builder.science_bonus = 1
	local booktab = {str = STRINGS.TABS.BOOKS, sort=999, icon = "tab_book.tex"}
	inst.components.builder:AddRecipeTab(booktab)

	Recipe("book_birds", {Ingredient("papyrus", 2), Ingredient("bird_egg", 2)}, booktab, {SCIENCE = 0, MAGIC = 0, ANCIENT = 0})
	Recipe("book_gardening", {Ingredient("papyrus", 2), Ingredient("seeds", 1), Ingredient("poop", 1)}, booktab, {SCIENCE = 1})
	Recipe("book_sleep", {Ingredient("papyrus", 2), Ingredient("nightmarefuel", 2)}, booktab, {MAGIC = 2})
	Recipe("book_brimstone", {Ingredient("papyrus", 2), Ingredient("redgem", 1)}, booktab, {MAGIC = 3})
	Recipe("book_tentacles", {Ingredient("papyrus", 2), Ingredient("tentaclespots", 1)}, booktab, {SCIENCE = 3})

end


return MakePlayerCharacter("wickerbottom", nil, assets, fn, {"papyrus", "papyrus"}) 
