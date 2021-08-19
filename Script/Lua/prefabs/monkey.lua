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

    local mesh_renderer = inst.entity:AddMeshRenderer()
    
    local mesh = LoadResource(assets.mesh)
    mesh_renderer.mesh = mesh

    local mesh_meta_data = require(assets.mesh)
    
    local tex_diffuse = LoadResource(mesh_meta_data.diffuse)
    local tex_normal = LoadResource(mesh_meta_data.normal)
    local tex_specular = LoadResource(mesh_meta_data.specular)

    local mat = Material.new(tex_diffuse, tex_normal, tex_specular)
    mesh_renderer.material = mat

    return inst
end

return Prefab("monkey", fn, assets)
