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