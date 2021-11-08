// Game.h
// created on 2021/3/28
// author @zoloypzuo
#ifndef ZELOENGINE_GAME_H
#define ZELOENGINE_GAME_H

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Core/RHI/Object/Camera.h"
#include "Core/ECS/Entity.h"
#include "Core/RHI/Object/LightPlain.h"
#include "Renderer/OpenGL/Drawable/MeshRenderer.h"  // TODO extract to Core

// TODO move namespace Zelo::Core::Game
// TODO rename to Scene
class Game : public Singleton<Game>, public IRuntimeModule {
public:
    struct FastAccessComponents {
        std::vector<MeshRenderer *> meshRenderers;
        std::vector<Camera *> cameras;
        std::vector<Zelo::Core::RHI::LightPlain *> lights;
    };

public:
    Game();

    ~Game() override;

    void initialize() override;

    void finalize() override;

    void update() override;

public:
    static Game *getSingletonPtr();

public:
    std::shared_ptr<Zelo::Core::ECS::Entity> getRootNode();

    const FastAccessComponents &getFastAccessComponents() const { return m_fastAccessComponents; }

public:
    Zelo::GUID_t SpawnPrefab(const std::string &name);

    Zelo::Core::ECS::Entity *CreateEntity();

    void SetActiveCamera(PerspectiveCamera *camera);

private:
    std::shared_ptr<Zelo::Core::ECS::Entity> rootScene{};
    Zelo::GUID_t m_entityGuidCounter{};

    FastAccessComponents m_fastAccessComponents;
};

#endif //ZELOENGINE_GAME_H