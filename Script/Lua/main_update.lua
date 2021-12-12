-- main_update
-- created on 2021/8/21
-- author @zoloypzuo
local tick = 0
local function Update()
    RunScheduler(tick)
    tick = tick + 1
end

return Update