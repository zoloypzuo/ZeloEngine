local getinfo = debug.getinfo
local max = math.max
local concat = table.concat

function DumpComponent( comp )
	for name,value in pairs(comp) do
		if type(value) == "function" then
			local info = debug.getinfo(value,"LnS")
			print(string.format("      %s = function - %s", name, info.source..":"..tostring(info.linedefined)))
		else
			if value and type(value) == "table" and value.IsValid and type(value.IsValid) == "function" then
			   print(string.format("      %s = %s (valid:%s)", name, tostring(value),tostring(value:IsValid())))
			else
		   		print(string.format("      %s = %s", name, tostring(value)))
			end
		end
	end
end

function DumpEntity(ent)
	print("============================================ Dumping entity ",ent,"============================================")
	print(ent.entity:GetDebugString())
	print("--------------------------------------------------------------------------------------------------------------------")
	for name,value in pairs(ent) do
		if type(value) == "function" then
			local info = debug.getinfo(value,"LnS")
			print(string.format("   %s = function - %s", name, info.source..":"..tostring(info.linedefined)))
		else
			if value and type(value) == "table" and value.IsValid and type(value.IsValid) == "function" then
			   print(string.format("   %s = %s (valid:%s)", name, tostring(value),tostring(value:IsValid())))
			else
			   print(string.format("   %s = %s", name, tostring(value)))
			end
		end
	end
	print("--------------------------------------------------------------------------------------------------------------------")
	for i,v in pairs(ent.components) do
		print("   Dumping component",i)
		DumpComponent(v)
	end
	print("====================================================================================================================================")
end

function DumpUpvalues(func)
	print("============================================ Dumping Upvalues ============================================")
	local info = debug.getinfo(func, "nuS")
	print(string.format("Upvalues (%d of 'em) for function %s defined at %s:%s", info.nups, tostring(info.name), tostring(info.source), tostring(info.linedefined)))
    for i = 1,math.huge do
        local name, v = debug.getupvalue(func,i)
        if name == nil then break end
        print(string.format("%d:\t %s (%s) \t= %s", i,name,type(v),tostring(v)))
    end
	print("--------------------------------------------------------------------------------------------------------------------")
end