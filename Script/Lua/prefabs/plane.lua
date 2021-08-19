-- plane
-- created on 2021/8/9
-- author @zoloypzuo
local assets = {
    mesh_gen = "plane.mesh_gen";
    diffuse  = "bricks2.jpg";
    normal   = "bricks2_normal.jpg";
    specular = "bricks2_specular.png";
}

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst:AddTag("plane")

    local mesh_renderer = inst.entity:AddMeshRenderer()
    
    local mesh_gen = assets.mesh_gen
    local mesh = LoadResource(mesh_gen)
    mesh_renderer.mesh = mesh
    
    local tex_diffuse = LoadResource(assets.diffuse)
    local tex_normal = LoadResource(assets.normal)
    local tex_specular = LoadResource(assets.specular)

    local mat = Material.new(tex_diffuse, tex_normal, tex_specular)
    mesh_renderer.material = mat

    return inst
end

return Prefab("plane", fn, assets)
