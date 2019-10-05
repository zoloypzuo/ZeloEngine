
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
    Asset("ANIM", "anim/willow.zip"),
	Asset("SOUND", "sound/willow.fsb")    
}

local prefabs = 
{
    "willowfire",
    "lighter",
}

local start_inv = 
{
	"lighter",
}

local function sanityfn(inst)
	local x,y,z = inst.Transform:GetWorldPosition()	
	local delta = 0
	local max_rad = 10
	local ents = TheSim:FindEntities(x,y,z, max_rad, {"fire"})
    for k,v in pairs(ents) do 
    	if v.components.burnable and v.components.burnable.burning then
    		local sz = TUNING.SANITYAURA_TINY
    		local rad = v.components.burnable:GetLargestLightRadius() or 1
    		sz = sz * ( math.min(max_rad, rad) / max_rad )
			local distsq = inst:GetDistanceSqToInst(v)
			delta = delta + sz/math.max(1, distsq)
    	end
    end
    
    return delta
end

local fn = function(inst)
	inst:AddComponent("firebug")
	inst.components.firebug.prefab = "willowfire"
	inst.components.health.fire_damage_scale = 0
	inst.components.sanity:SetMax(TUNING.WILLOW_SANITY)

	inst.components.sanity.custom_rate_fn = sanityfn
	inst.components.inventory:GuaranteeItems(start_inv)
end


return MakePlayerCharacter("willow", prefabs, assets, fn, start_inv) 
