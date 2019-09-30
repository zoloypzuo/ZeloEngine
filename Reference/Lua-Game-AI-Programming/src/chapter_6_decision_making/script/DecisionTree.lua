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