// ISerializable.h
// created on 2021/7/15
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include <yaml-cpp/yaml.h>

namespace Zelo::Core::Interface {
class ISerializable {
    virtual ~ISerializable() = default;

    virtual void OnSerialize(YAML::Emitter &emitter) = 0;

    virtual void OnDeserialize(const YAML::Node &node) = 0;
};
}
