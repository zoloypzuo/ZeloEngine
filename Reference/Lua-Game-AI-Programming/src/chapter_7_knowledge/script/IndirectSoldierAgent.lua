require "Blackboard"
require "DebugUtilities"
require "KnowledgeSource"
require "SandboxUtilities"
require "Soldier/Soldier"
require "MindBodyControl/SoldierController"
require "SoldierKnowledge"
require "Soldier/SoldierLogic"

local soldier;
local soldierController;
local soldierLogic;
local soldierUserData;

function Agent_Cleanup(agent)
end

function Agent_HandleEvent(agent, event)
    if (event.source == "keyboard" and event.pressed) then
        local key = event.key;

        if (key == "1_key" or key == "numpad_1_key") then
            soldierController:QueueCommand(agent, SoldierController.Commands.IDLE);
        elseif (key == "2_key" or key == "numpad_2_key") then
            soldierController:QueueCommand(agent, SoldierController.Commands.SHOOT);
        elseif (key == "3_key" or key == "numpad_3_key") then
            soldierController:QueueCommand(agent, SoldierController.Commands.MOVE);
        elseif (key == "4_key" or key == "numpad_4_key") then
            soldierController:ImmediateCommand(agent, SoldierController.Commands.DIE);
        elseif (key == "5_key" or key == "numpad_5_key") then
            soldierController:QueueCommand(agent, SoldierController.Commands.CHANGE_STANCE);
        elseif (key == "6_key" or key == "numpad_6_key") then
            soldierController:QueueCommand(agent, SoldierController.Commands.RELOAD);
        end
    end
end

function Agent_Initialize(agent)
    soldier = Soldier_CreateSoldier(agent);
    weapon = Soldier_CreateWeapon(agent);

    soldierController = SoldierController.new(agent, soldier, weapon);

    Soldier_AttachWeapon(soldier, weapon);
    weapon = nil;

    soldierUserData = {};
    soldierUserData.agent = agent;
    soldierUserData.controller = soldierController;
    soldierUserData.blackboard = Blackboard.new(soldierUserData);
    soldierUserData.blackboard:Set("alive", true);
    soldierUserData.blackboard:Set("ammo", 10);
    soldierUserData.blackboard:Set("maxAmmo", 10);
    soldierUserData.blackboard:Set("maxHealth", Agent.GetHealth(agent));
    soldierUserData.blackboard:AddSource(
            "enemy",
            KnowledgeSource.new(SoldierKnowledge_ChooseBestEnemy));
    soldierUserData.blackboard:AddSource(
            "bestFleePosition",
            KnowledgeSource.new(SoldierKnowledge_ChooseBestFleePosition),
            5000);

    -- soldierLogic = SoldierLogic_DecisionTree(soldierUserData);
    -- soldierLogic = SoldierLogic_FiniteStateMachine(soldierUserData);
    soldierLogic = SoldierLogic_BehaviorTree(soldierUserData);
end

function Agent_Update(agent, deltaTimeInMillis)
    if (soldierUserData.blackboard:Get("alive")) then
        soldierLogic:Update(deltaTimeInMillis);
    end

    soldierController:Update(agent, deltaTimeInMillis);
end