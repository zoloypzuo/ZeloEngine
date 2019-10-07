require "Action"

DecisionTree = {};

function DecisionTree.SetBranch(self, branch)
    self.branch_ = branch;
end

function DecisionTree.Update(self, deltaTimeInMillis)
    -- Skip execution if the tree hasn't been setup yet.
    if (self.branch_ == nil) then
        return;
    end

    -- Search the tree for an Action to run if not currently
    -- executing an Action.
    if (self.currentAction_ == nil) then
        self.currentAction_ = self.branch_:Evaluate();

        self.currentAction_:Initialize();
    end
    
    local status = self.currentAction_:Update(deltaTimeInMillis);
    
    -- Clean up the Action once it has terminated.
    if (status == Action.Status.TERMINATED) then
        self.currentAction_:CleanUp();
        self.currentAction_ = nil;
    end
end

function DecisionTree.new()
    local decisionTree = {};
    
    -- The DecisionTree's data members.
    decisionTree.branch_ = nil;
    decisionTree.currentAction_ = nil;
    
    -- The DecisionTree's accessor functions.
    decisionTree.SetBranch = DecisionTree.SetBranch;
    decisionTree.Update = DecisionTree.Update;
    
    return decisionTree;
end