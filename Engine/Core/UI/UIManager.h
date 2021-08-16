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
};
}
