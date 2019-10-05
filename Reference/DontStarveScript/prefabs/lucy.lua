local assets=
{
	Asset("ANIM", "anim/lucy_axe.zip"),
    Asset("ANIM", "anim/swap_lucy_axe.zip"),
    Asset("MINIMAP_IMAGE", "lucy_axe"),
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_lucy_axe", "swap_lucy_axe")
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
    
    inst:AddTag("irreplaceable")
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "lucy_axe.png" )
    
    
    anim:SetBank("Lucy_axe")
    anim:SetBuild("Lucy_axe")
    anim:PlayAnimation("idle")
    
    inst:AddTag("sharp")
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.AXE_DAMAGE*.5)

    -----
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, 2)

    -------
    
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip)

    inst:AddComponent("talker")
    --inst.components.talker.ontalk = ontalk

    inst.components.talker.fontsize = 28
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(.9, .4, .4, 1)
    inst.components.talker.offset = Vector3(0,0,0)
    inst.components.talker.symbol = "swap_object"

    inst:AddComponent("sentientaxe")
    
    inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("woodie")
    
    
    inst:ListenForEvent("donetalking", function() inst.SoundEmitter:KillSound("talk") end)
    inst:ListenForEvent("ontalk", function() 
		if inst.components.sentientaxe.sound_override then
			inst.SoundEmitter:KillSound("talk")
			inst.SoundEmitter:PlaySound(inst.components.sentientaxe.sound_override, "special")
		else
			if not inst.SoundEmitter:PlayingSound("special") then
				inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/lucytalk_LP", "talk") 
			end
		end
	end)
    
    
    
    return inst
end


return Prefab( "common/inventory/lucy", fn, assets)
	   

