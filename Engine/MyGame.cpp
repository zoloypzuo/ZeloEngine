// MyGame.cpp
// created on 2021/4/10
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "MyGame.h"
#include "Zelo.h"
#include "Plane.h"
#include "MeshLoader.h"
#include "Material.h"

void MyGame::initialize() {
    Game::initialize();
    auto *input = Input::getSingletonPtr();
    input->registerKeyToAction(SDLK_SPACE, "fire");
    input->registerKeyToAction(SDLK_c, "swapCamera");

    input->bindAction("fire", IE_PRESSED, [this]() {
        Zelo::Parser::MeshLoader cube("cube.obj");
        cube.getEntity()->getTransform().setPosition(primary_camera->getParent()->getPosition());
        addToScene(cube.getEntity());
        auto dir = primary_camera->getParent()->getDirection();
    });

    input->bindAction("swapCamera", IE_PRESSED, [this]() {
//        GLRenderSystem::getSingletonPtr()->setActiveCamera(primary_camera2);
    });

    input->bindAction("swapCamera", IE_RELEASED, [this]() {
//        GLRenderSystem::getSingletonPtr()->setActiveCamera(primary_camera);
    });

    auto brickMat = std::make_shared<Zelo::Core::RHI::Material>(std::make_shared<GLTexture>(Zelo::Resource("bricks2.jpg")),
                                                                std::make_shared<GLTexture>(Zelo::Resource("bricks2_normal.jpg")),
                                                                std::make_shared<GLTexture>(Zelo::Resource("bricks2_specular.png")));
    auto planeMesh = Plane::getMesh();
    // ground
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform().setPosition(glm::vec3(-5, -2, 0)).setScale(glm::vec3(10, 1, 10));

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform().setPosition(glm::vec3(5, -2, 0)).setScale(glm::vec3(10, 1, 10));

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform().setPosition(glm::vec3(-5, -2, 10)).setScale(glm::vec3(10, 1, 10));

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform().setPosition(glm::vec3(5, -2, 10)).setScale(glm::vec3(10, 1, 10));

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

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform()
                .setPosition(glm::vec3(5, 3, -5))
                .setScale(glm::vec3(10, 1, 10))
                .rotate(glm::vec3(1, 0, 0), glm::pi<float>() / 2.f);

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

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform()
                .setPosition(glm::vec3(5, 3, 15))
                .setScale(glm::vec3(10, 1, 10))
                .rotate(glm::vec3(1, 0, 0), -glm::pi<float>() / 2.f);

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

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform()
                .setPosition(glm::vec3(-10, 3, 10))
                .setScale(glm::vec3(10, 1, 10))
                .rotate(glm::vec3(0, 0, 1), -glm::pi<float>() / 2.f);

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

        addToScene(plane);
    }
    {
        auto plane = std::make_shared<Entity>();
        plane->addComponent<MeshRenderer>(planeMesh, brickMat);
        plane->getTransform()
                .setPosition(glm::vec3(10, 3, 10))
                .setScale(glm::vec3(10, 1, 10))
                .rotate(glm::vec3(0, 0, 1), glm::pi<float>() / 2.f);

        addToScene(plane);
    }

    /*{
      MeshLoader ml("Pregnant.obj");
      ml.getEntity()->getTransform().setPosition(glm::vec3(0 + (i * 3), -2, -2.5));
      ml.getEntity()->addComponent<Sphere>(1);
      addToScene(ml.getEntity());
    }*/

    for (int i = 0; i < 10; i++) {
        Zelo::Parser::MeshLoader ml("AncientUgandan.obj");
        ml.getEntity()->getTransform().setPosition(glm::vec3(0, i * 3, -2.5));
        addToScene(ml.getEntity());
    }

    Zelo::Parser::MeshLoader money("monkey3.obj");
    money.getEntity()->getTransform().setPosition(glm::vec3(0, 0, 8));
    money.getEntity()->addComponent<PerspectiveCamera>(Mathf::PI / 2.0f, 800.0f / 600.0f,
                                                       0.05f, 100.0f);
    money.getEntity()->addComponent<SpotLight>(glm::vec3(0.1f, 1.0f, 1.0f), 5.8f, 0.7f,
                                               std::make_shared<Attenuation>(0.0f, 0.0f, 0.2f));
    addToScene(money.getEntity());

    Zelo::Parser::MeshLoader money2("monkey3.obj");
    money2.getEntity()->addComponent<PerspectiveCamera>(Mathf::PI / 2.0f, 800.0f / 600.0f,
                                                        0.8f, 100.0f);
    money2.getEntity()->addComponent<FreeMove>();
#if defined(ANDROID)
    money2.getEntity()->addComponent<FreeLook>(0.1f);
#else
    money2.getEntity()->addComponent<FreeLook>();
#endif
    money2.getEntity()->getTransform().setPosition(glm::vec3(0, 0, 5)).setScale(glm::vec3(0.8, 0.8, 0.8));
    money2.getEntity()->addComponent<SpotLight>(glm::vec3(1.0f, 1.0f, 1.0f), 2.8f, 0.7f,
                                                std::make_shared<Attenuation>(0.0f, 0.0f, 0.2f));

    addToScene(money2.getEntity());

    primary_camera = money2.getEntity()->getComponent<PerspectiveCamera>();

    Zelo::Parser::MeshLoader light("monkey3.obj");
    light.getEntity()->getTransform().setPosition(glm::vec3(-2.0f, 4.0f, -1.0f));
    light.getEntity()->addComponent<DirectionalLight>(glm::vec3(1), 2.8f);

    addToScene(light.getEntity());

//    GLRenderSystem::getSingletonPtr()->setActiveCamera(primary_camera);
}