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

require "GUI"
require "SandboxUtilities"

local ui;

local k_hint = [[
W/A/S/D: to move 
Hold Shift: to accelerate movement 
Hold RMB: to look 

Space: shoot block

F1: to reset the camera
F2: toggle the menu 
F5: toggle performance information 
F6: toggle camera information 
F7: toggle physics debug);]]

local k_scene_config = {
    -- misc meshes
    { "modular_block", -3, 0, 0 },
    { "modular_cooling", -3, 0, 3 },
    { "modular_roof", -2, 0, -4 },

    -- brick meshes
    { "modular_pillar_brick_3", -1, 0, 0 },
    { "modular_pillar_brick_2", -1, 0, 3 },
    { "modular_pillar_brick_1", -1, 0, 6 },
    { "modular_brick_door", 1, 0, 0 },
    { "modular_brick_double_window", 4, 0, 0 },
    { "modular_brick_small_double_window", 7, 0, 0 },
    { "modular_brick_small_window_1", 10, 0, 0 },
    { "modular_brick_window_1", 13, 0, 0 },
    { "modular_brick_small_window_2", 16, 0, 0 },
    { "modular_brick_window_2", 18, 0, 0 },
    { "modular_wall_brick_1", 1, 0, -6 },
    { "modular_wall_brick_2", 4, 0, -6 },
    { "modular_wall_brick_3", 6, 0, -6 },
    { "modular_wall_brick_4", 8, 0, -6 },
    { "modular_wall_brick_5", 11, 0, -6 },

    -- concrete meshes
    { "modular_pillar_concrete_3", -2, 0, 0 },
    { "modular_pillar_concrete_2", -2, 0, 3 },
    { "modular_pillar_concrete_1", -2, 0, 6 },
    { "modular_concrete_door", 1, 0, 3 },
    { "modular_concrete_double_window", 4, 0, 3 },
    { "modular_concrete_small_double_window", 7, 0, 3 },
    { "modular_concrete_small_window_1", 10, 0, 3 },
    { "modular_concrete_window_1", 13, 0, 3 },
    { "modular_concrete_small_window_2", 16, 0, 3 },
    { "modular_concrete_window_2", 18, 0, 3 },
    { "modular_wall_concrete_1", 1, 0, -3 },
    { "modular_wall_concrete_2", 4, 0, -3 },
    { "modular_wall_concrete_3", 6, 0, -3 },
    { "modular_wall_concrete_4", 8, 0, -3 },
    { "modular_wall_concrete_5", 11, 0, -3 },

    -- metal meshes
    { "modular_hangar_door", 1, 0, 6 },
}

local function load_scene(sandbox, scene_config)
    for _, v in pairs(scene_config) do
        --name, x, y, z = table.unpack(v) lua 5.1 has no unpack
        name = v[1]
        x = v[2]
        y = v[3]
        z = v[4]
        SandboxUtilities_CreateObject(sandbox, name, Vector.new(x, y, z))
    end
end

local function CreateSandboxText(sandbox)
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
            GUI.MarkupColor.White .. GUI.Markup.SmallMono .. k_hint)
end

function Sandbox_Cleanup(sandbox)
end

function Sandbox_HandleEvent(sandbox, event)
    GUI_HandleEvent(sandbox, event);

    if (event.source == "keyboard" and event.pressed) then
        if (event.key == "f1_key") then
            Sandbox.SetCameraPosition(sandbox, Vector.new(7, 5, -18));
            Sandbox.SetCameraOrientation(sandbox, Vector.new(-160, 0, -180));
        elseif (event.key == "f2_key") then
            UI.SetVisible(ui, not UI.IsVisible(ui));
        elseif (event.key == "space_key") then
            SandboxUtilities_ShootBox(sandbox);
        end
    end
end

function Sandbox_Initialize(sandbox)
    GUI_CreateUI(sandbox);
    CreateSandboxText(sandbox);

    -- Initialize the camera position to focus on the soldier.
    Sandbox.SetCameraPosition(sandbox, Vector.new(7, 5, -18));
    Sandbox.SetCameraOrientation(sandbox, Vector.new(-160, 0, -180));

    Sandbox.CreateSkyBox(
            sandbox, "ThickCloudsWaterSkyBox", Vector.new(0, 180, 0));

    -- Create Lighting.
    Sandbox.SetAmbientLight(sandbox, Vector.new(0.3));

    local directional = Core.CreateDirectionalLight(sandbox, Vector.new(1, -1, 1));
    Core.SetLightDiffuse(directional, Vector.new(1.8, 1.4, 0.9));
    Core.SetLightSpecular(directional, Vector.new(1.8, 1.4, 0.9));

    local plane = Sandbox.CreatePlane(sandbox, 200, 200);
    Core.SetRotation(plane, Vector.new(0, 0, 0));
    Core.SetPosition(plane, Vector.new(0, 0, 0));
    Core.SetMaterial(plane, "Ground2");

    load_scene(sandbox, k_scene_config)
end

function Sandbox_Update(sandbox, deltaTimeInMillis)
    GUI_UpdateUI(sandbox);
end
