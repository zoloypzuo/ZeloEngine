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

require "Action"
require "BehaviorTree"
require "DecisionBranch"
require "DecisionTree"
require "Evaluator"
require "FiniteStateMachine"
require "SoldierActions"
require "SoldierEvaluators"

local function ChangeStanceAction(userData)
    return Action.new(
        "changeStance",
        SoldierActions_ChangeStanceInitialize,
        SoldierActions_ChangeStanceUpdate,
        SoldierActions_ChangeStanceCleanUp,
        userData);
end

local function DieAction(userData)
    return Action.new(
        "die",
        SoldierActions_DieInitialize,
        SoldierActions_DieUpdate,
        SoldierActions_DieCleanUp,
        userData);
end

local function FleeAction(userData)
    return Action.new(
        "flee",
        SoldierActions_FleeInitialize,
        SoldierActions_FleeUpdate,
        SoldierActions_FleeCleanUp,
        userData);
end

local function IdleAction(userData)
    return Action.new(
        "idle",
        SoldierActions_IdleInitialize,
        SoldierActions_IdleUpdate,
        SoldierActions_IdleCleanUp,
        userData);
end

local function MoveAction(userData)
    return Action.new(
        "move",
        SoldierActions_MoveToInitialize,
        SoldierActions_MoveToUpdate,
        SoldierActions_MoveToCleanUp,
        userData);
end

local function PursueAction(userData)
    return Action.new(
        "pursue",
        SoldierActions_PursueInitialize,
        SoldierActions_PursueUpdate,
        SoldierActions_PursueCleanUp,
        userData);
end

local function RandomMoveAction(userData)
    return Action.new(
        "randomMove",
        SoldierActions_RandomMoveInitialize,
        SoldierActions_RandomMoveUpdate,
        SoldierActions_RandomMoveCleanUp,
        userData);
end

local function ReloadAction(userData)
    return Action.new(
        "reload",
        SoldierActions_ReloadInitialize,
        SoldierActions_ReloadUpdate,
        SoldierActions_ReloadCleanUp,
        userData);
end

local function ShootAction(userData)
    return Action.new(
        "shoot",
        SoldierActions_ShootInitialize,
        SoldierActions_ShootUpdate,
        SoldierActions_ShootCleanUp,
        userData);
end

function SoldierLogic_DecisionTree(userData)
    local tree = DecisionTree.new();

    local isAliveBranch = DecisionBranch.new();
    local criticalBranch = DecisionBranch.new();
    local moveFleeBranch = DecisionBranch.new();
    local enemyBranch = DecisionBranch.new();
    local ammoBranch = DecisionBranch.new();
    local shootBranch = DecisionBranch.new();
    local moveRandomBranch = DecisionBranch.new();
    local randomBranch = DecisionBranch.new();

    isAliveBranch:AddChild(criticalBranch);
    isAliveBranch:AddChild(DieAction(userData));
    isAliveBranch:SetEvaluator(
        function()
            if SoldierEvaluators_IsNotAlive(userData) then
                return 2;
            end
            return 1;
        end);

    criticalBranch:AddChild(moveFleeBranch);
    criticalBranch:AddChild(enemyBranch);
    criticalBranch:SetEvaluator(
        function()
            if SoldierEvaluators_HasCriticalHealth(userData) then
                return 1;
            end
            return 2;
        end);

    moveFleeBranch:AddChild(MoveAction(userData));
    moveFleeBranch:AddChild(FleeAction(userData));
    moveFleeBranch:SetEvaluator(
        function()
            if SoldierEvaluators_HasMovePosition(userData) then
                return 1;
            end
            return 2;
        end);

    enemyBranch:AddChild(ammoBranch);
    enemyBranch:AddChild(moveRandomBranch);
    enemyBranch:SetEvaluator(
        function()
            if SoldierEvaluators_HasEnemy(userData) then
                return 1;
            end
            return 2;
        end);

    ammoBranch:AddChild(shootBranch);
    ammoBranch:AddChild(ReloadAction(userData));
    ammoBranch:SetEvaluator(
        function()
            if SoldierEvaluators_HasAmmo(userData) then
                return 1;
            end
            return 2;
        end);

    shootBranch:AddChild(ShootAction(userData));
    shootBranch:AddChild(PursueAction(userData));
    shootBranch:SetEvaluator(
        function()
            if SoldierEvaluators_CanShootAgent(userData) then
                return 1;
            end
            return 2;
        end);

    moveRandomBranch:AddChild(MoveAction(userData));
    moveRandomBranch:AddChild(randomBranch);
    moveRandomBranch:SetEvaluator(
        function()
            if SoldierEvaluators_HasMovePosition(userData) then
                return 1;
            end
            return 2;
        end);

    randomBranch:AddChild(RandomMoveAction(userData));
    randomBranch:AddChild(IdleAction(userData));
    randomBranch:SetEvaluator(
        function()
            if SoldierEvaluators_Random(userData) then
                return 1;
            end
            return 2;
        end);

    tree:SetBranch(isAliveBranch);
    
    return tree;
