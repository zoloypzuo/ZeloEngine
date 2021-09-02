-- plane
-- created on 2021/8/9
-- author @zoloypzuo
local assets = {
    mesh = "monkey3.obj";
    material = "monkey.mat";
}

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst:AddTag("monkey")

    local mesh_renderer = inst.entity:AddMeshRenderer()

    mesh_renderer.mesh = LoadResource(assets.mesh)

    mesh_renderer.material = LoadResource(assets.material)

    return inst
end

return Prefab("monkey", fn, assets)
