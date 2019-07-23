-- eight-queen puzzle

-- 目标：每个皇后不能互相攻击

-- 数组a表示每一行的皇后所在的列

-- 棋盘大小
N = 8

-- 检查(n, c)是否不会被攻击
function is_place_ok(a, n, c)
    for i = 1, N do
        if a[i] == c or a[i] - i == c - n or a[i] + i == c + n then
            return false
        end
    end
    return true
end

function print_solution(a)
    for i = 1, N do
        for j = 1, N do
            io.write(a[i] == j and "X" or "-", " ")
        end
        io.write("\n")
    end
    io.write("\n")
end

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

add_queen({},1)