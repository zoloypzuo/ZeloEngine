a = {2, 3, 5, 7}

function func(a)
	local b = a*a
	return b
end


function testout()
	for i=1, #a do
		print(a[i])
	end
	mymap(a, func)
	for i=1, #a do
		print(a[i])
	end
end

