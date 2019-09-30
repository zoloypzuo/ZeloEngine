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

require "Action";
require "FiniteState";
require "FiniteStateTransition";

FiniteStateMachine = {};

local function EvaluateTransitions(self, transitions)
    for index = 1, #transitions do
        -- Find the first transition that evaulates to true,
        -- return the state the transition points to.
        if (transitions[index].evaluator_(self.userData_)) then
            return transitions[index].toStateName_;
        end
    end
end

function FiniteStateMachine.AddState(self, name, action)
    self.states_[name] = FiniteState.new(name, action);
end

function FiniteStateMachine.AddTransition(
    self, fromStateName, toStateName, evaluator)
    -- Ensure both states exist within the FSM.
    if (self:ContainsState(fromStateName) and
        self:ContainsState(toStateName)) then

        if (self.transitions_[fromStateName] == nil) then
            self.transitions_[fromStateName] = {};
        end

        -- Add the new transition to the "from" state.
        table.insert(
            self.transitions_[fromStateName],
            FiniteStateTransition.new(toStateName, evaluator));
    end
end

function FiniteStateMachine.ContainsState(self, stateName)
    return self.states_[stateName] ~= nil;
end

function FiniteStateMachine.ContainsTransition(self, fromStateName, toStateName)
    return self.transitions_[fromStateName] ~= nil and
        self.transitions_[fromStateName][toStateName] ~= nil;
end

function FiniteStateMachine.GetCurrentStateName(self)
    if (self.currentState_) then
        return self.currentState_.name_;
    end
end

function FiniteStateMachine.GetCurrentStateStatus(self)
    if (self.currentState_) then
        return self.currentState_.action_.status_;
    end
end

function FiniteStateMachine.SetState(self, stateName)
    if (self:ContainsState(stateName)) then
        if (self.currentState_) then
            self.currentState_.action_:CleanUp();
        end
        
        self.currentState_ = self.states_[stateName];
        self.currentState_.action_:Initialize();
    end
end

function FiniteStateMachine.Update(self, deltaTimeInMillis)
    if (self.currentState_) then
        local status = self:GetCurrentStateStatus();
        
        if (status == Action.Status.RUNNING) then
            self.currentState_.action_:Update(deltaTimeInMillis);
        elseif (status == Action.Status.TERMINATED) then
            -- Evaluate all transitions to find the next state
            -- to move the FSM to.
            local toStateName =
                EvaluateTransitions(self, self.transitions_[self.currentState_.name_]);
            if (self.states_[toStateName] ~= nil) then
                self.currentState_.action_:CleanUp();
                self.currentState_ = self.states_[toStateName];
                self.currentState_.action_:Initialize();
            end
        end
    end
end

function FiniteStateMachine.new(userData)
    local fsm = {};

    -- The FiniteStateMachine's data members.
    fsm.currentState_ = nil;
    fsm.states_ = {};
    fsm.transitions_ = {};
    fsm.userData_ = userData;

    -- The FiniteStateMachine's accessor functions.
    fsm.AddState = FiniteStateMachine.AddState;
    fsm.AddTransition = FiniteStateMachine.AddTransition;
    fsm.ContainsState = FiniteStateMachine.ContainsState;
    fsm.ContainsTransition = FiniteStateMachine.ContainsTransition;
    fsm.GetCurrentStateName = FiniteStateMachine.GetCurrentStateName;
    fsm.GetCurrentStateStatus = FiniteStateMachine.GetCurrentStateStatus;
    fsm.SetState = FiniteStateMachine.SetState;
    fsm.Update = FiniteStateMachine.Update;

    return fsm;
end