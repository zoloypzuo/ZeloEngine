local assets=
{
	Asset("ANIM", "anim/ruins_bat.zip"),
	Asset("ANIM", "anim/swap_ruins_bat.zip"),
    Asset("INV_IMAGE", "ruins_bat"),
}

local prefabs =
{
    "shadowtentacle",
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_ruins_bat", "swap_ruins_bat")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local summonchance = 0.2

local function onattack(inst, owner, target)
    if math.random() < summonchance then
        local pt = target:GetPosition()
        local st_pt =  FindWalkableOffset(pt or owner:GetPosition(), math.random()*2*PI, 2, 3)
        if st_pt then
            inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
            inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")            
            st_pt = st_pt + pt
            local st = SpawnPrefab("shadowtentacle")
            --print(st_pt.x, st_pt.y, st_pt.z)
            st.Transform:SetPosition(st_pt.x, st_pt.y, st_pt.z)
            st.components.combat:SetTarget(target)
        end
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("ruins_bat")
    anim:SetBank("ruins_bat")
    anim:SetBuild("ruins_bat")
    anim:PlayAnimation("idle")
    
    inst:AddTag("sharp")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.RUINS_BAT_DAMAGE)
    inst.components.weapon:SetOnAttack(onattack)
    
    -------
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.RUINS_BAT_USES)
    inst.components.finiteuses:SetUses(TUNING.RUINS_BAT_USES)
    
    inst.components.finiteuses:SetOnFinished( onfinished )

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    inst.components.equippable.walkspeedmult = TUNING.RUINS_BAT_SPEED_MULT
    return inst
end

return Prefab( "common/inventory/ruins_bat", fn, assets, prefabs) 
