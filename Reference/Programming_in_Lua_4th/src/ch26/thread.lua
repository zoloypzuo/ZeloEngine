local socket = require("socket")

-- 一个不会阻塞的接受数据函数，在没有收到足够数据时挂起
local function receive(connection)
    connection:settimeout(0)
    local s, status, partial = connection:receive(2 ^ 10)
    if status == "timeout" then
        coroutine.yield(connection)
    end
    return (s or partial), status
end

local function download(host, file)
    local c = assert(socket.connect(host, 80))
    local count = 0 -- TODO rename to n_bytes
    local request = string.format("GET %s HTTP/1.0\nhost: %s\n\n", file, host)
    c:send(request)

    repeat
        -- 原始的receive是阻塞调用，是下载的瓶颈
        -- local s, status, partial = c:receive(2 ^ 10)
        local s, status = receive(c)
        count = count + #s
    until status == "closed"

    c:close()

    print(file, count)
end

-- 单线程下载
-- 用不了，因为我已经改为多线程了
-- 懒得写单线程版本了
function test()
    local host = "www.lua.org"
    local file = "/manual/5.3/manual.html"
    download(host, file)
end

-- TODO to mod scheduler

-- all active tasks
tasks = {}

-- 创建任务
function get(host, file)
    local co = coroutine.wrap(
            function()
                download(host, file)
            end
    )
    table.insert(tasks, co)
end

-- 调度循环
function dispath()
    local i = 1
    local timeout = {}
    while true do
        -- 当前任务为空
        if tasks[i] == nil then
            if tasks[1] == nil then
                break
            end
            i = 1
            timeout = {}
        else
            -- 执行任务
            local res = tasks[i]()
            -- 任务结束则销毁任务
            if not res then
                table.remove(tasks, i)
            else
                -- 否则执行下一个任务
                i = i + 1
                timeout[#timeout + 1] = res
                if #timeout == #tasks then
                    -- 如果所有连接超时，等待状态发生变化
                    socket.select(timeout)
                end
            end
        end
    end
end

local host = "www.lua.org"
local file = "/manual/5.3/manual.html"

get(host, file)
get(host, file)
get(host, file)
get(host, file)

dispath()

--/manual/5.3/manual.html	327583
--/manual/5.3/manual.html	327583
--/manual/5.3/manual.html	327583
--/manual/5.3/manual.html	327583
