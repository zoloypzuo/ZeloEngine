local CreateEntity = CreateEntity
local LoadResource = LoadResource
local Prefab = Prefab

local assets = {
    scene = "bistro_wireframe.scene";
    mat = "bistro_wireframe.mat";
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("bistro_wireframe")

    inst.entity:AddMeshRenderer(
            LoadResource(assets.scene),
            LoadResource(assets.mat)
    )

    return inst
end

return Prefab("bistro_wireframe", fn, assets)
