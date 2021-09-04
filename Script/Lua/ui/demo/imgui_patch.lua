---@class ImGui
local ImGui = {}

---@alias float number
---@alias double number
---@alias int number

---@alias ImGuiWindowFlags number
---@alias ImGuiFocusedFlags number
---@alias ImGuiHoveredFlags number
---@alias ImGuiCond number
---@alias ImGuiCol number
---@alias ImGuiStyleVar number
---@alias ImGuiDir number
---@alias ImGuiComboFlags number
---@alias ImGuiInputTextFlags number
---@alias ImGuiColorEditFlags number
---@alias ImGuiTreeNodeFlags number
---@alias ImGuiSelectableFlags number
---@alias ImGuiPopupFlags number
---@alias ImGuiTabBarFlags number
---@alias ImGuiTabItemFlags number
---@alias ImGuiDockNodeFlags number
---@alias ImGuiMouseButton number
---@alias ImGuiKey number
---@alias ImGuiMouseCursor number
---@alias ImGuiDragDropFlags number

---@alias ImguiCond number
---@alias ImFont number
---@alias unsigned number

-- ## Windows

--- Parameters: text (name), bool (open) [O], ImGuiWindowFlags (flags) [O]
--- Returns A: bool (shouldDraw)
--- Returns B & C: bool (open), bool (shouldDraw)
--- Overloads
--- shouldDraw = ImGui.Begin("Name")
--- open, shouldDraw = ImGui.Begin("Name", open)
--- open, shouldDraw = ImGui.Begin("Name", open, ImGuiWindowFlags.NoMove)
---@param name string
---@param open boolean
---@param flags ImGuiWindowFlags
function  ImGui.Begin(...) end

function  ImGui.End() end

-- ## Child Windows

--- Parameters: text (name), float (size_x) [O], float (size_y) [O], ImGuiWindowFlags (flags) [O]
--- Returns: bool (shouldDraw)
--- Overloads
--- shouldDraw = ImGui.BeginChild("Name", 100)
--- shouldDraw = ImGui.BeginChild("Name", 100)
--- shouldDraw = ImGui.BeginChild("Name", 100, 200)
--- shouldDraw = ImGui.BeginChild("Name", 100, 200, true)
--- shouldDraw = ImGui.BeginChild("Name", 100, 200, true, ImGuiWindowFlags.NoMove)
---@param name string
---@param size_x float
---@param size_y float
---@param flags ImGuiWindowFlags
---@return boolean @shouldDraw
function  ImGui.BeginChild(...) end

function  ImGui.EndChild() end

-- ## Windows Utilities

--- Returns: bool (appearing)
--- appearing = ImGui.IsWindowAppearing()
---@return boolean @appearing
function  ImGui.IsWindowAppearing() end

--- Returns: bool (collapsed)
--- collapsed = ImGui.IsWindowCollapsed()
---@return boolean @collapsed
function  ImGui.IsWindowCollapsed() end

--- Parameters: ImGuiFocusedFlags (flags) [O]
--- Returns: bool (focused)
--- Overloads
--- focused = ImGui.IsWindowFocused()
--- focused = ImGui.IsWindowFocused(ImGuiFocusedFlags.ChildWindows)
---@param flags ImGuiFocusedFlags
---@return boolean @focused
function  ImGui.IsWindowFocused(...) end

--- Parameters: ImGuiHoveredFlags (flags) [O]
--- Returns: bool (hovered)
--- Overloads
--- hovered = ImGui.IswindowHovered()
--- hovered = ImGui.IsWindowHovered(ImGuiHoveredFlags.ChildWindows)
---@param flags ImGuiHoveredFlags
---@return boolean @hovered
function  ImGui.IsWindowHovered(...) end

--- Returns: float (dpiScale)
--- dpiScale = ImGui.GetWindowDpiScale()
---@return float @dpiScale
function  ImGui.GetWindowDpiScale() end

--- Returns: float (pos_x), float (pos_y)
--- pos_x, pos_y = ImGui.GetWindowPos()
---@return float @pos_x
---@return float @pos_y
function  ImGui.GetWindowPos() end

--- Returns: float (size_x), float (size_y)
--- size_x, size_y = ImGui.GetWindowSize()
---@return float @size_x
---@return float @size_y
function  ImGui.GetWindowSize() end

--- Returns: float (width)
--- width = ImGui.GetWindowWidth()
---@return float @width
function  ImGui.GetWindowWidth() end

--- Returns: float (height)
--- height = ImGui.GetWindowHeight()
---@return float @height
function  ImGui.GetWindowHeight() end

--- Parameters: float (pos_x), float (pos_y), ImGuiCond (cond) [O], float (pivot_x) [O], float (pivot_y) [O]
--- Overloads
---@param pos_x float
---@param pos_y float
---@param cond ImGuiCond
---@param pivot_x float
---@param pivot_y float
function  ImGui.SetNextWindowPos(...) end

--- Parameters: float (size_x), float (size_y), ImGuiCond (cond) [O]
--- Overloads
---@param size_x float
---@param size_y float
---@param cond ImGuiCond
function  ImGui.SetNextWindowSize(...) end

--- Parameters: float (min_x), float (min_y), float (max_x), float (max_y)
---@param min_x float
---@param min_y float
---@param max_x float
---@param max_y float
function  ImGui.SetNextWindowSizeConstraints(...) end

--- Parameters: float (size_x), float (size_y)
---@param size_x float
---@param size_y float
function  ImGui.SetNextWindowContentSize(...) end

--- Parameters: bool (collapsed), ImGuiCond (cond) [O]
--- Overloads
---@param collapsed boolean
---@param cond ImGuiCond
function  ImGui.SetNextWindowCollapsed(...) end

function  ImGui.SetNextWindowFocus() end

--- Parameters: float (alpha)
---@param alpha float
function  ImGui.SetNextWindowBgAlpha(...) end

--- Parameters: float (pos_x), float (pos_y), ImguiCond (cond) [O]
--- Overloads
---@param pos_x float
---@param pos_y float
---@param cond ImguiCond
function  ImGui.SetWindowPos(...) end

--- Parameters: float (size_x), float (size_y), ImguiCond (cond) [O]
--- Overloads
---@param size_x float
---@param size_y float
---@param cond ImguiCond
function  ImGui.SetWindowSize(...) end

--- Parameters: bool (collapsed), ImguiCond (cond) [O]
--- Overloads
---@param collapsed boolean
---@param cond ImguiCond
function  ImGui.SetWindowCollapsed(...) end

function  ImGui.SetWindowFocus() end

--- Parameters: float (scale)
---@param scale float
function  ImGui.SetWindowFontScale(...) end

--- Parameters: text (name), float (pos_x), float (pos_y), ImGuiCond (cond) [O]
--- Overloads
---@param name string
---@param pos_x float
---@param pos_y float
---@param cond ImGuiCond
function  ImGui.SetWindowPos(...) end

--- Parameters: text (name), float (size_x), float (size_y), ImGuiCond (cond) [O]
--- Overloads
---@param name string
---@param size_x float
---@param size_y float
---@param cond ImGuiCond
function  ImGui.SetWindowSize(...) end

--- Parameters: text (name), bool (collapsed), ImGuiCond (cond) [O]
--- Overloads
---@param name string
---@param collapsed boolean
---@param cond ImGuiCond
function  ImGui.SetWindowCollapsed(...) end

--- Parameters: text (name)
---@param name string
function  ImGui.SetWindowFocus(...) end

-- ## Content Region

--- Returns: float (x), float (y)
--- x, y = ImGui.GetContentRegionMax()
---@return float @x
---@return float @y
function  ImGui.GetContentRegionMax() end

--- Returns: float (x), float (y)
--- x, y = ImGui.GetContentRegionAvail()
---@return float @x
---@return float @y
function  ImGui.GetContentRegionAvail() end

--- Returns: float (x), float (y)
--- x, y = ImGui.GetWindowContentRegionMin()
---@return float @x
---@return float @y
function  ImGui.GetWindowContentRegionMin() end

--- Returns: float (x), float (y)
--- x, y = ImGui.GetWindowContentRegionMax()
---@return float @x
---@return float @y
function  ImGui.GetWindowContentRegionMax() end

--- Returns: float (width)
--- width = ImGui.GetWindowContentRegionWidth()
---@return float @width
function  ImGui.GetWindowContentRegionWidth() end

-- ## Windows Scrolling

--- Returns: float (x)
--- x = ImGui.GetScrollX()
---@return float @x
function  ImGui.GetScrollX() end

--- Returns: float (y)
--- y = ImGui.GetScrollY()
---@return float @y
function  ImGui.GetScrollY() end

--- Returns: float (x)
--- x = ImGui.GetScrollMaxX()
---@return float @x
function  ImGui.GetScrollMaxX() end

