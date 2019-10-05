
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
    --Asset("ANIM", "anim/wendy.zip"),
    Asset("ANIM", "anim/wes.zip"),
    Asset("ANIM", "anim/player_mount_wes.zip"),    
	Asset("ANIM", "anim/player_mime.zip"),    
}

local prefabs = { "balloons_empty" }

local start_inv = 
{
	"balloons_empty",
}

local fn = function(inst)
	inst.components.health:SetMaxHealth(TUNING.WILSON_HEALTH * .75 )
	inst.components.hunger:SetMax(TUNING.WILSON_HUNGER * .75 )
	inst.components.combat.damagemultiplier = .75
	inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE*1.25)
	inst.components.sanity:SetMax(TUNING.WILSON_SANITY*.75)
	inst.components.inventory:GuaranteeItems(start_inv)
	inst.components.talker.special_speech = true
end


return MakePlayerCharacter("wes", prefabs, assets, fn, start_inv) 
