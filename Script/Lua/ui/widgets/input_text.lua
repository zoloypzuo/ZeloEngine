-- input_text
-- created on 2021/8/22
-- author @zoloypzuo
local widget = require("ui.widget")

-- public DataWidget<std::string>
local InputText = Class(widget.AWidget, function(self, parent, content, label)
    widget.AWidget._ctor(self, parent)
    self.content = content or "?"
    self.label = label or ""
    self.selectAllOnClick = false
    self.ContentChangedEvent = EventProcessor()
    self.EnterPressedEvent = EventProcessor()
end)

function InputText:_UpdateImpl()
    -- std::string previousContent = content;
    --
    --content.resize(256,);
    --bool enterPressed = ImGui::InputText((label + m_widgetID).c_str(), &content[0], 256,
    --                                        ImGuiInputTextFlags_EnterReturnsTrue |
    --                                        (selectAllOnClick ? ImGuiInputTextFlags_AutoSelectAll : 0));
    --content = content.c_str();
    --
    --if (content != previousContent) {
    --    ContentChangedEvent.Invoke(content);
    --    this->NotifyChange();
    --}
    --
    --if (enterPressed)
    --    EnterPressedEvent.Invoke(content);
    local text, selected = ImGui.InputText(self.label, "?", 256)
    print(text, tostring(selected))
end

return { InputText = InputText }