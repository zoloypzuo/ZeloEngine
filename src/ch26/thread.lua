local function downloadfile(host, file)
    local socket = require("socket")

    local c = assert(socket.connect(host, 80))

    local request = string.format("GET %s HTTP/1.0\nhost: %s\n\n", file, host)
    c:send(request)

    repeat
        local s, status, partial = c:receive(2 ^ 10)
        io.write(s or partial)
    until status == "closed"

    c:close()
end

local host = "www.lua.org"
local file = "/manual/5.3/manual.html"
downloadfile(host, file)
