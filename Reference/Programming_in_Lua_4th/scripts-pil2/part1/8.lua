-- require 编译并执行1次
f1 = require "part1.8_1"
f2 = require "part1.8_1"
print("use require")
if type(f1)=="function" then
	f1()
	f2()
end
print("")

-- dofile每次都编译执行
f1 = dofile("part1/8_1.lua")
f2 = dofile("part1/8_1.lua")
print("use dofile")
if type(f1)=="function" then
	f1()
	f2()
end
print("")

-- loadfile只编译，不执行
f1 = loadfile("part1/8_1.lua")
f2 = loadfile("part1/8_1.lua")
print("use loadfile")
if type(f1)=="function" then
	f1()
	f2()
end
