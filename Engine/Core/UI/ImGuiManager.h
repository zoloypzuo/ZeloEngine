// ImGuiManager.h
// created on 2021/8/16
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Core/UI/Resource/Font.h"
#include "Core/Plugin/Plugin.h"

namespace Zelo::Core::UI {
class ImGuiManager :
        public Singleton<ImGuiManager>,
        public Plugin {
public:
    enum class EStyle {
        IM_CLASSIC_STYLE,
        IM_DARK_STYLE,
        IM_LIGHT_STYLE,
        DUNE_DARK, ALTERNATIVE_DARK
    };
public:
    ImGuiManager() = default;

    ~ImGuiManager() override = default;

    const std::string &getName() const override;

    void install() override;

    void uninstall() override;

    void initialize() override;

    void finalize() override;

    void update() override;

public:
    static ImGuiManager *getSingletonPtr();

    static ImGuiManager &getSingleton();

public:
    void render() override;

    ZELO_SCRIPT_API void ApplyStyle(EStyle style);

    ZELO_SCRIPT_API void UseFont(Font &font);

    ZELO_SCRIPT_API void EnableDocking(bool value);

    ZELO_SCRIPT_API bool IsDockingEnabled() const;

    ZELO_SCRIPT_API void ResetLayout() const;

    ZELO_SCRIPT_API std::string OpenFileDialog();

    ZELO_SCRIPT_API std::string SaveFileDialog();

    ZELO_SCRIPT_API void MessageBox(int type, const std::string &title, const std::string &message);
};
}
