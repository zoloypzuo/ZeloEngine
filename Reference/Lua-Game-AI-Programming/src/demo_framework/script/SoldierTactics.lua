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

require "AgentSenses"

SoldierTactics = {};
SoldierTactics.InfluenceMap = {};

local eventHandlers = {};
local bulletImpacts = {};
local bulletShots = {};
local deadFriendlies = {};
local seenEnemies = {};

local function HandleBulletImpactEvent(sandbox, eventType, event)
    table.insert(bulletImpacts, { position = event.position, ttl = 1500 });
end

local function HandleBulletShotEvent(sandbox, eventType, event)
    table.insert(bulletShots, { position = event.position, ttl = 1500 });
end

local function HandleDeadFriendlySightedEvent(sandbox, eventType, event)
    deadFriendlies[event.agent:GetId()] = event;
end

local function HandleEnemySightedEvents(sandbox, eventType, event)
    seenEnemies[event.agent:GetId()] = event;
end

local function HandleEvent(sandbox, sandbox, eventType, event)
    if (eventHandlers[eventType]) then
        eventHandlers[eventType](sandbox, eventType, event);
    end
end

local function InitializeDangerousAreas(sandbox, layer)
    Sandbox.SetFalloff(sandbox, layer, 0.2);
    Sandbox.SetInertia(sandbox, layer, 0.5);
end

local function InitializeTeamAreas(sandbox, layer)
    Sandbox.SetFalloff(sandbox, layer, 0.2);
    Sandbox.SetInertia(sandbox, layer, 0.5);
end

local function PruneEvents(events, deltaTimeInMillis)
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

local function UpdateDangerousAreas(sandbox, layer, deltaTimeInMillis)
    Sandbox.ClearInfluenceMap(sandbox, layer);

    bulletImpacts = PruneEvents(bulletImpacts, deltaTimeInMillis);

    for key, value in pairs(bulletImpacts) do
        local position = Sandbox.FindClosestPoint(
            sandbox, "default", value.position);

        Sandbox.SetInfluence(sandbox, layer, position, -1);
    end

    bulletShots = PruneEvents(bulletShots, deltaTimeInMillis);
    
    for key, value in pairs(bulletShots) do
        local position = Sandbox.FindClosestPoint(
            sandbox, "default", value.position);

        Sandbox.SetInfluence(sandbox, layer, position, -1);
    end

    for key, value in pairs(deadFriendlies) do
        local position = Sandbox.FindClosestPoint(
            sandbox, "default", value.agent:GetPosition());

        if (value.agent:GetTeam() == "team2") then
            Sandbox.SetInfluence(sandbox, layer, position, -1);
        end
    end

    for key, value in pairs(seenEnemies) do
        local position = Sandbox.FindClosestPoint(
            sandbox, "default", value.seenAt);

        if (value.agent:GetTeam() ~= "team2") then
            Sandbox.SetInfluence(sandbox, layer, position, -1);
        end
    end

    Sandbox.SpreadInfluenceMap(sandbox, layer);
    
    SoldierTactics_DrawInfluenceMap(sandbox, layer);
end

local function UpdateTeamAreas(sandbox, layer, deltaTimeInMillis)
    Sandbox.ClearInfluenceMap(sandbox, layer);

    local agents = Sandbox.GetAgents(sandbox);

    for index = 1, #agents do
        local agent = agents[index];
        if (agent:GetHealth() > 0) then
            local position = Sandbox.FindClosestPoint(
                sandbox, "default", agent:GetPosition());
        
            if (agent:GetTeam() == "team1") then
                Sandbox.SetInfluence(sandbox, layer, position, -1);
            else
                Sandbox.SetInfluence(sandbox, layer, position, 1);
            end
        end
    end

    Sandbox.SpreadInfluenceMap(sandbox, layer);
    
    -- SoldierTactics_DrawInfluenceMap(sandbox, layer);
end

SoldierTactics.InfluenceMap.DangerousAreas = {
    initializeFunction = InitializeDangerousAreas,
    layer = 0,
    lastUpdate = 0,
    updateFrequency = 500,
    updateFunction = UpdateDangerousAreas };
    
SoldierTactics.InfluenceMap.TeamAreas = {
    initializeFunction = InitializeTeamAreas,
    layer = 1,
    lastUpdate = 0,
    updateFrequency = 500,
    updateFunction = UpdateTeamAreas };

function SoldierTactics_DrawInfluenceMap(sandbox, layer)
    Sandbox.DrawInfluenceMap(
        sandbox,
        layer,
        { 0, 0, 1, 0.9 },
        { 0, 0, 0, 0.75 },
        { 1, 0, 0, 0.9 });
end

function SoldierTactics_InitializeTactics(sandbox)
    eventHandlers[AgentCommunications.EventType.BulletImpact] =
        HandleBulletImpactEvent;
    eventHandlers[AgentCommunications.EventType.BulletShot] =
        HandleBulletShotEvent;
    eventHandlers[AgentCommunications.EventType.DeadFriendlySighted] =
        HandleDeadFriendlySightedEvent;
    eventHandlers[AgentCommunications.EventType.EnemySighted] =
        HandleEnemySightedEvents;

    Sandbox.AddEventCallback(sandbox, sandbox, HandleEvent);

    local influenceMapConfig = {
        CellHeight = 1,
        CellWidth = 2,
        BoundaryMinOffset = Vector.new(0.18, 0, 0.35) };

    Sandbox.CreateInfluenceMap(sandbox, "default", influenceMapConfig);

    for key, value in pairs(SoldierTactics.InfluenceMap) do
        value.initializeFunction(sandbox, value.layer);
    end
end

function SoldierTactics_UpdateTactics(sandbox, deltaTimeInMillis)
    for key, value in pairs(SoldierTactics.InfluenceMap) do
        value.lastUpdate = value.lastUpdate + deltaTimeInMillis;

        if (value.lastUpdate > value.updateFrequency) then
            value.updateFunction(sandbox, value.layer, deltaTimeInMillis);
            value.lastUpdate = 0;
        end
    end
end