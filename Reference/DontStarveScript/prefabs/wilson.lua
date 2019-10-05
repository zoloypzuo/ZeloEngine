
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
    Asset("ANIM", "anim/wilson.zip"),
	Asset("ANIM", "anim/beard.zip"),
}

local prefabs = 
{
    "beardhair",
}

local fn = function(inst)

    inst:AddComponent("beard")
    inst.components.beard.onreset = function()
        inst.AnimState:ClearOverrideSymbol("beard")
    end
    inst.components.beard.prize = "beardhair"
    
    --tune the beard economy...
	local beard_days = {4, 8, 16}
	local beard_bits = {1, 3,  9}
    
    inst.components.beard:AddCallback(beard_days[1], function()
        inst.AnimState:OverrideSymbol("beard", "beard", "beard_short")
        inst.components.beard.bits = beard_bits[1]
    end)
    
    inst.components.beard:AddCallback(beard_days[2], function()
        inst.AnimState:OverrideSymbol("beard", "beard", "beard_medium")
        inst.components.beard.bits = beard_bits[2]
    end)
    
    inst.components.beard:AddCallback(beard_days[3], function()
        inst.AnimState:OverrideSymbol("beard", "beard", "beard_long")
        inst.components.beard.bits = beard_bits[3]
    end)
    
end

return MakePlayerCharacter("wilson", prefabs, assets, fn) 
