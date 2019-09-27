-- eight-queen puzzle

-- 目标：每个皇后不能互相攻击

-- 数组a表示每一行的皇后所在的列

-- 棋盘大小
N = 8

-- 检查(n, c)是否不会被攻击
-- 如果在指定位置放置皇后，是否会遭到攻击
-- 第n个皇后（n行），放在c列，是否会和a中n-1个皇后冲突
-- 因为行不会冲突，因此检查列和对角线即可
function is_place_ok(a, n, c)
    for i = 1, N do
        local item = assert(a[i])
        if item == c or item - i == c - n or item + i == c + n then
            return false
        end
    end
    return true
end

-- 打印棋盘
function print_solution(a)
    for i = 1, N do
        for j = 1, N do
            io.write(a[i] == j and "X" or "-", " ")
        end
        io.write("\n")
    end
    io.write("\n===================================\n")
end

-- 核心，现在已经有n-1个皇后且无冲突，正确地放置了，需要尝试放置第n~N个皇后
-- 回溯法搜索
function add_queen(a, n)
    if n > N then
        print_solution(a)
    else
        for c = 1, N do
            if is_place_ok(a, n, c) then
                a[n] = c
                add_queen(a, n + 1)
            end
        end
    end
end

add_queen({}, 1)
