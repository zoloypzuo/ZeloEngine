local assets=
{
	Asset("ANIM", "anim/pitchfork.zip"),
	--Asset("ANIM", "anim/goldenpitchfork.zip"),
	Asset("ANIM", "anim/swap_pitchfork.zip"),
	--Asset("ANIM", "anim/swap_goldenpitchfork.zip"),
}
    
local function onfinished(inst)
    inst:Remove()
end
    
local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_pitchfork", "swap_pitchfork")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end
    
    
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()    
    MakeInventoryPhysics(inst)
    
    anim:SetBank("pitchfork")
    anim:SetBuild("pitchfork")
    anim:PlayAnimation("idle")
    
    inst:AddTag("sharp")
    
    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.PITCHFORK_USES)
    inst.components.finiteuses:SetUses(TUNING.PITCHFORK_USES)
    inst.components.finiteuses:SetOnFinished( onfinished) 
    inst.components.finiteuses:SetConsumption(ACTIONS.TERRAFORM, .125)
    -------
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.PITCHFORK_DAMAGE)
    
    inst:AddInherentAction(ACTIONS.TERRAFORM)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("terraformer")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    
    return inst
end

--local function onequipgold(inst, owner) 
    --owner.AnimState:OverrideSymbol("swap_object", "swap_goldenpitchfork", "swap_goldenpitchfork")
	--owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")     
    --owner.AnimState:Show("ARM_carry") 
    --owner.AnimState:Hide("ARM_normal") 
--end


--local function golden(Sim)
	--local inst = fn(Sim)
	--inst.AnimState:SetBuild("goldenpitchfork")
    --inst.components.finiteuses:SetConsumption(ACTIONS.TERRAFORM, .125 / TUNING.GOLDENTOOLFACTOR)
    --inst.components.weapon.attackwear = 1 / TUNING.GOLDENTOOLFACTOR
    --inst.components.researchvalue.basevalue = TUNING.RESEARCH_VALUE_GOLD_TOOL
    
    --inst.components.equippable:SetOnEquip( onequipgold )
    
	--return inst
--end


return Prefab( "common/inventory/pitchfork", fn, assets) --,
	   --Prefab( "common/inventory/goldenpitchfork", golden, assets) 
	   

