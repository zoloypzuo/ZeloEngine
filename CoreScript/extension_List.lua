-- extension_List.lua
-- created on 2019/10/18
-- author @zoloypzuo

--> List{List{1},List{2}}:join_list()
--{1,2}
-->
-- 名字蛮难起的，join，concat都被他用来拼接字符串了。。
function List:join_list()
    return self:reduce(function(a, b)
        return a .. b
    end)
end