--- Returns: float (y)
--- y = ImGui.GetScrollMaxY()
---@return float @y
function  ImGui.GetScrollMaxY() end

--- Parameters: float (scroll_x)
---@param scroll_x float
function  ImGui.SetScrollX(...) end

--- Parameters: float (scroll_y)
---@param scroll_y float
function  ImGui.SetScrollY(...) end

--- Parameters: float (center_x_ratio) [O]
--- Overloads
---@param center_x_ratio float
function  ImGui.SetScrollHereX(...) end

--- Parameters: float (center_y_ratio) [O]
--- Overloads
---@param center_y_ratio float
function  ImGui.SetScrollHereY(...) end

--- Parameters: float (local_x), float (center_x_ratio) [O]
--- Overloads
---@param local_x float
---@param center_x_ratio float
function  ImGui.SetScrollFromPosX(...) end

--- Parameters: float (local_y), float (center_y_ratio) [O]
--- Overloads
---@param local_y float
---@param center_y_ratio float
function  ImGui.SetScrollFromPosY(...) end

--- Parameters: ImFont* (font)
---@param font ImFont
function  ImGui.PushFont(...) end

-- ## Parameters Stacks (Shared)

--- Parameters: ImFont* (font)
---@param font ImFont
function  ImGui.PushFont(...) end

function  ImGui.PopFont() end

--- Parameters: ImGuiCol (idx), float (color_r), float (color_g), float (color_b), float (color_a)
---@param idx ImGuiCol
---@param color_r float
---@param color_g float
---@param color_b float
---@param color_a float
function  ImGui.PushStyleColor(...) end

--- Parameters: int (count) [O]
--- Overloads
---@param count int
function  ImGui.PopStyleColor(...) end

--- Parameters A: ImGuiStyleVar (idx), float (value)
--- Parameters B: ImGuiStyleVar (idx), float (value_x), float (value_y)
--- Overloads
function  ImGui.PushStyleVar(...) end

--- Parameters: int (count) [O]
---@param count int
function  ImGui.PopStyleVar(...) end

--- Parameters: ImGuiCol (idx)
--- Returns: float (color_r), float (color_g), float (color_b), float (color_a)
--- color_r, color_g, color_b, color_a = ImGui.GetStyleColorVec4(ImGuiCol.Text)
---@param idx ImGuiCol
---@return float @color_r
---@return float @color_g
---@return float @color_b
---@return float @color_a
function  ImGui.GetStyleColorVec4(...) end

--- Returns: ImFont*
--- font = ImGui.GetFont()
---@return ImFont
function  ImGui.GetFont() end

--- Returns: float (fontSize)
--- fontSize = ImGui.GetFontSize()
---@return float @fontSize
function  ImGui.GetFontSize() end

--- Returns: float (x), float (y)
--- x, y = ImGui.GetFontTexUvWhitePixel()
---@return float @x
---@return float @y
function  ImGui.GetFontTexUvWhitePixel() end

-- ## Parameter Stacks (Current Window)

--- Parameters: float (width)
---@param width float
function  ImGui.PushItemWidth(...) end

function  ImGui.PopItemWidth() end

--- Parameters: float (width)
---@param width float
function  ImGui.SetNextItemWidth(...) end

--- Returns: float (width)
--- width = ImGui.CalcItemWidth()
---@return float @width
function  ImGui.CalcItemWidth() end

--- Parameters: float (wrap_local_pos_x) [O]
--- Overloads
---@param wrap_local_pos_x float
function  ImGui.PushTextWrapPos(...) end

function  ImGui.PopTextWrapPos() end

--- Parameters: bool (allow_keyboard_focus)
---@param allow_keyboard_focus boolean
function  ImGui.PushAllowKeyboardFocus(...) end

function  ImGui.PopAllowKeyboardFocus() end

--- Parameters: bool (repeat)
---@param repeat boolean
function  ImGui.PushButtonRepeat(...) end

function  ImGui.PopButtonRepeat() end

-- ## Cursor / Layout

function  ImGui.Separator() end

--- Parameters: float (offset_from_start_x) [O], float (spacing) [O]
--- Overloads
---@param offset_from_start_x float
---@param spacing float
function  ImGui.SameLine(...) end

function  ImGui.NewLine() end

function  ImGui.Spacing() end

--- Parameters: float (size_x), float (size_y)
---@param size_x float
---@param size_y float
function  ImGui.__Dummy(...) end

--- Parameters: float (indent_w) [O]
---@param indent_w float
function  ImGui.Indent(...) end

--- Parameters: float (indent_w) [O]
---@param indent_w float
function  ImGui.Unindent(...) end

function  ImGui.BeginGroup() end

function  ImGui.EndGroup() end

--- Returns: float (x), float(y)
--- x, y = ImGui.GetCursorPos()
---@return float @x
---@return float(y)
function  ImGui.GetCursorPos() end

--- Returns: float (x)
--- x = ImGui.GetCursorPosX()
---@return float @x
function  ImGui.GetCursorPosX() end

--- Returns: float (y)
--- y = ImGui.GetCursorPosY()
---@return float @y
function  ImGui.GetCursorPosY() end

--- Parameters: float (x), float (y)
---@param x float
---@param y float
function  ImGui.SetCursorPos(...) end

--- Parameters: float (x)
---@param x float
function  ImGui.SetCursorPosX(...) end

--- Parameters: float (y)
---@param y float
function  ImGui.SetCursorPosY(...) end

--- Returns: float (x), float(y)
--- x, y = ImGui.GetCursorStartPos()
---@return float @x
---@return float(y)
function  ImGui.GetCursorStartPos() end

--- Returns: float (x), float(y)
--- x, y = ImGui.GetCursorScreenPos()
---@return float @x
---@return float(y)
function  ImGui.GetCursorScreenPos() end

--- Parameters: float (x), float (y)
---@param x float
---@param y float
function  ImGui.SetCursorScreenPos(...) end

function  ImGui.AlignTextToFramePadding() end

--- Returns: float (height)
--- height = ImGui.GetTextLineHeight()
---@return float @height
function  ImGui.GetTextLineHeight() end

--- Returns: float (height)
--- height = ImGui.GetTextLineHeightWithSpacing()
---@return float @height
function  ImGui.GetTextLineHeightWithSpacing() end

--- Returns: float (height)
--- height = ImGui.GetFrameHeight()
---@return float @height
function  ImGui.GetFrameHeight() end

--- Returns: float (height)
--- height = ImGui.GetFrameHeightWithSpacing()
---@return float @height
function  ImGui.GetFrameHeightWithSpacing() end

-- ## ID Stack / Scopes

--- Parameters A: text (str_id)
--- Parameters B: text (str_id_begin), text (str_id_end)
--- Parameters C: int (int_id)
--- Overloads
function  ImGui.PushID(...) end

function  ImGui.PopID() end

--- Parameters A: text (str_id)
--- Parameters B: text (str_id_begin), text (str_id_end)
--- Returns: int (id)
--- Overloads
--- id = ImGui.PushID("MyID")
--- id = ImGui.PushID("MyID_Begin", "MyID_End")
---@return int @id
function  ImGui.GetID(...) end

-- ## Widgets: Text

--- Parameters: text (text), text (text_end) [O]
--- Overloads
---@param text string
---@param text_end string
function  ImGui.TextUnformatted(...) end

--- Parameters: text (text)
---@param text string
function  ImGui.Text(...) end

--- Parameters: float (color_r), float (color_g), float (color_b), float (color_a), text (text)
---@param color_r float
---@param color_g float
---@param color_b float
---@param color_a float
---@param text string
function  ImGui.TextColored(...) end

--- Parameters: text (text)
---@param text string
function  ImGui.TextDisabled(...) end

--- Parameters: text (text)
---@param text string
function  ImGui.TextWrapped(...) end

--- Parameters: text (label), text (text)
---@param label string
---@param text string
function  ImGui.LabelText(...) end

--- Parameters: text (text)
---@param text string
function  ImGui.BulletText(...) end

-- ## Widgets: Main

--- Parameters: text (label), float (size_x) [O], float (size_y) [O]
--- Returns: bool (clicked)
--- Overloads
--- clicked = ImGui.Button("Label")
--- clicked = ImGui.Button("Label", 100, 50)
---@param label string
---@param size_x float
---@param size_y float
---@return boolean @clicked
function  ImGui.Button(...) end

--- Parameters: text (label)
--- Returns: bool (clicked)
--- clicked = ImGui.SmallButton("Label")
---@param label string
---@return boolean @clicked
function  ImGui.SmallButton(...) end

--- Parameters: text (label), float (size_x), float (size_y)
--- Returns: bool (clicked)
--- clicked = ImGui.InvisibleButton("Label", 100, 50)
---@param label string
---@param size_x float
---@param size_y float
---@return boolean @clicked
function  ImGui.InvisibleButton(...) end

