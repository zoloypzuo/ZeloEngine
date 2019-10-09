DecisionBranch = {}

DecisionBranch.Type = "DecisionBranch";

function DecisionBranch.AddChild(self, child, index)
    -- Add the child at the specified index, or as the last child.
    index = index or (#self.children_ + 1);

    table.insert(self.children_, index, child);
end

function DecisionBranch.Evaluate(self)
    assert(self.evaluator_);
    -- Execute the branch's evaluator function, this much return a numeric
    -- value which indicates what child should execute.
    local eval = self.evaluator_();

    assert(type(eval) == "number", "evaluator must return a number");
    assert(eval <= #self.children_, "evaluator must choose a child to execute");

    local choice = self.children_[eval];

    if (choice.type_ == DecisionBranch.Type) then
        -- Recursively evaluate children that are decisions branches.
        return choice:Evaluate();
    else
        -- Return the leaf action.
        return choice;
    end
end

function DecisionBranch.SetEvaluator(self, evaluator)
    assert(type(evaluator) == "function", "evaluator must be a function");
    self.evaluator_ = evaluator;
end

function DecisionBranch.new()
    local branch = {};

    -- The DecisionBranch's data members.
    branch.children_ = {};
    branch.evaluator_ = nil;
    branch.type_ = DecisionBranch.Type;

    -- The DecisionBranch's accessor functions.
    branch.AddChild = DecisionBranch.AddChild;
    branch.Evaluate = DecisionBranch.Evaluate;
    branch.SetEvaluator = DecisionBranch.SetEvaluator;

    return branch;
end