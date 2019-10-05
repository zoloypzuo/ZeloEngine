
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
    Asset("ANIM", "anim/wendy.zip"),
	Asset("SOUND", "sound/wendy.fsb")    
}

local prefabs = 
{
    "abigail_flower",
}

local function custom_init(inst)

    inst.components.sanity.night_drain_mult = TUNING.WENDY_SANITY_MULT
    inst.components.sanity.neg_aura_mult = TUNING.WENDY_SANITY_MULT
    inst.components.combat.damagemultiplier = TUNING.WENDY_DAMAGE_MULT
	

    inst:DoTaskInTime(0, function() 
    		local found = false
    		for k,v in pairs(Ents) do
    			if v.prefab == "abigail" then
    				found = true
    				break
    			end
    		end
    		if not found then
    			inst.components.inventory:GuaranteeItems(prefabs)
    		end
    	end)
	

end


return MakePlayerCharacter("wendy", prefabs, assets, custom_init, prefabs) 
