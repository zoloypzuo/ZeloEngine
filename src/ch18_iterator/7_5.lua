--

function allwords(f)
    for line in io.lines() do 
	for word in string.gmatch(line "%w+") do
	    f(word)
	end
    end
end

allwords(print)
