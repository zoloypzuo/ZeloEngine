if PLATFORM == "WIN32" then

require "copas"
local port = 1995

function echoHandler(skt)	
	skt = copas.wrap(skt)
	while true do
		local data, err = skt:receive("*l")
		if data then
			InjectDebugCommand(data)
		else
			Print(VERBOSITY.ERROR, "Telnet error: " .. err)
			break
		end
	end
end


local server = socket.bind("*", port)
local ip, port = server:getsockname()
Print(VERBOSITY.DEBUG, "Please telnet to localhost on port " .. port)

copas.addserver(server, echoHandler)

function DoServerUpdate()
	copas.step(0)
	return true
end

AddWallUpdateFn(DoServerUpdate)

end
