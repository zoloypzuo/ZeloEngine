// ImGuiManager.h
// created on 2021/8/16
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Core/Interface/IDrawable.h"
#include "Core/UI/Resource/Font.h"

namespace Zelo::Core::UI {
class ImGuiManager :
        public Singleton<ImGuiManager>,
        public IRuntimeModule,
        public IDrawable {
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

    void initialize() override;

    void finalize() override;

    void update() override;

public:
    static ImGuiManager *getSingletonPtr();

    static ImGuiManager &getSingleton();

public:
    void draw() override;

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
