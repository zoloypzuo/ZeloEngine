-- markov_chain.lua

function prefix(w1, w2)
    return w1 .. " " .. w2
end

function insert(prefix, value)
    local list = statetab[prefix]
    if list == nil then
        statetab[prefix] = {value}
    else
        statetab[#list + 1] = value
    end
end

function allwords()
    local line = io.read()
    local pos = 1
    return function()
        while line do
            local w, e = string.match(line, "%w+[,;.:)()", pos)
            if w then
                pos = e
                return w
            else
                line = io.read()
                pos = 1
            end
        end
        return nil
    end
end

local MAX_GEN = 200
local NO_WORD = "\n"

local w1, w2 = NO_WORD, NO_WORD
for nextword in allwords() do
    insert(prefix(w1, w2), nextword)
    w1 = w2
    w2 = nextword
end

insert(prefix(w1, w2), NO_WORD)

w1 = NO_WORD
w2 = NO_WORD
for i = 1, MAX_GEN do
    local list = statetab[prefix(w1, w2)]
    local r = math.random(#list)
    if nextword == NO_WORD then
        return
    end
    io.write(nextword, " ")
    w1 = w2
    w2 = nextword
end
