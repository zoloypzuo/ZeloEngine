--第6章，这一章的内容要完全理解可能需要做很多实际的东西，看很多遍

-- 测试local与global
local print = print
_G["print"] = math.pi
print("helo world")
print(_G["print"])

-- 高阶函数
-- 不知道derivative和derivative1哪个效率更高
function derivative(f, delta)
    delta = delta or 1e-4
    return function(x)
        return (f(x + delta) - f(x)) / delta
    end
end

function derivative1(f, x, delta)
    delta = delta or 1e-4
    return (f(x + delta) - f(x)) / delta
end

c1 = derivative(math.sin)
c2 = derivative1(math.sin, 10)
print(c1(10))
print(c2)

-- 6.2

--local fact = function(n)
--上面这种写法是错的，这是一个直接递归函数
--报错如下
--.../GitHub/Lua/PrgInLua2/scripts/part1/6.lua:33: attempt to call global 'fact' (a nil value)
--原因是fact尝试指向全局变量
local function fact(n)
    if n == 0 then
        return 1
    else
        return n * fact(n - 1)
    end
end

print(fact(3))






