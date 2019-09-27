-- string.gmatch.lua

for word in string.gmatch("some thing", "%a+") do  --> "some"; "thing"
    print(word)
end