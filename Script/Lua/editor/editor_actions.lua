-- editor_actions
-- created on 2021/8/25
-- author @zoloypzuo
local EditorActions = Class(function(self)

end)

function EditorActions:MoveToTarget()

end

function EditorActions:DelayAction(action, delayInFrame)
    delayInFrame = delayInFrame or 1
    scheduler:ExecuteInTime(delayInFrame * FRAME, action)
end

function EditorActions:DestroyEntity()

end

function EditorActions:UnselectEntity()

end

function EditorActions:DuplicateEntity(entityToDuplicate, forcedParent, focus) -- Entity, Entity, bool
    
end

TheEditorActions = EditorActions()