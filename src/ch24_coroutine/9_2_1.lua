print("9_2.lua run begin...")
function receiver()
    print("receiver wait for receive")
    local status, value = coroutine.resume(producer)
    print("get value:", value)
    return value
end

function send(x)
    coroutine.yield(x)
end

producer = coroutine.create(
function()
    while true do
	print("please input:")
	local x = io.read()
	print("send:", x)
	send(x)
    end
end
)

q = false
bb = {}
while not q do
	print(bb)
	bb = {}
	v = receiver()
	if(v=='q') then
	    q = true
	end
end
