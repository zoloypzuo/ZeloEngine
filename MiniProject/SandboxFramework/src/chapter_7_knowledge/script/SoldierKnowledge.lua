
require "Soldier/Soldier"

function SoldierKnowledge_ChooseBestEnemy(userData)
    local sandbox = userData.agent:GetSandbox();
    local position = Agent.GetPosition(userData.agent);
    local agents = Sandbox.GetAgents(userData.agent:GetSandbox());

    local closestEnemy;
    local distanceToEnemy;

    for index = 1, #agents do
        local agent = agents[index];

        -- Only check against living agents.
        if (Agent.GetId(agent) ~= Agent.GetId(userData.agent) and
                Agent.GetHealth(agent) > 0) then

            local distanceToAgent = Vector.DistanceSquared(position, agent:GetPosition());

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
        for index = 1, 32 do
            position = Sandbox.RandomPoint(sandbox, "default");

            local distanceToAgent = Vector.DistanceSquared(position, enemyPosition);

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