-- 动画的状态
AnimationState = {};

function AnimationState.new()
    local state = {};

    -- 动画
    -- Contains the Ogre AnimationState animation.
    state.animation_ = nil;

    -- 状态名
    -- The name of the animation state, this must be unique within the
    -- animation state machine.
    state.name_ = "";

    -- 状态是否循环
    -- Whether the animation is looping.
    state.looping_ = false;

    -- 动画播放速率
    -- How fast the animation should play.
    state.rate_ = 1;
    
    return state;
end