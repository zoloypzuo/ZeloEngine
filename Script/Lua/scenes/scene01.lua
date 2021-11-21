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

-- monkeys
do
    -- put one at origin
    local monkey0 = SpawnPrefab("monkey")
    monkey0.name = "origin"
    
    for i = 0, 10 do
        local monkey = SpawnPrefab("monkey")
        monkey.components.transform:SetPosition(2, i * 3, 0.5)
    end
end

-- lights
do
    -- sun
    local sun = SpawnPrefab("monkey")
    sun.name = "sun"
    sun.components.transform:SetPosition(-3.000, 17.000, 7.000)
    local light = sun.entity:AddLight()
    light.Type = ELightType.DIRECTIONAL
    light.Color = Vector3(1, 1, 1)
    light.Intensity = 1.5

end

do
    local avatar = SpawnPrefab("monkey")
    avatar.name = "avatar"
    avatar.components.transform:SetPosition(0, 0, 5)
    avatar.components.transform:SetScale(0.8, 0.8, 0.8)

    local camera = avatar.entity:AddCamera()
    camera.fov = PI / 2
    camera.aspect = 800 / 600
    camera.zNear = 0.05
    camera.zFar = 100

    avatar.entity:AddFreeMove()
    avatar.entity:AddFreeLook()

    local spotLight = avatar.entity:AddLight()
    --    POINT = 0,
    -- DIRECTIONAL = 1,
    -- SPOT = 2,
    -- AMBIENT_BOX = 3,
    -- AMBIENT_SPHERE = 4
    spotLight.Type = ELightType.SPOT
    spotLight.Color = Vector3(1, 1, 1)
    spotLight.Intensity = 100
    spotLight.Linear = 20

    TheSim:SetActiveCamera(camera)
end
