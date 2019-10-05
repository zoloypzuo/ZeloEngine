local assets=
{
    Asset("ANIM", "anim/walrus_tusk.zip"),
}

local function create()
    
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    MakeInventoryPhysics(inst)
   
    inst.AnimState:SetBank("walrus_tusk")
    inst.AnimState:SetBuild("walrus_tusk")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inventoryitem")
    
    return inst
end

return Prefab( "common/inventory/walrus_tusk", create, assets) 