--- Parameters: text (str_id), ImGuiDir (dir)
--- Returns: bool (clicked)
--- clicked = ImGui.ArrowButton("I have an arrow", ImGuiDir.Down)
---@param str_id string
---@param dir ImGuiDir
---@return boolean @clicked
function  ImGui.ArrowButton(...) end

--- Parameters: text (label), bool (value)
--- Returns: bool (value), bool (pressed)
--- value, pressed = ImGui.Checkbox("My Checkbox", value)
---@param label string
---@param value boolean
---@return boolean @value
---@return boolean @pressed
function  ImGui.Checkbox(...) end

--- Parameters A: text (label), bool (active)
--- Parameters B: text (label), int (value), int (v_button)
--- Returns A: bool (pressed)
--- Returns B: int (value), bool (pressed)
--- Overloads
--- pressed = ImGui.RadioButton("Click me", pressed == true)
--- value, pressed = ImGui.RadioButton("Click me too", value, 2)
function  ImGui.RadioButton(...) end

--- Parameters: float (fraction), float (size_x) [O], float (size_y) [O], text (overlay) [O]
--- Overloads
---@param fraction float
---@param size_x float
---@param size_y float
---@param overlay string
function  ImGui.ProgressBar(...) end

function  ImGui.Bullet() end

-- ## Widgets: Combo Box

--- Parameters: text (label), text (previewValue), ImGuiComboFlags (flags) [O]
--- Returns: bool (shouldDraw)
--- Overloads
--- shouldDraw = ImGui.BeginCombo("My Combo", "Preview")
--- shouldDraw = ImGui.BeginCombo("My Combo", "Preview", ImGuiComboFlags.PopupAlignLeft)
---@param label string
---@param previewValue string
---@param flags ImGuiComboFlags
---@return boolean @shouldDraw
function  ImGui.BeginCombo(...) end

function  ImGui.EndCombo() end

--- Parameters A: text (label), int (current_item), table (items), int (items_count), int (popup_max_height_in_items) [O] 
--- Parameters B: text (label), int (current_item), text (items_separated_by_zeros), int (popup_max_height_in_items) [O] 
--- Returns: int (current_item), bool (clicked)
--- Overloads
--- current_item, clicked = ImGui.Combo("Label", current_item, { "Option 1 ", "Option 2" }, 2)
--- current_item, clicked = ImGui.Combo("Label", current_item, { "Option 1 ", "Option 2" }, 2, 5)
--- current_item, clicked = ImGui.Combo("Label", current_item, "Option1\0Option2\0")
--- current_item, clicked = ImGui.Combo("Label", current_item, "Option1\0Option2\0", 5)
---@return int @current_item
---@return boolean @clicked
function  ImGui.Combo(...) end

-- ## Widgets: Drags

--- Parameters: text (label), float (value), float (value_speed) [O], float (value_min) [O], float (value_max) [O], text (format) [O], float (power) [O]
--- Returns: float (value), bool (used)
--- Overloads
--- value, used = ImGui.DragFloat("Label", value)
--- value, used = ImGui.DragFloat("Label", value, 0.01)
--- value, used = ImGui.DragFloat("Label", value, 0.01, -10)
--- value, used = ImGui.DragFloat("Label", value, 0.01, -10, 10)
--- value, used = ImGui.DragFloat("Label", value, 0.01, -10, 10, "%.1f")
--- value, used = ImGui.DragFloat("Label", value, 0.01, -10, 10, "%.1f", 0.5)
---@param label string
---@param value float
---@param value_speed float
---@param value_min float
---@param value_max float
---@param format string
---@param power float
---@return float @value
---@return boolean @used
function  ImGui.DragFloat(...) end

--- Parameters: text (label), table (values), float (value_speed) [O], float (value_min) [O], float (value_max) [O], text (format) [O], float (power) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.DragFloat2("Label", values)
--- values, used = ImGui.DragFloat2("Label", values, 0.01)
--- values, used = ImGui.DragFloat2("Label", values, 0.01, -10)
--- values, used = ImGui.DragFloat2("Label", values, 0.01, -10, 10)
--- values, used = ImGui.DragFloat2("Label", values, 0.01, -10, 10, "%.1f")
--- values, used = ImGui.DragFloat2("Label", values, 0.01, -10, 10, "%.1f", 0.5)
---@param label string
---@param values table
---@param value_speed float
---@param value_min float
---@param value_max float
---@param format string
---@param power float
---@return table @values
---@return boolean @used
function  ImGui.DragFloat2(...) end

--- Parameters: text (label), table (values), float (value_speed) [O], float (value_min) [O], float (value_max) [O], text (format) [O], float (power) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.DragFloat3("Label", values)
--- values, used = ImGui.DragFloat3("Label", values, 0.01)
--- values, used = ImGui.DragFloat3("Label", values, 0.01, -10)
--- values, used = ImGui.DragFloat3("Label", values, 0.01, -10, 10)
--- values, used = ImGui.DragFloat3("Label", values, 0.01, -10, 10, "%.1f")
--- values, used = ImGui.DragFloat3("Label", values, 0.01, -10, 10, "%.1f", 0.5)
---@param label string
---@param values table
---@param value_speed float
---@param value_min float
---@param value_max float
---@param format string
---@param power float
---@return table @values
---@return boolean @used
function  ImGui.DragFloat3(...) end

--- Parameters: text (label), table (values), float (value_speed) [O], float (value_min) [O], float (value_max) [O], text (format) [O], float (power) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.DragFloat4("Label", values)
--- values, used = ImGui.DragFloat4("Label", values, 0.01)
--- values, used = ImGui.DragFloat4("Label", values, 0.01, -10)
--- values, used = ImGui.DragFloat4("Label", values, 0.01, -10, 10)
--- values, used = ImGui.DragFloat4("Label", values, 0.01, -10, 10, "%.1f")
--- values, used = ImGui.DragFloat4("Label", values, 0.01, -10, 10, "%.1f", 0.5)
---@param label string
---@param values table
---@param value_speed float
---@param value_min float
---@param value_max float
---@param format string
---@param power float
---@return table @values
---@return boolean @used
function  ImGui.DragFloat4(...) end

--- Parameters: text (label), int (value), float (value_speed) [O], int (value_min) [O], int (value_max) [O], text (format) [O]
--- Returns: int (value), bool (used)
--- Overloads
--- value, used = ImGui.DragInt("Label", value)
--- value, used = ImGui.DragInt("Label", value, 0.01)
--- value, used = ImGui.DragInt("Label", value, 0.01, -10)
--- value, used = ImGui.DragInt("Label", value, 0.01, -10, 10)
--- value, used = ImGui.DragInt("Label", value, 0.01, -10, 10, "%d")
---@param label string
---@param value int
---@param value_speed float
---@param value_min int
---@param value_max int
---@param format string
---@return int @value
---@return boolean @used
function  ImGui.DragInt(...) end

--- Parameters: text (label), table (values), float (value_speed) [O], int (value_min) [O], int (value_max) [O], text (format) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.DragInt2("Label", values)
--- values, used = ImGui.DragInt2("Label", values, 0.01)
--- values, used = ImGui.DragInt2("Label", values, 0.01, -10)
--- values, used = ImGui.DragInt2("Label", values, 0.01, -10, 10)
--- values, used = ImGui.DragInt2("Label", values, 0.01, -10, 10, "%d")
---@param label string
---@param values table
---@param value_speed float
---@param value_min int
---@param value_max int
---@param format string
---@return table @values
---@return boolean @used
function  ImGui.DragInt2(...) end

--- Parameters: text (label), table (values), float (value_speed) [O], int (value_min) [O], int (value_max) [O], text (format) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.DragInt3("Label", values)
--- values, used = ImGui.DragInt3("Label", values, 0.01)
--- values, used = ImGui.DragInt3("Label", values, 0.01, -10)
--- values, used = ImGui.DragInt3("Label", values, 0.01, -10, 10)
--- values, used = ImGui.DragInt3("Label", values, 0.01, -10, 10, "%d")
---@param label string
---@param values table
---@param value_speed float
---@param value_min int
---@param value_max int
---@param format string
---@return table @values
---@return boolean @used
function  ImGui.DragInt3(...) end

--- Parameters: text (label), table (values), float (value_speed) [O], int (value_min) [O], int (value_max) [O], text (format) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.DragInt4("Label", values)
--- values, used = ImGui.DragInt4("Label", values, 0.01)
--- values, used = ImGui.DragInt4("Label", values, 0.01, -10)
--- values, used = ImGui.DragInt4("Label", values, 0.01, -10, 10)
--- values, used = ImGui.DragInt4("Label", values, 0.01, -10, 10, "%d")
---@param label string
---@param values table
---@param value_speed float
---@param value_min int
---@param value_max int
---@param format string
---@return table @values
---@return boolean @used
function  ImGui.DragInt4(...) end

