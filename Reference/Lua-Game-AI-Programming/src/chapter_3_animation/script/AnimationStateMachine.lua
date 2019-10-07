require "AnimationState";
require "AnimationTransition";
require "AnimationUtilities";

AnimationStateMachine = {};

function AnimationStateMachine.new()
    local asm = {};

    --
    -- data members
    --

    -- 当前状态
    asm.currentState_ = nil;
    -- 当前转换
    asm.currentTransition_ = nil;
    -- 准备转换到的下一个状态
    asm.nextState_ = nil;
    -- 状态列表
    asm.states_ = {};
    -- 状态回调列表
    asm.stateCallbacks_ = {};
    -- 转换列表
    asm.transitions_ = {};
    -- 转换开始时间
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

--
-- 辅助函数，初始化，更新和清除
--

local function InitializeAnimation(animation, startTime)
    Animation.Reset(animation);
    Animation.SetEnabled(animation, true);
    Animation.SetWeight(animation, 1);

    if (startTime ~= nil) then
        Animation.SetTime(animation, startTime);
    end
end

-- 更新动画，可以指定动画播放速率
local function StepAnimation(animation, deltaTimeInMillis, rate)
    rate = rate or 1;
    Animation.StepAnimation(animation, deltaTimeInMillis * rate);
end

-- 禁用动画片段后动画不再参与混合
local function ClearAnimation(animation)
    Animation.SetEnabled(animation, false);
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

-- 添加状态
-- 名字要确保唯一
function AnimationStateMachine:AddState(name, animation, looping, rate)
    local state = AnimationState.new();
    state.name_ = name;
    state.animation_ = animation;
    state.rate_ = rate or state.rate_;
    state.looping_ = looping or state.looping_;

    self.states_[name] = state;

    ClearAnimation(animation);
    Animation.SetLooping(animation, state.looping_);
end

-- 添加转换
function AnimationStateMachine:AddTransition(
        fromStateName, toStateName, blendOutWindow, duration, blendInWindow)
    assert(self:ContainsState(fromStateName) and
            self:ContainsState(toStateName))

    local transition = AnimationTransition.new();
    transition.blendOutWindow_ = blendOutWindow or transition.blendOutWindow_;
    transition.duration_ = duration or transition.duration_;
    transition.blendInWindow_ = blendInWindow or transition.blendInWindow_;

    if (self.transitions_[fromStateName] == nil) then
        self.transitions_[fromStateName] = {};
    end

    self.transitions_[fromStateName][toStateName] = transition;
end

function AnimationStateMachine:ContainsState(stateName)
    return self.states_[stateName] ~= nil;
end

function AnimationStateMachine:ContainsTransition(fromStateName, toStateName)
    return self.transitions_[fromStateName] ~= nil and
            self.transitions_[fromStateName][toStateName] ~= nil;
end

function AnimationStateMachine.GetCurrentStateName(self)
    if (self.currentState_) then
        return self.currentState_.name_;
    end
end

-- 请求转换状态
--
-- 因为动画的播放，转换都是有过程的，所以请求转换会等待上一个转换结束再开始执行转换
-- 状态转换是原子性的，一个时刻至多一个转换请求
function AnimationStateMachine.RequestState(self, stateName)
    -- Ignore all new requests when a request is pending.（当现在正在进行转换时忽略其他转换请求）
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

-- 强制设置状态
--
-- 名字建议加上Force
-- 强制设置状态会导致动画跳动
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

local function CallCallbacks(callbacks, stateName)
    for index = 1, #callbacks do
        callbacks[index].callback(stateName, callbacks[index].data);
    end
end

local function HandleCallbacks(self, stateName)
    if (self.stateCallbacks_[stateName]) then
        CallCallbacks(self.stateCallbacks_[stateName], stateName);
    end
end

function AnimationStateMachine.Update(self, deltaTimeInMillis, currentTimeInMillis)
    local deltaTimeInSeconds = deltaTimeInMillis / 1000;
    local currentTimeInSeconds = currentTimeInMillis / 1000;

    --
    -- See if we can move to the next state, either through a transition or directly.（如果当前没有转换，直接进入下一个状态）
    --
    if (self.currentTransition_ == nil and self.nextState_) then
        local currentAnimTime = Animation.GetTime(self.currentState_.animation_);
        local currentAnimLength = Animation.GetLength(self.currentState_.animation_);
        local deltaTime = deltaTimeInSeconds * self.currentState_.rate_;

        if (self:ContainsTransition(self.currentState_.name_, self.nextState_.name_)) then
            local transition = self.transitions_[self.currentState_.name_][self.nextState_.name_];
            -- 如果混合窗口时间过了，进入下一个状态
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

    --
    -- Step animations that are currently playing.（更新运行中的动画）
    --
    if (self.currentTransition_) then
        -- The asm is currently transitioning to the next state.
        AnimationUtilities_LinearBlendTo(
                self.currentState_.animation_,
                self.nextState_.animation_,
                self.currentTransition_.duration_,
                self.transitionStartTime_,
                currentTimeInSeconds);

        StepAnimation(
                self.currentState_.animation_,
                deltaTimeInMillis,
                self.currentState_.rate_);
        StepAnimation(
                self.nextState_.animation_,
                deltaTimeInMillis,
                self.currentState_.rate_);

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
