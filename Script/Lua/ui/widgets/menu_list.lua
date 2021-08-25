-- menu_list
-- created on 2021/8/25
-- author @zoloypzuo
c = [=[
class MenuItem : public DataWidget<bool> {
public:

    MenuItem(const std::string &name, const std::string &shortcut = "", bool checkable = false, bool checked = false);

protected:
    void _Draw_Impl() override;

public:
    std::string name;
    std::string shortcut;
    bool checkable;
    bool checked;
    Event::Event<> ClickedEvent;
    Event::Event<bool> ValueChangedEvent;

private:
    bool m_selected;
};
MenuItem(const std::string &name, const std::string &shortcut, bool checkable,
                                        bool checked) :
        DataWidget(m_selected), name(name), shortcut(shortcut), checkable(checkable), checked(checked) {
}

void _Draw_Impl() {
    bool previousValue = checked;

    if (ImGui::MenuItem((name + m_widgetID).c_str(), shortcut.c_str(), checkable ? &checked : nullptr, enabled))
        ClickedEvent.Invoke();

    if (checked != previousValue) {
        ValueChangedEvent.Invoke(checked);
        this->NotifyChange();
    }
}

class MenuList : public Layout::Group {
public:

    MenuList(const std::string &name, bool locked = false);

protected:
    virtual void _Draw_Impl() override;

public:
    std::string name;
    bool locked;
    Event::Event<> ClickedEvent;

private:
    bool m_opened;
};
MenuList(const std::string &name, bool locked) :
        name(name), locked(locked) {
}

void _Draw_Impl() {
    if (ImGui::BeginMenu(name.c_str(), !locked)) {
        if (!m_opened) {
            ClickedEvent.Invoke();
            m_opened = true;
        }

        DrawWidgets();
        ImGui::EndMenu();
    } else {
        m_opened = false;
    }
}
]=]
local MenuItem = Class()