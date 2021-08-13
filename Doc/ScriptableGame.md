# Scriptable Game
# main_function.lua

该文件中存了核心的全局函数，C从这个文件获取Lua函数执行

# 完整原来Game代码
```c++
Game::initialize();
auto *input = Input::getSingletonPtr();
input->registerKeyToAction(SDLK_SPACE, "fire");
input->registerKeyToAction(SDLK_c, "swapCamera");

input->bindAction("fire", IE_PRESSED, [this]() {
    MeshLoader cube("cube.obj");
    cube.getEntity()->getTransform().setPosition(primary_camera->getParent()->getPosition());
    addToScene(cube.getEntity());
    auto dir = primary_camera->getParent()->getDirection();
});

input->bindAction("swapCamera", IE_PRESSED, [this]() {
    GLManager::getSingletonPtr()->setActiveCamera(primary_camera2);
});

input->bindAction("swapCamera", IE_RELEASED, [this]() {
    GLManager::getSingletonPtr()->setActiveCamera(primary_camera);
});


primary_camera = money2.getEntity()->getComponent<PerspectiveCamera>();

MeshLoader light("monkey3.obj");
light.getEntity()->getTransform().setPosition(glm::vec3(-2.0f, 4.0f, -1.0f));
light.getEntity()->addComponent<DirectionalLight>(glm::vec3(1), 2.8f);

addToScene(light.getEntity());

GLManager::getSingletonPtr()->setActiveCamera(primary_camera);
```