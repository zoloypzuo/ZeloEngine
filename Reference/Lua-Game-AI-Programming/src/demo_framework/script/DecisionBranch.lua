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