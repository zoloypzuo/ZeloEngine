-- Create a weaktable before starting this and destroy it when done?
-- Then we don't have a weak table hanging around

-- not gonna work, we changed loadfile
--function TryLoad(name)
--	print("TryReload",name)
--	local f, err= loadfile(name..".lua")
--	if not f then
--		print(err)	
--		return false
--	end
--	return true
--end


local function cloneTable(t)
  local rtn = {}
  for k, v in pairs(t) do rtn[k] = v end
  return rtn
end

InvalidatedTables = {}

-- based on lume (https://github.com/rxi/lume) with some slight modifications for our class system
-- (remapping base class functions as we have inheritance through prototypes)
-- TODO: doesn't support adding a function to a baseclass and using it from the derived through reloading
function hotswap(modname)
  local oldglobal = cloneTable(_G)
  local updated = {}

  local function update(old, new)
    if updated[old] then return end 
    updated[old] = true
    local oldmt, newmt = getmetatable(old), getmetatable(new)
    if oldmt and newmt then 
	if oldmt ~= newmt then
		InvalidatedTables[new] = true
		update(oldmt, newmt) 
	end
    end	
    -- remove functions that were undefined in the new version
    for k, v in pairs(old) do
	if type(v)=='function' then
	   if new and new[k]==nil then
		old[k] = nil	
	   end
        end
    end
    -- remap the table, store the changed functions so we can monkeypatch derived classes
    if new then
         for k, v in pairs(new) do
            if type(v) == "table" then 
                update(old[k], v) 
            else 
                old[k] = v    -- copy the function over from new to old. So old is now useless
            end
        end
    end

  end   -- function update
  local err = nil
  local function onerror(e)
    for k, v in pairs(_G) do _G[k] = oldglobal[k] end
    err = e
  end
  


  local ok, oldmod = pcall(require, modname)
  oldmod = ok and oldmod or nil

  xpcall(function()
    package.loaded[modname] = nil
    local newmod = require(modname)
    if type(oldmod) == "table" then update(oldmod, newmod) end
    for k, v in pairs(oldglobal) do
      if v ~= _G[k] and type(v) == "table" then 
        update(v, _G[k])
        _G[k] = v
      end
    end
  end, onerror)
  package.loaded[modname] = oldmod
   if err then  
     print("hotswap : error",err)
     return nil, err 
   end
   print("success")

  return oldmod
end

-- Clean up this class to only have its own members, nothing derived
function ScrubClass(cls, inh)
--	print("ScrubClass",cls, inh)
	for i,v in pairs(cls) do
	   if inh[i]==v then
		-- this was inherited from our baseclass
                cls[i] = nil
	   end
	end

end

function MonkeyPatchClass(mt)
	-- patch this class. basically gather all function in the class and its baseclasses
	-- and get them in here
        -- (this can be optimized for sure if needed. If none of the classes in the chain are dirty we can move on for example)
	local curmt = mt
	local classchain = {}
	while curmt do
		classchain[#classchain+1] = curmt
		curmt = curmt._base
	end
	-- from baseclass to most derived
	local newmt = {}
	for i=#classchain,1,-1 do
		local curmt = classchain[i]
		for i,v in pairs(curmt) do
			newmt[i] = v
		end
	end
	for i,v in pairs(mt) do
		mt[i] = nil
	end
	for i,j in pairs(newmt) do
		mt[i] = j
	end
end

-- okay, we have all old and all new metatables

function MonkeyPatchClasses()
	-- first scrub the classes, get rid of all functions that were copied for inheritance
        -- oh crap, if it was changed in the baseclass it won't be scrubbed.
	-- keep a pointer to the original function it replaces?
	for i,v in pairs(ClassRegistry) do
		ScrubClass(i,v)	
	end
	-- Reconstruct the class table bottom up. If a derived class has an already existing entry and it's different then it must be the most recent one
	for i,v in pairs(ClassRegistry) do
		MonkeyPatchClass(i)	
	end

end

function DoReload()
	print("before hotswap")
	if IsConsole() then
		TheSim:PurgeLuaFileCache()
	end

	local index = 1
	print("before check:")
	local modifiedFiles = {}
	for i,v in pairs(RequiredFilesForReload) do
		local time = TheSim:GetFileModificationTime(i)
		if time ~= v then
			print("Modified file:",i)
			modifiedFiles[#modifiedFiles+1] = i
		end
		--print(index, i,v,time)
		index = index + 1
	end
	
	local backup_package_path = package.path

	local files = modifiedFiles
	for i=1,#files do 
		local filename = files[i] --line --"screens/mainscreen"
		print("HotSwapping : ",filename)
		-- in order to qualify it must either contain /scripts/ or start with scripts/
		local s1,e1 = string.find(filename,"scripts/",1,true)
		local s2,e2 = string.find(filename,"/scripts/",1,true)
		if s1 == 1 or s2 then		
			if s1==1 then
				filename = filename:sub(e1+1)
			elseif s2 then
				filename = filename:sub(e2+1)
			end
			-- strip the .lua
			filename = filename:sub(1,#filename-4)
			print("hotswapping ".."["..filename.."]")
			local result = hotswap(filename)
			result = nil
			collectgarbage()
			for i,v in pairs(InvalidatedTables) do
				ClassRegistry[i]=nil
			end
			InvalidatedTables = {}
		end
	end
	MonkeyPatchClasses()
	package.path = backup_package_path
	print("after hotswap")
end

local LastProbeReload = false

function ProbeReload( ispressed )
	if ispressed and ispressed ~= LastProbeReload then
		print("Reload")
		DoReload()
	end
	LastProbeReload = ispressed
end

