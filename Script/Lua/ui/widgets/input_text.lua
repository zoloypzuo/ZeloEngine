-- input_text
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")

local InputText = Class(AWidget, function(self, parent, content, label)
    AWidget._ctor(self, parent)
    self.content = content or "?"
    self.label = label or ""
    self.selectAllOnClick = false

    self.getter = nil
    self.setter = nil

    local processor = EventProcessor()
    self.ContentChangedEvent = EventWrapper(processor, "ContentChangedEvent")
    self.EnterPressedEvent = EventWrapper(processor, "EnterPressedEvent")
end)

function InputText:_UpdateImpl()
    local flag = 0
    if self.selectAllOnClick then
        flag = bit.bor(ImGuiInputTextFlags.EnterReturnsTrue, ImGuiInputTextFlags.AutoSelectAll)
    else
        flag = ImGuiInputTextFlags.EnterReturnsTrue
    end

    if self.getter then
        self.content = self.getter()
    end

    local label = self.label .. self.id
    local text, selected = ImGui.InputText(label, self.content, 256, flag)

    if text ~= self.content then
        self.content = text

        if self.setter then
            self.setter(text)
        end

        self.ContentChangedEvent:HandleEvent(text)
    end

    if selected then
        self.EnterPressedEvent:HandleEvent()
    end

    self.content = text
end

return InputText