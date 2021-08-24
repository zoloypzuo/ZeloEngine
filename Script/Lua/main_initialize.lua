-- main_initialize.lua
-- created on 2021/8/18
-- author @zoloypzuo

--collectgarbage("stop") -- fix gc

-- singleton
TheSim = Game.GetSingletonPtr()
UI = UIManager.GetSingletonPtr()

-- resource
table.insert(package.loaders, 1, ResourceMetaDataLoader)

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
    return Material.new(tex_diffuse, tex_normal, tex_specular)
end)

-- UI
UI.enable_docking = false;
UI:ApplyStyle(EStyle.DUNE_DARK)
UI:UseFont(LoadResource("Ruda-Bold.ttf"))
TheFrontEnd:LoadPanel("project_hub_panel")

--require("scenes.scene01")