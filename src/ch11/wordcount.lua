-- wordcount.lua

-- 目标：读取一段文本，输出其中出现频率最高的单词

local counter = {}

for line in io.lines("alice_in_wonderland.txt") do
    for word in string.gmatch(line, "%w+") do
        counter[word] = (counter[word] or 0) + 1
    end
end

local words = {}

for w in pairs(counter) do
    words[#words + 1] = w
end

table.sort(
    words,
    function(w1, w2)
        return counter[w1] > counter[w2] or counter[w1] == counter[w2] and w1 < w2
    end
)

local n = math.min(tonumber(arg[1]) or math.huge,#words)

for i =1,n do
    io.write(words[i],counter[words[i]],"\n")
end