-- engine.lua
-- created on 2021/5/5
-- author @zoloypzuo
local Zelo = require("Zelo")

local Engine = Class(function(self)
    self.engine_cxx = Zelo.Engine.getSingleton()
end)

engine = Engine()
