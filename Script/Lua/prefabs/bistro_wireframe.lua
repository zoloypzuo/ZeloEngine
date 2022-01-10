-- plane
-- created on 2021/8/9
-- author @zoloypzuo
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

    inst.inst:AddComponent("mesh_scene_renderer",
            LoadResource(assets.scene), LoadResource(assets.mat))

    return inst
end

return Prefab("bistro_wireframe", fn, assets)
