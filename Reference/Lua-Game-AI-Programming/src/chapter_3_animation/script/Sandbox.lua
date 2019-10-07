require "AnimationStateMachine"
require "AnimationUtilities"
require "SandboxUtilities"
require "GUI"

local soldierAsm;
local weaponAsm;
local weaponState = "sniper";
local ui;
local cameraUi;
local displaySkeleton;

local function CreateSandboxText(sandbox)
    ui = Sandbox.CreateUIComponent(sandbox, 1);
    local width = Sandbox.GetScreenWidth(sandbox);
    local height = Sandbox.GetScreenHeight(sandbox);
    local uiWidth = 300;
    local uiHeight = 300;
    
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
        "F3: toggle skeleton" .. GUI.MarkupNewline ..
        "F5: toggle performance information" .. GUI.MarkupNewline ..
        "F6: toggle camera information" .. GUI.MarkupNewline ..
        "F7: toggle physics debug" .. GUI.MarkupNewline ..
        GUI.MarkupNewline ..
        "Num 1: melee animation" .. GUI.MarkupNewline ..
        "Num 2: sniper reload animation" .. GUI.MarkupNewline ..
        "Num 3: sniper transform to smg animation" .. GUI.MarkupNewline ..
        "Num 4: smg transform to sniper animation" .. GUI.MarkupNewline ..
        "Num 5: fire animation" .. GUI.MarkupNewline ..
        "Num 6: run forward animation" .. GUI.MarkupNewline ..
        "Num 7: run backward animation" .. GUI.MarkupNewline ..
        "Num 8: death animation" .. GUI.MarkupNewline ..
        "Num 9: headshot animation" .. GUI.MarkupNewline);
end

local function IsNumKey(key, numKey)
    -- Match both numpad keys and numeric keys.
    return string.find(key, string.format("^[numpad_]*%d_key$", numKey));
end

function Sandbox_Cleanup(sandbox)
end

function Sandbox_HandleEvent(sandbox, event)
    GUI_HandleEvent(sandbox, event);

    if (event.source == "keyboard" and event.pressed) then
        if (event.key == "f1_key") then
            Sandbox.SetCameraPosition(sandbox, Vector.new(0, 1, -3));
            Sandbox.SetCameraForward(sandbox, Vector.new(0, 0, -1));
        elseif (event.key == "f2_key") then
            UI.SetVisible(ui, not UI.IsVisible(ui));
        elseif (event.key == "f3_key") then
            displaySkeleton = not displaySkeleton;
            Animation.SetDisplaySkeleton(soldier, displaySkeleton);
        elseif (IsNumKey(event.key, 1)) then
            soldierAsm:RequestState("melee");
        elseif (IsNumKey(event.key, 2)) then
            if (weaponState == "sniper" and soldierAsm:RequestState("reload")) then
                weaponAsm:RequestState("sniper_reload");
            end
        elseif (IsNumKey(event.key, 3)) then
            if (weaponState == "sniper") then
                if (soldierAsm:RequestState("smg_transform")) then
                    weaponAsm:RequestState("smg_transform");
                    weaponState = "smg";
                end
            end
        elseif (IsNumKey(event.key, 4)) then
            if (weaponState == "smg") then
                if (soldierAsm:RequestState("sniper_transform")) then
                    weaponAsm:RequestState("sniper_transform");
                    weaponState = "sniper";
                end
            end
        elseif (IsNumKey(event.key, 5)) then
            soldierAsm:RequestState("fire");
        elseif (IsNumKey(event.key, 6)) then
            soldierAsm:RequestState("run_forward");
        elseif (IsNumKey(event.key, 7)) then
            soldierAsm:RequestState("run_backward");
        elseif (IsNumKey(event.key, 8)) then
            soldierAsm:RequestState("dead");
        elseif (IsNumKey(event.key, 9)) then
            soldierAsm:RequestState("dead_headshot");
        end
    end
end

