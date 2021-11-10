-- editor_drawer
-- created on 2021/8/25
-- author @zoloypzuo
local InputText = require("ui.widgets.input_text")
local TextColored = require("ui.widgets.text_colored")
local CheckBox = require("ui.widgets.checkbox")
local DragFloat3 = require("ui.widgets.drag_float3")
local DragNumber = require("ui.widgets.drag_number")
local ComboBox = require("ui.widgets.combobox")

-- const
local TitleColor = RGBA(0.85, 0.65, 0)
local _MIN_FLOAT = -999999999
local _MAX_FLOAT = 999999999

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

function EditorDrawer:DrawEnum(root, name, enum_class, getter, setter)
    _CreateTitle(root, name)

    -- generate inverse index
    local choices_inverse = {}
    for k, v in pairs(enum_class) do
        choices_inverse[v] = k
    end

    local widget = root:CreateWidget(ComboBox, choices_inverse)

    widget.getter = getter
    widget.setter = setter
end

-- GUIDrawer::DrawScalar<float>(p_root, "Intensity", m_data.intensity, 0.005f, GUIDrawer::_MIN_FLOAT, GUIDrawer::_MAX_FLOAT);
-- -- 	template<typename T>
-- 	inline void GUIDrawer::DrawScalar(OvUI::Internal::WidgetContainer & p_root, const std::string & p_name, T & p_data, float p_step, T p_min, T p_max)
-- 	{
-- 		static_assert(std::is_scalar<T>::value, "T must be a scalar");

-- 		CreateTitle(p_root, p_name);
-- 		auto& widget = p_root.CreateWidget<OvUI::Widgets::Drags::DragSingleScalar<T>>(GetDataType<T>(), p_min, p_max, p_data, p_step, "", GetFormat<T>());
-- 		auto& dispatcher = widget.AddPlugin<OvUI::Plugins::DataDispatcher<T>>();
-- 		dispatcher.RegisterReference(p_data);
-- 	}

function EditorDrawer:DrawNumber(root, name, getter, setter)
    _CreateTitle(root, name)
    local widget = root:CreateWidget(DragNumber, _MIN_FLOAT, _MAX_FLOAT, 1.0)

    widget.getter = getter
    widget.setter = setter
end

local TheEditorDrawer = EditorDrawer

return TheEditorDrawer