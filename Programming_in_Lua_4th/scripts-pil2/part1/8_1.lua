print("call 8_1")
function f81()
	print("call f81")
end

-- 是否将下面的return语句注释掉并调用8.lua便可以看出
-- require dofile loadfile的区别
-- 如果包含return语句，执行结果是
--[[
call 8_1
use require
call f81
call f81

call 8_1
call 8_1
use dofile
call f81
call f81

use loadfile
call 8_1
call 8_1

否则，输出为
call 8_1
use require

call 8_1
call 8_1
use dofile

use loadfile
call 8_1
call 8_1
--]]
--return f81
