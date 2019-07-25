--

local iterator

function allwords()
    local state = {line = io.read(), pos = 1}
    return iterator, state
end

function iterator(state)
    while state.line do
		local s, e = string.find(state.line, "%w+", state.pos)
	    if s then
			state.pos = e + 1
			return string.sub(state.line, s, e)
	    else
			state.line = io.read()
			state.pos = 1
	    end
	end
	return nil
end

f = io.open("9_2_1.lua", "r")
io.input(f)
for word in allwords() do
    print(word)
end
