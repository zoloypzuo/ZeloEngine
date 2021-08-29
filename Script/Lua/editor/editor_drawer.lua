-- editor_drawer
-- created on 2021/8/25
-- author @zoloypzuo
local PanelWindow = require("ui.panel_window")
local Button = require("ui.widgets.button")
local InputText = require("ui.widgets.input_text")
local Spacing = require("ui.layouts.spacing")
local Separator = require("ui.widgets.separator")
local Columns = require("ui.layouts.column")
local Text = require("ui.widgets.text")
local TextColored = require("ui.widgets.text_colored")
local Group = require("ui.layouts.group")
local TreeNode = require("ui.layouts.tree_node")
local ContextualMenu = require("ui.plugins.contextual_menu")
local MenuItem = require("ui.widgets.menu_item")
local MenuList = require("ui.widgets.menu_list")
local CheckBox = require("ui.widgets.checkbox")
local DragFloat3 = require("ui.widgets.drag_float3")

-- TODO draw string
-- TODO draw bool
--
-- static void DrawString(OvUI::Internal::WidgetContainer &root, const std::string &name, std::string &data);
-- static void DrawString(OvUI::Internal::WidgetContainer &root, const std::string &name,
--      std::function<std::string(void)> gatherer, std::function<void(std::string)> provider);
--     DrawBoolean(OvUI::Internal::WidgetContainer &root, const std::string &name, std::function<bool(void)> gatherer,
--                std::function<void(bool)> provider);
--     static void DrawBoolean(OvUI::Internal::WidgetContainer &root, const std::string &name, bool &data);

-- const
local TitleColor = RGBA(0.85, 0.65, 0)
local ClearButtonColor = RGBA(0.5, 0, 0)
local _MIN_FLOAT = -999999999
local _MAX_FLOAT = 999999999
local __EMPTY_TEXTURE = nil

local EditorDrawer = {}

local function _CreateTitle(root, name)
    root:CreateWidget(TextColored, name, TitleColor)
end

function EditorDrawer:DrawString(root, name, getter, setter)
    _CreateTitle(root, name)
    local widget = root:CreateWidget(InputText, "")

    widget.getter = getter
    widget.setter = setter
end

function EditorDrawer:DrawBoolean(root, name, getter, setter)
    _CreateTitle(root, name)
    local widget = root:CreateWidget(CheckBox)

    widget.getter = getter
    widget.setter = setter
end

function EditorDrawer:DrawVec3(root, name, getter, setter)
    _CreateTitle(root, name)
    local widget = root:CreateWidget(DragFloat3, _MIN_FLOAT, _MAX_FLOAT, 1.0)

    widget.getter = getter
    widget.setter = setter
end

local TheEditorDrawer = EditorDrawer

return TheEditorDrawer