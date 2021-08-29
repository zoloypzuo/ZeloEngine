-- scene01
-- created on 2021/8/24
-- author @zoloypzuo
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
    spotLight.color = Vector3(1, 1, 1)
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