-- ## Widgets: Sliders

--- Parameters: text (label), float (value), float (value_min), float (value_max), text (format) [O], float (power) [O]
--- Returns: float (value), bool (used)
--- Overloads
--- value, used = ImGui.SliderFloat("Label", value, -10, 10)
--- value, used = ImGui.SliderFloat("Label", value, -10, 10, "%.1f")
--- value, used = ImGui.SliderFloat("Label", value, -10, 10, "%.1f", 0.5)
---@param label string
---@param value float
---@param value_min float
---@param value_max float
---@param format string
---@param power float
---@return float @value
---@return boolean @used
function  ImGui.SliderFloat(...) end

--- Parameters: text (label), table (values), float (value_min), float (value_max), text (format) [O], float (power) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.SliderFloat2("Label", values, 0.01, -10, 10)
--- values, used = ImGui.SliderFloat2("Label", values, 0.01, -10, 10, "%.1f")
--- values, used = ImGui.SliderFloat2("Label", values, 0.01, -10, 10, "%.1f", 0.5)
---@param label string
---@param values table
---@param value_min float
---@param value_max float
---@param format string
---@param power float
---@return table @values
---@return boolean @used
function  ImGui.SliderFloat2(...) end

--- Parameters: text (label), table (values), float (value_min), float (value_max), text (format) [O], float (power) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.SliderFloat3("Label", values, 0.01, -10, 10)
--- values, used = ImGui.SliderFloat3("Label", values, 0.01, -10, 10, "%.1f")
--- values, used = ImGui.SliderFloat3("Label", values, 0.01, -10, 10, "%.1f", 0.5)
---@param label string
---@param values table
---@param value_min float
---@param value_max float
---@param format string
---@param power float
---@return table @values
---@return boolean @used
function  ImGui.SliderFloat3(...) end

--- Parameters: text (label), table (values), float (value_min), float (value_max), text (format) [O], float (power) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.SliderFloat4("Label", values, 0.01, -10, 10)
--- values, used = ImGui.SliderFloat4("Label", values, 0.01, -10, 10, "%.1f")
--- values, used = ImGui.SliderFloat4("Label", values, 0.01, -10, 10, "%.1f", 0.5)
---@param label string
---@param values table
---@param value_min float
---@param value_max float
---@param format string
---@param power float
---@return table @values
---@return boolean @used
function  ImGui.SliderFloat4(...) end

--- Parameters: text (label), float (v_rad), float (v_degrees_min) [O], float (v_degrees_max) [O], text (format) [O]
--- Returns: float (v_rad), bool (used)
--- Overloads
--- v_rad, used = ImGui.SliderAngle("Label", v_rad)
--- v_rad, used = ImGui.SliderAngle("Label", v_rad, -255)
--- v_rad, used = ImGui.SliderAngle("Label", v_rad, -255, 360)
--- v_rad, used = ImGui.SliderAngle("Label", v_rad, -255, 360, "%.0f deg")
---@param label string
---@param v_rad float
---@param v_degrees_min float
---@param v_degrees_max float
---@param format string
---@return float @v_rad
---@return boolean @used
function  ImGui.SliderAngle(...) end

--- Parameters: text (label), int (value), int (value_min), int (value_max), text (format) [O]
--- Returns: int (value), bool (used)
--- Overloads
--- value, used = ImGui.SliderInt("Label", value, -10, 10)
--- value, used = ImGui.SliderInt("Label", value, -10, 10, "%d")
---@param label string
---@param value int
---@param value_min int
---@param value_max int
---@param format string
---@return int @value
---@return boolean @used
function  ImGui.SliderInt(...) end

--- Parameters: text (label), table (values), int (value_min), int (value_max), text (format) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.SliderInt2("Label", values, -10, 10)
--- values, used = ImGui.SliderInt2("Label", values, -10, 10, "%d")
---@param label string
---@param values table
---@param value_min int
---@param value_max int
---@param format string
---@return table @values
---@return boolean @used
function  ImGui.SliderInt2(...) end

--- Parameters: text (label), table (values), int (value_min), int (value_max), text (format) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.SliderInt3("Label", values, -10, 10)
--- values, used = ImGui.SliderInt3("Label", values, -10, 10, "%d")
---@param label string
---@param values table
---@param value_min int
---@param value_max int
---@param format string
---@return table @values
---@return boolean @used
function  ImGui.SliderInt3(...) end

--- Parameters: text (label), table (values), int (value_min), int (value_max), text (format) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.SliderInt4("Label", values, -10, 10)
--- values, used = ImGui.SliderInt4("Label", values, -10, 10, "%d")
---@param label string
---@param values table
---@param value_min int
---@param value_max int
---@param format string
---@return table @values
---@return boolean @used
function  ImGui.SliderInt4(...) end

--- Parameters: text (label), float (size_x), float (size_y), float (value), float (value_min), float (value_max), text (format) [O], float (power) [O]
--- Returns: float (value), bool (used)
--- Overloads
--- value, used = ImGui.VSliderFloat("Label", 100, 25, value, -10, 10)
--- value, used = ImGui.VSliderFloat("Label", 100, 25, value, -10, 10, "%.1f")
--- value, used = ImGui.VSliderFloat("Label", 100, 25, value, -10, 10, "%.1f", 0.5)
---@param label string
---@param size_x float
---@param size_y float
---@param value float
---@param value_min float
---@param value_max float
---@param format string
---@param power float
---@return float @value
---@return boolean @used
function  ImGui.VSliderFloat(...) end

--- Parameters: text (label), float (size_x), float (size_y), int (value), int (value_min), int (value_max), text (format) [O]
--- Returns: int (value), bool (used)
--- Overloads
--- value, used = ImGui.VSliderInt("Label", 100, 25, value, -10, 10)
--- value, used = ImGui.VSliderInt("Label", 100, 25, value, -10, 10, "%d")
---@param label string
---@param size_x float
---@param size_y float
---@param value int
---@param value_min int
---@param value_max int
---@param format string
---@return int @value
---@return boolean @used
function  ImGui.VSliderInt(...) end

-- ## Widgets: Input with Keyboard

--- Parameters: text (label), text (text), int (buf_size), ImGuiInputTextFlags (flags) [O]
--- Returns: text (text), bool (selected)
--- Overloads
--- text, selected = ImGui.InputText("Label", text, 100)
--- text, selected = ImGui.InputText("Label", text, 100, ImGuiInputTextFlags.ReadOnly)
---@param label string
---@param text string
---@param buf_size int
---@param flags ImGuiInputTextFlags
---@return string @text
---@return boolean @selected
function  ImGui.InputText(...) end

--- Parameters: text (label), text (text), int (buf_size), float (size_x) [O], float (size_y) [O], ImGuiInputTextFlags (flags) [O]
--- Returns: text (text), bool (selected)
--- Overloads
--- text, selected = ImGui.InputTextMultiline("Label", text, 100)
--- text, selected = ImGui.InputTextMultiline("Label", text, 100, 200, 35)
--- text, selected = ImGui.InputTextMultiline("Label", text, 100, 200, 35, ImGuiInputTextFlags.ReadOnly)
---@param label string
---@param text string
---@param buf_size int
---@param size_x float
---@param size_y float
---@param flags ImGuiInputTextFlags
---@return string @text
---@return boolean @selected
function  ImGui.InputTextMultiline(...) end

--- Parameters: text (label), text (hint), text (text), int (buf_size), ImGuiInputTextFlags (flags) [O]
--- Returns: text (text), bool (selected)
--- Overloads
--- text, selected = ImGui.InputTextWithHint("Label", "Hint", text, 100)
--- text, selected = ImGui.InputTextWithHint("Label", "Hint", text, 100, ImGuiInputTextFlags.ReadOnly)
---@param label string
---@param hint string
---@param text string
---@param buf_size int
---@param flags ImGuiInputTextFlags
---@return string @text
---@return boolean @selected
function  ImGui.InputTextWithHint(...) end

--- Parameters: text (label), float (value), float (step) [O], float (step_fast) [O], text (format) [O], ImGuiInputTextFlags (flags) [O]
--- Returns: float (value), bool (used)
--- Overloads
--- value, used = ImGui.InputFloat("Label", value)
--- value, used = ImGui.InputFloat("Label", value, 1)
--- value, used = ImGui.InputFloat("Label", value, 1, 10)
--- value, used = ImGui.InputFloat("Label", value, 1, 10, "%.1f")
--- value, used = ImGui.InputFloat("Label", value, 1, 10, "%.1f", ImGuiInputTextFlags.None)
---@param label string
---@param value float
---@param step float
---@param step_fast float
---@param format string
---@param flags ImGuiInputTextFlags
---@return float @value
---@return boolean @used
function  ImGui.InputFloat(...) end

