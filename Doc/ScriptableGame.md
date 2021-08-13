# Scriptable Game

原先纯C代码

```c++
auto brickMat = std::make_shared<Material>(std::make_shared<GLTexture>(Zelo::Resource("bricks2.jpg")),
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
```

现在，预先注册 维护prefab表，先调用fn（创建entity），再用asset去构造Renderer组件

```lua
function SpawnPrefab(name)

    -- TheSim:ProfilerPush("SpawnPrefab "..name)

    -- "common/monsters/abigail" => "abigail"
    name = string.sub(name, string.find(name, "[^/]*$"))
    -- rename a name
    name = renames[name] or name

    local guid = TheSim:SpawnPrefab(name)

    -- TheSim:ProfilerPop()
    return Ents[guid]
end
```

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

MeshLoader money("monkey3.obj");
money.getEntity()->getTransform().setPosition(glm::vec3(0, 0, 8));
money.getEntity()->addComponent<PerspectiveCamera>(Mathf::PI / 2.0f, 800.0f / 600.0f,
                                                   0.05f, 100.0f);
money.getEntity()->addComponent<SpotLight>(glm::vec3(0.1f, 1.0f, 1.0f), 5.8f, 0.7f,
                                           std::make_shared<Attenuation>(0.0f, 0.0f, 0.2f));
addToScene(money.getEntity());

MeshLoader money2("monkey3.obj");
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

MeshLoader light("monkey3.obj");
light.getEntity()->getTransform().setPosition(glm::vec3(-2.0f, 4.0f, -1.0f));
light.getEntity()->addComponent<DirectionalLight>(glm::vec3(1), 2.8f);

addToScene(light.getEntity());

GLManager::getSingletonPtr()->setActiveCamera(primary_camera);
```