-- 4_1_url_encode.lua

-- policy
-- * special char -> "%xx"
-- * " " -> "+"
-- * "(name=value&)*name=value"

function unescape(s)
    s = string.gsub(s, "+", " ")
    s = string.gsub(s, "%%(%x%x)", function(h)
        -- 将十六进制字符转为数字，再转为字符
        return string.char(tonumber(h, 16))
    end)
    return s
end

assert(unescape("a%2Bb+%3D+c") == "a+b = c")

cgi = {}
function decode(s)
    for name, value in string.gmatch(s, "([^&=]+)=([^&=]+)") do
        name = unescape(name)
        value = unescape(value)
        cgi[name] = value
    end
end

function escape(s)
    s = string.gsub(s, "[&=+%%%c]", function(c)
        --print(c:byte())
        return string.format("%%%02X", string.byte(c))
    end)
    s = string.gsub(s, " ", "+")
    return s
end

function encode(t)
    local b = {}
    for k, v in pairs(t) do
        print(k, v)
        k = escape(k)
        v = escape(v)
        b[#b + 1] = (k .. "=" .. v)
    end
    return table.concat(b, "&")
end

args = { name = "al"; query = "a+b = c"; q = "yes or no" }

url = "name=al&query=a%2Bb+%3D+c&q=yes+or+no"
-- this will fail because table is iterated in a random order
--assert(encode(args) == t)
