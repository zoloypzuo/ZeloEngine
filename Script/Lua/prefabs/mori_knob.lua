local CreateEntity = CreateEntity
local LoadResource = LoadResource
local Prefab = Prefab

local assets = {
    scene = "mori_knob.scene";
    mat = "mori_knob.mat";
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("mori_knob")

    inst:AddComponent("mesh_scene_renderer",
            LoadResource(assets.scene), LoadResource(assets.mat))

    return inst
end

return Prefab("mori_knob", fn, assets)