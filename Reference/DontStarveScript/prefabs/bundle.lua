local function OnStartBundling(inst)--, doer)
    inst.components.stackable:Get():Remove()
end

local function MakeWrap(name, containerprefab, tag, cheapfuel)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
        Asset("INV_IMAGE", "bundlewrap"),
    }

    local prefabs =
    {
        name,
        containerprefab,
        "bundle",
        "bundle_blueprint",
        "bundle_large",
        "bundle_medium",
        "bundle_small",
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()

        MakeInventoryPhysics(inst)

        inst.entity:AddAnimState()
        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")

        if tag ~= nil then
            inst:AddTag(tag)
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        inst:AddComponent("bundlemaker")
        inst.components.bundlemaker:SetBundlingPrefabs(containerprefab, name)
        inst.components.bundlemaker:SetOnStartBundlingFn(OnStartBundling)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = cheapfuel and TUNING.TINY_FUEL or TUNING.MED_FUEL

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)
        inst.components.propagator.flashpoint = 10 + math.random() * 5

        return inst
    end

    return Prefab(name.."wrap", fn, assets, prefabs)
end

local function CollectContainerItems(container)
    local items = {}

    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item ~= nil then
            table.insert(items, item)
        end
    end

    return items
end

local function MakeContainer(name, build)
    local assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()

        inst:AddTag("bundle")

        --V2C: blank string for controller action prompt
        inst.name = " "

        -- local slotpos = {}

        -- for y = 0, 1 do
        --     table.insert(slotpos, Vector3(-35, -y*75 + 40 ,0))
        --     table.insert(slotpos, Vector3(-35 + 75, -y*75 + 40 ,0))
        -- end


        local slotpos =
        {
            Vector3(-37.5, 32 + 4, 0), 
            Vector3(37.5, 32 + 4, 0),
            Vector3(-37.5, -(32 + 4), 0), 
            Vector3(37.5, -(32 + 4), 0),
        }

        local widgetbuttoninfo =
        {
            text = STRINGS.ACTIONS.WRAPBUNDLE,
            position = Vector3(0, -100, 0),
            fn = function(container, doer)
				BufferedAction(inst.components.container.opener, inst, ACTIONS.WRAPBUNDLE):Do()
            end,

            validfn = function(inst)
                local items = CollectContainerItems(inst.components.container)
                return #items > 0
            end,
        }

        inst:AddComponent("container")
        inst.components.container:SetNumSlots(#slotpos)
        inst.components.container.widgetslotpos = slotpos
        inst.components.container.widgetanimbank =  "ui_bundle_2x2"
        inst.components.container.widgetanimbuild = "ui_bundle_2x2"
        inst.components.container.widgetpos = Vector3(200, 0,0)
        inst.components.container.side_align_tip = 200
        inst.components.container.type = "cooker"
        inst.components.container.widgetbuttoninfo = widgetbuttoninfo
        inst.components.container.itemtestfn = function(inst, item, slot)
            return item.prefab ~= "bundle"
        end

        inst.persists = false

        return inst
    end

    return Prefab(name, fn, assets)
end

local function onburnt(inst)
    inst.burnt = true
    inst.components.unwrappable:Unwrap()
end

local function onignite(inst)
    inst.components.unwrappable.canbeunwrapped = false
end

local function onextinguish(inst)
    inst.components.unwrappable.canbeunwrapped = true
end

local function MakeBundle(name, onesize, variations, loot, tossloot, setupdata)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
    }

    if variations ~= nil then
        for i = 1, variations do
            if onesize then
                table.insert(assets, Asset("INV_IMAGE", name..tostring(i)))
            else
                table.insert(assets, Asset("INV_IMAGE", name.."_small"..tostring(i)))
                table.insert(assets, Asset("INV_IMAGE", name.."_medium"..tostring(i)))
                table.insert(assets, Asset("INV_IMAGE", name.."_large"..tostring(i)))
            end
        end
    elseif not onesize then
        table.insert(assets, Asset("INV_IMAGE", name.."_small"))
        table.insert(assets, Asset("INV_IMAGE", name.."_medium"))
        table.insert(assets, Asset("INV_IMAGE", name.."_large"))
    end

    local prefabs =
    {
        "ash",
        name.."_unwrap",
    }

    if loot ~= nil then
        for i, v in ipairs(loot) do
            table.insert(prefabs, v)
        end
    end

    local function OnWrapped(inst, num, doer)
        local suffix =
            (onesize and "_onesize") or
            (num > 3 and "_large") or
            (num > 1 and "_medium") or
            "_small"

        if variations ~= nil then
            if inst.variation == nil then
                inst.variation = math.random(variations)
            end
            suffix = suffix..tostring(inst.variation)
            inst.components.inventoryitem:ChangeImageName(name..(onesize and tostring(inst.variation) or suffix))
        elseif not onesize then
            inst.components.inventoryitem:ChangeImageName(name..suffix)
        end

        inst.AnimState:PlayAnimation("idle"..suffix)

        if doer ~= nil and doer.SoundEmitter ~= nil then
            --doer.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
            --DANY ADD STUFF HERE
        end
    end

    local function OnUnwrapped(inst, pos, doer)
        if inst.burnt then
            SpawnPrefab("ash").Transform:SetPosition(pos:Get())
        else
            local loottable = (setupdata ~= nil and setupdata.lootfn ~= nil) and setupdata.lootfn(inst, doer) or loot
            if loottable ~= nil then
                --[[ TO DO, MAKE DS COMPATIBLE
				local moisture = inst.components.moisturelistener and inst.components.moisturelistener:GetMoisture() or 0
                local iswet = inst.components.moisturelistener and inst.components.moisturelistener:IsWet() or false
				]]
                for i, v in ipairs(loottable) do
                    local item = SpawnPrefab(v)
                    if item ~= nil then
                        if item.Physics ~= nil then
                            item.Physics:Teleport(pos:Get())
                        else
                            item.Transform:SetPosition(pos:Get())
                        end
                        --[[ TO DO, MAKE DS COMPATIBLE
                        if item.components.inventoryitem ~= nil then
                            item.components.inventoryitem:InheritMoisture(moisture, iswet)
                            if tossloot then
                                item.components.inventoryitem:OnDropped(true, .5)
                            end
                        end
                        ]]
                    end
                end
            end
            --SpawnPrefab(name.."_unwrap").Transform:SetPosition(pos:Get())
        end
        if doer ~= nil and doer.SoundEmitter ~= nil then
            doer.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
        end
        inst:Remove()
    end

    local OnSave = variations ~= nil and function(inst, data)
        data.variation = inst.variation
    end or nil

    -- TODO: pre load???
    local OnPreLoad = variations ~= nil and function(inst, data)
        if data ~= nil then
            inst.variation = data.variation
        end
    end or nil

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation(
            variations ~= nil and
            (onesize and "idle_onesize1" or "idle_large1") or
            (onesize and "idle_onesize" or "idle_large")
        )

        inst:AddTag("bundle")

        --unwrappable (from unwrappable component) added to pristine state for optimization
        inst:AddTag("unwrappable")

        if setupdata ~= nil and setupdata.common_postinit ~= nil then
            setupdata.common_postinit(inst, setupdata)
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        if variations ~= nil or not onesize then
            inst.components.inventoryitem:ChangeImageName(
                name..
                (variations == nil and "_large" or (onesize and "1" or "_large1"))
            )
        end

        inst:AddComponent("unwrappable")
        inst.components.unwrappable:SetOnWrappedFn(OnWrapped)
        inst.components.unwrappable:SetOnUnwrappedFn(OnUnwrapped)

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)
        inst.components.propagator.flashpoint = 10 + math.random() * 5
        inst.components.burnable:SetOnBurntFn(onburnt)
        inst.components.burnable:SetOnIgniteFn(onignite)
        inst.components.burnable:SetOnExtinguishFn(onextinguish)

        if setupdata ~= nil and setupdata.master_postinit ~= nil then
            setupdata.master_postinit(inst, setupdata)
        end

        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(function ()
            inst.components.unwrappable:Unwrap()
        end)
        inst.components.useableitem:SetCanInteractFn(function() return true end)

        inst.OnSave = OnSave
        inst.OnPreLoad = OnPreLoad

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return MakeContainer("bundle_container", "ui_bundle_2x2"),
    --"bundle", "bundlewrap"
    MakeBundle("bundle", false, nil, { "waxpaper" }),
    MakeWrap("bundle", "bundle_container", nil, false)