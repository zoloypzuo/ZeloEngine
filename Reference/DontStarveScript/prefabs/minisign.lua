require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/sign_mini.zip"),
    Asset("ATLAS_BUILD", "images/inventoryimages.xml", 256),
}

local assets_item =
{
    Asset("ANIM", "anim/sign_mini.zip"),
}

local prefabs =
{
    "minisign_item",
    "minisign_drawn",
}

local prefabs_item =
{
    "minisign",
}

local function ondeploy(inst, pt)--, deployer)
    local ent = SpawnPrefab("minisign")

    if inst.components.stackable ~= nil then
        inst.components.stackable:Get():Remove()
    else
        ent.components.drawable:OnDrawn(inst.components.drawable:GetImage())
        ent._imagename = inst._imagename
        inst:Remove()
    end

    ent.Transform:SetPosition(pt:Get())
    ent.SoundEmitter:PlaySound("dontstarve/common/craftable/sign/place")
end

local function dig_up(inst)--, worker)
    local image = inst.components.drawable:GetImage()
    if image then
        local item = inst.components.lootdropper:SpawnLootPrefab("minisign_drawn")
        item.components.drawable:OnDrawn(image)       
        item._imagename = inst._imagename
    else
        inst.components.lootdropper:SpawnLootPrefab("minisign_item")
    end
    inst:Remove()
end

local function onignite(inst)
    DefaultBurnFn(inst)
    inst.components.drawable:SetCanDraw(false)
end

local function onextinguish(inst)
    DefaultExtinguishFn(inst)
    if inst.components.drawable:GetImage() == nil then
        inst.components.drawable:SetCanDraw(true)
    end
end

local function OnDrawnFn(inst, image, src)
    if image ~= nil then
        inst.AnimState:OverrideSymbol("SWAP_SIGN", src and src.components.inventoryitem and src.components.inventoryitem:GetAtlas() or "images/inventoryimages.xml", image..".tex")
        if inst:HasTag("sign") then
            inst.components.drawable:SetCanDraw(false)
            inst._imagename = src and src.name or nil
            if src then
                inst.SoundEmitter:PlaySound("dontstarve/common/craftable/sign/draw")
            end
        end
    else
        inst.AnimState:ClearOverrideSymbol("SWAP_SIGN")
        if inst:HasTag("sign") then
            if not (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
                inst.components.drawable:SetCanDraw(true)
            end
            inst._imagename = nil
        end
    end
end

local function getstatus(inst)
    return inst.components.drawable:GetImage() == nil
        and "UNDRAWN"
        or nil
end

local function IsLowPriorityAction(act, force_inspect)
    return act == nil
        or act.action == ACTIONS.WALKTO
        or (act.action == ACTIONS.LOOKAT and not force_inspect)
end

local function displaynamefn(inst)
    if inst._imagename then
        return subfmt(STRINGS.NAMES.MINISIGN_DRAWN, { item = inst._imagename })        
    end
end

local function OnSave(inst, data)
    data.imagename = inst._imagename        
end

local function OnLoad(inst, data)
    if data and data.imagename then
        inst._imagename = data.imagename
    end        
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("sign_mini")
    inst.AnimState:SetBuild("sign_mini")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("sign")

    inst:AddTag("drawable")

    inst.displaynamefn = displaynamefn
    inst._imagename = nil

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)

    inst:AddComponent("drawable")
    inst.components.drawable:SetOnDrawnFn(OnDrawnFn)

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    inst.components.burnable:SetOnIgniteFn(onignite)
    inst.components.burnable:SetOnExtinguishFn(onextinguish)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

local function MakeItem(name, drawn)
    local function item_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("sign_mini")
        inst.AnimState:SetBuild("sign_mini")
        inst.AnimState:PlayAnimation(drawn and "item_drawn" or "item")

        if drawn then
            inst.displaynamefn = displaynamefn
            inst.drawnameoverride = STRINGS.NAMES.MINISIGN
            inst._imagename = nil
            --Use planted inspect strings for drawn version
            inst:SetPrefabNameOverride("minisign")
        end

        if drawn then
            inst.OnSave = OnSave
            inst.OnLoad = OnLoad

            inst:AddComponent("drawable")
            inst.components.drawable:SetOnDrawnFn(OnDrawnFn)
            inst.components.drawable:SetCanDraw(false)
        else
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        inst:AddComponent("deployable")
        inst.components.deployable.ondeploy = ondeploy
        inst.components.deployable.min_spacing = 0
        --inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL


        return inst
    end

    return Prefab(name, item_fn, assets_item, prefabs_item)
end

return Prefab("minisign", fn, assets, prefabs),
    MakeItem("minisign_item", false),
    MakeItem("minisign_drawn", true),
    MakePlacer("minisign_item_placer", "sign_mini", "sign_mini", "idle"),
    MakePlacer("minisign_drawn_placer", "sign_mini", "sign_mini", "idle")
