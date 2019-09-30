-- Animation.lua

---@class Animation
Animation = {}

---@param displaySkeleton boolean
function Animation.SetDisplaySkeleton(mesh, displaySkeleton)
end

function Animation.GetAnimation(mesh, clipPath)
end

function Animation.IsEnabled(anim)

end

---@type fun(anim:Animation,bool:boolean) @comment 启用动画，一个动画片段启用代表参与混合
function Animation.SetEnabled(anim, bool)
end

function Animation.StepAnimation(anim, bool)
end

---@type fun(anim:Animation) @comment 循环，是则循环播放，否则维持在最后一个关键帧
function Animation.IsLooping(anim)
end

function Animation.SetLooping(anim, bool)

end

---@type fun() @comment 书没翻译好
-- TODO 书的小节标题，但是现在时间紧，不去补文档，完善
function Animation.GetLength()

end

function Animation.GetTime(anim)

end
--{{{
-- Animation.lua
function Animation.__towatch(agent)
end
function Animation.AttachToBone(agent)
end
function Animation.GetAnimation(agent)
end
function Animation.GetBoneNames(agent)
end
function Animation.GetBonePosition(agent)
end
function Animation.GetBoneRotation(agent)
end
function Animation.GetLength(agent)
end
function Animation.GetName(agent)
end
function Animation.GetNormalizedTime(agent)
end
function Animation.GetTime(agent)
end
function Animation.GetWeight(agent)
end
function Animation.IsEnabled(agent)
end
function Animation.IsLooping(agent)
end
function Animation.Reset(agent)
end
function Animation.SetDisplaySkeleton(agent)
end
function Animation.SetEnabled(agent)
end
function Animation.SetLooping(agent)
end
function Animation.SetNormalizedTime(agent)
end
function Animation.SetTime(agent)
end
function Animation.SetWeight(agent)
end
function Animation.StepAnimation(agent)
end
--}}}
return Animation