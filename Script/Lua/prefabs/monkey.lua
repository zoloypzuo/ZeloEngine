-- plane
-- created on 2021/8/9
-- author @zoloypzuo
local assets = {
    mesh = "monkey3.obj";
}

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst:AddTag("monkey")

    -- local mesh_loader = MeshLoader.new(assets.mesh);
    -- local mesh_render_data_list = {mesh_loader:GetMeshRendererData()}
    -- for _, render_data in ipairs(mesh_render_data_list) do
    --     local mesh_renderer = inst.entity:AddMeshRenderer()
    --     mesh_renderer.mesh = mesh
    --     mesh_renderer.material = material
    -- end
    return inst
end

return Prefab("monkey", fn, assets)
