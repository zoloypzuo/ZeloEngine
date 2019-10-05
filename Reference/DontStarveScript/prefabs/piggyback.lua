local assets=
{
	Asset("ANIM", "anim/piggyback.zip"),
	Asset("ANIM", "anim/swap_piggyback.zip"),
}

local function onequip(inst, owner) 
    --owner.AnimState:OverrideSymbol("swap_body", "swap_backpack", "backpack")
    owner.AnimState:OverrideSymbol("swap_body", "swap_piggyback", "swap_body")
    owner.components.inventory:SetOverflow(inst)
    inst.components.container:Open(owner)
end

local function onunequip(inst, owner) 
    --owner.AnimState:ClearOverrideSymbol("backpack")
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.components.inventory:SetOverflow(nil)
    inst.components.container:Close(owner)
end


local function onopen(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_open", "open")
end

local function onclose(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close", "open")
end


local slotpos = {}

for y = 0, 5 do
	table.insert(slotpos, Vector3(-162, -y*75 + 170 ,0))
	table.insert(slotpos, Vector3(-162 +75, -y*75 + 170 ,0))
end

local function fn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("piggyback")
    inst.AnimState:SetBuild("piggyback")
    inst.AnimState:PlayAnimation("anim")

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("piggyback.png")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/backpack"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    inst.components.equippable.walkspeedmult = TUNING.PIGGYBACK_SPEED_MULT
    
    
    inst:AddComponent("container")
    inst.components.container:SetNumSlots(#slotpos)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_piggyback_2x6"
    inst.components.container.widgetanimbuild = "ui_piggyback_2x6"
    inst.components.container.widgetpos = Vector3(-5,-50,0)
	inst.components.container.side_widget = true  
    inst.components.container.type = "pack" 
	
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
 
    
    return inst
end

return Prefab( "common/inventory/piggyback", fn, assets) 
