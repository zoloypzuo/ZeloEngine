require "GUI"
require "SandboxUtilities"
require "Soldier/Soldier"

local _ui;
local _ui3ds = {};

local function _CreateSandboxText(sandbox)
    local ui = Sandbox.CreateUIComponent(sandbox, 1);
    local width = Sandbox.GetScreenWidth(sandbox);
    local height = Sandbox.GetScreenHeight(sandbox);
    local uiWidth = 300;
    local uiHeight = 280;

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
                    "F3: spawn a direct controlled soldier" .. GUI.MarkupNewline ..
                    "F4: spawn an indirect controlled soldier" .. GUI.MarkupNewline ..
                    "F5: toggle performance information" .. GUI.MarkupNewline ..
                    "F6: toggle camera information" .. GUI.MarkupNewline ..
                    "F7: toggle physics debug" .. GUI.MarkupNewline ..
                    GUI.MarkupNewline ..
                    "Switch Agents to:" .. GUI.MarkupNewline ..
                    "  Num 1: idle state" .. GUI.MarkupNewline ..
                    "  Num 2: shooting state" .. GUI.MarkupNewline ..
                    "  Num 3: moving state" .. GUI.MarkupNewline ..
                    "  Num 4: death state" .. GUI.MarkupNewline ..
                    "  Num 5: stand/crouch stance" .. GUI.MarkupNewline);

    return ui;
end

local function _InitializeAgent(agent)
    -- Randomly assign a position to the agent.
    agent:SetPosition(agent:GetPosition() +
            Vector.new(0, agent:GetHeight() / 2, 10) +
            Vector.new(math.random(-5, 5), 0, math.random(-5, 5)));

    -- Assign the same static cyclic path to all soldier agents.
    Soldier_SetPath(agent, SandboxUtilities_GetLevelPath(), true);
end

function Sandbox_Cleanup(sandbox)
end

function Sandbox_HandleEvent(sandbox, event)
    GUI_HandleEvent(sandbox, event);

    if (event.source == "keyboard" and event.pressed) then
        if (event.key == "f1_key") then
            -- Reset the camera position.
            Sandbox.SetCameraPosition(sandbox, Vector.new(-17, 10, 0));
            Sandbox.SetCameraOrientation(sandbox, Vector.new(-145, -50, -150));
        elseif (event.key == "f2_key") then
            UI.SetVisible(_ui, not UI.IsVisible(_ui));
        elseif (event.key == "f3_key") then
            -- Create a direct controlled agent.
            local agent = Sandbox.CreateAgent(sandbox, "MindBodyControl/DirectSoldierAgent.lua");

            _InitializeAgent(agent);
        elseif (event.key == "f4_key") then
            -- Create an indirect controlled agent.
            local agent = Sandbox.CreateAgent(sandbox, "MindBodyControl/IndirectSoldierAgent.lua");

            _InitializeAgent(agent);
        end
    end
end

function Sandbox_Initialize(sandbox)
    -- Setup the demo UI menu.
    GUI_CreateUI(sandbox);
    _ui = _CreateSandboxText(sandbox);

    -- Initialize the camera position to focus on the soldier.
    Sandbox.SetCameraPosition(sandbox, Vector.new(-17, 10, 0));
    Sandbox.SetCameraOrientation(sandbox, Vector.new(-145, -50, -150));

    -- Create the sandbox level, handles creating geometry, skybox, and lighting.
    SandboxUtilities_CreateLevel(sandbox);
end

function Sandbox_Update(sandbox, deltaTimeInMillis)
    -- Update the default UI.
    GUI_UpdateUI(sandbox);
end
