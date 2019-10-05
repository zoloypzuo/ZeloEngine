local assets =
{
	--Asset("ANIM", "anim/arrow_indicator.zip"),
}

    
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	--[[local anim = inst.entity:AddAnimState()
    
    anim:SetBank("arrow_indicator")
    anim:SetBuild("arrow_indicator")
    anim:PlayAnimation("arrow_loop", true)
    --]]

    inst:AddTag("spawnpoint")
    inst.persists = false
    
    return inst
end

return Prefab( "common/spawnpoint", fn, assets) 
