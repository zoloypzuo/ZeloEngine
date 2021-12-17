-- resource_loaders.lua
-- created on 2021/12/16
-- author @zoloypzuo
local RegisterResourceLoader = RegisterResourceLoader

table.insert(package.loaders, 1, ResourceMetaDataLoader)

MeshGenerators["plane"] = PlaneMeshGen

RegisterResourceLoader("MESH", function(name, data)
    local loader = MeshLoader.new(name, data.mesh_index)
    return Mesh.new(loader)
end)

RegisterResourceLoader("MESH_GEN", function(name, _)
    return Mesh.new(MeshGenerators[name].new())
end)

RegisterResourceLoader("TEX", function(name, _)
    return Texture.new(name);
end)

RegisterResourceLoader("FONT", function(name, data)
    return Font.new(name, data.font_size)
end)

RegisterResourceLoader("MATERIAL", function(name, data)
    local tex_diffuse = LoadResource(data.diffuse)
    local tex_normal = LoadResource(data.normal)
    local tex_specular = LoadResource(data.specular)
    local shader = nil
    if data.shader then
        shader = LoadResource(data.shader)
    end
    return Material.new(tex_diffuse, tex_normal, tex_specular, shader)
end)

RegisterResourceLoader("SCENE", function(name, data)
    local scene_file, mesh_file, material_file = data.scene_file, data.mesh_file, data.material_file
    return Scene.new(scene_file, mesh_file, material_file)
end)

RegisterResourceLoader("SHADER", function(name, data)
    return Shader.new(name)
end)