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
        -- A distance check to determine whether one Agent can
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
