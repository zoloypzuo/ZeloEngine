# Script/Lua

Lua脚本

* common，基础类库，基础数据结构，class实现
* editor，编辑器脚本
* engine，engine类脚本薄封装
* framework，脚本框架
* scriptlibs，第三方库
* ui，imgui封装

## 常见问题

### [?:运算符的Lua方案](http://lua-users.org/wiki/TernaryOperator)

没有好方法，本身语法不支持，所以不要复杂化，用普通if-else即可

#### and-or

这种方法是可以接受的，写法 cond and resultA or resultB，要求：
1. cond必须是bool
2. result不能是bool

说明：

下面这种语法，要求第一个必须是bool，不能是int或者其他，因为and运算符的规则

这个事情本身就要小心，lua的条件false规则和python不同，false和nil评估为假，其他都为真

此外，b or c不能是bool，边界条件是错误的
```lua
> =1 and 2 or 3
2
> =0 and 2 or 3
2
> =true and 2 or 3
2
> =false and 2 or 3
3
```
