-- pprint.lua
-- created on 2019/10/18
-- author @zoloypzuo
--
-- pretty pprint


local function print_table(t)
    assert(type(t) == "table")
    for k, v in pairs(t) do
        if type(v) == "table" then
            print_table(v)
        else
            print(v)
        end
    end
end

function pprint(...)
    for _, o in pairs({ ... }) do
        if type(o) == "table" then
            print_table(o)
        else
            print(o)
        end
    end
end