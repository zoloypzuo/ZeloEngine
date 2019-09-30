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

require "Soldier"

function SoldierKnowledge_ChooseBestEnemy(userData)
    local sandbox = userData.agent:GetSandbox();
    local position = Agent.GetPosition(userData.agent);
    local agents = Sandbox.GetAgents(userData.agent:GetSandbox());

    local closestEnemy;
    local distanceToEnemy;

    for index=1, #agents do
        local agent = agents[index];

        -- Only check against living agents.
        if (Agent.GetId(agent) ~= Agent.GetId(userData.agent) and
            Agent.GetHealth(agent) > 0) then

            local distanceToAgent =
                Vector.DistanceSquared(position, agent:GetPosition());

            if (closestEnemy == nil or distanceToAgent < distanceToEnemy) then
                local path = Sandbox.FindPath(
                    sandbox, "default", position, agent:GetPosition());

                -- Make sure the enemy is pathable.
                if (#path ~= 0) then
                    closestEnemy = agent;
                    distanceToEnemy = distanceToAgent;
                end
            end
        end
    end
    
    return { confidence = 1, evaluation = closestEnemy };
end

function SoldierKnowledge_ChooseBestFleePosition(userData)
    local sandbox = userData.agent:GetSandbox();
    local enemy = userData.blackboard:Get("enemy");

    local bestPosition;

    if (enemy) then
        local position;
        local bestDistance = 0;
        local enemyPosition = enemy:GetPosition();

        -- Try 32 points, and pick the furthest point away from the current
        -- enemy.
        for index=1, 32 do
            position = Sandbox.RandomPoint(sandbox, "default");

            local distanceToAgent =
                Vector.DistanceSquared(position, enemyPosition);

            if (bestDistance < distanceToAgent) then
                bestDistance = distanceToAgent;
                bestPosition = position;
            end
        end
    else
        -- Any position will work if the agent doesn't have an enemy.
        bestPosition = Soldier_PathToRandomPoint(userData.agent);
    end
    
    return { confidence = 1, evaluation = bestPosition };
end