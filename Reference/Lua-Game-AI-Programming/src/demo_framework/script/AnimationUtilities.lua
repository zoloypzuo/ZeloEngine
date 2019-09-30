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