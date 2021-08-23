# Script/Lua

Lua脚本

* behaviours，行为脚本，接入引擎回调
* common，基础类库，基础数据结构，class实现
* engine，engine类脚本薄封装
* framework，脚本框架
* scriptlibs，第三方库
*

## 常见问题

* [?:运算符的Lua方案](http://lua-users.org/wiki/TernaryOperator)
    * 没有好方法，本身语法不支持，所以不要复杂化，用普通if-else即可
  

## 多继承方案

https://www.reddit.com/r/gamedev/comments/1uni58/the_power_of_lua_and_mixins/

http://www.lua.org/wshop12/Cronin.pdf

https://github.com/kikito/middleclass

动机，UI控件框架需要多继承，Widget和WidgetContainer两个基类

参考Ruby的mixin机制，Mixin基类是抽象类，附加在Entity上提供功能

可以理解为组件，但是其实是继承进去的，不需要Entity.components.XXX来访问

用法，扩展了include(Mixin Class)接口
```lua
Hammer = class('Hammer', Entity)
Hammer:include(PhysicsRectangle)
Hammer:include(Timer)
Hammer:include(Visual)
Hammer:include(Steerable)
--...

Blaster = class('Blaster', Entity)
Blaster:include(Timer)
Blaster:include(PhysicsRectangle)
Blaster:include(Steerable)
Blaster:include(Stats)
Blaster:include(HittableRed)
Blaster:include(EnemyExploder)
--...
```

include支持列表，并返回类，则可以这么写

```lua
Dust = class('Dust', Entity):include(PhysicsRectangle, Timer, Fader, Visual)
```