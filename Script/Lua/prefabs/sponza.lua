local CreateEntity = CreateEntity
local LoadResource = LoadResource
local Prefab = Prefab

local assets = {
    scene = "sponza.scene";
    mat = "sponza.mat";
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("sponza")

    inst:AddComponent("mesh_scene_renderer",
            LoadResource(assets.scene), LoadResource(assets.mat))

    return inst
end

return Prefab("sponza", fn, assets)