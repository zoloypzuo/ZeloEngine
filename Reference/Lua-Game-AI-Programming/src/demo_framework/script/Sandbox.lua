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