AnimationState = {};

function AnimationState.new()
    local state = {};

    -- Contains the Ogre AnimationState animation.
    state.animation_ = nil;
    
    -- The name of the animation state, this must be unique within the
    -- animation state machine.
    state.name_ = "";
    
    -- Whether the animation is looping.
    state.looping_ = false;
    
    -- How fast the animation should play.
    state.rate_ = 1;
    
    return state;
end