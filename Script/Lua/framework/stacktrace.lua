local getinfo = debug.getinfo
local max = math.max
local concat = table.concat

local function getfiltersource(src)
    if not src then return "[?]" end
    if src:sub(1, 1) == "@" then
        src = src:sub(2)
    end
    return src
end

function SaveToString(v)
	local status, retval = xpcall(function() return tostring(v) end, function() return "*** failed to evaluate ***" end)
	local maxlen = 1024
	if retval:len() > maxlen then
			retval = retval:sub(1,maxlen).." [**truncated**]"
	end
	return retval
end

local function getformatinfo(info)
    if not info then return "**error**" end
    local source = getfiltersource(info.source)
    if info.currentline then
        source = source..":"..info.currentline
    end
    return ("@%s in (%s) %s (%s) <%d-%d>"):format(source, info.namewhat, info.name or "?", info.what, info.linedefined, info.lastlinedefined)
end

function getdebuglocals (res, level)
    local t = {}
    local index = 1
    while true do
        local name, value = debug.getlocal(level + 1, index)
        if not name then 
			break 
		end
		-- skip compiler generated variables 
	    if name:sub(1, 1) ~= "(" then
			if name == "self" and type(value)=="table" then
				if value.IsValid and type(value.IsValid) == "function" then
				    res[#res+1] = string.format("   self (valid:"..tostring(value:IsValid())..") =")
				else
				    res[#res+1] = string.format("   self =")
				end
				for i,v in pairs(value) do
					if type(v) == "function" then
						-- if it's a function show where we defined it
						local info = debug.getinfo(v,"LnS")
						res[#res+1]=string.format("      %s = function - %s", i, info.source..":"..tostring(info.linedefined))
					else
						if v and type(v)=="table" and v.IsValid and type (v.IsValid) == "function" then
							res[#res+1] = string.format("      %s = %s (valid:%s)", i, SaveToString(v),tostring(v:IsValid()))
						else
							res[#res+1] = string.format("      %s = %s", i, SaveToString(v))
						end
					end
				end
			else
				if type(value) == "function" then
					local info = debug.getinfo(value,"LnS")
					res[#res+1]=string.format("   %s = function - %s", name, info.source..":"..tostring(info.linedefined))
				else
					if value and type(value) == "table" and value.IsValid and type(value.IsValid) == "function" then
					   res[#res+1] = string.format("   %s = %s (valid:%s)", name, SaveToString(value),tostring(value:IsValid()))
					else
					   res[#res+1] = string.format("   %s = %s", name, SaveToString(value))
					end
				end
			end
		end
        index = index + 1
    end
    local res = table.concat(t, "\n")
	return res
end

function getdebugstack(res, start, top, bottom)
	-- disable strict. We may hit G
	setmetatable(_G,{})

    if not bottom then bottom = 10 end
    if not top then top = 12 end
    start = (start or 1) + 1

    local count = max(2, start)
    while getinfo(count) do
        count = count + 1
    end

    count = count - start

    if top + bottom >= count then
       top = count
       bottom = nil
    end
	local results = {}
    local s = {"stack traceback:"}
    for i = 1, top, 1 do
		local info = getinfo(start + i - 1)
		local s = getformatinfo(info)
		res[#res+1] = s
		getdebuglocals(res, start + i - 1)
    end
	return res
end

function DoStackTrace(err)
	local res = {}
	if err then
	    for idx,line in ipairs(string.split(err, "\n")) do
			res[#res+1] = "#"..line
	    end
		res[#res+1] = "#LUA ERROR stack traceback:"
	end
	res = getdebugstack(res,5)
	local retval = concat(res, "\n")
	return retval
end

function StackTrace(err)
	-- in case the assert handler asserts
	local inCaseOfPanic = tostring(err).."\nLUA ERROR "..debugstack()
	local status,retval = xpcall(function() return DoStackTrace(err) end, function() return inCaseOfPanic end)
    return retval
end

function StackTraceToLog()
	local s = StackTrace()
	print(s)
end

_TRACEBACK = StackTrace