--- Parameters: text (label), table (values), text (format) [O], ImGuiInputTextFlags (flags) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.InputFloat2("Label", values)
--- values, used = ImGui.InputFloat2("Label", values, "%.1f")
--- values, used = ImGui.InputFloat2("Label", values, "%.1f", ImGuiInputTextFlags.None)
---@param label string
---@param values table
---@param format string
---@param flags ImGuiInputTextFlags
---@return table @values
---@return boolean @used
function  ImGui.InputFloat2(...) end

--- Parameters: text (label), table (values), text (format) [O], ImGuiInputTextFlags (flags) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.InputFloat3("Label", values)
--- values, used = ImGui.InputFloat3("Label", values, "%.1f")
--- values, used = ImGui.InputFloat3("Label", values, "%.1f", ImGuiInputTextFlags.None)
---@param label string
---@param values table
---@param format string
---@param flags ImGuiInputTextFlags
---@return table @values
---@return boolean @used
function  ImGui.InputFloat3(...) end

--- Parameters: text (label), table (values), text (format) [O], ImGuiInputTextFlags (flags) [O]
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.InputFloat4("Label", values)
--- values, used = ImGui.InputFloat4("Label", values, "%.1f")
--- values, used = ImGui.InputFloat4("Label", values, "%.1f", ImGuiInputTextFlags.None)
---@param label string
---@param values table
---@param format string
---@param flags ImGuiInputTextFlags
---@return table @values
---@return boolean @used
function  ImGui.InputFloat4(...) end

--- Parameters: text (label), int (value), int (step) [O], int (step_fast) [O], ImGuiInputTextFlags (flags) [O] 
--- Returns: int (value), bool (used)
--- Overloads
--- value, used = ImGui.InputInt("Label", value)
--- value, used = ImGui.InputInt("Label", value, 1)
--- value, used = ImGui.InputInt("Label", value, 1, 10)
--- value, used = ImGui.InputInt("Label", value, 1, 10, ImGuiInputTextFlags.None)
---@param label string
---@param value int
---@param step int
---@param step_fast int
---@param flags ImGuiInputTextFlags
---@return int @value
---@return boolean @used
function  ImGui.InputInt(...) end

--- Parameters: text (label), table (values), ImGuiInputTextFlags (flags) [O] 
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.InputInt2("Label", values)
--- values, used = ImGui.InputInt2("Label", values, ImGuiInputTextFlags.None)
---@param label string
---@param values table
---@param flags ImGuiInputTextFlags
---@return table @values
---@return boolean @used
function  ImGui.InputInt2(...) end

--- Parameters: text (label), table (values), ImGuiInputTextFlags (flags) [O] 
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.InputInt3("Label", values)
--- values, used = ImGui.InputInt3("Label", values, ImGuiInputTextFlags.None)
---@param label string
---@param values table
---@param flags ImGuiInputTextFlags
---@return table @values
---@return boolean @used
function  ImGui.InputInt3(...) end

--- Parameters: text (label), table (values), ImGuiInputTextFlags (flags) [O] 
--- Returns: table (values), bool (used)
--- Overloads
--- values, used = ImGui.InputInt4("Label", values)
--- values, used = ImGui.InputInt4("Label", values, ImGuiInputTextFlags.None)
---@param label string
---@param values table
---@param flags ImGuiInputTextFlags
---@return table @values
---@return boolean @used
function  ImGui.InputInt4(...) end

--- Parameters: text (label), double (value), double (step) [O], double (step_fast) [O], text (format) [O], ImGuiInputTextFlags (flags) [O]
--- Returns: double (value), bool (used)
--- Overloads
--- value, used = ImGui.InputDouble("Label", value)
--- value, used = ImGui.InputDouble("Label", value, 1)
--- value, used = ImGui.InputDouble("Label", value, 1, 10)
--- value, used = ImGui.InputDouble("Label", value, 1, 10, "%.4f")
--- value, used = ImGui.InputDouble("Label", value, 1, 10, "%.4f", ImGuiInputTextFlags.None)
---@param label string
---@param value double
---@param step double
---@param step_fast double
---@param format string
---@param flags ImGuiInputTextFlags
---@return double @value
---@return boolean @used
function  ImGui.InputDouble(...) end

-- ## Widgets: Color Editor / Picker

--- Parameters: text (label), table (col), ImGuiColorEditFlags (flags) [O] 
--- Returns: table (col), bool (used)
--- Overloads
--- col, used = ImGui.ColorEdit3("Label", col)
--- col, used = ImGui.ColorEdit3("Label", col, ImGuiColorEditFlags.NoTooltip)
---@param label string
---@param col table
---@param flags ImGuiColorEditFlags
---@return table @col
---@return boolean @used
function  ImGui.ColorEdit3(...) end

--- Parameters: text (label), table (col), ImGuiColorEditFlags (flags) [O] 
--- Returns: table (col), bool (used)
--- Overloads
--- col, used = ImGui.ColorEdit4("Label", col)
--- col, used = ImGui.ColorEdit4("Label", col, ImGuiColorEditFlags.NoTooltip)
---@param label string
---@param col table
---@param flags ImGuiColorEditFlags
---@return table @col
---@return boolean @used
function  ImGui.ColorEdit4(...) end

--- Parameters: text (label), table (col), ImGuiColorEditFlags (flags) [O] 
--- Returns: table (col), bool (used)
--- Overloads
--- col, used = ImGui.ColorPicker3("Label", col)
--- col, used = ImGui.ColorPicker3("Label", col, ImGuiColorEditFlags.NoTooltip)
---@param label string
---@param col table
---@param flags ImGuiColorEditFlags
---@return table @col
---@return boolean @used
function  ImGui.ColorPicker3(...) end

--- Parameters: text (label), table (col), ImGuiColorEditFlags (flags) [O] 
--- Returns: table (col), bool (used)
--- Overloads
--- col, used = ImGui.ColorPicker4("Label", col)
--- col, used = ImGui.ColorPicker4("Label", col, ImGuiColorEditFlags.NoTooltip)
---@param label string
---@param col table
---@param flags ImGuiColorEditFlags
---@return table @col
---@return boolean @used
function  ImGui.ColorPicker4(...) end

--- Parameters: text (desc_id), table (col), ImGuiColorEditFlags (flags) [O], float (size_x) [O], float (size_y) [O]
--- Returns: bool (pressed)
--- Overloads
--- pressed = ImGui.ColorButton("Desc ID", { 1, 0, 0, 1 })
--- pressed = ImGui.ColorButton("Desc ID", { 1, 0, 0, 1 }, ImGuiColorEditFlags.None)
--- pressed = ImGui.ColorButton("Desc ID", { 1, 0, 0, 1 }, ImGuiColorEditFlags.None, 100, 100)
---@param desc_id string
---@param col table
---@param flags ImGuiColorEditFlags
---@param size_x float
---@param size_y float
---@return boolean @pressed
function  ImGui.ColorButton(...) end

--- Parameters: ImGuiColorEditFlags (flags)
---@param flags ImGuiColorEditFlags
function  ImGui.SetColorEditOptions(...) end

-- ## Widgets: Trees

--- Parameters: text (label), text (fmt) [O]
--- Returns: bool (open)
--- Overloads
--- open = ImGui.TreeNode("Label")
--- open = ImGui.TreeNode("Label", "Some Text")
---@param label string
---@param fmt string
---@return boolean @open
function  ImGui.TreeNode(...) end

--- Parameters: text (label), ImGuiTreeNodeFlags (flags) [O], text (fmt) [O]
--- Returns: bool (open)
--- Overloads
--- open = ImGui.TreeNodeEx("Label")
--- open = ImGui.TreeNodeEx("Label", ImGuiTreeNodeFlags.Selected)
--- open = ImGui.TreeNodeEx("Label", ImGuiTreeNodeFlags.Selected, "Some Text")
---@param label string
---@param flags ImGuiTreeNodeFlags
---@param fmt string
---@return boolean @open
function  ImGui.TreeNodeEx(...) end

--- Parameters: text (str_id)
---@param str_id string
function  ImGui.TreePush(...) end

function  ImGui.TreePop() end

--- Returns: float (spacing)
--- spacing = ImGui.GetTreeNodeToLabelSpacing()
---@return float @spacing
function  ImGui.GetTreeNodeToLabelSpacing() end

--- Parameters A: text (label), ImGuiTreeNodeFlags (flags) [O]
--- Parameters B: text (label), bool (open), ImGuiTreeNodeFlags (flags) [O]
--- Returns A: bool (notCollapsed)
--- Returns B: bool (open), bool (notCollapsed)
--- Overloads
--- notCollapsed = ImGui.CollapsingHeader("Label")
--- notCollapsed = ImGui.CollapsingHeader("Label", ImGuiTreeNodeFlags.Selected)
--- open, notCollapsed = ImGui.CollapsingHeader("Label", open)
--- open, notCollapsed = ImGui.CollapsingHeader("Label", open, ImGuiTreeNodeFlags.Selected)
function  ImGui.CollapsingHeader(...) end

