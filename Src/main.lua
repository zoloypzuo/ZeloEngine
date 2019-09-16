-- main.lua
-- created on 2019/9/15
-- author @zoloypzuo

package.path = [[.\?.lua';]] ..
        [[D:\ZeloEngine\Src\Config\Class\?.lua;]] ..
        [[D:\ZeloEngine\Src\Script\?.lua;]] ..
        [[D:\ZeloEngine\Src\Config\?.lua;]]
local o = require("d3d_app_config")

print(o.mainWndCaption)
