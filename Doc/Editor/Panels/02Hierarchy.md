# Hierarchy

## 搜索框

搜索场景图中每个节点的标签，对应场景图中会显示查找到的TreeNode列表

搜索为""时会重置为完整的场景图

## 场景图

Root开始Entity的name

![](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210712/Snipaste_2021-08-25_11-01-47.2odhru2vlue0.png)

因为我们是InGameEditor，所以需要实时对应场景图

我们不做独立的Editor，那是浪费时间，编辑场景图，保存场景图，加载场景图
这一套还是静态的，所以没有意义

我们暂时不做序列化，实时加Entity，编辑组件属性即可，之后看有什么需求再序列化

## 右键菜单 Context Menu

在某个节点上右键有菜单，其实是对场景图的操作

![](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210712/Snipaste_2021-08-25_14-39-30.w14lw1i1x5s.png)