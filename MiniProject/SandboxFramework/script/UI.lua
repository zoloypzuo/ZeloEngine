-- UI.lua

-- 这样有一个问题
-- UI没有类型
-- 其实UI是OOP最严重的


UI = {}
-- ？？？
function UI.__towatch(ui)
end


function UI.CreateChild(ui)
end

--
-- 属性
--
function UI.GetDimensions(ui)
end
function UI.GetFont(ui)
end
function UI.GetMarkupText(ui)
end
function UI.GetOffsetPosition(ui)
end
function UI.GetPosition(ui)
end
function UI.GetScreenPosition(ui)
end
function UI.GetText(ui)
end
function UI.GetTextMargin(ui)
end
function UI.IsVisible(ui)
end
function UI.SetBackgroundColor(ui)
end
function UI.SetDimensions(ui)
end
function UI.SetGradientColor(ui)
end
function UI.SetFont(ui)
end
function UI.SetFontColor(ui)
end
function UI.SetPosition(ui)
end
function UI.SetMarkupText(ui)
end
function UI.SetText(ui)
end
function UI.SetTextMargin(ui)
end
function UI.SetVisible(ui)
end
function UI.SetWorldPosition(ui)
end
function UI.SetWorldRotation(ui)
end
return UI