function traceback()
    for level = 1, math.huge do
	local info = debug.getinfo(level, "Sl")
	if not info then break end
	if info.what == "C" then
	    print(level, "C function")
	else
	    print(string.format("[%s]:%d", info.short_src, info.currentline))
	end
    end
end

function a()
    print("a called")
    traceback()
end

function b()
    print("b called")
    a()
end

function c()
    print("c called")
    b()
end

c()
