-- wordcount.lua

-- 目标：读取一段文本，输出其中出现频率最高的单词

local counter = {}

-- open file and read lines
for line in io.lines("alice_in_wonderland.txt") do
    -- for each word in the line, increment its counter
    for word in string.gmatch(line, "%w+") do
        counter[word] = (counter[word] or 0) + 1
    end
end

local words = {}

-- NOTE 这里lua和python是不一样的，虽然pairs返回kv对，但是w对应k，而不是kv对
for w in pairs(counter) do
    words[#words + 1] = w
end

table.sort(
    words,
    function(w1, w2)
        local item1 = assert(counter[w1])
        local item2 = assert(counter[w2])
        return item1 > item2 or item1 == item2 and w1 < w2
    end
)

-- NOTE tonumber(nil) returns nil
local n = math.min(tonumber(arg[1]) or math.huge, #words)

for i = 1, n do
    io.write(words[i], counter[words[i]], "\n")
end
