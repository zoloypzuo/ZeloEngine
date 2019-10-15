--[[
userData =
{
    agent, -- Sandbox Agent
    ammo, -- Agent Ammo
    controller, -- Agent Controller
    enemy, -- Agent Enemy
    health, -- Agent Health
    maxHealth, -- Agent Max Health
    movePosition, -- Agent Target Position
};
]]

function SoldierEvaluators_CanShootAgent(userData)
    if (userData.enemy ~= nil and Agent.GetHealth(userData.enemy) > 0) then
        local shootSquared = 3 * 3;
        if (Vector.DistanceSquared(
                userData.agent:GetPosition(),
                userData.enemy:GetPosition()) < shootSquared) then

            return true;
        end
    end ;

    return false;
end

function SoldierEvaluators_HasAmmo(userData)
    return userData.ammo ~= nil and userData.ammo > 0;
end

function SoldierEvaluators_HasNoAmmo(userData)
    return not SoldierEvaluators_HasAmmo(userData);
end

function SoldierEvaluators_HasCriticalHealth(userData)
    return Agent.GetHealth(userData.agent) < (userData.maxHealth * 0.2);
end

function SoldierEvaluators_HasEnemy(userData)
    local sandbox = userData.agent:GetSandbox();
    local position = Agent.GetPosition(userData.agent);
    local agents = Sandbox.GetAgents(userData.agent:GetSandbox());

    local closestEnemy;
    local distanceToEnemy;

    for index = 1, #agents do
        local agent = agents[index];
        if (Agent.GetId(agent) ~= Agent.GetId(userData.agent) and
                Agent.GetHealth(agent) > 0) then
            -- Find the closest enemy.
            local distanceToAgent = Vector.DistanceSquared(position, Agent.GetPosition(agent));

            if (closestEnemy == nil or distanceToAgent < distanceToEnemy) then
                local path = Sandbox.FindPath(
                        sandbox, "default", position, agent:GetPosition());

                -- If the agent can path to the enemy, use this enemy as the 
                -- best possible enemy.
                if (#path ~= 0) then
                    closestEnemy = agent;
                    distanceToEnemy = distanceToAgent;
                end
            end
        end
    end

    userData.enemy = closestEnemy;

    return userData.enemy ~= nil;
end

function SoldierEvaluators_HasNoEnemy(userData)
    return not SoldierEvaluators_HasEnemy(userData);
end

function SoldierEvaluators_HasMovePosition(userData)
    local movePosition = userData.agent:GetTarget();

    return movePosition ~= nil and
            (Vector.Distance(userData.agent:GetPosition(), movePosition) > 1.5);
end

function SoldierEvaluators_IsAlive(userData)
    return Agent.GetHealth(userData.agent) > 0;
end

function SoldierEvaluators_IsNotAlive(userData)
    return not SoldierEvaluators_IsAlive(userData);
end

function SoldierEvaluators_Random(userData)
    return math.random() >= 0.5;
end

function SoldierEvaluators_True(userData)
    return true;
end