--- Parameters: bool (open), ImGuiCond (cond) [O]
--- Overloads
---@param open boolean
---@param cond ImGuiCond
function  ImGui.SetNextItemOpen(...) end

--- Parameters: text (label), bool (selected) [O], ImGuiSelectableFlags (flags) [O], float (size_x) [O], float (size_y) [O]
--- Returns: bool (selected)
--- Overloads
--- selected = ImGui.Selectable("Label")
--- selected = ImGui.Selectable("Label", selected)
--- selected = ImGui.Selectable("Label", selected, ImGuiSelectableFlags.AllowDoubleClick)
--- selected = ImGui.Selectable("Label", selected, ImGuiSelectableFlags.AllowDoubleClick, 100, 100)
---@param label string
---@param selected boolean
---@param flags ImGuiSelectableFlags
---@param size_x float
---@param size_y float
---@return boolean @selected
function  ImGui.Selectable(...) end

-- ## Widgets: Selectables

--- Parameters: text (label), bool (selected) [O], ImGuiSelectableFlags (flags) [O], float (size_x) [O], float (size_y) [O]
--- Returns: bool (selected)
--- Overloads
--- selected = ImGui.Selectable("Label")
--- selected = ImGui.Selectable("Label", selected)
--- selected = ImGui.Selectable("Label", selected, ImGuiSelectableFlags.AllowDoubleClick)
--- selected = ImGui.Selectable("Label", selected, ImGuiSelectableFlags.AllowDoubleClick, 100, 100)
---@param label string
---@param selected boolean
---@param flags ImGuiSelectableFlags
---@param size_x float
---@param size_y float
---@return boolean @selected
function  ImGui.Selectable(...) end

-- ## Widgets: List Boxes

--- Parameters: text (label), int (current_item), table (items), int (items_count), int (height_in_items) [O]
--- Returns: int (current_item), bool (clicked)
--- Overloads
--- current_item, clicked = ImGui.ListBox("Label", current_item, { "Item 1", "Item 2", 2 })
--- current_item, clicked = ImGui.ListBox("Label", current_item, { "Item 1", "Item 2", 2 }, 5)
---@param label string
---@param current_item int
---@param items table
---@param items_count int
---@param height_in_items int
---@return int @current_item
---@return boolean @clicked
function  ImGui.ListBox(...) end

--- Parameters A: text (label), float (size_x), float (size_y) 
--- Parameters B: text (label), int (items_count), int (height_in_items) [0]
--- Returns: bool (open)
--- Overloads
--- open = ImGui.ListBoxHeader("Label", 100.0, 100.0) -- size as params
--- open = ImGui.ListBoxHeader("Label", 5)
--- open = ImGui.ListBoxHeader("Label", 5, 5)     -- items count and height
---@return boolean @open
function  ImGui.ListBoxHeader(...) end

function  ImGui.ListBoxFooter() end

-- ## Widgets: Value() Helpers

--- Parameters A : text (prefix) bool/int/unsigned int/float (value), text (float_format) [O] -- format only available with float
--- Overloads
function  ImGui.Value(...) end

--- Returns: bool (shouldDraw)
--- shouldDraw = ImGui.BeginMenuBar()
---@return boolean @shouldDraw
function  ImGui.BeginMenuBar() end

-- ## Widgets: Menus

--- Returns: bool (shouldDraw)
--- shouldDraw = ImGui.BeginMenuBar()
---@return boolean @shouldDraw
function  ImGui.BeginMenuBar() end

function  ImGui.EndMenuBar() end

--- Returns: bool (shouldDraw)
--- shouldDraw = ImGui.BeginMainMenuBar()
---@return boolean @shouldDraw
function  ImGui.BeginMainMenuBar() end

function  ImGui.EndMainMenuBar() end

--- Parameters: text (label), bool (enabled) [O]
--- Returns: bool (shouldDraw)
--- Overloads
--- shouldDraw = ImGui.BeginMenu("Label")
--- shouldDraw = ImGui.BeginMenu("Label", true)
---@param label string
---@param enabled boolean
---@return boolean @shouldDraw
function  ImGui.BeginMenu(...) end

function  ImGui.EndMenu() end

--- Parameters A: text (label), text (shortcut) [0]
--- Parameters B: text (label), text (shortcut), bool (selected)
--- Returns A: bool (activated)
--- returns B: bool (selected), bool (activated)
--- Overloads
--- activated = ImGui.MenuItem("Label")
--- activated = ImGui.MenuItem("Label", "ALT+F4")
--- selected, activated = ImGui.MenuItem("Label", "ALT+F4", selected)
--- selected, activated = ImGui.MenuItem("Label", "ALT+F4", selected, true)
function  ImGui.MenuItem(...) end

-- ## Tooltips

function  ImGui.BeginTooltip() end

function  ImGui.EndTooltip() end

--- Parameters: text (fmt)
---@param fmt string
function  ImGui.SetTooltip(...) end

-- ## Popups, Modals

--- Parameters: text (str_id), ImGuiWindowFlags (flags) [O]
--- Returns: bool (open)
--- Overloads
--- open = ImGui.BeginPopup("String ID")
--- open = ImGui.BeginPopup("String ID", ImGuiWindowFlags.NoCollapse)
---@param str_id string
---@param flags ImGuiWindowFlags
---@return boolean @open
function  ImGui.BeginPopup(...) end

--- Parameters: text (name), bool (open) [O], ImGuiWindowFlags (flags) [O]
--- Returns: bool (open)
--- Overloads
--- open = ImGui.BeginPopupModal("Name")
--- open = ImGui.BeginPopupModal("Name", open)
--- open = ImGui.BeginPopupModal("Name", open, ImGuiWindowFlags.NoCollapse)
---@param name string
---@param open boolean
---@param flags ImGuiWindowFlags
---@return boolean @open
function  ImGui.BeginPopupModal(...) end

function  ImGui.EndPopup() end

--- Parameters: text (str_id), ImGuiPopupFlags (popup_flags)
--- Overloads
---@param str_id string
---@param popup_flags ImGuiPopupFlags
function  ImGui.OpenPopup(...) end

--- Parameters: text (str_id), ImGuiPopupFlags (popup_flags)
--- Returns: bool (open)
--- Overloads
--- open = ImGui.OpenPopupContextItem()
--- open = ImGui.OpenPopupContextItem("String ID")
--- open = ImGui.OpenPopupContextItem("String ID", ImGuiPopupFlags.NoOpenOverExistingPopup)
---@param str_id string
---@param popup_flags ImGuiPopupFlags
---@return boolean @open
function  ImGui.OpenPopupContextItem(...) end

function  ImGui.CloseCurrentPopup() end

--- Parameters: text (str_id), ImGuiPopupFlags (popup_flags)
--- Returns: bool (open)
--- Overloads
--- open = ImGui.BeginPopupContextItem()
--- open = ImGui.BeginPopupContextItem("String ID")
--- open = ImGui.BeginPopupContextItem("String ID", ImGuiPopupFlags.NoOpenOverExistingPopup)
---@param str_id string
---@param popup_flags ImGuiPopupFlags
---@return boolean @open
function  ImGui.BeginPopupContextItem(...) end

--- Parameters: text (str_id), ImGuiPopupFlags (popup_flags)
--- Returns: bool (open)
--- Overloads
--- open = ImGui.BeginPopupContextWindow()
--- open = ImGui.BeginPopupContextWindow("String ID")
--- open = ImGui.BeginPopupContextWindow("String ID", ImGuiPopupFlags.NoOpenOverExistingPopup)
---@param str_id string
---@param popup_flags ImGuiPopupFlags
---@return boolean @open
function  ImGui.BeginPopupContextWindow(...) end

--- Parameters: text (str_id), ImGuiPopupFlags (popup_flags)
--- Returns: bool (open)
--- Overloads
--- open = ImGui.BeginPopupContextVoid()
--- open = ImGui.BeginPopupContextVoid("String ID")
--- open = ImGui.BeginPopupContextVoid("String ID", ImGuiPopupFlags.NoOpenOverExistingPopup)
---@param str_id string
---@param popup_flags ImGuiPopupFlags
---@return boolean @open
function  ImGui.BeginPopupContextVoid(...) end

--- Parameters: text (str_id), ImGuiPopupFlags (popup_flags)
--- Overloads
---@param str_id string
---@param popup_flags ImGuiPopupFlags
function  ImGui.IsPopupOpen(...) end

--- Parameters: int (count) [O], text (id) [O], bool (border) [O]
--- Overloads
---@param count int
---@param id string
---@param border boolean
function  ImGui.Columns(...) end

-- ## Columns

--- Parameters: int (count) [O], text (id) [O], bool (border) [O]
--- Overloads
---@param count int
---@param id string
---@param border boolean
function  ImGui.Columns(...) end

