print("9_2_2.lua run begin...")
function receive(prod)
    print("func receiver start, prod = ", prod)
    local status, value = coroutine.resume(prod)
    print("get value:", value)
    return value
end

function send(x)
    coroutine.yield(x)
end

function producer()
    print("func producer start")
    return coroutine.create(function()
        while true do
            print("please input:")
            local x = io.read()
            print("send:", x)
            send(x)
        end
    end)
end

function filter(prod)
    print("function filter start, prod = ", prod)
    return coroutine.create(function()
        for line = 1, math.huge do
            local x = receive(prod)
            x = string.format("%5d %s", line, x)
            send(x)
        end
    end)
end

function consumer(prod)
    while true do
        local x = receive(prod)
        io.write(x, " x finish\n")
    end
end

p = producer()
f = filter(p)
consumer(f)
