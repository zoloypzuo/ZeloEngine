local assets=
{
	Asset("ANIM", "anim/diviningrod.zip"),
	Asset("ANIM", "anim/swap_diviningrod.zip"),
	Asset("ANIM", "anim/diviningrod_fx.zip"),
}

local prefabs =
{
    "dr_hot_loop",
    "dr_warmer_loop",
    "dr_warm_loop_2",
    "dr_warm_loop_1",
}

local EFFECTS = 
{
    hot = "dr_hot_loop",--{anim="hot_loop", tint=Vector3(181/255, 32/255, 32/255)},
    warmer = "dr_warmer_loop",--{anim="warmer_loop", tint=Vector3(255/255, 163/255, 26/255)},
    warm = "dr_warm_loop_2",--{anim="warm_loop", tint=Vector3(105/255, 182/255, 239/255)},
    cold = "dr_warm_loop_1",--{anim="warm_loop", tint=Vector3(105/255, 160/255, 255/255)},
}

local function FindClosestPart(inst)

    if inst.tracking_parts == nil then
        inst.tracking_parts = {}
        for k,v in pairs(Ents) do
            if v:HasTag("teleportato") or v:HasTag("teleportato_part") or v.prefab == "adventure_portal" then
                table.insert(inst.tracking_parts, v)
            end
        end
    end

    if inst.tracking_parts then
        local closest = nil
        local closest_dist = nil
        for k,v in pairs(inst.tracking_parts) do
            if v:IsValid() and not v:IsInLimbo() then
                local dist = v:GetDistanceSqToInst(inst)
                if not closest_dist or dist < closest_dist then
                    closest = v
                    closest_dist = dist
                end
            end
        end

        return closest
    end

end

local function CheckTargetPiece(inst)
    if inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner then
        local intensity = 0
        local closeness = nil
        local fx = nil
        local target = FindClosestPart(inst) --FindEntity(inst, TUNING.DIVINING_MAXDIST, function(guy) return (guy:HasTag("teleportato") or guy:HasTag("teleportato_part") ) and not guy:IsInLimbo() end)
        local nextpingtime = TUNING.DIVINING_DEFAULTPING
        if target then
            local distsq = inst.components.inventoryitem.owner:GetDistanceSqToInst(target)
            intensity = math.max(0, 1 - (distsq/(TUNING.DIVINING_MAXDIST*TUNING.DIVINING_MAXDIST) ))
            for k,v in ipairs(TUNING.DIVINING_DISTANCES) do
                closeness = v
                fx = EFFECTS[v.describe]

                if v.maxdist and distsq <= v.maxdist*v.maxdist then
                    nextpingtime = closeness.pingtime
                    break
                end
            end
        end

        if closeness ~= inst.closeness then
            inst.closeness = closeness
	        local desc = inst.components.inspectable:GetDescription(inst.components.inventoryitem.owner)
	        if desc then
	            inst.components.inventoryitem.owner.components.talker:Say(desc)
	        end
        end
        
        if fx then
            inst.effect = SpawnPrefab(fx)--PlayFX(Vector3(0,0,0), "diviningrod_fx", "diviningrod_fx", fx.anim, nil, nil, fx.tint or Vector3(1, 1, 1) )
            local follower = inst.effect.entity:AddFollower()
	        follower:FollowSymbol(inst.components.inventoryitem.owner.GUID, "swap_object", 75, -300, 1 )
	    end

        inst.SoundEmitter:PlaySound("dontstarve/common/diviningrod_ping", "ping")
        inst.SoundEmitter:SetParameter("ping", "intensity", intensity)
        inst.task = inst:DoTaskInTime(nextpingtime or 1, CheckTargetPiece)
    end 
end

local function onequip(inst, owner) 
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:OverrideSymbol("swap_object", "swap_diviningrod", "swap_diviningrod")
    if not inst.disabled then
        inst.closeness = nil 
        inst.tracking_parts = nil       
        inst.task = inst:DoTaskInTime(1, CheckTargetPiece)
    end
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
    if inst.effect and inst.effect:IsValid() then
	    inst.effect:Remove()
        inst.effect = nil
    end
    inst.closeness = nil
end

local function describe(inst)
    if inst.components.equippable:IsEquipped() then
        if inst.closeness and inst.closeness.describe then
            return string.upper(inst.closeness.describe)
        end
        return "COLD"
    end
end

local function OnSave(inst, data)
    data.disabled = inst.disabled
end

local function OnLoad(inst, data)
    if data then
        inst.disabled = data.disabled
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()        
    MakeInventoryPhysics(inst)
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "diviningrod.png" )
    
    anim:SetBank("diviningrod")
    anim:SetBuild("diviningrod")
    anim:PlayAnimation("dropped")
    
	inst:AddTag("irreplaceable")
	inst:AddTag("nonpotatable")
	inst:AddTag("diviningrod")
    inst:AddTag("nopunch")
    inst:AddComponent("inspectable")

    inst:AddComponent("key")
    inst.components.key.keytype = "maxwell" 
    
    inst:AddComponent("inventoryitem")
    inst.components.inspectable.getstatus = describe
    
    inst:AddComponent("equippable")
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
    return inst
end


return Prefab( "common/inventory/diviningrod", fn, assets, prefabs) 

