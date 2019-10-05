local assets=
{
	Asset("ANIM", "anim/boat_sunk.zip"),
}

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    
    MakeObstaclePhysics(inst, 1)

    anim:SetBank("boat_sunk")
    anim:SetBuild("boat_sunk")

    inst:AddComponent("inspectable")
    --MakeSnowCovered(inst, .01)        
    return inst
end
   
return Prefab("forest/objects/sunkboat", fn, assets) 
