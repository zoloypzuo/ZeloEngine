require "DebugUtilities"
require "SandboxUtilities"

require "GUI"

-- 我写的，因为SoldierLogic是demo-framework里的脚本
-- 现在，SoldierAction和SoldierEvaluator在c6和demo-frame work里是不一样的，没有黑板逻辑，你没区分的话，就会运行时错误
IS_CHAPTER_6 = true

local _drawNavMesh;
local _ui;

local _agents = {};

local function _CreateSandboxText(sandbox)
    local ui = Sandbox.CreateUIComponent(sandbox, 1);
    local width = Sandbox.GetScreenWidth(sandbox);
    local height = Sandbox.GetScreenHeight(sandbox);
    local uiWidth = 300;
    local uiHeight = 160;

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
                    "F1: to reset the camera" .. GUI.MarkupNewline ..
                    "F2: toggle the menu" .. GUI.MarkupNewline ..
                    "F3: toggle the navigation mesh" .. GUI.MarkupNewline ..
                    "F5: toggle performance information" .. GUI.MarkupNewline ..
                    "F6: toggle camera information" .. GUI.MarkupNewline ..
                    "F7: toggle physics debug");

    return ui;
end

function Sandbox_Cleanup(sandbox)
end

function Sandbox_HandleEvent(sandbox, event)
    GUI_HandleEvent(sandbox, event);

    if (event.source == "keyboard" and event.pressed) then
        if (event.key == "f1_key") then
            Sandbox.SetCameraPosition(sandbox, Vector.new(-30, 18, -17));
            Sandbox.SetCameraOrientation(sandbox, Vector.new(-146, -40, -157));
        elseif (event.key == "f2_key") then
            UI.SetVisible(_ui, not UI.IsVisible(_ui));
        elseif (event.key == "f3_key") then
            _drawNavMesh = not _drawNavMesh;
            Sandbox.SetDebugNavigationMesh(sandbox, "default", _drawNavMesh);
        end
    end
end

function Sandbox_Initialize(sandbox)
    -- Setup the demo UI menu.
    GUI_CreateUI(sandbox);
    _ui = _CreateSandboxText(sandbox);

    -- Initialize the camera position to focus on the soldier.
    Sandbox.SetCameraPosition(sandbox, Vector.new(-30, 18, -17));
    Sandbox.SetCameraOrientation(sandbox, Vector.new(-146, -40, -157));

    -- Create the sandbox level, handles creating geometry, skybox, and lighting.
    SandboxUtilities_CreateLevel(sandbox);

    -- Override the default navigation mesh config generation, prevent 
    local navMeshConfig = {
        MinimumRegionArea = 250,
        WalkableRadius = 0.4,
        WalkableClimbHeight = 0.2,
        WalkableSlopeAngle = 45 };

    _drawNavMesh = true;
    Sandbox.CreateNavigationMesh(sandbox, "default", navMeshConfig);
    Sandbox.SetDebugNavigationMesh(sandbox, "default", true);

    -- Create agents and randomly place them on the navmesh.
    for i = 1, 7 do
        local agent = Sandbox.CreateAgent(sandbox, "IndirectSoldierAgent.lua");
        table.insert(_agents, agent);

        local randomPosition = Sandbox.RandomPoint(sandbox, "default");
        agent:SetPosition(randomPosition);
        agent:SetTarget(randomPosition);
    end
end

function Sandbox_Update(sandbox, deltaTimeInMillis)
    -- Update the default UI.
    GUI_UpdateUI(sandbox);
end
