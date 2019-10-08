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
    for index = 1, #self.children_ do
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