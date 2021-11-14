# Resource

```c
+---Effects // 特效
| +---Animations
| +---Textures
| +---Materials
| +---Prefabs
| \---Textures
|
+---Entities // 有动画的动态东西
| |
| \---char_example_skeleton // 东西的名称
| | skeleton@attack.fbx
| | skeleton@damage.fbx
| | skeleton@death.fbx
| | skeleton@idle.fbx
| | skeleton@Knockback.fbx
| | skeleton@Run.fbx
| | skeleton@skill.fbx
| | skeleton@skin.fbx
| | skeleton@stand.fbx
| | skeleton@walk.fbx
| |
| +---Animations // 所有动画相关的东西
| | skeleton.controller
| |
| +---Materials
| | skeleton_d.mat
| |
| +---Prefabs // 预览美术效果用的Prefab
| \---Textures
| skeleton_d.tif
|
+---Objects // 没有动画的静态东西，包括场景装饰
+---Prefabs // 主要给程序用，配置好资源用于游戏直接加载
| char_example_skeleton.prefab
|
+---Scenes
| |
| +---example // 场景相同名称目录，放场景相关的导航、光照贴图等资源
| |
| \---example.unity
|
\---Shaders
```