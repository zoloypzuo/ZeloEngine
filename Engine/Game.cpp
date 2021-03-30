// Game.cpp
// created on 2021/3/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Game.h"
#include "Entity.h"
#include "Engine.h"
// TODO rm it
#include "Renderer/OpenGL/Light.h"
#include "Renderer/OpenGL/Material.h"
#include "Renderer/OpenGL/Texture.h"
#include "Renderer/OpenGL/MeshRenderer.h"
#include "Renderer/OpenGL/GLManager.h"
#include "Renderer/OpenGL/Camera.h"
#include "Renderer/OpenGL/MeshLoader.h"

class Game::Impl : public IRuntimeModule {
public:
    void initialize() override;

    void finalize() override;

    void update() override;

    void addToScene(std::shared_ptr<Entity> entity);

public:
    std::shared_ptr<Entity> root;
};

void Game::Impl::initialize() {
    root = std::make_unique<Entity>();
    auto brickMat = std::make_shared<Material>(std::make_shared<Texture>(Asset("bricks2.jpg")),
                                               std::make_shared<Texture>(Asset("bricks2_normal.jpg")),
                                               std::make_shared<Texture>(Asset("bricks2_specular.png")));
    auto planeMesh = Plane::getMesh();
    // ground
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform().setPosition(glm::vec3(-5, -2, 0)).setScale(glm::vec3(10, 1, 10));
//     plane->addComponent<BoxCollider>(glm::vec3(5, 0, 5), 0);

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform().setPosition(glm::vec3(5, -2, 0)).setScale(glm::vec3(10, 1, 10));
//     plane->addComponent<BoxCollider>(glm::vec3(5, 0, 5), 0);

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform().setPosition(glm::vec3(-5, -2, 10)).setScale(glm::vec3(10, 1, 10));
//     plane->addComponent<BoxCollider>(glm::vec3(5, 0, 5), 0);

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform().setPosition(glm::vec3(5, -2, 10)).setScale(glm::vec3(10, 1, 10));
//     plane->addComponent<BoxCollider>(glm::vec3(5, 0, 5), 0);

        addToScene(plane);
    }

    // front wall
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform()
                .setPosition(glm::vec3(-5, 3, -5))
                .setScale(glm::vec3(10, 1, 10))
                .rotate(glm::vec3(1, 0, 0), glm::pi<float>() / 2.f);
//     plane->addComponent<BoxCollider>(glm::vec3(5, 0, 5), 0);

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform()
                .setPosition(glm::vec3(5, 3, -5))
                .setScale(glm::vec3(10, 1, 10))
                .rotate(glm::vec3(1, 0, 0), glm::pi<float>() / 2.f);
//     plane->addComponent<BoxCollider>(glm::vec3(5, 0, 5), 0);

        addToScene(plane);
    }

    // back wall
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform()
                .setPosition(glm::vec3(-5, 3, 15))
                .setScale(glm::vec3(10, 1, 10))
                .rotate(glm::vec3(1, 0, 0), -glm::pi<float>() / 2.f);
//     plane->addComponent<BoxCollider>(glm::vec3(5, 0, 5), 0);

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform()
                .setPosition(glm::vec3(5, 3, 15))
                .setScale(glm::vec3(10, 1, 10))
                .rotate(glm::vec3(1, 0, 0), -glm::pi<float>() / 2.f);
//     plane->addComponent<BoxCollider>(glm::vec3(5, 0, 5), 0);

        addToScene(plane);
    }

    // left wall
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform()
                .setPosition(glm::vec3(-10, 3, 0))
                .setScale(glm::vec3(10, 1, 10))
                .rotate(glm::vec3(0, 0, 1), -glm::pi<float>() / 2.f);
//     plane->addComponent<BoxCollider>(glm::vec3(5, 0, 5), 0);

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform()
                .setPosition(glm::vec3(-10, 3, 10))
                .setScale(glm::vec3(10, 1, 10))
                .rotate(glm::vec3(0, 0, 1), -glm::pi<float>() / 2.f);