end

function SoldierLogic_FiniteStateMachine(userData)
    local fsm = FiniteStateMachine.new(userData);
    fsm:AddState("die", DieAction(userData));
    fsm:AddState("flee", FleeAction(userData));
    fsm:AddState("idle", IdleAction(userData));
    fsm:AddState("move", MoveAction(userData));
    fsm:AddState("pursue", PursueAction(userData));
    fsm:AddState("randomMove", RandomMoveAction(userData));
    fsm:AddState("reload", ReloadAction(userData));
    fsm:AddState("shoot", ShootAction(userData));

    -- idle action
    fsm:AddTransition("idle", "die", SoldierEvaluators_IsNotAlive);
    fsm:AddTransition("idle", "flee", SoldierEvaluators_HasCriticalHealth);
    fsm:AddTransition("idle", "reload", SoldierEvaluators_HasNoAmmo);
    fsm:AddTransition("idle", "shoot", SoldierEvaluators_CanShootAgent);
    fsm:AddTransition("idle", "pursue", SoldierEvaluators_HasEnemy);
    fsm:AddTransition("idle", "randomMove", SoldierEvaluators_Random);
    fsm:AddTransition("idle", "idle", SoldierEvaluators_True);

    -- move action
    fsm:AddTransition("move", "die", SoldierEvaluators_IsNotAlive);
    fsm:AddTransition("move", "flee", SoldierEvaluators_HasCriticalHealth);
    fsm:AddTransition("move", "reload", SoldierEvaluators_HasNoAmmo);
    fsm:AddTransition("move", "shoot", SoldierEvaluators_CanShootAgent);
    fsm:AddTransition("move", "pursue", SoldierEvaluators_HasEnemy);
    fsm:AddTransition("move", "move", SoldierEvaluators_HasMovePosition);
    fsm:AddTransition("move", "randomMove", SoldierEvaluators_Random);
    fsm:AddTransition("move", "idle", SoldierEvaluators_True);
    
    -- random move action
    fsm:AddTransition("randomMove", "die", SoldierEvaluators_IsNotAlive);
    fsm:AddTransition("randomMove", "move", SoldierEvaluators_True);
    
    -- shoot action
    fsm:AddTransition("shoot", "die", SoldierEvaluators_IsNotAlive);
    fsm:AddTransition("shoot", "flee", SoldierEvaluators_HasCriticalHealth);
    fsm:AddTransition("shoot", "reload", SoldierEvaluators_HasNoAmmo);
    fsm:AddTransition("shoot", "shoot", SoldierEvaluators_CanShootAgent);
    fsm:AddTransition("shoot", "pursue", SoldierEvaluators_HasEnemy);
    fsm:AddTransition("shoot", "randomMove", SoldierEvaluators_Random);
    fsm:AddTransition("shoot", "idle", SoldierEvaluators_True);
    
    -- flee action
    fsm:AddTransition("flee", "die", SoldierEvaluators_IsNotAlive);
    fsm:AddTransition("flee", "move", SoldierEvaluators_True);
    
    -- die action
    
    -- pursue action
    fsm:AddTransition("pursue", "die", SoldierEvaluators_IsNotAlive);
    fsm:AddTransition("pursue", "flee", SoldierEvaluators_HasCriticalHealth);
    fsm:AddTransition("pursue", "shoot", SoldierEvaluators_CanShootAgent);
    fsm:AddTransition("pursue", "idle", SoldierEvaluators_True);
    
    -- reload action
    fsm:AddTransition("reload", "die", SoldierEvaluators_IsNotAlive);
    fsm:AddTransition("reload", "shoot", SoldierEvaluators_CanShootAgent);
    fsm:AddTransition("reload", "pursue", SoldierEvaluators_HasEnemy);
    fsm:AddTransition("reload", "randomMove", SoldierEvaluators_Random);
    fsm:AddTransition("reload", "idle", SoldierEvaluators_True);

    fsm:SetState("idle");
    
    return fsm;
