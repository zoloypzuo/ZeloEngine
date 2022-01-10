local CreateEntity = CreateEntity
local LoadResource = LoadResource
local Prefab = Prefab

local assets = {
    mesh_gen = "plane.mesh_gen";
    material = "plane.mat";
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("plane")

    inst.entity:AddMeshRenderer(
            LoadResource(assets.mesh_gen),
            LoadResource(assets.material)
    )

    return inst
end

return Prefab("plane", fn, assets)
