-- Sandbox.lua

--local Sandbox = require("api/Sandbox")

function Sandbox_Cleanup(sandbox)

end

function Sandbox_HandleEvent(sandbox, event)
    -- 判定输入
    if (event.source == "keyboard" and event.pressed and event.key == "space_key") then
        local block = Sandbox.CreateObject(sandbox, "models/nobiax_modular/modular_block.mesh")

        -- 获得相机位置和朝向
        -- 设置方块，从屏幕中心（即相机位置）向前方（即相机朝向）放射
        local cameraPosition = Sandbox.GetCameraPosition(sandbox)
        local cameraForward = Sandbox.GetCameraForward(sandbox)
        local blockPosition = cameraPosition + cameraForward * 2
        local rotation = Sandbox.GetCameraOrientation(sandbox)

        Core.SetMass(block, 15)
        Core.SetPosition(block, blockPosition)
        Core.SetRotation(block, rotation)

        -- 施加冲量
        Core.ApplyImpulse(block, cameraForward * 15000)
        Core.ApplyAngularImpulse(block, Sandbox.GetCameraLeft(sandbox) * 10)
    end
end

function Sandbox_Initialize(sandbox)
    -- 创建平面，指定宽度，高度；并创建半空间并添加到物理模拟中
    local plane = Sandbox.CreatePlane(sandbox, 200, 200)
    -- 设置ogre材质，于media/materials/base.material中定义
    Core.SetMaterial(plane, "Ground2")

    -- ...
    -- 创建平行光，指定方向
    -- 方向为斜向下
    local directional = Core.CreateDirectionalLight(sandbox, Vector.new(1, -1, 1))
    -- 设置漫反射和高光颜色
    -- 他说分量值是大于1的，我不理解
    Core.SetLightDiffuse(directional, Vector.new(1.8, 1.4, 0.9))
    Core.SetLightSpecular(directional, Vector.new(1.8, 1.4, 0.9))

    -- ...
    -- 创建天空盒，指定材质名和rotation，以欧拉角，以角度
    -- 天空盒的ogre材质位于media/materials/skybox.material
    Sandbox.CreateSkyBox(sandbox, "ThickCloudsWaterSkyBox", Vector.new(0, 180, 0));

    -- ...
    local mesh = Core.CreateMesh(sandbox, "models/nobiax_modular/modular_block.mesh")
    Core.SetPosition(mesh, Vector.new(0, 1, 0))
    Core.SetRotation(mesh, Vector.new(0, 45, 0))

    -- ...
    local object = Sandbox.CreateObject(sandbox, "models/nobiax_modular/modular_block.mesh")
    Core.SetMass(object, 15)
    Core.SetPosition(object, Vector.new(0, 1, 0))
    Core.SetRotation(object, Vector.new(0, 45, 0))

    -- ...
    local agent = Sandbox.CreateAgent(sandbox, "Tutorial for EmmyDoc.lua")
end

function Sandbox_Update(sandbox, deltaTimeInMillis)

end
