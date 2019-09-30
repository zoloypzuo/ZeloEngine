require "AnimationState";
require "AnimationTransition";
require "AnimationUtilities";

AnimationStateMachine = {};

local function CallCallbacks(callbacks, stateName)
    for index = 1, #callbacks do
        callbacks[index].callback(stateName, callbacks[index].data);
    end
end

local function ClearAnimation(animation)
    Animation.SetEnabled(animation, false);
end

local function HandleCallbacks(self, stateName)
    if (self.stateCallbacks_[stateName]) then
        CallCallbacks(self.stateCallbacks_[stateName], stateName);
    end
end

local function InitializeAnimation(animation, startTime)
    Animation.Reset(animation);
    Animation.SetEnabled(animation, true);
    Animation.SetWeight(animation, 1);
    
    if (startTime ~= nil) then
        Animation.SetTime(animation, startTime);
    end
end

local function StepAnimation(animation, deltaTimeInMillis, rate)
    rate = rate or 1;
    
    Animation.StepAnimation(animation, deltaTimeInMillis * rate);
end

function AnimationStateMachine.AddStateCallback(self, name, callback, data)
    if (self:ContainsState(name)) then
        if (not self.stateCallbacks_[name]) then
            self.stateCallbacks_[name] = {};
        end
        table.insert(
            self.stateCallbacks_[name], { callback = callback, data = data });
    end
end

function AnimationStateMachine.AddState(self, name, animation, looping, rate)
    local state = AnimationState.new();
    state.name_ = name;
    state.animation_ = animation;
    state.rate_ = rate or state.rate_;
    state.looping_ = looping or state.looping_;
    
    self.states_[name] = state;
    
    ClearAnimation(animation);
    Animation.SetLooping(animation, state.looping_);
end

function AnimationStateMachine.AddTransition(
    self, fromStateName, toStateName, blendOutWindow, duration, blendInWindow)
    if (self:ContainsState(fromStateName) and
        self:ContainsState(toStateName)) then
        
        local transition = AnimationTransition.new();
        transition.blendOutWindow_ = blendOutWindow or transition.blendOutWindow_;
        transition.duration_ = duration or transition.duration_;
        transition.blendInWindow_ = blendInWindow or transition.blendInWindow_;
        
        if (self.transitions_[fromStateName] == nil) then
            self.transitions_[fromStateName] = {};
        end
        
        self.transitions_[fromStateName][toStateName] = transition;
    end
end

function AnimationStateMachine.ContainsState(self, stateName)
    return self.states_[stateName] ~= nil;
end

function AnimationStateMachine.ContainsTransition(self, fromStateName, toStateName)
    return self.transitions_[fromStateName] ~= nil and
        self.transitions_[fromStateName][toStateName] ~= nil;
end

function AnimationStateMachine.GetCurrentStateName(self)
    if (self.currentState_) then
        return self.currentState_.name_;
    end
end

function AnimationStateMachine.RequestState(self, stateName)
    -- Ignore all new requests when a request is pending.
    if (self.nextState_ == nil and self:ContainsState(stateName)) then
        local currentState = self.currentState_;
        
        -- Immediately set the requested state if no state exists.
        if (currentState == nil) then
          self:SetState(stateName);
        else
           self.nextState_ = self.states_[stateName];
        end
        
        return true;
    end
    return false;
end

function AnimationStateMachine.SetState(self, stateName)
    if (self:ContainsState(stateName)) then
        if (self.currentState_) then
            ClearAnimation(self.currentState_.animation_);
        end
        if (self.nextState_) then
            ClearAnimation(self.nextState_.animation_);
        end
        
        self.nextState_ = nil;
        self.currentTransition_ = nil;
        self.transitionStartTime_ = nil;
        self.currentState_ = self.states_[stateName];
        InitializeAnimation(self.currentState_.animation_);
    end
end

