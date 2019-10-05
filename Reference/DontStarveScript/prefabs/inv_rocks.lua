local assets=
{
	Asset("ANIM", "anim/rocks.zip"),
}

local names = {"f1","f2","f3"}

local function onsave(inst, data)
	data.anim = inst.animname
end

local function onload(inst, data)
    if data and data.anim then
        inst.animname = data.anim
	    inst.AnimState:PlayAnimation(inst.animname)
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("rocks")
    inst.AnimState:SetBuild("rocks")
    inst.animname = names[math.random(#names)]
    inst.AnimState:PlayAnimation(inst.animname)

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ELEMENTAL"
    inst.components.edible.hungervalue = 1
    inst:AddComponent("tradable")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

	inst:AddComponent("repairer")
	inst.components.repairer.repairmaterial = "stone"
	inst.components.repairer.healthrepairvalue = TUNING.REPAIR_ROCKS_HEALTH

    inst.OnSave = onsave 
    inst.OnLoad = onload 
    return inst
end

return Prefab( "common/inventory/rocks", fn, assets) 
