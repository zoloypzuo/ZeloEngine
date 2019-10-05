function EraseFiles(cb, files)
	
	if not next(files) then
		if cb then
			cb(true, {})
		end
	end
	
	local res = {
	}
	
	for i,v in pairs(files) do
		res[v] = true
	end
	
	local overall_success = true
	local deleted_files = {}
	
	local function onerased(success, file)
		res[file] = nil
		if success then
			table.insert(deleted_files, file)
		else
			overall_success = false
		end
		
		if not next(res) then
			if cb then
				cb(overall_success, deleted_files)
			end
		end
	end
	
	for i,v in pairs(files) do
		print ("Erasing", v)
		if PLATFORM == "PS4" then
		    -- skip the file exists check on console
		    ErasePersistentString(v, function(success) onerased(success, v) end)
		else
		    TheSim:CheckPersistentStringExists(v, function (exists)
				    if exists == true then
					    ErasePersistentString(v, function(success) onerased(success, v) end)
				    else
					    onerased(true, v)
				    end
			    end)
		end
	end
end



function CheckFiles(cb, files)
	
	if not next(files) then
		if cb then
			cb{}
		end
	end
	
	local res = {
	}
	
	for i,v in pairs(files) do
		res[v] = true
	end
	
	local file_status = {}
	local function onchecked(success, file)
		res[file] = nil
		file_status[file] = success
		
		if not next(res) then
			if cb then
				cb(file_status)
			end
		end
	end
	
	for i,v in pairs(files) do
		TheSim:CheckPersistentStringExists(v, function(exists) onchecked(exists, v) end)
	end
end