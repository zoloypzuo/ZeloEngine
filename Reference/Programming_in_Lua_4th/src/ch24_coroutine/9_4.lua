
require "socket"

function download (host, file, localfile)
	local f = nil
	print("open:", localfile)
	if localfile then
		f = io.open(localfile, "w")
	end

	local c = assert(socket.connect(host, 80))
	local count = 0
	c:send("GET " .. file .. " HTTP/1.0\r\n\r\n")

	while true do
		local s, status, partial = receive(c)
		if f then
			f:write(s or partial)
		end
		count = count + #(s or partial)
		print(count)
		if status == "closed" then break end
	end
	if f then
		print("close:", localfile)
		f:close()
	end
	c:close()
end

function receive (connection)
	connection:settimeout(0)
	print("before receive", connection)
	local s, status, partial = connection:receive(2^10)
	print("after receive")
	if status == "timeout" then
		coroutine.yield(connection)
	end
	return s or partial, status
end

threads = {}

function get (host, file, localfile)
	local co = coroutine.create(function ()
		download(host, file, localfile)
	end)
	table.insert(threads, co)
end
---[[
function dispatch()
	local i = 1
	while true do
		if threads[i] == nil then
			if threads[1] == nil then break end
			i = 1
		end
		local status, res = coroutine.resume(threads[i])
		if not res then
			print("remove:", i)
			table.remove(threads, i)
		else
			i = i + 1
		end
	end
end
--]]
function dispatchSelect()
	local i = 1
	local connections = {}
	while true do
		if threads[i] == nil then
			if threads[1] == nil then break end
			i = 1
			print("start")
			connections = {}
			print("end")
		end
		---[=[
		local status, res = coroutine.resume(threads[i])
		if not res then
			print("remove:", i)
			table.remove(threads, i)
		else
			i = i + 1
			---[[
			connections[#connections+1] = res
			print("sizeof connections:", #connections)
			if #connections == #threads then
				socket.select(connections)
			end
			---]]
		end
		---]=]
	end
end

host = "www.w3.org"
get(host, "/TR/REC-html32.html", "rec32.html")
get(host, "/TR/html401/html40.txt", "html40.txt")

--dispatch()
dispatchSelect()
