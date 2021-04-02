//
// Created by zoloypzuo on 2021/3/28.
//

#ifndef ZELOENGINE_ZELOPREREQUISITES_H
#define ZELOENGINE_ZELOPREREQUISITES_H

#include "ZeloPlatform.h"

#include <memory>
#include <iostream>
#include <sstream>
#include <functional>
#include <typeindex>
#include <algorithm>
#include <chrono>
#include <utility>
#include <typeindex>

// containers
#include <string>
#include <array>
#include <vector>
#include <map>
#include <unordered_map>
#include <unordered_set>

#include <glm/glm.hpp>

class IRuntimeModule {
public:
    virtual ~IRuntimeModule() = default;

    virtual void initialize() = 0;

    virtual void finalize() = 0;

    virtual void update() = 0;
};

#endif //ZELOENGINE_ZELOPREREQUISITES_H
