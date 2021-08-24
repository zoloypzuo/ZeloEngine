-- panel
-- created on 2021/8/21
-- author @zoloypzuo
local APanel = require("ui.panel")

local PanelTransformableMixin = Class(APanel, function(self)
    APanel._ctor(self)
    --const OvMaths::FVector2 &defaultPosition = OvMaths::FVector2(-1.f, -1.f),
    --const OvMaths::FVector2 &defaultSize = OvMaths::FVector2(-1.f, -1.f),
    --Settings::EHorizontalAlignment defaultHorizontalAlignment = Settings::EHorizontalAlignment::LEFT,
    --Settings::EVerticalAlignment defaultVerticalAlignment = Settings::EVerticalAlignment::TOP,
    --bool ignoreConfigFile = false

    --    OvMaths::FVector2 m_defaultPosition;
    --    OvMaths::FVector2 m_defaultSize;
    --    Settings::EHorizontalAlignment m_defaultHorizontalAlignment;
    --    Settings::EVerticalAlignment m_defaultVerticalAlignment;
    --    bool m_ignoreConfigFile;
    --
    --    OvMaths::FVector2 m_position = OvMaths::FVector2(0.0f, 0.0f);
    --    OvMaths::FVector2 m_size = OvMaths::FVector2(0.0f, 0.0f);
    --
    --    bool m_positionChanged = false;
    --    bool m_sizeChanged = false;
    --
    --    Settings::EHorizontalAlignment m_horizontalAlignment = Settings::EHorizontalAlignment::LEFT;
    --    Settings::EVerticalAlignment m_verticalAlignment = Settings::EVerticalAlignment::TOP;
    --
    --    bool m_alignmentChanged = false;
    --    bool m_firstFrame = true;

    --bool autoSize = true;
end)

function PanelTransformableMixin:Update()
    if self.enabled then
        self:_UpdateImpl()
    end
end

function PanelTransformableMixin:_UpdateImpl()
    self:UpdateWidgets()
end

return PanelTransformableMixin