a = array.new(1000)
print(a)
print(a:size())
for i=1,1000 do
    a:set(i, i%5==0)
end
print(a:get(10))
print(a:get(11))

