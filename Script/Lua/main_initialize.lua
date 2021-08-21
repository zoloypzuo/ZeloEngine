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
TheFrontEnd:LoadPanel("main_panel")

-- ground
do
    local plane = SpawnPrefab("plane")
    plane.components.transform:SetPosition(-5, -2, 0)
    plane.components.transform:SetScale(10, 1, 10)
end
do
    local plane = SpawnPrefab("plane")
    plane.components.transform:SetPosition(5, -2, 0)
    plane.components.transform:SetScale(10, 1, 10)
end
do
    local plane = SpawnPrefab("plane")
    plane.components.transform:SetPosition(-5, -2, 10)
    plane.components.transform:SetScale(10, 1, 10)
end
do
    local plane = SpawnPrefab("plane")
    plane.components.transform:SetPosition(5, -2, 10)
    plane.components.transform:SetScale(10, 1, 10)
end

-- front wall
do
    local plane = SpawnPrefab("plane")
    plane.components.transform:SetPosition(-5, 3, -5)
    plane.components.transform:SetScale(10, 1, 10)
    plane.components.transform:Rotate(1, 0, 0, PI / 2)
end
do
    local plane = SpawnPrefab("plane")
    plane.components.transform:SetPosition(5, 3, -5)
    plane.components.transform:SetScale(10, 1, 10)
    plane.components.transform:Rotate(1, 0, 0, PI / 2)
end

-- back wall
do
    local plane = SpawnPrefab("plane")
    plane.components.transform:SetPosition(-5, 3, 15)
    plane.components.transform:SetScale(10, 1, 10)
    plane.components.transform:Rotate(1, 0, 0, -PI / 2)
end
do
    local plane = SpawnPrefab("plane")
    plane.components.transform:SetPosition(5, 3, 15)
    plane.components.transform:SetScale(10, 1, 10)
    plane.components.transform:Rotate(1, 0, 0, -PI / 2)
end

-- left wall
do
    local plane = SpawnPrefab("plane")
    plane.components.transform:SetPosition(-10, 3, 0)
    plane.components.transform:SetScale(10, 1, 10)
    plane.components.transform:Rotate(0, 0, 1, -PI / 2)
end
do
    local plane = SpawnPrefab("plane")
    plane.components.transform:SetPosition(-10, 3, 10)
    plane.components.transform:SetScale(10, 1, 10)
    plane.components.transform:Rotate(0, 0, 1, -PI / 2)
end

-- right wall
do
    local plane = SpawnPrefab("plane")
    plane.components.transform:SetPosition(10, 3, 0)
    plane.components.transform:SetScale(10, 1, 10)
    plane.components.transform:Rotate(0, 0, 1, PI / 2)
end
do
    local plane = SpawnPrefab("plane")
    plane.components.transform:SetPosition(10, 3, 10)
    plane.components.transform:SetScale(10, 1, 10)
    plane.components.transform:Rotate(0, 0, 1, PI / 2)
end

--do
--    local monkey = SpawnPrefab("monkey")
--end

--do
-- for i=0,10 do
--     local monkey = SpawnPrefab("monkey")
--     monkey.components.transform:SetPosition(0, i * 3, -2.5)
-- end
--end

do
    local avatar = SpawnPrefab("monkey")
    avatar.components.transform:SetPosition(0, 0, 5)
    avatar.components.transform:SetScale(0.8, 0.8, 0.8)

    local camera = avatar.entity:AddCamera()
    camera.fov = PI / 2
    camera.aspect = 800 / 600
    camera.zNear = 0.05
    camera.zFar = 100

    local attenuation = Attenuation.new()
    attenuation.constant = 0
    attenuation.linear = 0
    attenuation.exponent = 0.2
    local spotLight = avatar.entity:AddSpotLight()
    spotLight.color = vec3.new(1, 1, 1)
    spotLight.intensity = 2.8
    spotLight.cutoff = 0.7
    spotLight.attenuation = attenuation

    avatar.entity:AddFreeMove()
    avatar.entity:AddFreeLook()

    TheSim:SetActiveCamera(camera)
end

do
    local sun = SpawnPrefab("monkey")
    sun.components.transform:SetPosition(-2, 4, -1)
    local light = sun.entity:AddDirectionalLight()
    light.color = vec3.new(1)
    light.intensity = 2.8
end