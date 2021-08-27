# Hierarchy

## 搜索框

搜索场景图中每个节点的标签，对应场景图中会显示查找到的TreeNode列表

搜索为""时会重置为完整的场景图

不做，没需求，单纯显隐逻辑

## 场景图

Root开始Entity的name

![](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210712/Snipaste_2021-08-25_11-01-47.2odhru2vlue0.png)

## 右键菜单 Context Menu

在某个节点上右键有菜单，其实是对场景图的操作

![](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210712/Snipaste_2021-08-25_14-39-30.w14lw1i1x5s.png)

## 场景图

首先加载一个空的Root
然后脚本加载场景，监听脚本的Entity加载去构造场景图  // 这样成本低

