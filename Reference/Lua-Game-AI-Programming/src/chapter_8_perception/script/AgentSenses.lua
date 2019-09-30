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
require "DebugUtilities"

local PruneEvents;
local SendNewDeadEnemyEvent;
local SendNewDeadFriendlyEvent;
local SendNewEnemyEvent;
local lastUpdate = 0;

local function HandleBulletImpactEvent(userData, eventType, event)
    local blackboard = userData.blackboard;
    local bulletImpacts = blackboard:Get("bulletImpacts") or {};
    
    table.insert(bulletImpacts, { position = event.position, ttl = 1000 });
    blackboard:Set("bulletImpacts", bulletImpacts);
end

local function HandleBulletShotEvent(userData, eventType, event)
    local blackboard = userData.blackboard;
    local bulletShots = blackboard:Get("bulletShots") or {};
    
    table.insert(bulletShots, { position = event.position, ttl = 1000 });
    blackboard:Set("bulletShots", bulletShots);
end

local function HandleDeadEnemySightedEvent(userData, eventType, event)
    local blackboard = userData.blackboard;
    local knownAgents = userData.blackboard:Get("visibleAgents") or {};
    local knownBodies = userData.blackboard:Get("deadEnemies") or {};
    
    knownAgents[event.agent:GetId()] = nil;
    knownBodies[event.agent:GetId()] = event;
    
    userData.blackboard:Set("visibleAgents", knownAgents);
    userData.blackboard:Set("deadEnemies", knownBodies);
end

local function HandleDeadFriendlySightedEvent(userData, eventType, event)
    local blackboard = userData.blackboard;
    local knownBodies = userData.blackboard:Get("deadFriendlies") or {};
    
    knownBodies[event.agent:GetId()] = event;
    userData.blackboard:Set("deadFriendlies", knownBodies);
end

local function HandleEnemySightedEvent(userData, eventType, event)
    local blackboard = userData.blackboard;
    local knownAgents = userData.blackboard:Get("visibleAgents") or {};
    
    knownAgents[event.agent:GetId()] = event;
    userData.blackboard:Set("visibleAgents", knownAgents);
end

local function HandleNewAgentSightings(userData, knownAgents, spottedAgents)
    local newAgentSightings = {};
    
    for key, value in pairs(spottedAgents) do
        local agentId = value.agent:GetId();
    
        if (knownAgents[agentId] == nil or
            (value.lastSeen - knownAgents[agentId].lastSeen) > 500) then
            newAgentSightings[agentId] = value;
        end
    end
    
    local sandbox = userData.agent:GetSandbox();
    
    for key, value in pairs(newAgentSightings) do
        if (userData.agent:GetTeam() ~= value.agent:GetTeam()) then
            if (value.agent:GetHealth() > 0) then
                SendNewEnemyEvent(
                    sandbox, userData.agent, value.agent, value.seenAt, value.lastSeen);
            else
                SendNewDeadEnemyEvent(
                    sandbox, userData.agent, value.agent, value.seenAt, value.lastSeen);
            end
        elseif (value.agent:GetHealth() <= 0) then
            SendNewDeadFriendlyEvent(
                sandbox, userData.agent, value.agent, value.seenAt, value.lastSeen);
        end
    end
end

local function PruneBlackboardEvents(
    blackboard, attribute, deltaTimeInMillis)
    
    local attributeValue = blackboard:Get(attribute);
    
    if (attributeValue) then
        blackboard:Set(
            attribute,
            PruneEvents(attributeValue, deltaTimeInMillis));
    end
end

PruneEvents = function(events, deltaTimeInMillis)
    local validEvents = {};
    
    for index = 1, #events do
        local event = events[index];
        event.ttl = event.ttl - deltaTimeInMillis;
        
        if (event.ttl > 0) then
            table.insert(validEvents, event);
        end
    end
    
    return validEvents;
end

SendNewDeadEnemyEvent = function(sandbox, agent, enemy, seenAt, lastSeen)
    local event = {
        agent = enemy,
        seenAt = seenAt,
        lastSeen = lastSeen};

    AgentCommunications_SendTeamMessage(
        sandbox,
        agent,
        AgentCommunications.EventType.DeadEnemySighted,
        event);
end

