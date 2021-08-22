-- input_text
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")

-- public DataWidget<std::string>
local InputText = Class(AWidget, function(self, parent, content, label)
    AWidget._ctor(self, parent)
    self.content = content or "?"
    self.label = label or ""
    self.selectAllOnClick = false
    self.ContentChangedEvent = EventProcessor()
    self.EnterPressedEvent = EventProcessor()
end)

function InputText:_UpdateImpl()
    --if (content != previousContent) {
    --    ContentChangedEvent.Invoke(content);
    --    this->NotifyChange();
    --}
    local flag = 0
    if self.selectAllOnClick then
        flag = bit.bor(ImGuiInputTextFlags.EnterReturnsTrue, ImGuiInputTextFlags.AutoSelectAll)
    else
        flag = ImGuiInputTextFlags.EnterReturnsTrue
    end
    local text, selected = ImGui.InputText(self.label, self.content, 256, flag)

    if text ~= self.content then
        self.content = text
        self:_OnContentChanged(text)
    end

    if selected then
        self:_OnEnterPressed()
    end
end

function InputText:AddOnContentChangedHandler(fn)
    self.ContentChangedEvent:AddEventHandler("on_content_changed", fn)
end

function InputText:_OnContentChanged(content)
    self.ContentChangedEvent:HandleEvent("on_content_changed", content)
end

function InputText:AddOnEnterPressedHandler(fn)
    self.ContentChangedEvent:AddEventHandler("on_enter_pressed", fn)
end

function InputText:_OnEnterPressed()
    self.ContentChangedEvent:HandleEvent("on_enter_pressed")
end

return InputText