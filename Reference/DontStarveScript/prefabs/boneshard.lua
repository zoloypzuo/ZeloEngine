local assets = 
{
	Asset("ANIM", "anim/bone_shards.zip")
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    anim:SetBank("bone_shards")
    anim:SetBuild("bone_shards")
    anim:PlayAnimation("idle",false)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages.xml"

    inst:AddComponent("stackable")

	return inst
end

return Prefab("common/inventory/boneshard", fn, assets)