SendNewDeadFriendlyEvent = function(sandbox, agent, friendly, seenAt, lastSeen)
    local event = {
        agent = friendly,
        seenAt = seenAt,
        lastSeen = lastSeen};

    AgentCommunications_SendTeamMessage(
        sandbox,
        agent,
        AgentCommunications.EventType.DeadFriendlySighted,
        event);
end

SendNewEnemyEvent = function(sandbox, agent, enemy, seenAt, lastSeen)
    local event = {
        agent = enemy,
        seenAt = seenAt,
        lastSeen = lastSeen};

    AgentCommunications_SendTeamMessage(
        sandbox,
        agent,
        AgentCommunications.EventType.EnemySighted,
        event);
end

local function UpdateVisibility(userData)
    local agents = Sandbox.GetAgents(userData.agent:GetSandbox());
    local visibleAgents = {};

    for index = 1, #agents do
        if (agents[index] ~= userData.agent) then
            canSeeAgentInfo = AgentSenses_CanSeeAgent(userData, agents[index], true);
            
            if (canSeeAgentInfo) then
                visibleAgents[agents[index]:GetId()] = canSeeAgentInfo;
            end
        end
    end
    
    local knownAgents = userData.blackboard:Get("visibleAgents") or {};
    HandleNewAgentSightings(userData, knownAgents, visibleAgents);
    
    for key, value in pairs(visibleAgents) do
        knownAgents[key] = value;
    end
    
    userData.blackboard:Set("visibleAgents", knownAgents);
end

function AgentSenses_CanSeeAgent(userData, agent, debug)
    local sandbox = userData.agent:GetSandbox();
    local position = Animation.GetBonePosition(userData.soldier, "b_Head1");
    local rotation = Animation.GetBoneRotation(userData.soldier, "b_Head1");
    -- The negative forward vector is used here, but is model specific.
    local forward = Vector.Rotate(Vector.new(0, 0, -1), rotation);
    local rayCastPosition = position + forward / 2;
    local sandboxTime = Sandbox.GetTimeInMillis(sandbox);
    local centroid = agent:GetPosition();
    local rayVector = Vector.Normalize(centroid - rayCastPosition);
    local dotProduct = Vector.DotProduct(rayVector, forward);
    
    -- Only check visibility within a 45 degree tolerance
    local cos45Degrees = 0.707;
    
    if (dotProduct >= cos45Degrees) then
        local raycast = Sandbox.RayCastToObject(sandbox, rayCastPosition, centroid);
                
        if ((raycast.result and
            Agent.IsAgent(raycast.object) and
            raycast.object:GetId() == agent:GetId()) or
            not raycast.result) then
            
            if (debug) then
                Core.DrawLine(rayCastPosition, centroid, DebugUtilities.Green);
            end
        
            local visibleAgent = {};
            visibleAgent["agent"] = agent;
            visibleAgent["seenAt"] = centroid;
            visibleAgent["lastSeen"] = sandboxTime;
            
            return visibleAgent;
        else
            if (debug) then
                Core.DrawLine(rayCastPosition, centroid, DebugUtilities.Red);
            end
        end
    end
    
    return false;
end

function AgentSenses_InitializeSenses(userData)
    local eventCallbacks = {};

    eventCallbacks[AgentCommunications.EventType.BulletImpact] =
        HandleBulletImpactEvent;
    eventCallbacks[AgentCommunications.EventType.BulletShot] =
        HandleBulletShotEvent;
    eventCallbacks[AgentCommunications.EventType.DeadEnemySighted] =
        HandleDeadEnemySightedEvent;
    eventCallbacks[AgentCommunications.EventType.DeadFriendlySighted] =
        HandleDeadFriendlySightedEvent
    eventCallbacks[AgentCommunications.EventType.EnemySighted] =
        HandleEnemySightedEvent;

    for eventType, callback in pairs(eventCallbacks) do
        AgentCommunications_AddEventCallback(userData, eventType, callback);
    end
end

function AgentSenses_UpdateSenses(sandbox, userData, deltaTimeInMillis)
    PruneBlackboardEvents(
        userData.blackboard, "bulletImpacts", deltaTimeInMillis);
    PruneBlackboardEvents(
        userData.blackboard, "bulletShots", deltaTimeInMillis);
    
    local updateInterval = 500;
    updateInterval = 1;
    
    lastUpdate = lastUpdate + deltaTimeInMillis;
    
    if (lastUpdate > updateInterval) then
        UpdateVisibility(userData);
        lastUpdate = lastUpdate % updateInterval;
    end
end