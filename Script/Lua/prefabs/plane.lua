-- plane
-- created on 2021/8/9
-- author @zoloypzuo
local assets = {
    mesh_gen = "plane";
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
    local mesh = Mesh.new(MeshGenerators[mesh_gen].new())
    mesh_renderer.mesh = mesh
    
    local tex_diffuse = Texture.new(assets.diffuse)
    local tex_normal = Texture.new(assets.normal)
    local tex_specular = Texture.new(assets.specular)

    local mat = Material.new(tex_diffuse, tex_normal, tex_specular)
    mesh_renderer.material = mat

    return inst
end

return Prefab("plane", fn, assets)
