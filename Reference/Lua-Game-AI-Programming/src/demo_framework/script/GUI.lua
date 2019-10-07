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

GUI = {};

GUI.Fonts ={};

GUI.Fonts.Small =           "small";
GUI.Fonts.SmallMono =       "small_mono";
GUI.Fonts.Medium =          "medium";
GUI.Fonts.MediumMono =      "medium_mono";
GUI.Fonts.Large =           "large";
GUI.Fonts.LargeMono =       "large_mono";

GUI.Markup = {};

GUI.Markup.Small =          "%@9%";
GUI.Markup.SmallMono =      "%@91%";
GUI.Markup.Medium =         "%@14%";
GUI.Markup.MediumMono =     "%@141%";
GUI.Markup.Large =          "%@24%";
GUI.Markup.LargeMono =      "%@241%";

GUI.MarkupNewline = "\n";

GUI.MarkupColor = {};

GUI.MarkupColor.White =     "%0";
GUI.MarkupColor.Red =       "%1";
GUI.MarkupColor.Green =     "%2";
GUI.MarkupColor.Blue =      "%3";
GUI.MarkupColor.Yellow =    "%4";
GUI.MarkupColor.Purple =    "%5";
GUI.MarkupColor.Teal =      "%6";
GUI.MarkupColor.Orange =    "%7";
GUI.MarkupColor.Gray =      "%8";
GUI.MarkupColor.Black =     "%9";

GUI.MarkupColorTable = {};
GUI.MarkupColorTable[0] =    { r = 1.0,  g = 1.0,  b = 1.0,  a = 1.0 };
GUI.MarkupColorTable[1] =    { r = 1.0,  g = 0.0,  b = 0.0,  a = 1.0 };
GUI.MarkupColorTable[2] =    { r = 0.0,  g = 1.0,  b = 0.0,  a = 1.0 };
GUI.MarkupColorTable[3] =    { r = 0.0,  g = 0.0,  b = 1.0,  a = 1.0 };
GUI.MarkupColorTable[4] =    { r = 1.0,  g = 1.0,  b = 0.0,  a = 1.0 };
GUI.MarkupColorTable[5] =    { r = 1.0,  g = 0.0,  b = 1.0,  a = 1.0 };
GUI.MarkupColorTable[6] =    { r = 0.0,  g = 1.0,  b = 1.0,  a = 1.0 };
GUI.MarkupColorTable[7] =    { r = 1.0,  g = 0.65, b = 0.0,  a = 1.0 };
GUI.MarkupColorTable[8] =    { r = 0.75, g = 0.75, b = 0.75, a = 1.0 };
GUI.MarkupColorTable[9] =    { r = 0.0,  g = 0.0,  b = 0.0,  a = 1.0 };

GUI.Palette = {};

GUI.Palette.DarkBlueGradient =      { r = 0, g = 0.2, b = 0.4, a = 0.5 };
GUI.Palette.DarkBlackGradient =     { r = 0.1, g = 0.1, b = 0.1, a = 0.6 };

local _cameraUI;
local _profileUI;

local _averageRenderTimes = {};
local _averageSimTimes = {};
local _averageTotalSimTimes = {};

local function _ColorValue(value, mediumValue, lowValue)
    if (value <= lowValue) then
        return GUI.MarkupColor.Red;
    elseif (value <= mediumValue) then
        return GUI.MarkupColor.Orange;
    end
    
    return GUI.MarkupColor.Green;
end

