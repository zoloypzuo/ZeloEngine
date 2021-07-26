#pragma once

#include "ZeloPrerequisites.h"

#include "Scene.h"

namespace Zelo {

class SceneSerializer {
public:
    explicit SceneSerializer(const std::shared_ptr<Scene> &scene);

    void Serialize(const std::string &filepath);

    void SerializeRuntime(const std::string &filepath);

    bool Deserialize(const std::string &filepath);

    bool DeserializeRuntime(const std::string &filepath);

private:
    std::shared_ptr<Scene> m_Scene;
};

}
