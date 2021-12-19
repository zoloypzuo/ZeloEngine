-- main_initialize.lua
-- created on 2021/8/18
-- author @zoloypzuo

-- singleton
global("TheSim")
TheSim = Game.GetSingletonPtr()

require("resource_loaders")
require("plugins")

-- TODO load scene
LoadAvatar()
SpawnPrefab("bistro")