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

local agentUserData = {};
local agentCallbacks = {};

AgentCommunications = {};

AgentCommunications.EventType = {};
AgentCommunications.EventType.AgentDeath = "AgentDeath";
AgentCommunications.EventType.AgentEnemySelection = "AgentEnemySelection";
AgentCommunications.EventType.BulletImpact = "BulletImpact";
AgentCommunications.EventType.BulletShot = "BulletShot";
AgentCommunications.EventType.DeadEnemySighted = "DeadEnemySighted";
AgentCommunications.EventType.DeadFriendlySighted = "DeadFriendlySighted";
AgentCommunications.EventType.EnemySelection = "EnemySelection";
AgentCommunications.EventType.EnemySighted = "EnemySighted";
AgentCommunications.EventType.PositionUpdate = "PositionUpdate";
AgentCommunications.EventType.RetreatPosition = "RetreatPosition";

local function AgentCommunications_HandleEvent(sandbox, agent, eventType, event)
    local callbacks = agentCallbacks[agent:GetId()];
    
    if (callbacks == nil or
        callbacks[eventType] == nil or
        type(callbacks[eventType]) ~= "function") then

        return;
    end
    
    if (not event["teamOnly"] or
        (event["teamOnly"] and agent:GetTeam() == event["team"])) then

        callbacks[eventType](agentUserData[agent:GetId()], eventType, event);
    end
end

function AgentCommunications_AddEventCallback(userData, eventType, callback)
    local agentId = userData.agent:GetId();

    if (agentCallbacks[agentId] == nil) then
        agentCallbacks[agentId] = {};
        agentUserData[agentId] = userData;
        
        Sandbox.AddEventCallback(
            userData.agent:GetSandbox(),
            userData.agent,
            AgentCommunications_HandleEvent);
    end
    
    agentCallbacks[agentId][eventType] = callback;
end

function AgentCommunications_SendMessage(sandbox, messageType, message)
    Sandbox.AddEvent(sandbox, messageType, message);
end

function AgentCommunications_SendTeamMessage(sandbox, agent, messageType, message)
    message["team"] = agent:GetTeam();
    message["teamOnly"] = true;

    Sandbox.AddEvent(sandbox, messageType, message);
end