function AnimationStateMachine.Update(self, deltaTimeInMillis, currentTimeInMillis)
    local deltaTimeInSeconds = deltaTimeInMillis/1000;
    local currentTimeInSeconds = currentTimeInMillis/1000;
    
    -- See if we can move to the next state, either through a transition or directly.
    if (self.currentTransition_ == nil and self.nextState_) then
        local currentAnimTime = Animation.GetTime(self.currentState_.animation_);
        local currentAnimLength = Animation.GetLength(self.currentState_.animation_);
        local deltaTime = deltaTimeInSeconds * self.currentState_.rate_;

        if (self:ContainsTransition(self.currentState_.name_, self.nextState_.name_)) then
            local transition =
                self.transitions_[self.currentState_.name_][self.nextState_.name_];

            if ((currentAnimTime + deltaTime) >=
                (currentAnimLength - transition.blendOutWindow_)) then
                
                self.currentTransition_ = transition;
                self.transitionStartTime_ = currentTimeInSeconds;
                InitializeAnimation(
                    self.nextState_.animation_, transition.blendInWindow_);

                HandleCallbacks(self, self.nextState_.name_);
            end
        else
            if ((currentAnimTime + deltaTimeInSeconds) >= currentAnimLength) then
                -- Current animation finished, move to the next state without blending.
                ClearAnimation(self.currentState_.animation_);
                InitializeAnimation(self.nextState_.animation_);
                
                self.currentState_ = self.nextState_;
                self.nextState_ = nil;
                
                HandleCallbacks(self, self.currentState_.name_);
            end
        end
    end

    -- Step animations that are currently playing.
    if (self.currentTransition_) then
        -- The asm is currently transitioning to the next state.
        AnimationUtilities_LinearBlendTo(
            self.currentState_.animation_,
            self.nextState_.animation_,
            self.currentTransition_.duration_,
            self.transitionStartTime_,
            currentTimeInSeconds);

        StepAnimation(
            self.currentState_.animation_, deltaTimeInMillis, self.currentState_.rate_);
        StepAnimation(
            self.nextState_.animation_, deltaTimeInMillis, self.currentState_.rate_);

        -- The current state's animation ended.
        if (Animation.GetWeight(self.currentState_.animation_) == 0) then
            ClearAnimation(self.currentState_.animation_);
            self.currentState_ = self.nextState_;
            self.nextState_ = nil;
            self.currentTransition_ = nil;
            self.transitionStartTime_ = nil;
        end
    elseif (self.currentState_) then
        local currentAnimTime = Animation.GetTime(self.currentState_.animation_);
        local currentAnimLength = Animation.GetLength(self.currentState_.animation_);
        local deltaTime = deltaTimeInSeconds * self.currentState_.rate_;
        
        local timeStepped = (currentAnimTime + deltaTime);
        
        while timeStepped >= currentAnimLength do
            HandleCallbacks(self, self.currentState_.name_);
            
            timeStepped = timeStepped - currentAnimLength;
        end
        
        StepAnimation(
            self.currentState_.animation_, deltaTimeInMillis, self.currentState_.rate_);
    end
end

function AnimationStateMachine.new()
    local asm = {};
    
    -- data members
    asm.currentState_ = nil;
    asm.currentTransition_ = nil;
    asm.nextState_ = nil;
    asm.states_ = {};
    asm.stateCallbacks_ = {};
    asm.transitions_ = {};
    asm.transitionStartTime_ = nil;
    
    -- object functions
    asm.AddState = AnimationStateMachine.AddState;
    asm.AddStateCallback = AnimationStateMachine.AddStateCallback;
    asm.AddTransition = AnimationStateMachine.AddTransition;
    asm.ContainsState = AnimationStateMachine.ContainsState;
    asm.ContainsTransition = AnimationStateMachine.ContainsTransition;
    asm.GetCurrentStateName = AnimationStateMachine.GetCurrentStateName;
    asm.RequestState = AnimationStateMachine.RequestState;
    asm.SetState = AnimationStateMachine.SetState;
    asm.Update = AnimationStateMachine.Update;
    
    return asm;
end