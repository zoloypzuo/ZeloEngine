-- widget
-- created on 2021/8/21
-- author @zoloypzuo
local AWidget = require("ui.widget")

local function WidgetSimple(name)
    -- simple stateless widget
    --
    -- Example:
    -- local Text = Class(AWidget, function(self, parent, content)
    --    AWidget._ctor(self, parent)
    --    self.content = content or ""
    -- end)
    --
    -- function Text:_UpdateImpl()
    --    ImGui.Text(self.content)
    -- end

    -- =>
    -- Text = WidgetSimple("Text")
    local cls = Class(AWidget, function(self, parent, ...)
        AWidget._ctor(self, parent)
        self.args = { ... }
    end)

    function cls:_UpdateImpl()
        assert(ImGui[name])
        ImGui[name](unpack(self.args))
    end

    return cls
end

return WidgetSimple