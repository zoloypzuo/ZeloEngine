--[[
  Copyright (c) 2013 David Young dayoung@goliathdesigns.com

  This software is provided 'as-is', without any express or implied
  warranty. In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
]]

require "DebugUtilities";
require "GUI";

local ui;

-- Default path to assign to path following agents.
local k_waypoints = {
    Vector.new(0, 0, 0),
    Vector.new(30, 0, 0),
    Vector.new(30, 0, 50),
    Vector.new(-30, 0, 0),
    Vector.new(-30, 0, 20) };

local function CreateSandboxText(sandbox)
    -- Create a UI component to display text on.
    ui = Sandbox.CreateUIComponent(sandbox, 1);
    local width = Sandbox.GetScreenWidth(sandbox);
    local height = Sandbox.GetScreenHeight(sandbox);
    local uiWidth = 300;
    local uiHeight = 180;

    UI.SetPosition(ui, width - uiWidth - 20, height - uiHeight - 35);
    UI.SetDimensions(ui, uiWidth, uiHeight);
    UI.SetTextMargin(ui, 10, 10);
    GUI_SetGradientColor(ui);

    UI.SetMarkupText(
            ui,
            GUI.MarkupColor.White .. GUI.Markup.SmallMono ..
                    "W/A/S/D: to move" .. GUI.MarkupNewline ..
                    "Hold Shift: to accelerate movement" .. GUI.MarkupNewline ..
                    "Hold RMB: to look" .. GUI.MarkupNewline ..
                    GUI.MarkupNewline ..
                    "Space: shoot block" .. GUI.MarkupNewline ..
                    GUI.MarkupNewline ..
                    "F1: to reset the camera" .. GUI.MarkupNewline ..
                    "F2: toggle the menu" .. GUI.MarkupNewline ..
                    "F5: toggle performance information" .. GUI.MarkupNewline ..
                    "F6: toggle camera information" .. GUI.MarkupNewline ..
                    "F7: toggle physics debug" .. [[	1. 按住右键调整相机方向
wsad移动，shift加速]]);
end

function Sandbox_Cleanup(sandbox)
end

function Sandbox_HandleEvent(sandbox, event)
    -- Pass events into the UI system.
    GUI_HandleEvent(sandbox, event);

    if (event.source == "keyboard" and event.pressed) then
        if (event.key == "f1_key") then
            Sandbox.SetCameraPosition(sandbox, Vector.new(-30, 5, 7));
            Sandbox.SetCameraOrientation(sandbox, Vector.new(-131, -68, -133));
        elseif (event.key == "f2_key") then
            UI.SetVisible(ui, not UI.IsVisible(ui));
        elseif (event.key == "space_key") then
            local block = Sandbox.CreateObject(
                    sandbox,
                    "models/nobiax_modular/modular_block.mesh");

            local cameraPosition = Sandbox.GetCameraPosition(sandbox);

            -- Normalized forward camera vector.
            local cameraForward = Sandbox.GetCameraForward(sandbox);

            -- Offset the block’s position in front of the camera.
            local blockPosition = cameraPosition + cameraForward * 2;

            local rotation = Sandbox.GetCameraOrientation(sandbox);

            Core.SetMass(block, 15);
            Core.SetRotation(block, rotation);
            Core.SetPosition(block, blockPosition);

            -- Applies instantaneous force for only one update tick.
            Core.ApplyImpulse(
                    block, Vector.new(cameraForward * 15000));

            -- Applies instantaneous angular force for one update 
            -- tick.  In this case blocks will always spin forwards  
            -- regardless where the camera is looking. 
            Core.ApplyAngularImpulse(
                    block, Sandbox.GetCameraLeft(sandbox) * 10);
        end
    end
end

function Sandbox_Initialize(sandbox)
    -- 缓存资源，这里不如说是预载资源，这样第一次访问时从缓存取，没有延迟，这应该是一个重要的大资源
    -- Caching a resource prevents a slowdown when the mesh/material/etc is
    -- first encountered.
    Core.CacheResource("models/nobiax_modular/modular_block.mesh");

    --
    -- Create the demo specific UI, and default UI.（创建默认ui）
    --
    GUI_CreateUI(sandbox);
    -- 显示快捷键提示文本
    CreateSandboxText(sandbox);

    --
    -- Set an initial camera position and orientation.
    --
    Sandbox.SetCameraPosition(sandbox, Vector.new(-30, 5, 7));
    Sandbox.SetCameraOrientation(sandbox, Vector.new(-131, -68, -133));

    --
    -- 场景中的环境
    --

    -- skybox
    Sandbox.CreateSkyBox(
            sandbox, "ThickCloudsWaterSkyBox", Vector.new(0, 180, 0));

    -- 一个大平面
    -- When creating a plane from the Sandbox module this will attach a physics
    -- representation to the graphics representation.
    -- NOTE: A plane in the physics world is infinite in all directions.
    local plane = Sandbox.CreatePlane(sandbox, 200, 200);
    Core.SetMaterial(plane, "Ground2");

    -- 光照
    -- Set the ambient light color.
    Sandbox.SetAmbientLight(sandbox, Vector.new(0.3));

    -- Create a Directional light for the sun.
    local directional = Core.CreateDirectionalLight(sandbox, Vector.new(1, -1, 1));

    -- Color is represented by a red, green, and blue vector.
    Core.SetLightDiffuse(directional, Vector.new(1.8, 1.4, 0.9));
    Core.SetLightSpecular(directional, Vector.new(1.8, 1.4, 0.9));

    --
    -- 智能体
    --

    -- Create an initial random seeking agent.
    Sandbox.CreateAgent(sandbox, "SeekingAgent.lua");

    -- Create a pursuing agent to follow the seeking agent.
    Sandbox.CreateAgent(sandbox, "PursuingAgent.lua");

    -- Create a group of followers that follow the seeking agent.
    for i = 1, 5 do
        Sandbox.CreateAgent(sandbox, "FollowerAgent.lua");
    end

    -- Create pathing agents with various speeds.
    for i = 1, 20 do
        local agent = Sandbox.CreateAgent(sandbox, "PathingAgent.lua");

        -- Assign the same path to every agent.
        agent:SetPath(k_waypoints, true);

        -- Randomly vary speeds to allow agents to pass one another.
        local randomSpeed = math.random(
                agent:GetMaxSpeed() * 0.85,
                agent:GetMaxSpeed() * 1.15);

        agent:SetMaxSpeed(randomSpeed);
    end
end

function Sandbox_Update(sandbox, deltaTimeInMillis)
    -- Update the default UI.
    GUI_UpdateUI(sandbox);

    -- Grab all Sandbox objects, not including agents.
    local objects = Sandbox.GetObjects(sandbox);

    -- Draw debug bounding sphere representations for objects with mass.
    DebugUtilities_DrawDynamicBoundingSpheres(objects);
end
