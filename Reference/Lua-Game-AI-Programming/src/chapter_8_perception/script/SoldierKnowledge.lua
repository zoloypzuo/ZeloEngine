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

require "AgentCommunications"
require "Soldier"

local function SendNewEnemyEvent(sandbox, agent, enemy)
    AgentCommunications_SendMessage(
        sandbox,
        AgentCommunications.EventType.AgentEnemySelection,
        { agent = agent, enemy = enemy });
end

function SoldierKnowledge_ChooseBestVisibleEnemy(userData)
    local sandbox = userData.agent:GetSandbox();
    local sandboxTime = Sandbox.GetTimeInMillis(sandbox);
    local position = Agent.GetPosition(userData.agent);
    local team = userData.agent:GetTeam();
    local visibleEnemies = userData.blackboard:Get("visibleAgents") or {};
    
    local closestEnemy;
    local distanceToEnemy;
    
    for key, value in pairs(visibleEnemies) do
        if ((sandboxTime - value.lastSeen) <= 1000) then
            local agent = value.agent;
        
            if (agent:GetId() ~= userData.agent:GetId() and
                Agent.GetHealth(agent) > 0 and
                agent:GetTeam() ~= team) then
                local distanceToAgent =
                    Vector.DistanceSquared(position, Agent.GetPosition(agent));
                if (closestEnemy == nil or distanceToAgent < distanceToEnemy) then
                    local path = Sandbox.FindPath(
                        sandbox, "default", position, agent:GetPosition());
                    
                    if (#path ~= 0) then
                        closestEnemy = agent;
                        distanceToEnemy = distanceToAgent;
                    end
                end
            end
        end
    end
    
    return { confidence = 1, evaluation = closestEnemy };
end

function SoldierKnowledge_ChooseBestEnemy(userData)
    local sandbox = userData.agent:GetSandbox();
    local position = Agent.GetPosition(userData.agent);
    local agents = Sandbox.GetAgents(userData.agent:GetSandbox());
    local team = userData.agent:GetTeam();
    
    local closestEnemy;
    local distanceToEnemy;
    
    for index=1, #agents do
        local agent = agents[index];

        -- Only check against living agents.
        if (agent:GetId() ~= userData.agent:GetId() and
            Agent.GetHealth(agent) > 0 and
            agent:GetTeam() ~= team) then

            local distanceToAgent =
                Vector.DistanceSquared(position, Agent.GetPosition(agent));

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
    
    SendNewEnemyEvent(sandbox, userData.agent, closestEnemy);
    
    return { confidence = 1, evaluation = closestEnemy };
end

local function ScoreDangerFromBulletImpacts(positions, impacts, scores)
    local safeDistanceFromBulletImpactSquared = 10 * 10;

    for index=1, #positions do
        for key, impact in pairs(impacts) do
            local distanceToImpact =
                Vector.DistanceSquared(positions[index], impact.position);
            
            if (distanceToImpact < safeDistanceFromBulletImpactSquared) then
                scores[index] = scores[index] - 0.5;
            end
        end
    end
end

local function ScoreDangerFromBulletShots(positions, shots, scores)
    local safeDistanceFromBulletShotSquared = 20 * 20;

    for index=1, #positions do
        for key, shot in pairs(shots) do
            local distanceToShot =
                Vector.DistanceSquared(positions[index], shot.position);
            
            if (distanceToShot < safeDistanceFromBulletShotSquared) then
                scores[index] = scores[index] - 0.25;
            end
        end
    end
end

local function ScoreDangerFromEnemies(positions, enemies, scores)
    local safeDistanceFromEnemySquared = 30 * 30;

    for index=1, #positions do
        for key, value in pairs(enemies) do
            local enemyInfo = value;
            
            local distanceToAgent =
                Vector.DistanceSquared(positions[index], enemyInfo.seenAt);
                
            if (distanceToAgent < safeDistanceFromEnemySquared) then
                scores[index] = scores[index] - 1;
            end
        end
    end
end

local function ScoreDangerFromDeadBodies(positions, bodies, scores)
    local safeDistanceFromDeadBody = 20 * 20;

    for index=1, #positions do
        for key, body in pairs(bodies) do
            local distanceToBody =
                Vector.DistanceSquared(positions[index], body.seenAt);
            
            if (distanceToBody < safeDistanceFromDeadBody) then
                scores[index] = scores[index] - 1;
            end
        end
    end
end

function SoldierKnowledge_ChooseBestFleePosition(userData)
    local sandbox = userData.agent:GetSandbox();
    local bestPosition;
    
    local bulletImpacts = userData.blackboard:Get("bulletImpacts") or {};
    local bulletShots = userData.blackboard:Get("bulletShots") or {};
    local visibleEnemies = userData.blackboard:Get("visibleAgents") or {};
    local deadEnemies = userData.blackboard:Get("deadEnemies") or {};
    local deadFriendlies = userData.blackboard:Get("deadFriendlies") or {};

    if (#visibleEnemies) then
        local positions = {};
        local scores = {};
        local bestScore = 0;
        
        -- Pick 32 random points to score.
        for index=1, 32 do
            table.insert(positions, Sandbox.RandomPoint(sandbox, "default"));
            scores[index] = 0;
        end
        
        ScoreDangerFromBulletImpacts(positions, bulletImpacts, scores);
        ScoreDangerFromBulletShots(positions, bulletShots, scores);
        ScoreDangerFromDeadBodies(positions, deadFriendlies, scores);
        ScoreDangerFromDeadBodies(positions, deadEnemies, scores);
        ScoreDangerFromEnemies(positions, visibleEnemies, scores);
        
        -- find the best position
        bestScore = scores[1];
        bestPosition = positions[1];
        
        for index=2, #positions do
            if (bestScore < scores[index]) then
                bestScore = scores[index];
                bestPosition = positions[index];
            end
        end
    else
        -- Any position will work if the agent doesn't have an enemy.
        bestPosition = Soldier_PathToRandomPoint(userData.agent);
    end
    
    return { confidence = 1, evaluation = bestPosition };
end