function Sandbox_Initialize(sandbox)
    -- Setup the demo UI menu.
    GUI_CreateUI(sandbox);
    CreateSandboxText(sandbox);

    -- Create a background skybox.
    Sandbox.CreateSkyBox(
        sandbox, "ThickCloudsWaterSkyBox", Vector.new(0, 180, 0));

    -- Create a ground plane with physics.
    local plane = Sandbox.CreatePlane(sandbox, 200, 200);
    Core.SetMaterial(plane, "Ground2");

    -- Helper functions to setup lighting.
    SandboxUtilities_CreateLights(sandbox);

    -- Initialize the camera position to focus on the soldier.
    Sandbox.SetCameraPosition(sandbox, Vector.new(0, 1, -3));
    Sandbox.SetCameraForward(sandbox, Vector.new(0, 0, -1));

    --
    --
    --

    -- Create the basic soldier mesh without a physics representation.
    soldier = Core.CreateMesh(
        sandbox, "models/futuristic_soldier/futuristic_soldier_dark_anim.mesh");

    -- Set the position and rotation to work with the camera's default position.
    Core.SetPosition(soldier, Vector.new(0, 0, 0));
    Core.SetRotation(soldier, Vector.new(0, -90, 0));
    
    -- Toggle on the skeletal debug information.
    displaySkeleton = true;
    Animation.SetDisplaySkeleton(soldier, displaySkeleton);

    -- Create the soldier's weapon mesh.
    local weapon = Core.CreateMesh(
        sandbox, "models/futuristic_soldier/soldier_weapon.mesh");

    -- Retrieve and store the weapon animations before attaching the weapon to
    -- the soldier.
    local sniperIdle = Animation.GetAnimation(weapon, "sniper_idle");
    local smgIdle = Animation.GetAnimation(weapon, "smg_idle");

    --
    -- Create an animation state machine to handle weapon animations.
    --
    weaponAsm = AnimationStateMachine.new();

    weaponAsm:AddState("smg_idle", Animation.GetAnimation(weapon, "smg_idle"), true);
    weaponAsm:AddState("smg_transform", Animation.GetAnimation(weapon, "smg_transform"));
    weaponAsm:AddState("sniper_idle", sniperIdle, true);
    weaponAsm:AddState("sniper_reload", Animation.GetAnimation(weapon, "sniper_reload"));
    weaponAsm:AddState("sniper_transform", Animation.GetAnimation(weapon, "sniper_transform"));

    weaponAsm:AddTransition("sniper_idle", "sniper_reload", Animation.GetLength(sniperIdle), 0.2);
    weaponAsm:AddTransition("sniper_idle", "sniper_transform", Animation.GetLength(sniperIdle), 0.2);
    weaponAsm:AddTransition("sniper_reload", "sniper_idle", 0.2, 0.2);
    weaponAsm:AddTransition("sniper_transform", "sniper_idle", 0.2, 0.2);
    weaponAsm:AddTransition("smg_idle", "smg_transform", Animation.GetLength(smgIdle), 0.2);
    weaponAsm:AddTransition("smg_transform", "smg_idle", 0.2, 0.2);

    -- Request a default looping animation to play.
    weaponAsm:RequestState("sniper_idle");

    local idleAim = Animation.GetAnimation(soldier, "stand_idle_aim");
    local idleAimLength = Animation.GetLength(idleAim);

    --
    -- Create an animation state machine to handle soldier animations.
    --
    soldierAsm = AnimationStateMachine.new();

    soldierAsm:AddState("idle_aim", Animation.GetAnimation(soldier, "stand_idle_aim"), true);
    soldierAsm:AddState("dead", Animation.GetAnimation(soldier, "stand_dead_2"));
    soldierAsm:AddState("dead_headshot", Animation.GetAnimation(soldier, "stand_dead_headshot"));
    soldierAsm:AddState("fire", Animation.GetAnimation(soldier, "stand_fire_one_shot"), true);
    soldierAsm:AddState("melee", Animation.GetAnimation(soldier, "stand_melee_1_with_weapon"));
    soldierAsm:AddState("reload", Animation.GetAnimation(soldier, "stand_reload"));
    soldierAsm:AddState("run_backward", Animation.GetAnimation(soldier, "stand_run_backward_aim"), true);
    soldierAsm:AddState("run_forward", Animation.GetAnimation(soldier, "stand_run_forward_aim"), true);
    soldierAsm:AddState("smg_transform", Animation.GetAnimation(soldier, "stand_smg_transform"));
    soldierAsm:AddState("sniper_transform", Animation.GetAnimation(soldier, "stand_sniper_transform"));

    -- Idle Transitions
    -- All transitions from idle can happen at any time in the idle animation.
    soldierAsm:AddTransition("idle_aim", "dead", idleAimLength, 0.2);
    soldierAsm:AddTransition("idle_aim", "dead_headshot", idleAimLength, 0.2);
    soldierAsm:AddTransition("idle_aim", "fire", idleAimLength, 0.1);
    soldierAsm:AddTransition("idle_aim", "melee", idleAimLength, 0.2);
    soldierAsm:AddTransition("idle_aim", "reload", idleAimLength, 0.2);
    soldierAsm:AddTransition("idle_aim", "run_backward", idleAimLength, 0.2);
    soldierAsm:AddTransition("idle_aim", "run_forward", idleAimLength, 0.2);
    soldierAsm:AddTransition("idle_aim", "smg_transform", idleAimLength, 0.2);
    soldierAsm:AddTransition("idle_aim", "sniper_transform", idleAimLength, 0.2);
    
    -- Fire Transitions
    soldierAsm:AddTransition("fire", "idle_aim", 0.1, 0.1);
    -- Melee Transitions
    soldierAsm:AddTransition("melee", "idle_aim", 0.2, 0.2);
    -- Reload Transitions
    soldierAsm:AddTransition("reload", "idle_aim", 0.2, 0.2);
    -- Run Backward Transitions
    soldierAsm:AddTransition("run_backward", "idle_aim", 0.2, 0.2);
    -- Run Forward Transitions
    soldierAsm:AddTransition("run_forward", "idle_aim", 0.2, 0.2);
    -- SMG Transitions
    soldierAsm:AddTransition("smg_transform", "idle_aim", 0.2, 0.2);
    -- Sniper Transitions
    soldierAsm:AddTransition("sniper_transform", "idle_aim", 0.2, 0.2);
    
    -- Request a default looping animation to play.
    soldierAsm:RequestState("idle_aim");
    
    -- Once a mesh is attached to a bone, you cannot reference the mesh again.
    Animation.AttachToBone(
        soldier,
        "b_RightHand",
        weapon,
        Vector.new(0.04, 0.05, -0.01),
        Vector.new(98.0, 97.0, 0));
    
    weapon = nil;
end

function Sandbox_Update(sandbox, deltaTimeInMillis)
    -- Update the default UI.
    GUI_UpdateUI(sandbox);

    -- Update the animation state machines to handle blending
    -- and animation playback.
    soldierAsm:Update(deltaTimeInMillis, Sandbox.GetTimeInMillis(sandbox));
    weaponAsm:Update(deltaTimeInMillis, Sandbox.GetTimeInMillis(sandbox));

    -- Always send both state machines back to the idle animation.（因为这次是动画演示，所以每帧都尝试回归idle状态）
    if (soldierAsm:GetCurrentStateName() ~= "idle_aim") then
        soldierAsm:RequestState("idle_aim");
    end
    
    if (weaponState == "sniper") then
        if (weaponAsm:GetCurrentStateName() ~= "sniper_idle") then
            weaponAsm:RequestState("sniper_idle");
        end
    elseif (weaponState == "smg") then
        if (weaponAsm:GetCurrentStateName() ~= "smg_idle") then
            weaponAsm:RequestState("smg_idle");
        end
    end
end
