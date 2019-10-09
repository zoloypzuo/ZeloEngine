AnimationUtilities = {}

local function clamp(min, max, value)
    if (value < min) then
        return min;
    elseif (value > max) then
        return max;
    end

    return value;
end

-- time is in seconds
function AnimationUtilities_LinearBlendIn(
        animation, blendTime, startTime, currentTime)

    blendTime = clamp(0.01, blendTime, blendTime);
    local percent = clamp(0, 1, (currentTime - startTime) / blendTime);

    Animation.SetWeight(animation, percent);
end

-- time is in seconds
function AnimationUtilities_LinearBlendOut(
        animation, blendTime, startTime, currentTime)

    blendTime = clamp(0.01, blendTime, blendTime);
    local percent = clamp(0, 1, (currentTime - startTime) / blendTime);

    Animation.SetWeight(animation, 1 - percent);
end

-- time is in seconds
function AnimationUtilities_LinearBlendTo(
        startAnimation, endAnimation, blendTime, startTime, currentTime)
    AnimationUtilities_LinearBlendIn(
            endAnimation, blendTime, startTime, currentTime);
    AnimationUtilities_LinearBlendOut(
            startAnimation, blendTime, startTime, currentTime);
end

-- Steps the animation to keep in sync with the reference animation.
-- This is useful when blending two looped animations together that are
-- authored to be the same length with the same foot placement.
function AnimationUtilities_StepSynced(referenceAnimation, animation)
    local normalizedTime = Animation.GetNormalizedTime(referenceAnimation);

    Animation.SetTime(Animation.GetLength(animation) * normalizedTime);
end