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