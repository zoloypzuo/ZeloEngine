AnimationTransition = {};

function AnimationTransition.new()
    local transition = {};

    -- 混合曲线
    -- The blend curve determines how two animation states are blended
    -- together.
    transition.blendCurve_ = "linear";

    -- 混入窗口偏移
    -- The "to" animation state will start the animation at the blend in
    -- window time.
    -- ex: A value of 0.5 will start to blend the animation 0.5 seconds into
    -- the animation.
    transition.blendInWindow_ = 0;

    -- 混出窗口偏移
    -- The "from" animation state's length minus the blend out window time
    -- determines when the animation state machine will transition to the
    -- next animation state.
    -- ex: If the animation is 2.0 seconds long with a 0.5 second blend out
    -- window then the new animation will start blending in as early as the
    -- 1.5 second mark in the animation
    transition.blendOutWindow_ = 0;

    -- 动画混合时间
    -- The duration of the blend controls how long one state will blend into
    -- the next state.
    -- This is the minimum amount of time before a new animation can be
    -- selected.
    transition.duration_ = 0.2;

    return transition;
end