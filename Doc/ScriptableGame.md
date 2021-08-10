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
