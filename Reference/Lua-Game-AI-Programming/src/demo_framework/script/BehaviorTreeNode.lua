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

BehaviorTreeNode = {};

-- All possible behavior tree node types.
BehaviorTreeNode.Type = {
    ACTION = "ACTION",
    CONDITION = "CONDITION",
    SELECTOR = "SELECTOR",
    SEQUENCE = "SEQUENCE"
};

function BehaviorTreeNode.AddChild(self, child, index)
    index = index or (#self.children_ + 1);
    
    table.insert(self.children_, index, child);
    
    child.parent_ = self;
end

function BehaviorTreeNode.ChildIndex(self, child)
    for index=1, #self.children_ do
        if (self.children_[index] == child) then
            return index;
        end
    end
    
    return -1;
end

function BehaviorTreeNode.GetChild(self, childIndex)
    return self.children_[childIndex];
end

function BehaviorTreeNode.GetNumberOfChildren(self)
    return #self.children_;
end

function BehaviorTreeNode.GetParent(self)
    return self.parent_;
end

function BehaviorTreeNode.SetAction(self, action)
    self.action_ = action;
end

function BehaviorTreeNode.SetEvaluator(self, evaluator)
    self.evaluator_ = evaluator;
end

function BehaviorTreeNode.SetType(self, type)
    self.type_ = type;
end

function BehaviorTreeNode.new(name, type)
    local node = {};
    
    -- The BehaviorTreeNode's data members.
    node.action_ = nil;
    node.children_ = {};
    node.evaluator_ = nil;
    node.name_ = name or "";
    node.parent_ = nil;
    node.type_ = type or BehaviorTreeNode.Type.ACTION;
    
    -- The BehaviorTreeNode's accessor functions.
    node.AddChild = BehaviorTreeNode.AddChild;
    node.ChildIndex = BehaviorTreeNode.ChildIndex;
    node.GetChild = BehaviorTreeNode.GetChild;
    node.GetNumberOfChildren = BehaviorTreeNode.GetNumberOfChildren;
    node.GetParent = BehaviorTreeNode.GetParent;
    node.SetAction = BehaviorTreeNode.SetAction;
    node.SetEvaluator = BehaviorTreeNode.SetEvaluator;
    node.SetType = BehaviorTreeNode.SetType;
    
    return node;
end