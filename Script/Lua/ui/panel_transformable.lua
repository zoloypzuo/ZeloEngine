-- panel
-- created on 2021/8/21
-- author @zoloypzuo
local APanel = require("ui.panel")
require("ui.ui_consts")

local PanelTransformable = Class(APanel, function(
        self,
        defaultPosition,
        defaultSize,
        defaultHorizontalAlignment,
        defaultVerticalAlignment,
        ignoreConfigFile)
    APanel._ctor(self)
    -- ImGui::SetWindowPos/ImGui::GetWindowPos
    -- 控件缓存位置，并同步给ImGui（仅当改变时）
    -- 根据对齐算位置和大小
    self.m_defaultPosition = defaultPosition or Vector2(-1, -1)
    self.m_defaultSize = defaultSize or Vector2(-1, -1)
    self.m_defaultHorizontalAlignment = defaultHorizontalAlignment or EHorizontalAlignment.LEFT
    self.m_defaultVerticalAlignment = defaultVerticalAlignment or EVerticalAlignment.TOP

    self.m_ignoreConfigFile = ignoreConfigFile or false

    self.m_position = Vector2(0, 0)
    self.m_size = Vector2(0, 0)
    self.m_positionChanged = false
    self.m_sizeChanged = false

    self.m_horizontalAlignment = EHorizontalAlignment.LEFT
    self.m_verticalAlignment = EVerticalAlignment.TOP
    self.m_alignmentChanged = false

    self.autoSize = true

    self.m_firstFrame = true
end)

function PanelTransformable:Update()
    if not self.m_firstFrame then
        if not self.autoSize then
            self:_UpdateSize()
        end
        self.size = Vector2(ImGui.GetWindowSize())
        self:UpdatePosition()
        self.m_position = Vector2(ImGui.GetWindowPos())
        self.m_firstFrame = false
    end
end

function PanelTransformable:_UpdateImpl()
    error("implemented by derived class")
end

function PanelTransformable:SetPosition(position)
    self.m_position = position
    self.m_positionChanged = true
end

function PanelTransformable:SetSize(size)
    self.m_size = size
    self.m_sizeChanged = true
end

function PanelTransformable:SetAlignment(horizontalAlignment, verticalAlignment)
    self.m_horizontalAlignment = horizontalAlignment
    self.m_verticalAlignment = verticalAlignment
    self.m_alignmentChanged = true
end

function PanelTransformable:_UpdateSize()
    if self.m_sizeChanged then
        ImGui.SetWindowSize(self.m_size.x, self.m_size.y, ImGuiCond.Always)
        self.m_sizeChanged = false
    end
end

function PanelTransformable:_UpdatePosition()
    if self.m_defaultPosition.x ~= -1 and self.m_defaultPosition ~= 1 then
        local offsettedDefaultPos = self.m_defaultPosition + self:_CalculatePositionAlignmentOffset(true)
        local flag = self.m_ignoreConfigFile and ImGuiCond.Once or ImGuiCond.FirstUseEver
        ImGui.SetWindowPos(offsettedDefaultPos.x, offsettedDefaultPos.y, flag)
    end

    if self.m_positionChanged or self.m_alignmentChanged then
        local offset = self:_CalculatePositionAlignmentOffset(false)
        local offsettedDefaultPos = self.m_position + offset
        ImGui.SetWindowPos(offsettedDefaultPos.x, offsettedDefaultPos.y, ImGuiCond.Always)
        self.m_positionChanged = false;
        self.m_alignmentChanged = false;
    end
end

function PanelTransformable:_CalculatePositionAlignmentOffset(default)
    local result = Vector2()
    local HA = default and self.m_defaultHorizontalAlignment or self.m_horizontalAlignment
    if HA == EHorizontalAlignment.CENTER then
        result.x = result.x - self.m_size.x / 2
    elseif HA == EHorizontalAlignment.RIGHT then
        result.x = result.x - self.m_size.x
    end

    local VA = default and self.m_defaultVerticalAlignment or self.m_VerticalAlignment
    if VA == EVerticalAlignment.MIDDLE then
        result.x = result.x - self.m_size.x / 2
    elseif VA == EVerticalAlignment.BOTTOM then
        result.x = result.x - self.m_size.x
    end
    return result
end

return PanelTransformable