-- editor_actions
-- created on 2021/8/25
-- author @zoloypzuo
local EditorActions = Class(function(self)
    self.processor = EventProcessor()
    self.OnSelectEntity = EventWrapper(self.processor, "OnSelectEntity")
end)

function EditorActions:MoveToTarget(entity)
    print("MoveToTarget not implemented")
end

function EditorActions:DelayAction(delayInFrame, action, ...)
    delayInFrame = delayInFrame or 1
    scheduler:ExecuteInTime(delayInFrame * FRAME, self[action], nil, ...)
end

function EditorActions:DestroyEntity()
    print("DestroyEntity not implemented")
end

function EditorActions:SelectEntity(entity)
    self.OnSelectEntity:HandleEvent(entity)
end

function EditorActions:UnselectEntity()
    print("UnselectEntity not implemented")
end

function EditorActions:DuplicateEntity(entityToDuplicate, forcedParent, focus)
    -- Entity, Entity, bool
    print("DuplicateEntity not implemented", entityToDuplicate, forcedParent, focus)
end

function EditorActions:ResetLayout()
    print("ResetLayout")
    UI:ResetLayout("Config/default_layout.ini")
end

function EditorActions:LoadSandbox(name)
    print("LoadSandbox", name)
    local file = io.open("project_hub.txt", "w")
    file:write(name)
    file:close()
    PushEngine()
    Quit()
end

TheEditorActions = EditorActions()
