debug.sethook(print, "l")

function trace(event, line)
    local s = debug.getinfo(2).short_src
    print(s .. ":" .. line)
end

debug.sethook(trace, "l")


a = 3
print(a)
