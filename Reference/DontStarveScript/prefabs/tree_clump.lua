local assets =
{
	Asset("ANIM", "anim/tree_clump.zip"),
}

    
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    
    MakeObstaclePhysics(inst, 1.25)    

    anim:SetBank("tree_clump")
    anim:SetBuild("tree_clump")
    anim:PlayAnimation("anim", false)
    
    inst:AddComponent("inspectable")
    
    return inst
end

return Prefab( "common/objects/treeclump", fn, assets) 
