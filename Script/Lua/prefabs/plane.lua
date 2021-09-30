-- plane
-- created on 2021/8/9
-- author @zoloypzuo
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

    local mesh_renderer = inst.entity:AddMeshRenderer()
    mesh_renderer.mesh = LoadResource(assets.mesh_gen)
    mesh_renderer.material = LoadResource(assets.material)

    return inst
end

return Prefab("plane", fn, assets)
