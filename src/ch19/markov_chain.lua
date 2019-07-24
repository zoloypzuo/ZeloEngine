-- markov_chain.lua

-- 目标：输入基础文本，生成伪随机文本
-- 哪个单词能出现在基础文本中由n个前缀单词序列之后，这里n为2
-- 首先构造一个(prefix2, prefix1) => word的字典，并记录这个概率p(word)
-- 比如"nice to meet you"，可以生成(nice, to) => meet和(to, meet) => you
-- 然后生成随机文本，使得随机文本中p'(word)和p(word)相等

-- 迭代器函数，每次迭代返回最后两个单词
function allwords()
    local fh = assert(io.open("alice_in_wonderland.txt", "r"))
    local line = fh:read()
    local pos = 1
    return function()
        while line do
            local w, e = string.match(line, "(%w+[,;.:]?)()", pos)
            if w then
                pos = e
                return w
            else
                line = fh:read()
                pos = 1
            end
        end
        return nil
    end
end

-- prefix2和prefix1拼接构造key
function prefix(w1, w2)
    return w1 .. " " .. w2
end

local statetab = {}

function insert(prefix, value)
    local list = statetab[prefix]
    if list == nil then
        statetab[prefix] = {value}
    else
        statetab[#list + 1] = value
    end
end

-- 表

local MAX_GEN = 200
-- no word用于占位，基础文本的开头加两个，结尾加一个
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
    local nextword = list[r]
    if nextword == NO_WORD then
        return
    end
    print(nextword, " ")
    w1 = w2
    w2 = nextword
end
