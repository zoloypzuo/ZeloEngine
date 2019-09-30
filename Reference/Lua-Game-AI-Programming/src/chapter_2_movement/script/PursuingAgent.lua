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

require "AgentUtilities";

local enemy;

function Agent_Cleanup(agent)
end

function Agent_HandleEvent(agent, event)
end

function Agent_Initialize(agent)
    AgentUtilities_CreateAgentRepresentation(
        agent, agent:GetHeight(), agent:GetRadius());

    -- Assign an acceptable target radius.
    agent:SetTargetRadius(1.0);
    -- Randomly assign a position to the agent.
    agent:SetPosition(
        Vector.new(math.random(-50, 50), 0, math.random(-50, 50)));

    -- Find the first valid agent and assign the agent as an enemy.
    local agents = Sandbox.GetAgents(agent:GetSandbox());
    for index = 1, #agents do
        if (agents[index] ~= agent) then
            enemy = agents[index];
            agent:SetTarget(enemy:GetPosition());
            break;
        end
    end
    
    -- Make the pursuing Agent slightly slower than the enemy.
    agent:SetMaxSpeed(enemy:GetMaxSpeed() * 0.8);
end

function Agent_Update(agent, deltaTimeInMillis)
    -- Calculate the future position of the enemy agent.
    agent:SetTarget(enemy:PredictFuturePosition(1));

    local destination = agent:GetTarget();
    local deltaTimeInSeconds = deltaTimeInMillis / 1000;
    local seekForce = agent:ForceToPosition(destination);
    local targetRadius = agent:GetTargetRadius();
    local position = agent:GetPosition();

    -- Apply seeking force to the predicted position.
    AgentUtilities_ApplyPhysicsSteeringForce(agent, seekForce, deltaTimeInSeconds);
    AgentUtilities_ClampHorizontalSpeed(agent);

    -- Draw debug information for target and target radius.
    Core.DrawCircle(
        destination, targetRadius, Vector.new(1, 0, 0));
    Core.DrawLine(position, destination, Vector.new(0, 1, 0));
end
