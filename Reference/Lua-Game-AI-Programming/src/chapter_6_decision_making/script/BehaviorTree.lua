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

require "BehaviorTreeNode"

BehaviorTree = {};

local _EvaluateSelector;
local _EvaluateSequence;

_EvaluateSelector = function(self, node, deltaTimeInMillis)
    -- Try and evaluate all children.  Returns the first child that can
    -- execute.  If no child can successfully execute the selector fails.

    for index = 1, #node.children_ do
        local child = node:GetChild(index);
        
        if (child.type_ == BehaviorTreeNode.Type.ACTION) then
            -- Execute all Actions, since Actions cannot fail.
            return { node = child, result = true};
        elseif (child.type_ == BehaviorTreeNode.Type.CONDITION) then
            -- Conditions are only valid within sequences, if one is
            -- encountered in a selector the tree is malformed.
            assert(false);
            return { result = false };
        elseif (child.type_ == BehaviorTreeNode.Type.SELECTOR) then
            -- Recursively evaluate child selectors.
            local result = _EvaluateSelector(self, child, deltaTimeInMillis);
            if (result.result) then
                return result;
            end
        elseif (child.type_ == BehaviorTreeNode.Type.SEQUENCE) then
            -- Evaluate a sequence, if it returns successfully then return the
            -- result.
            -- The result of a sequence may not contain a node to execute.
            local result = _EvaluateSequence(self, child, deltaTimeInMillis);
            if (result.result) then
                return result;
            end
        end
    end
    
    return { result = false };
end

_EvaluateSequence = function(self, node, deltaTimeInMillis, index)
    -- Try and evaluate all children.  Returns a false result if a child is
    -- unable to execute, such as a condition failing or child
    -- sequence/selector being unable to find a valid Action to run.
    index = index or 1;

    for count=index, #node.children_ do
        local child = node:GetChild(count);
        
        if (child.type_ == BehaviorTreeNode.Type.ACTION) then
            -- Execute all Actions, since Actions cannot fail.
            return { node = child, result = true};
        elseif (child.type_ == BehaviorTreeNode.Type.CONDITION) then
            local result = child.evaluator_(self.userData_);
        
            -- Break out of execution if a condition fails.
            if (not child.evaluator_(self.userData_)) then
                return { result = false };
            end
        elseif (child.type_ == BehaviorTreeNode.Type.SELECTOR) then
            local result = _EvaluateSelector(self, child, deltaTimeInMillis);
            
            -- Unable to find an Action to run, return failure.
            if (not result.result) then
                return { result = false };
            elseif (result.result and result.node ~= nil) then
                -- Found an Action to execute, pass the result back to the
                -- caller.
                return result;
            end
            
            -- A selector must return an Action to be considered successful,
            -- if no Action was found, then the selectored failed.
        elseif (child.type_ == BehaviorTreeNode.Type.SEQUENCE) then
            local result = _EvaluateSequence(self, child, deltaTimeInMillis);
            
            -- Sequence reported failure, propagate failure to the caller.
            if (not result.result) then
                return { result = false };
            elseif (result.result and result.node ~= nil) then
                -- Found an Action to execute, pass the result back to the
                -- caller.
                return result;
            end

            -- There is a third possible case, the sequence completed
            -- successfully and has no additiona children to execute.
            -- In that case let the sequence continue executing additional
            -- children.
        end
        
        -- Move to the next child to execute.
        count = count + 1;
    end
    
    -- Returns success without an Action to run if all children executed
    -- successfully.
    return { result = true };
end

local function _EvaluateNode(self, node, deltaTimeInMillis)
    if (node.type_ == BehaviorTreeNode.Type.ACTION) then
        -- No further evaluation is necessary if an Action is found.
        return node;
    elseif (node.type_ == BehaviorTreeNode.Type.CONDITION) then
        -- Conditions should be evaluated immediately, if the behavior tree
        -- is trying to evaluate this node, there is something structurally
        -- wrong in the behavior tree.
        assert(false);  -- invalid structure
    elseif (node.type_ == BehaviorTreeNode.Type.SELECTOR) then
        -- Treat the node like a selector and find the first valid child action.
        local result = _EvaluateSelector(self, node, deltaTimeInMillis);
        if (result.result) then
            return result.node;
        end
    elseif (node.type_ == BehaviorTreeNode.Type.SEQUENCE) then
        -- Treat the node like a sequence and find the first valid child action.
        local result = _EvaluateSequence(self, node, deltaTimeInMillis);
        if (result.result) then
            return result.node;
        end
    end
end

local function _ContinueEvaluation(self, node, deltaTimeInMillis)
    local parentNode = node:GetParent();
    local childNode = node;

    -- Navigates upward within the tree to find any sequences that require
    -- continued evaluation.
    while (parentNode ~= nil) do
        if (parentNode.type_ == BehaviorTreeNode.Type.SEQUENCE) then
            -- Found a sequence, continue evaluating from the current
            -- executing node within the sequence.
            local childIndex = parentNode:ChildIndex(childNode);
            
            -- So long as the executing child was not the last node within
            -- the sequence, evaluate the sequence starting on the next child
            -- node.
            if (childIndex < parentNode:GetNumberOfChildren()) then
                return _EvaluateSequence(
                    self,
                    parentNode,
                    deltaTimeInMillis,
                    childIndex + 1);
            end
        end
        
        -- Move one parent up in the tree.
        childNode = parentNode;
        parentNode = childNode:GetParent();
    end
end

function BehaviorTree.SetNode(self, node)
    self.node_ = node;
end

function BehaviorTree.Update(self, deltaTimeInMillis)
    if (self.currentNode_ == nil) then
        -- Find the first valid Action to execute.
        self.currentNode_ = _EvaluateNode(self, self.node_, deltaTimeInMillis);
    end

    if (self.currentNode_ ~= nil) then
        local status = self.currentNode_.action_.status_;
        
        if (status == Action.Status.UNINITIALIZED) then
            self.currentNode_.action_:Initialize();
        elseif (status == Action.Status.TERMINATED) then
            self.currentNode_.action_:CleanUp();

            -- Continue evaluation in case the Action's parent was a sequence.
            -- _ContinueEvaluation can return nil, in case the tree needs to be
            -- reevaluated.
            self.currentNode_ = _ContinueEvaluation(
                self, self.currentNode_, deltaTimeInMillis);
        elseif (status == Action.Status.RUNNING) then
            self.currentNode_.action_:Update(deltaTimeInMillis);
        end
    end
end

function BehaviorTree.new(userData)
    local tree = {};
    
    -- The BehaviorTree's data members.
    tree.currentNode_ = nil;
    tree.node_ = nil;
    tree.userData_ = userData;
    
    -- The BehaviorTree's accessor functions.
    tree.SetNode = BehaviorTree.SetNode;
    tree.Update = BehaviorTree.Update;
    
    return tree;
end