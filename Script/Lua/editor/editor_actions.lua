-- editor_actions
-- created on 2021/8/25
-- author @zoloypzuo
local EditorActions = Class(function(self)
    self.processor = EventProcessor()
    self.OnSelectEntity = EventWrapper(self.processor, "OnSelectEntity")
end)

function EditorActions:MoveToTarget(entity)
    print("MoveToTarget")
end

function EditorActions:DelayAction(delayInFrame, action, ...)
    delayInFrame = delayInFrame or 1
    scheduler:ExecuteInTime(delayInFrame * FRAME, self[action], nil, ...)
end

function EditorActions:DestroyEntity()
    print("DestroyEntity")
end

function EditorActions:SelectEntity(entity)
    print("SelectEntity")
    self.OnSelectEntity:HandleEvent(entity)
end

function EditorActions:UnselectEntity()
    print("UnselectEntity")
end

function EditorActions:DuplicateEntity(entityToDuplicate, forcedParent, focus)
    -- Entity, Entity, bool
    print("DuplicateEntity", entityToDuplicate, forcedParent, focus)
end

TheEditorActions = EditorActions()
