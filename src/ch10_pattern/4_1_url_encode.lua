-- 4_1_url_encode.lua

-- policy
-- * special char -> "%xx"
-- * " " -> "+"
-- * "(name=value&)*name=value"

url_args = { name = "al"; query = "a+b = c"; q = "yes or no" }

escaped_s = "name=al&query=a%2Bb+%3D+c&q=yes+or+no"
--assert(url_encode(url_args) == escaped_s)

function unescape(s)
    s = string.gsub(s, "+", " ")
    s = string.gsub(s, "%%(%x%x)", function(h)
        return string.char(tonumber(h, 16))
    end)
    return s
end

print(unescape(escaped_s))