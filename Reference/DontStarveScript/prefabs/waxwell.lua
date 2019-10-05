
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
    Asset("ANIM", "anim/waxwell.zip"),
	Asset("SOUND", "sound/maxwell.fsb")    
}

local prefabs = 
{
	"shadowwaxwell",	
}

local start_inv = 
{
	"waxwelljournal",
	"nightsword",
	"armor_sanity",
	"purplegem",
	"nightmarefuel",
	"nightmarefuel",
	"nightmarefuel",
	"nightmarefuel",
}

local function custom_init(inst)
	inst:AddComponent("reader")

	inst.components.sanity.dapperness = TUNING.DAPPERNESS_HUGE
	inst.components.health:SetMaxHealth(TUNING.WILSON_HEALTH * .5 )
	inst.soundsname = "maxwell"

	inst.components.inventory:GuaranteeItems({"waxwelljournal"})
end

return MakePlayerCharacter("waxwell", prefabs, assets, custom_init, start_inv) 
