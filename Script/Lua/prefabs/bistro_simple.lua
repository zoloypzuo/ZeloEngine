local CreateEntity = CreateEntity
local LoadResource = LoadResource
local Prefab = Prefab

local assets = {
    scene = "bistro_simple.scene";
    mat = "bistro_simple.mat";
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("bistro_simple")

    inst.entity:AddMeshRenderer(
            LoadResource(assets.scene),
            LoadResource(assets.mat)
    )

    return inst
end

return Prefab("bistro_simple", fn, assets)
