function d_allsavenames(suffix)
	suffix = suffix or ""
	local filenames = {
		"saveindex"..suffix,
		"profile"..suffix,
		"modindex"..suffix,
	}
	for i,type in ipairs({"porkland", "survival", "shipwrecked", "adventure", "cave", "volcano"}) do
		if type == "cave" then
			for num=1,10 do
				for level=1,2 do
					for slot=1,5 do
						table.insert(filenames, string.format("%s_%d_%d_%d%s", type, num, level, slot, suffix))
					end
				end
			end
		else
			for slot=1,5 do
				table.insert(filenames, string.format("%s_%d%s", type, slot, suffix))
			end
		end
	end
	return filenames
end

function d_convertreleasetodev(foldername)
	foldername = foldername or "restore"
	local toerase = {}
	for i,file in ipairs(d_allsavenames("")) do
		if file == "saveindex" then
			d_decodedata(foldername.."/"..file, false, "_dev", function(savedata)
				print("Fixing Saveindex!!")
				for i,slot in ipairs(savedata.slots) do
					for mode, modedata in pairs(slot.modes) do
						modedata.file = modedata.file and modedata.file.."_dev"
						for i,modefile in ipairs(modedata.files or {}) do
							modedata.files[i] = modefile.."_dev"
						end
					end
					if slot.resurrectors then
						local newresurrectors = {}
						for id,cost in pairs(slot.resurrectors) do
							local name,rest = string.match(id, "([a-zA-Z0-9_]+)(:%d+)")
							newresurrectors[name.."_dev"..rest] = cost
						end
						slot.resurrectors = newresurrectors
					end
				end
			end)
		else
			d_decodedata(foldername.."/"..file, true, "_dev")
		end
		table.insert(toerase, foldername.."/"..file)
	end
	EraseFiles(function() print("Erased old files!") end, toerase)
end

function d_encodedata(path)
	print("ENCODING",path)
	TheSim:GetPersistentString(path, function(load_success, str)
		if load_success then
			print("LOADED...")
			local success, savedata = RunInSandbox(str)
			local str = DataDumper(savedata, nil, true)
			TheSim:SetPersistentString(path.."_encoded", str, true, function()
				print("SAVED!")
			end)
		else
			print("ERROR LOADING FILE! (wrong path?)")
		end
	end)
end

function d_decodedata(path, skipread, suffix, datacb)
	print("DECODING",path)
	suffix = suffix or "_decoded"
	TheSim:GetPersistentString(path, function(load_success, str)
		if load_success then
			print("LOADED...")
			if not skipread then
				local success, savedata = RunInSandbox(str)
				if datacb ~= nil then
					datacb(savedata)
				end
				str = DataDumper(savedata, nil, false)
			end
			TheSim:SetPersistentString(path..suffix, str, false, function()
				print("SAVED!")
			end)
		else
			print("ERROR LOADING FILE! (wrong path?)")
		end
	end)
end

function d_decodealldata(suffix, prefix)
	print("*******************************")
	print("ABOUT TO DECODE")
	prefix = prefix or ""
	for i,file in ipairs(d_allsavenames(suffix)) do
		d_decodedata(prefix..file, true)
	end
	print("Done decoding")
	print("*******************************")
end

local frdata = {
	lastidx = 0,
	spacing = 40,
	task = nil,
	holdtime = 2,
	datapoints = {},
	first = true,
}

local function LoadSurveyData()
	local datapoints = {}
	local name = SaveGameIndex:GetSaveGameName(SaveGameIndex:GetCurrentMode(), SaveGameIndex:GetCurrentSaveSlot()).."_hotspots"
	TheSim:GetPersistentString(name, function(success, str)
		if success then
			local success, data = RunInSandbox(str)
			if success then
				print("Loaded hotspot data from "..name)
				datapoints = data
			end
		end
	end)
	return datapoints
end

function d_framerate_survey(resume, fast)
	if resume then
		frdata.datapoints = LoadSurveyData()
		frdata.lastidx = #frdata.datapoints
	end
	print(string.format("Starting survey"))
	frdata.task = GetPlayer():DoPeriodicTask(frdata.holdtime * (fast and 0.1 or 1), function(inst)
		if not frdata.first then
			local pos = inst:GetPosition()
			local fps, smooth = TheSim:GetFPS()
			local datapoint = {x=pos.x, y=pos.z, fps=fps*1000, smooth=smooth, phase=GetClock():GetPhase(), ents=GetLastPerfEntLists()}
			table.insert(frdata.datapoints, datapoint)
			print(string.format("Gathering: x=%.2f, y=%.2f, fps=%.2f, smooth=%.2f, phase=%s. (%d/%d)", datapoint.x, datapoint.y, datapoint.fps, datapoint.smooth, datapoint.phase, #frdata.datapoints, #GetWorld().topology.nodes))

			local name = SaveGameIndex:GetSaveGameName(SaveGameIndex:GetCurrentMode(), SaveGameIndex:GetCurrentSaveSlot()).."_hotspots"
			TheSim:SetPersistentString(name, DataDumper(frdata.datapoints, nil, false), false, function() print("Wrote hotspots to "..name) end)
		else
			frdata.first = false
		end

		frdata.lastidx = frdata.lastidx + 1
		local nextnode = GetWorld().topology.nodes[frdata.lastidx]
		if not nextnode then
			print("*****************************")
			print("Survey complete. Samples: ", #frdata.datapoints)
			print("*****************************")
			frdata.task:Cancel()
			frdata.task = nil
			return
		else
			c_teleport(nextnode.cent[1], 0, nextnode.cent[2])
			TheCamera:Snap()
			c_sethunger(1)
			c_setsanity(1)
			c_sethealth(1)
			c_setboathealth(1)
		end

	end)
end

local nexthotspotidx = 1
function d_framerate_hotspot(idx)
	local datapoints = LoadSurveyData()
	idx = idx or nexthotspotidx
	table.sort(datapoints, function(a,b) return b.smooth < a.smooth end)
	local datapoint = datapoints[idx]
	if datapoint ~= nil then
		print(string.format("Warping: x=%.2f, y=%.2f, fps=%.2f, smooth=%.2f, phase=%s", datapoint.x, datapoint.y, datapoint.fps, datapoint.smooth, datapoint.phase))
		print("Ents:")
		dumptable(datapoint.ents)
		print("Cmps:")
		dumptable(datapoint.cmps)
		print("EntCmps:")
		dumptable(datapoint.entcmps)
		c_teleport(datapoint.x, 0, datapoint.y)
	end
	nexthotspotidx = idx + 1
end