function  ImGui.NextColumn() end

--- Returns: int (index)
--- index = ImGui.GetColumnIndex()
---@return int @index
function  ImGui.GetColumnIndex() end

--- Parameters: int (column_index) [O]
--- Returns: float (width)
--- Overloads
--- width = ImGui.GetColumnWidth()
--- width = ImGui.getColumnWidth(2)
---@param column_index int
---@return float @width
function  ImGui.GetColumnWidth(...) end

--- Parameters: int (column_index), float (width)
---@param column_index int
---@param width float
function  ImGui.SetColumnWidth(...) end

--- Parameters: int (column_index) [O]
--- Returns: float (offset)
--- Overloads
--- offset = ImGui.GetColumnOffset()
--- offset = ImGui.GetColumnOffset(2)
---@param column_index int
---@return float @offset
function  ImGui.GetColumnOffset(...) end

--- Parameters: int (column_index), float (offset)
---@param column_index int
---@param offset float
function  ImGui.SetColumnOffset(...) end

--- Returns: int (count)
--- count = ImGui.GetColumnsCount()
---@return int @count
function  ImGui.GetColumnsCount() end

-- ## Tab Bars, Tabs

--- Parameters: text (str_id), ImGuiTabBarFlags (flags)
--- Returns: bool (open)
--- Overloads
--- open = ImGui.BeginTabBar("String ID")
--- open = ImGui.BeginTabBar("String ID", ImGuiTabBarFlags.Reorderable)
---@param str_id string
---@param flags ImGuiTabBarFlags
---@return boolean @open
function  ImGui.BeginTabBar(...) end

function  ImGui.EndTabBar() end

--- Parameters A: text (label)
--- Parameters B: text (label), bool (open), ImGuiTabItemFlags (flags) [O]
--- Returns A: bool (selected)
--- Returns B: bool (open), bool (selected)
--- Overloads
--- selected = ImGui.BeginTabItem("Label")
--- open, selected = ImGui.BeginTabItem("Label", open)
--- open, selected = ImGui.BeginTabItem("Label", open, ImGuiTabItemFlags_NoTooltip)
function  ImGui.BeginTabItem() end

function  ImGui.EndTabItem() end

--- Parameters: text (tab_or_docked_window_label)
---@param tab_or_docked_window_label string
function  ImGui.SetTabItemClosed(...) end

-- ## Docking

--- Parameters: unsigned int (id), float (size_x) [O], float (size_y) [O], ImGuiDockNodeFlags (flags) [O]
--- Overloads
---@param int unsigned
---@param size_x float
---@param size_y float
---@param flags ImGuiDockNodeFlags
function  ImGui.DockSpace(...) end

--- Parameters: unsigned int (dock_id), ImGuiCond (cond) [O]
--- Overloads
---@param int unsigned
---@param cond ImGuiCond
function  ImGui.SetNextWindowDockID(...) end

--- Returns: unsigned int (id)
--- id = ImGui.GetWindowDockID()
---@return unsigned @int
function  ImGui.GetWindowDockID() end

--- Returns: bool (docked)
--- docked = ImGui.IsWindowDocked()
---@return boolean @docked
function  ImGui.IsWindowDocked() end

-- ## Logging

--- Parameters: int (auto_open_depth) [O]
--- Overloads
---@param auto_open_depth int
function  ImGui.LogToTTY(...) end

--- Parameters: int (auto_open_depth) [O], text (fileName) [O]
--- Overloads
---@param auto_open_depth int
---@param fileName string
function  ImGui.LogToFile(...) end

--- Parameters: int (auto_open_depth) [O]
--- Overloads
---@param auto_open_depth int
function  ImGui.LogToClipboard(...) end

function  ImGui.LogFinish() end

function  ImGui.LogButtons() end

--- Parameters: text (fmt)
---@param fmt string
function  ImGui.LogText(...) end

-- ## Clipping

--- Parameters: float (min_x), float (min_y), float (max_x), float (max_y), bool (intersect_current)
---@param min_x float
---@param min_y float
---@param max_x float
---@param max_y float
---@param intersect_current boolean
function  ImGui.PushClipRect(...) end

function  ImGui.PopClipRect() end

-- ## Focus, Activation

function  ImGui.SetItemDefaultFocus() end

--- Parameters: int (offset) [O]
--- Overloads
---@param offset int
function  ImGui.SetKeyboardFocusHere(...) end

--- Parameters: ImGuiHoveredFlags (flags) [O]
--- Returns: bool (hovered)
--- Overloads
--- hovered = ImGui.IsItemHovered()
--- hovered = ImGui.IsItemHovered(ImGuiHoveredFlags.ChildWindows)
---@param flags ImGuiHoveredFlags
---@return boolean @hovered
function  ImGui.IsItemHovered(...) end

-- ## Item / Widgets Utilities

--- Parameters: ImGuiHoveredFlags (flags) [O]
--- Returns: bool (hovered)
--- Overloads
--- hovered = ImGui.IsItemHovered()
--- hovered = ImGui.IsItemHovered(ImGuiHoveredFlags.ChildWindows)
---@param flags ImGuiHoveredFlags
---@return boolean @hovered
function  ImGui.IsItemHovered(...) end

--- Returns: bool (active)
--- active = ImGui.IsItemActive()
---@return boolean @active
function  ImGui.IsItemActive() end

--- Returns: bool (focused)
--- focused = ImGui.IsItemFocused()
---@return boolean @focused
function  ImGui.IsItemFocused() end

--- Parameters: ImGuiMouseButton (mouse_button) [O]
--- Returns: bool (clicked)
--- Overloads
--- clicked = ImGui.IsItemClicked()
--- clicked = ImGui.IsItemClicked(ImGuiMouseButton.Middle)
---@param mouse_button ImGuiMouseButton
---@return boolean @clicked
function  ImGui.IsItemClicked(...) end

--- Returns: bool (visible)
--- visible = ImGui.IsItemVisible()
---@return boolean @visible
function  ImGui.IsItemVisible() end

--- Returns: bool (edited)
--- edited = ImGui.IsItemEdited()
---@return boolean @edited
function  ImGui.IsItemEdited() end

--- Returns: bool (activated)
--- activated = ImGui.IsItemActivated()
---@return boolean @activated
function  ImGui.IsItemActivated() end

--- Returns: bool (deactivated)
--- deactivated = ImGui.IsItemDeactivated()
---@return boolean @deactivated
function  ImGui.IsItemDeactivated() end

--- Returns: bool (deactivated_after_edit)
--- deactivated_after_edit = ImGui.IsItemDeactivatedAfterEdit()
---@return boolean @deactivated_after_edit
function  ImGui.IsItemDeactivatedAfterEdit() end

--- Returns: bool (toggled_open)
--- toggled_open = ImGui.IsItemToggledOpen()
---@return boolean @toggled_open
function  ImGui.IsItemToggledOpen() end

--- Returns: bool (any_item_hovered)
--- any_item_hovered = ImGui.IsAnyItemHovered()
---@return boolean @any_item_hovered
function  ImGui.IsAnyItemHovered() end

--- Returns: bool (any_item_active)
--- any_item_active = ImGui.IsAnyItemActive()
---@return boolean @any_item_active
function  ImGui.IsAnyItemActive() end

--- Returns: bool (any_item_focused)
--- any_item_focused = ImGui.IsAnyItemFocused()
---@return boolean @any_item_focused
function  ImGui.IsAnyItemFocused() end

--- Returns: float (x), float (y)
--- x, y = ImGui.GetItemRectMin()
---@return float @x
---@return float @y
function  ImGui.GetItemRectMin() end

--- Returns: float (x), float (y)
--- x, y = ImGui.GetItemRectMax()
---@return float @x
---@return float @y
function  ImGui.GetItemRectMax() end

--- Returns: float (x), float (y)
--- x, y = ImGui.GetItemRectSize()
---@return float @x
---@return float @y
function  ImGui.GetItemRectSize() end

function  ImGui.SetItemAllowOverlap() end

-- ## Miscellaneous Utilities

--- Parameters A: float (size_x), float (size_y)
--- Parameters B: float(min_x), float (min_y), float (max_x), float (max_y)
--- Returns: bool (visible)
--- Overloads
--- visible = ImGui.IsRectVisible(100, 100)
--- visible = ImGui.IsRectVisible(50, 50, 200, 200)
---@return boolean @visible
function  ImGui.IsRectVisible(...) end

--- Returns double (time)
--- time = ImGui.GetTime()
function  ImGui.GetTime() end

--- Returns int (frame_count)
--- frame_count = ImGui.GetFrameCount()
function  ImGui.GetFrameCount() end

