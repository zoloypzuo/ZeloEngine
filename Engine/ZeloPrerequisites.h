//
// Created by zoloypzuo on 2021/3/28.
//

#ifndef ZELOENGINE_ZELOPREREQUISITES_H
#define ZELOENGINE_ZELOPREREQUISITES_H

#include "ZeloPlatform.h"

#include <string>
#include <memory>
#include <map>
#include <functional>
#include <vector>
#include <map>
#include <typeindex>
#include <algorithm>
#include <memory>
#include <chrono>

#include <glm/glm.hpp>

class IRuntimeModule {
public:
    virtual ~IRuntimeModule() = default;

    virtual void initialize() = 0;

    virtual void finalize() = 0;

    virtual void update() = 0;
};

#endif //ZELOENGINE_ZELOPREREQUISITES_H
