require "prefabutil"

local function test_ground(inst, pt)
    local tiletype = GetGroundTypeAtPosition(pt)
    return tiletype == GROUND.DIRT or inst.data.tile == "webbing"
end

local function ondeploy(inst, pt, deployer)
    if deployer and deployer.SoundEmitter then
        deployer.SoundEmitter:PlaySound("dontstarve/wilson/dig")
    end

    local ground = GetWorld()
    if ground then
        local original_tile_type = ground.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
        local x, y = ground.Map:GetTileCoordsAtPoint(pt.x, pt.y, pt.z)
        if x and y then
            ground.Map:SetTile(x, y, inst.data.tile)
            ground.Map:RebuildLayer(original_tile_type, x, y)
            ground.Map:RebuildLayer(inst.data.tile, x, y)
        end

        local minimap = TheSim:FindFirstEntityWithTag("minimap")
        if minimap then
            minimap.MiniMap:RebuildLayer(original_tile_type, x, y)
            minimap.MiniMap:RebuildLayer(inst.data.tile, x, y)
        end
    end

    inst.components.stackable:Get():Remove()
end

local function make_turf(data)
    local name = data.name

    local assets = {
        Asset("ANIM", "anim/turf.zip"),
        Asset("INV_IMAGE", "turf_" .. name)
    }

    local prefabs = {
        "gridplacer",
    }

    local function fn(Sim)
        local inst = CreateEntity()
        inst:AddTag("groundtile")
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("turf")
        inst.AnimState:SetBuild("turf")
        inst.AnimState:PlayAnimation(data.anim)

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.data = data

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL
        MakeMediumBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)

        inst:AddComponent("deployable")
        --inst.components.deployable.test = function() return true end
        inst.components.deployable.ondeploy = ondeploy
        inst.components.deployable.test = test_ground
        inst.components.deployable.min_spacing = 0
        inst.components.deployable.placer = "gridplacer"

        ---------------------
        return inst
    end

    return Prefab("common/objects/turf_" .. name, fn, assets, prefabs)
end

local turfs = {
    { name = "road", anim = "road", tile = GROUND.ROAD },
    { name = "rocky", anim = "rocky", tile = GROUND.ROCKY },
    { name = "forest", anim = "forest", tile = GROUND.FOREST },
    { name = "marsh", anim = "marsh", tile = GROUND.MARSH },
    { name = "grass", anim = "grass", tile = GROUND.GRASS },
    { name = "savanna", anim = "savanna", tile = GROUND.SAVANNA },
    { name = "dirt", anim = "dirt", tile = GROUND.DIRT },
    { name = "woodfloor", anim = "woodfloor", tile = GROUND.WOODFLOOR },
    { name = "carpetfloor", anim = "carpet", tile = GROUND.CARPET },
    { name = "checkerfloor", anim = "checker", tile = GROUND.CHECKER },

    { name = "cave", anim = "cave", tile = GROUND.CAVE },
    { name = "fungus", anim = "fungus", tile = GROUND.FUNGUS },
    { name = "fungus_red", anim = "fungus_red", tile = GROUND.FUNGUSRED },
    { name = "fungus_green", anim = "fungus_green", tile = GROUND.FUNGUSGREEN },

    { name = "sinkhole", anim = "sinkhole", tile = GROUND.SINKHOLE },
    { name = "underrock", anim = "rock", tile = GROUND.UNDERROCK },
    { name = "mud", anim = "mud", tile = GROUND.MUD },
}

local prefabs = {}
for k, v in pairs(turfs) do
    table.insert(prefabs, make_turf(v))
end

return unpack(prefabs) 
