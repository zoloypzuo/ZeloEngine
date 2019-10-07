require "AgentSenses"
require "Blackboard"
require "DebugUtilities"
require "KnowledgeSource"
require "SandboxUtilities"
require "Soldier"
require "SoldierController"
require "SoldierKnowledge"
require "SoldierLogic"

local _soldierController;
local soldierLogic;
local soldierUserData;

local lastTeam = "team1";

function Agent_Cleanup(agent)
end

function Agent_HandleEvent(agent, event)
end

function Agent_Initialize(agent)
    agent:SetTeam("team" .. (agent:GetId() % 2 + 1));

    soldierUserData = {};

    if (agent:GetTeam() == "team1") then
        soldierUserData.soldier = Soldier_CreateSoldier(agent);
    else
        soldierUserData.soldier = Soldier_CreateLightSoldier(agent);
    end
    
    local weapon = Soldier_CreateWeapon(agent);

    _soldierController = SoldierController.new(
        agent, soldierUserData.soldier, weapon);

    Soldier_AttachWeapon(soldierUserData.soldier, weapon);
    weapon = nil;

    soldierUserData.agent = agent;
    soldierUserData.controller = _soldierController;

    soldierUserData.blackboard = Blackboard.new(soldierUserData);
    soldierUserData.blackboard:Set("alive", true);
    soldierUserData.blackboard:Set("ammo", 10);
    soldierUserData.blackboard:Set("maxAmmo", 10);
    soldierUserData.blackboard:Set("maxHealth", Agent.GetHealth(agent));
    soldierUserData.blackboard:AddSource(
        "enemy",
        KnowledgeSource.new(SoldierKnowledge_ChooseBestVisibleEnemy));
    soldierUserData.blackboard:AddSource(
        "bestFleePosition",
        KnowledgeSource.new(SoldierKnowledge_ChooseBestFleePosition),
        5000);
    soldierUserData.blackboard:Set("bulletImpacts", {});
    soldierUserData.blackboard:Set("visibleAgents", {});

    AgentSenses_InitializeSenses(soldierUserData);

    -- soldierLogic = SoldierLogic_DecisionTree(soldierUserData);
    -- soldierLogic = SoldierLogic_FiniteStateMachine(soldierUserData);
    soldierLogic = SoldierLogic_BehaviorTree(soldierUserData);
end

function Agent_Update(agent, deltaTimeInMillis)
    if (soldierUserData.blackboard:Get("alive")) then
        soldierLogic:Update(deltaTimeInMillis);
        
        AgentSenses_UpdateSenses(
            agent:GetSandbox(), soldierUserData, deltaTimeInMillis);
    end

    _soldierController:Update(agent, deltaTimeInMillis);
    
    --[[
    if (agent:GetTeam() == "team1") then
        local visibleAgents = soldierUserData.blackboard:Get("visibleAgents");
        
        for key, value in pairs(visibleAgents) do
            Core.DrawSphere(value.seenAt, 0.05, DebugUtilities.Black, true);
        end
    end
    ]]
end