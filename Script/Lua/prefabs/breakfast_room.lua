local CreateEntity = CreateEntity
local LoadResource = LoadResource
local Prefab = Prefab

local assets = {
    scene = "breakfast_room.scene";
    mat = "breakfast_room.mat";
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("breakfast_room")

    inst:AddComponent("mesh_scene_renderer",
            LoadResource(assets.scene), LoadResource(assets.mat))

    return inst
end

return Prefab("breakfast_room", fn, assets)