//     plane->addComponent<BoxCollider>(glm::vec3(5, 0, 5), 0);

        addToScene(plane);
    }

    // right wall
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform()
                .setPosition(glm::vec3(10, 3, 0))
                .setScale(glm::vec3(10, 1, 10))
                .rotate(glm::vec3(0, 0, 1), glm::pi<float>() / 2.f);
//     plane->addComponent<BoxCollider>(glm::vec3(5, 0, 5), 0);

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform()
                .setPosition(glm::vec3(10, 3, 10))
                .setScale(glm::vec3(10, 1, 10))
                .rotate(glm::vec3(0, 0, 1), glm::pi<float>() / 2.f);
//     plane->addComponent<BoxCollider>(glm::vec3(5, 0, 5), 0);

        addToScene(plane);
    }

    /*{
      MeshLoader ml("Pregnant.obj");
      ml.getEntity()->getTransform().setPosition(glm::vec3(0 + (i * 3), -2, -2.5));
      ml.getEntity()->addComponent<Sphere>(1);
      addToScene(ml.getEntity());
    }*/

//    for (int i = 0; i < 10; i++) {
//        MeshLoader ml("AncientUgandan.obj");
//        ml.getEntity()->getTransform().setPosition(glm::vec3(0, i * 3, -2.5));
//        ml.getEntity()->addComponent<SphereCollider>(1, 1);
//        addToScene(ml.getEntity());
//    }
//
//    MeshLoader money("monkey3.obj");
//    money.getEntity()->getTransform().setPosition(glm::vec3(0, 0, 8));
//    money.getEntity()->addComponent<PerspectiveCamera>(glm::pi<float>() / 2.0f, getEngine()->getWindow()->getWidth() /
//                                                                                (float) getEngine()->getWindow()->getHeight(),
//                                                       0.05f, 100.0f);
//    //money.getEntity()->addComponent<SpotLight>(glm::vec3(0.1f, 1.0f, 1.0f), 5.8f, 0.7f, std::make_shared<Attenuation>(0, 0, 0.2));
//    money.getEntity()->addComponent<SphereCollider>(1, 1);
//    addToScene(money.getEntity());
//
    MeshLoader money2("monkey3.obj");
    money2.getEntity()->addComponent<PerspectiveCamera>(glm::pi<float>() / 2.0f, 800 / 600,
                                                        0.8f, 100.0f);
//    money2.getEntity()->addComponent<FreeMove>();
//#if defined(ANDROID)
//    money2.getEntity()->addComponent<FreeLook>(0.1f);
//#else
//    money2.getEntity()->addComponent<FreeLook>();
//#endif
//    money2.getEntity()->getTransform().setPosition(glm::vec3(0, 0, 5)).setScale(glm::vec3(0.8, 0.8, 0.8));
//    money2.getEntity()->addComponent<SpotLight>(glm::vec3(1.0f, 1.0f, 1.0f), 2.8f, 0.7f,
//                                                std::make_shared<Attenuation>(0, 0, 0.2));
//
//    addToScene(money2.getEntity());

    std::shared_ptr<PerspectiveCamera> primary_camera = money2.getEntity()->getComponent<PerspectiveCamera>();

    GLManager::getSingletonPtr()->setActiveCamera(primary_camera);
}

void Game::Impl::finalize() {

}

void Game::Impl::update() {
    root->updateAll(Input::getSingletonPtr(), Engine::getSingletonPtr()->getDeltaTime());
}

void Game::Impl::addToScene(std::shared_ptr<Entity> entity) {
    root->addChild(entity);
}


void Game::update() {
    pImpl_->update();
}

template<> Game *Singleton<Game>::msSingleton = nullptr;

Game &Game::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}

Game *Game::getSingletonPtr() {
    return msSingleton;
}

std::shared_ptr<Entity> Game::getRootNode() {
    return std::shared_ptr<Entity>();
}

Game::Game() : pImpl_(std::make_unique<Impl>()) {
    pImpl_->initialize();
}

Game::~Game() {
    pImpl_->finalize();
}