end

local function CreateSelector()
    return BehaviorTreeNode.new("selector", BehaviorTreeNode.Type.SELECTOR);
end

local function CreateSequence()
    return BehaviorTreeNode.new("sequence", BehaviorTreeNode.Type.SEQUENCE);
end

local function CreateAction(name, action)
    local node = BehaviorTreeNode.new(name, BehaviorTreeNode.Type.ACTION);
    node:SetAction(action);
    return node;
end

local function CreateCondition(name, evaluator)
    local condition = BehaviorTreeNode.new(name, BehaviorTreeNode.Type.CONDITION);
    condition:SetEvaluator(evaluator);
    return condition;
end

function SoldierLogic_BehaviorTree(userData)
    local tree = BehaviorTree.new(userData);
    
    local node;
    local child;
    
    node = CreateSelector();
    tree:SetNode(node);
    
    -- die action
    child = CreateSequence();
    node:AddChild(child);
    node = child;
    
    child = CreateCondition("is not alive", SoldierEvaluators_IsNotAlive);
    node:AddChild(child);
    node = child;
    
    node = child:GetParent();
    child = CreateAction("die", DieAction(userData));
    node:AddChild(child);
    node = child;
    
    -- flee action
    node = node:GetParent();
    node = node:GetParent();
    child = CreateSequence();
    node:AddChild(child);
    node = child;
    
    child = CreateCondition("has critical health", SoldierEvaluators_HasCriticalHealth);
    node:AddChild(child);
    node = child;
    
    node = node:GetParent();
    child = CreateAction("flee", FleeAction(userData));
    node:AddChild(child);
    node = child;
    
    -- reload/shoot/move/pursue actions
    node = node:GetParent();
    node = node:GetParent();
    child = CreateSequence();
    node:AddChild(child);
    node = child;
    
    child = CreateCondition("has enemy", SoldierEvaluators_HasEnemy);
    node:AddChild(child);
    node = child;
    
    node = node:GetParent();
    child = CreateSelector();
    node:AddChild(child);
    node = child;
    
    -- reload action
    child = CreateSequence();
    node:AddChild(child);
    node = child;
    
    child = CreateCondition("has no ammo", SoldierEvaluators_HasNoAmmo);
    node:AddChild(child);
    node = child;
    
    node = node:GetParent();
    child = CreateAction("reload", ReloadAction(userData));
    node:AddChild(child);
    node = child;
    
    -- shoot action
    node = node:GetParent();
    node = node:GetParent();
    child = CreateSequence();
    node:AddChild(child);
    node = child;
    
    child = CreateCondition("can shoot enemy", SoldierEvaluators_CanShootAgent);
    node:AddChild(child);
    node = child;
    
    node = node:GetParent();
    child = CreateAction("shoot", ShootAction(userData));
    node:AddChild(child);
    node = child;
    
    -- pursue action
    node = node:GetParent();
    node = node:GetParent();
    child = CreateAction("pursue", PursueAction(userData));
    node:AddChild(child);
    node = child;
    
    -- move action
    node = node:GetParent();
    node = node:GetParent();
    node = node:GetParent();
    child = CreateSequence();
    node:AddChild(child);
    node = child;
    
    child = CreateCondition("has move position", SoldierEvaluators_HasMovePosition);
    node:AddChild(child);
    node = child;
    
    node = node:GetParent();
    child = CreateAction("move to position", MoveAction(userData));
    node:AddChild(child);
    node = child;
    
    -- random action
    node = node:GetParent();
    node = node:GetParent();
    child = CreateSequence();
    node:AddChild(child);
    node = child;
    
    child = CreateCondition("50/50 chance", SoldierEvaluators_Random);
    node:AddChild(child);
    node = child;
    
    node = node:GetParent();
    child = CreateAction("random move", RandomMoveAction(userData));
    node:AddChild(child);
    node = child;
    
    -- idle action
    node = node:GetParent();
    node = node:GetParent();
    child = CreateAction("idle", IdleAction(userData));
    node:AddChild(child);
    node = child;
    
    return tree;
end