#include "ZeloPreCompiledHeader.h"
#include "Entity.h"

namespace Zelo {

Entity::Entity(entt::entity handle, Scene *scene)
        : m_EntityHandle(handle), m_Scene(scene) {
}

}