--- Parameters: ImGuiCol (idx)
--- Returns: text (style_color_name)
--- style_color_name = ImGui.GetStyleColorName(ImGuiCol.Text)
---@param idx ImGuiCol
---@return string @style_color_name
function  ImGui.GetStyleColorName(...) end

--- Parameters: unsigned int (id), float (size_x), float (size_y), ImGuiWindowFlags (flags) [O]
--- Returns: bool (open)
--- Overloads
--- open = ImGui.BeginChildFrame(0, 100, 100)
--- open = ImGui.BeginChildFrame(0, 100, 100, ImGuiWindowFlags.NoBackground)
---@param int unsigned
---@param size_x float
---@param size_y float
---@param flags ImGuiWindowFlags
---@return boolean @open
function  ImGui.BeginChildFrame(...) end

function  ImGui.EndChildFrame() end

-- ## Text Utilities

--- Parameters: text (text), text (text_end) [O], bool (hide_text_after_double_hash) [O], float (wrap_width) [O]
--- Returns: float (x), float (y)
--- Overloads
--- x, y = ImGui.CalcTextSize("Calculate me")
--- x, y = ImGui.CalcTextSize("Calculate me", " with an ending?")
--- x, y = ImGui.CalcTextSize("Calculate me", " with an ending?", true)
--- x, y = ImGui.CalcTextSize("Calculate me", " with an ending?", true, 100)
---@param text string
---@param text_end string
---@param hide_text_after_double_hash boolean
---@param wrap_width float
---@return float @x
---@return float @y
function  ImGui.CalcTextSize(...) end

-- ## Color Utilities

--- Parameters: float (r), float (g), float (b)
--- Returns: float (h), float (s), float (v)
--- h, s, v = ImGui.ColorConvertRGBtoHSV(1, 0, 0.5)
---@param r float
---@param g float
---@param b float
---@return float @h
---@return float @s
---@return float @v
function  ImGui.ColorConvertRGBtoHSV(...) end

--- Parameters: float (h), float (s), float (v)
--- Returns: float (r), float (g), float (b)
--- r, g, b = ImGui.ColorConvertHSVtoRGB(1, 0, 0.5)
--- ## Inputs Utilities: Keyboard
--- ImGui.GetKeyIndex(...)
--- Parameters: ImGuiKey (key)
--- Returns: int (index)
--- index = ImGui.GetKeyIndex(ImGuiKey.Tab)
---@param h float
---@param s float
---@param v float
---@return float @r
---@return float @g
---@return float @b
function  ImGui.ColorConvertHSVtoRGB(...) end

-- ## Inputs Utilities: Keyboard

--- Parameters: ImGuiKey (key)
--- Returns: int (index)
--- index = ImGui.GetKeyIndex(ImGuiKey.Tab)
---@param key ImGuiKey
---@return int @index
function  ImGui.GetKeyIndex(...) end

--- Parameters: int (key_index)
--- Returns: bool (down)
--- down = ImGui.IsKeyDown(0)
---@param key_index int
---@return boolean @down
function  ImGui.IsKeyDown(...) end

--- Parameters: int (key_index), bool (repeat) [O]
--- Returns: bool (pressed)
--- Overloads
--- pressed = ImGui.IsKeyPressed(0)
--- pressed = ImGui.IsKeyPressed(0, true)
---@param key_index int
---@param repeat boolean
---@return boolean @pressed
function  ImGui.IsKeyPressed(...) end

--- Parameters: int (key_index)
--- Returns: bool (released)
--- released = ImGui.IsKeyReleased(0)
---@param key_index int
---@return boolean @released
function  ImGui.IsKeyReleased(...) end

--- Parameters: int (key_index), float (repeat_delay), float (rate)
--- Returns: int (pressed_amount)  
--- pressed_amount = ImGui.GetKeyPressedAmount(0, 0.5, 5)
---@param key_index int
---@param repeat_delay float
---@param rate float
---@return int @pressed_amount
function  ImGui.GetKeyPressedAmount(...) end

--- Parameters: bool (want_capture_keyboard_value) [O]
--- Overloads
---@param want_capture_keyboard_value boolean
function  ImGui.CaptureKeyboardFromApp(...) end

--- Parameters: ImGuiMouseButton (button)
--- Returns: bool (down)
--- down = ImGui.IsMouseDown(ImGuiMouseButton.Right)
---@param button ImGuiMouseButton
---@return boolean @down
function  ImGui.IsMouseDown(...) end

-- ## Inputs Utilities: Mouse

--- Parameters: ImGuiMouseButton (button)
--- Returns: bool (down)
--- down = ImGui.IsMouseDown(ImGuiMouseButton.Right)
---@param button ImGuiMouseButton
---@return boolean @down
function  ImGui.IsMouseDown(...) end

--- Parameters: ImGuiMouseButton (button), bool (repeat) [O]
--- Returns: bool (clicked)
--- Overloads
--- clicked = ImGui.IsMouseClicked(ImGuiMouseButton.Right)
--- clicked = ImGui.IsMouseClicked(ImGuiMouseButton.Right, false)
---@param button ImGuiMouseButton
---@param repeat boolean
---@return boolean @clicked
function  ImGui.IsMouseClicked(...) end

--- Parameters: ImGuiMouseButton (button)
--- Returns: bool (released)
--- released = ImGui.IsMouseReleased(ImGuiMouseButton.Right)
---@param button ImGuiMouseButton
---@return boolean @released
function  ImGui.IsMouseReleased(...) end

--- Parameters: ImGuiMouseButton (button)
--- Returns: bool (double_clicked)
--- double_clicked = ImGui.IsMouseDoubleClicked(ImGuiMouseButton.Right)
---@param button ImGuiMouseButton
---@return boolean @double_clicked
function  ImGui.IsMouseDoubleClicked(...) end

--- Parameters: float (min_x), float (min_y), float (max_x), float (max_y), bool (clip) [O]
--- Returns: bool (hovered)
--- hovered = ImGui.IsMouseHoveringRect(0, 0, 100, 100)
--- hovered = ImGui.IsMouseHoveringRect(0, 0, 100, 100, true)
---@param min_x float
---@param min_y float
---@param max_x float
---@param max_y float
---@param clip boolean
---@return boolean @hovered
function  ImGui.IsMouseHoveringRect(...) end

--- Returns: bool (any_mouse_down)
--- any_mouse_down = ImGui.IsAnyMouseDown()
---@return boolean @any_mouse_down
function  ImGui.IsAnyMouseDown() end

--- Returns: float (x), float (y)
--- x, y = ImGui.GetMousePos()
---@return float @x
---@return float @y
function  ImGui.GetMousePos() end

--- Returns: float (x), float (y)
--- x, y = ImGui.GetMousePosOnOpeningCurrentPopup()
---@return float @x
---@return float @y
function  ImGui.GetMousePosOnOpeningCurrentPopup() end

--- Parameters: ImGuiMouseButton (button), float (lock_threshold) [O]
--- Returns: bool (dragging)
--- Overloads
--- dragging = ImGui.IsMouseDragging(ImGuiMouseButton.Middle)
--- dragging = ImGui.IsMouseDragging(ImGuiMouseButton.Middle, 0.5)
---@param button ImGuiMouseButton
---@param lock_threshold float
---@return boolean @dragging
function  ImGui.IsMouseDragging(...) end

--- Parameters: ImGuiMouseButton (button) [O], float (lock_threshold) [O]
--- Returns: float (x), float (y)
--- Overloads
--- x, y = ImGui.GetMouseDragDelta()
--- x, y = ImGui.GetMouseDragDelta(ImGuiMouseButton.Middle)
--- x, y = ImGui.GetMouseDragDelta(ImGuiMouseButton.Middle, 0.5)
---@param button ImGuiMouseButton
---@param lock_threshold float
---@return float @x
---@return float @y
function  ImGui.GetMouseDragDelta(...) end

--- Parameters: ImGuiMouseButton (button) [O]
--- Overloads
---@param button ImGuiMouseButton
function  ImGui.ResetMouseDragDelta(...) end

--- Returns: ImGuiMouseCursor (cursor)
--- cursor = ImGui.GetMouseCursor()
---@return ImGuiMouseCursor @cursor
function  ImGui.GetMouseCursor() end

--- Parameters: ImGuiMouseCursor (cursor_type)
---@param cursor_type ImGuiMouseCursor
function  ImGui.SetMouseCursor(...) end

--- Parameters: bool (want_capture_mouse_value) [O]
--- Overloads
---@param want_capture_mouse_value boolean
function  ImGui.CaptureMouseFromApp() end

--- Returns: text (text)
--- text = ImGui.GetClipboardText()
---@return string @text
function  ImGui.GetClipboardText() end

-- ## Clipboard Utilities

--- Returns: text (text)
--- text = ImGui.GetClipboardText()
---@return string @text
function  ImGui.GetClipboardText() end

--- Parameters: text (text)
---@param text string
function  ImGui.SetClipboardText(...) end
