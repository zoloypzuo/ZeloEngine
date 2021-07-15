// ISerializable.h
// created on 2021/7/15
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

namespace Zelo::Core::Interface {
class ISerializable {
    virtual ~ISerializable() = default;

    virtual void OnSerialize();

    virtual void OnDeserialize();
};
}
