--[[
userData =
{
    agent, -- Sandbox Agent
    blackboard,  -- Agent Blackboard
    controller, -- Agent Controller
};
]]

function SoldierEvaluators_CanShootAgent(userData)
    local enemy = userData.blackboard:Get("enemy");
    
    if (enemy ~= nil and
        -- A simple distance check to determine whether one Agent can
        -- shoot another.
        Agent.GetHealth(enemy) > 0 and
        Vector.Distance(userData.agent:GetPosition(), enemy:GetPosition()) < 3) then
        return true;
    end;
    return false;
end

function SoldierEvaluators_HasAmmo(userData)
    local ammo = userData.blackboard:Get("ammo");
    
    return ammo ~= nil and ammo > 0;
end

function SoldierEvaluators_HasNoAmmo(userData)
    return not SoldierEvaluators_HasAmmo(userData);
end

function SoldierEvaluators_HasCriticalHealth(userData)
    local maxHealth = userData.blackboard:Get("maxHealth");

    return Agent.GetHealth(userData.agent) < (maxHealth * 0.2);
end

function SoldierEvaluators_HasEnemy(userData)
    return userData.blackboard:Get("enemy") ~= nil;
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
