// UIManager.h
// created on 2021/8/16
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Core/Interface/IDrawable.h"

namespace Zelo::Core::UI {
class UIManager :
        public Singleton<UIManager>,
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
    UIManager() = default;

    ~UIManager() override = default;

    void initialize() override;

    void finalize() override;

    void update() override;

public:
    static UIManager *getSingletonPtr();

    static UIManager &getSingleton();

public:
    void draw() override;

    ZELO_SCRIPT_API void ApplyStyle(EStyle style);
};
}
