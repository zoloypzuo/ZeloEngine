require "DebugUtilities"
require "SandboxUtilities"

local agents = {};

local function DrawPaths()
    for index = 1, #agents do
        local agent = agents[index];
        if (agent:GetHealth() > 0) then
            local path = agent:GetPath();
            DebugUtilities_DrawPath(path, false, Vector.new(0, 0.02, 0));
            Core.DrawSphere(agent:GetTarget(), 0.1, DebugUtilities.Red, true);
        end
    end
end

function Sandbox_Cleanup(sandbox)
end

function Sandbox_HandleEvent(sandbox, event)
    if (event.source == "keyboard" and event.pressed) then
        local key = event.key;
        if ( key == "space_key" ) then
            SandboxUtilities_ShootBox(sandbox);
        elseif ( key == "f1_key" ) then
            local drawDebug = Sandbox.GetDrawPhysicsWorld(sandbox);
            Sandbox.SetDrawPhysicsWorld(sandbox, not drawDebug);
        elseif ( key == "f2_key" ) then
            Sandbox.SetCameraPosition(sandbox, Vector.new(-0.7, 1.5, -0.7));
            Sandbox.SetCameraForward(sandbox, Vector.new(-0.4, 0, -1));
        elseif (key == "f3_key") then
            Sandbox.CreateNavigationMesh(
                sandbox, "default", { MinimumRegionArea = 15 });
            Sandbox.SetDebugNavigationMesh(sandbox, "default", true);
        end
    end
end

function Sandbox_Initialize(sandbox)
    Core.CacheResource("models/nobiax_modular/modular_block.mesh");

    SandboxUtilities_CreateLevel(sandbox);
    
    local navMeshConfig = {
        MinimumRegionArea = 250,
        WalkableRadius = 0.4,
        WalkableClimbHeight = 0.2,
        WalkableSlopeAngle = 45 };
    
    Sandbox.CreateNavigationMesh(sandbox, "default", navMeshConfig);
    Sandbox.SetDebugNavigationMesh(sandbox, "default", true);
    
    for i=1, 3 do
        local agent = Sandbox.CreateAgent(sandbox, "IndirectSoldierAgent.lua");
        table.insert(agents, agent);
        
        local position = Sandbox.RandomPoint(sandbox, "default");
        position.y = position.y + agent:GetHeight() / 2.0;
        agent:SetPosition(position);
        agent:SetTarget(agent:GetPosition());
    end
end

function Sandbox_Update(sandbox, deltaTimeInMillis)
    local deltaTimeInSeconds = deltaTimeInMillis / 1000;
    
    DrawPaths();
end