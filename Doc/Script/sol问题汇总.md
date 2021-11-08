# sol问题汇总

## new_enum创建空表

比较诡异，同样的代码，我单独跑用例是好的，但是Zelo里就不对

测了一下enum注册进去就是number，也没有类型

目前的解决是使用create_table