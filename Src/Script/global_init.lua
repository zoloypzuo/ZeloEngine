-- global_init.lua
-- created on 2019/9/26
-- author @zoloypzuo
--
-- 这些内容将以全局变量或函数的形式提供，补充标准lua
-- 全局是出于方便性的考虑
-- 标准库缺乏很多基本函数，与python形成很大的对比；我们需要长期选择，和扩充自己的lua
--
-- 所有的全局脚本都在这里进行require，不要比如在std_extension中require其他全局脚本list
-- 这是出于便于管理的原因，你可以看到有一些初始化顺序依赖的问题，都放在global，便于决策

--
-- 初始化是蛮坑爹的
-- 这里要把基础的组件优先初始化
--
require("strict") -- Class.lua要用strict
require("std_extension")
require("PlainClass")
require("Class")

--
-- 数据结构
-- 在基础组件后初始化
--
require("list")

-- 工具
-- 工具是独立的，最后加载
require "util"
