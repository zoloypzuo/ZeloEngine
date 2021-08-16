# Entity

# callback

* OnAwake和OnStart在创建/第一次激活时调用
* Enable/Disable在激活状态切换时调用
* OnDestroy在析构时调用，与OnAwake/OnStart配对，如果没有初始化过则不调用
* OnUpdate/OnFixedUpdate/OnLateUpdate由引擎更新调用

```c++
void OnAwake();

void OnStart();

void OnEnable();

void OnDisable();

void OnDestroy();

void OnUpdate(float deltaTime);

void OnFixedUpdate(float deltaTime);

void OnLateUpdate(float deltaTime);
```

# state

* m_destroyed，标记销毁状态，下帧销毁
* m_sleeping，标记不受active影响

## active

场景图上勾选某一Entity则激活它，这个是递归行为，影响该Entiity的子树

记录当前值和上次的值，切换时调用Enable和Disable
```c++
bool m_active = true;
bool m_wasActive = false;
```

`IsSelfActive`返回`m_active`

`IsActive`返回根到该Entity路径上是否都是active
```c++
bool Entity::IsActive() const {
    return m_active && (m_parentEntity ? m_parentEntity->IsActive() : true);
}
```

`SetActive`递归设置激活
首先递归记录wasActive

```c++
void Entity::SetActive(bool active) {
    if (active != m_active) {
        RecursiveWasActiveUpdate();
        m_active = active;
        RecursiveActiveUpdate();
    }
}
```

睡眠表示当前节点不受递归影响
调用Enable和Disable，如果没有调用过则调用Awake和Start

```c++
if (!m_sleeping) {
    if (!m_wasActive && isActive) {
        if (!m_awake)
            OnAwake();

        OnEnable();

        if (!m_started)
            OnStart();
    }

    if (m_wasActive && !isActive)
        OnDisable();
}
```