local function _ComputeNewTime(times, newTime)
    table.insert(times, newTime);
    
    if (#times > 15) then
        table.remove(times, 1);
    end
    
    local averageTime = 0;
    
    for index=1, #times do
        averageTime = averageTime + times[index];
    end
    
    return averageTime / #times;
end

local function _SetupMarkupColorTable(sandbox)
    for key, value in pairs(GUI.MarkupColorTable) do
        Sandbox.SetMarkupColor(sandbox, key, value.r, value.g, value.b, value.a);
    end
end

function GUI_CreateCameraInformation(sandbox)
    _cameraUI = Sandbox.CreateUIComponent(sandbox, 1);
    local width = Sandbox.GetScreenWidth(sandbox);
    local height = Sandbox.GetScreenHeight(sandbox);
    local uiWidth = 300;
    local uiHeight = 135;
    
    UI.SetPosition(_cameraUI, width - uiWidth - 20, 30 + uiHeight);
    UI.SetDimensions(_cameraUI, uiWidth, uiHeight);
    UI.SetTextMargin(_cameraUI, 10, 10);
    UI.SetVisible(_cameraUI, false);
    GUI_SetGradientColor(_cameraUI);
    
    GUI_UpdateCameraInformation(sandbox, _cameraUI);
    
    return _cameraUI;
end

function GUI_CreateProfileInformation(sandbox)
    _profileUI = Sandbox.CreateUIComponent(sandbox, 1);
    local width = Sandbox.GetScreenWidth(sandbox);
    local height = Sandbox.GetScreenHeight(sandbox);
    local uiWidth = 300;
    local uiHeight = 125;
    
    UI.SetPosition(_profileUI, width - uiWidth - 20, 20);
    UI.SetDimensions(_profileUI, uiWidth, uiHeight);
    UI.SetTextMargin(_profileUI, 10, 10);
    UI.SetVisible(_profileUI, false);
    GUI_SetGradientColor(_profileUI);
    
    GUI_UpdateProfileInformation(sandbox, _profileUI);
    
    return _profileUI;
end

function GUI_CreateUI(sandbox)
    _SetupMarkupColorTable(sandbox);
    GUI_CreateCameraInformation(sandbox);
    GUI_CreateProfileInformation(sandbox);
end

function GUI_HandleEvent(sandbox, event)
    if (event.source == "keyboard" and event.pressed) then
        if (event.key == "f5_key") then
            UI.SetVisible(_profileUI, not UI.IsVisible(_profileUI));
        elseif (event.key == "f6_key") then
            UI.SetVisible(_cameraUI, not UI.IsVisible(_cameraUI));
        elseif (event.key == "f7_key") then
            local drawDebug = Sandbox.GetDrawPhysicsWorld(sandbox);
            Sandbox.SetDrawPhysicsWorld(sandbox, not drawDebug);
        end
    end
end

function GUI_OrientTowardCamera(sandbox, ui, position)
    local cameraVec = Sandbox.GetCameraPosition(sandbox) - position;
    cameraVec.y = 0;

    local forwardVec = Vector.Normalize(cameraVec);
    local dotProduct = Vector.DotProduct(forwardVec, Vector.new(0, 0, 1));
    local crossProduct = Vector.CrossProduct(forwardVec, Vector.new(0, 0, 1));

    local yRotation = math.deg(math.acos(dotProduct));

    if (crossProduct.y > 0) then
        yRotation = yRotation * -1;
    end

    UI.SetWorldRotation(ui, Vector.new(0, yRotation, 0));
    UI.SetWorldPosition(ui, position);
end

function GUI_SetGradientColor(ui)
    UI.SetGradientColor(
        ui,
        "north_south",
        GUI.Palette.DarkBlueGradient.r,
        GUI.Palette.DarkBlueGradient.g,
        GUI.Palette.DarkBlueGradient.b,
        GUI.Palette.DarkBlueGradient.a,
        GUI.Palette.DarkBlackGradient.r,
        GUI.Palette.DarkBlackGradient.g,
        GUI.Palette.DarkBlackGradient.b,
        GUI.Palette.DarkBlackGradient.a);
end

function GUI_UpdateCameraInformation(sandbox)
    if (not UI.IsVisible(_cameraUI)) then
        return;
    end

    local forward = Sandbox.GetCameraForward(sandbox);
    local rotation = Sandbox.GetCameraOrientation(sandbox);
    local position = Sandbox.GetCameraPosition(sandbox);
    local left = Sandbox.GetCameraLeft(sandbox);
    local up = Sandbox.GetCameraUp(sandbox);

    local cameraInfo = GUI.Markup.SmallMono ..
    "Camera Information:" .. GUI.MarkupNewline ..
    GUI.MarkupNewline ..
    string.format("  Position: |%7.2f, %7.2f, %7.2f |", position.x, position.y, position.z) ..
    GUI.MarkupNewline ..
    string.format("  Rotation: |%7.2f, %7.2f, %7.2f |", rotation.x, rotation.y, rotation.z) ..
    GUI.MarkupNewline ..
    GUI.MarkupNewline ..
    string.format("  Left:     |%7.2f, %7.2f, %7.2f |", left.x, left.y, left.z) ..
    GUI.MarkupNewline ..
    string.format("  Up:       |%7.2f, %7.2f, %7.2f |", up.x, up.y, up.z) ..
    GUI.MarkupNewline ..
    string.format("  Forward:  |%7.2f, %7.2f, %7.2f |", forward.x, forward.y, forward.z);

    UI.SetMarkupText(_cameraUI, GUI.MarkupColor.White .. cameraInfo);
end

function GUI_UpdateProfileInformation(sandbox)
    if (not UI.IsVisible(_profileUI)) then
        return;
    end

    local renderTime = _ComputeNewTime(
        _averageRenderTimes, Sandbox.GetRenderTime(sandbox)) / 1000;
    local simTime = _ComputeNewTime(
        _averageSimTimes, Sandbox.GetSimulationTime(sandbox)) / 1000;
    local totalSimTime = _ComputeNewTime(
        _averageTotalSimTimes, Sandbox.GetTotalSimulationTime(sandbox)) / 1000;

    local fps = 1000 / renderTime;
    local simSteps = 1000 / totalSimTime;

    local profileInfo = GUI.Markup.SmallMono ..
    "Performance Information:" .. GUI.MarkupNewline ..
    GUI.MarkupNewline ..    
    string.format(
        "  Frames per Second:        %s%7.0f%s",
        _ColorValue(fps, 45, 25),
        fps,
        GUI.MarkupColor.White) ..
    GUI.MarkupNewline ..
    string.format("  Render Time:              %7.2f ms", renderTime) ..
    GUI.MarkupNewline ..
    GUI.MarkupNewline ..
    string.format(
        "  Steps per Second:         %s%7.0f%s (30)",
        _ColorValue(simSteps, 25, 15),
        simSteps,
        GUI.MarkupColor.White) ..
    GUI.MarkupNewline ..
    string.format("  Simulation Time:          %7.2f ms", simTime);

    UI.SetMarkupText(_profileUI, GUI.MarkupColor.White .. profileInfo);
end

function GUI_UpdateUI(sandbox)
    GUI_UpdateCameraInformation(sandbox);
    GUI_UpdateProfileInformation(sandbox);
end