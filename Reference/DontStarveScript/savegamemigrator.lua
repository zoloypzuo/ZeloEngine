local PopupDialogScreen = require "screens/popupdialog"

SaveGameMigrator = Class(function(self)
end)

-- names that start with "latest_" shouldn't be taken into consideration, Init() does that for some reason
local function isValidSlotFile(name)
	local start = name:sub(1,7)
	return start ~= "latest_"
end

function SaveGameMigrator:MigrateFrom(frombranch)
	if frombranch == SaveGameIndex:GetSaveIndexName() then
		print("Error: Can't migrate from myself to myself!")
		return
	end

	self.frombranch = frombranch

	print("Attempting to migrate from",frombranch)
	local ent = CreateEntity()
	ent:DoTaskInTime(0, function()
							TheFrontEnd:HideConsoleLog()
							TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.MIGRATION_TOOL, string.format(STRINGS.UI.MAINSCREEN.MIGRATION_DIALOG_INFO, frombranch), 
							{
                               {text=STRINGS.UI.MAINSCREEN.YES, cb = function() 
																		TheFrontEnd:PopScreen() 	
																		self:DoMigrate() 	
																	end},
							   {text=STRINGS.UI.MAINSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  }
                            ))
							ent:Remove()
						end)
end

function SaveGameMigrator:DoMigrate()
	print("Do Migrate")
	local migrateSlots = self:GetSlotsToMigrate()
	local availableSlots = self:GetAvailableSlots()
	local slotsNeeded = #migrateSlots
	local slotsAvailable = #availableSlots
	print(string.format("   Slots needed: %d",slotsNeeded))
	print(string.format("   Available slots: %d",slotsAvailable))
	if slotsAvailable < slotsNeeded then
		print("   Not enough slots available, aborting")
		local slotsNeededString = string.format(STRINGS.UI.MAINSCREEN.MIGRATION_FAIL,slotsNeeded)
		TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.WARNING, slotsNeededString, {{text=STRINGS.UI.MAINSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end}}))
		return
	else
		print("   Got enough slots, start migrate!")
		assert(#availableSlots >= #migrateSlots)
		for i=1,#migrateSlots do
			print("-----------------------------------")
			print(string.format("Migrate slot %s to slot %s",migrateSlots[i], availableSlots[i]))
			self:MigrateSlot(migrateSlots[i], availableSlots[i])
		end
		print("Migration done")
		TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.MIGRATION_SUCCESSFUL_HEADER, STRINGS.UI.MAINSCREEN.MIGRATION_SUCCESSFUL, {{text=STRINGS.UI.MAINSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end}}))		
	end
end

function SaveGameMigrator:GetMigrateSaveIndexName()
	local name = "saveindex" 
	if self.frombranch ~= "release" then
		name = name .. "_"..self.frombranch
	end
	return name
end

function SaveGameMigrator:GetSlotsToMigrate()
	local name = self:GetMigrateSaveIndexName()

	local postfix = "";
	-- load the saveindex for this backup
	local saveIndexBackupName = name
	print(string.format("Check for saveindex slots from %s", saveIndexBackupName))
	local totalSlots = {}
        TheSim:GetPersistentString(saveIndexBackupName, function(load_success, str)
							     	if load_success then
									local success, savedata = RunInSandbox(str)
									-- If we are on steam cloud this will stop a currupt saveindex file from 
									-- ruining everyones day.. 
									if success and string.len(str) > 0 and savedata ~= nil then
										local data = savedata
										print(string.format("SaveIndex %s loaded, counting active slots", saveIndexBackupName))
										-- check the slots
										if data.slots then
											for index, slot in pairs(data.slots) do										
												print(string.format("   Checking slot %s",tostring(index)))
												local hasFiles = false
												for j,k in pairs(slot.modes) do
													if k.files then
														for n,m in pairs(k.files) do
															local name = m
															if isValidSlotFile(name) then
																print(string.format("      Found file %s",name))
																hasFiles = true
															end
														end
													end
													if k.file then
														local name = k.file
														if isValidSlotFile(name) then
															print(string.format("      Found file %s",name))														
															hasFiles = true
														end
													end
												end
												if hasFiles then
													print("      Slot has files")
													totalSlots[#totalSlots + 1] = index
												else
													print("      Slot has no files")
												end
											end
					
										end
									
									else
										print ("Data corrupt for "..saveIndexBackupName)
									end
								else
									print(string.format("Failed to load %s, not restoring", saveIndexBackupName))
							        end
							end)
	return totalSlots
end

function SaveGameMigrator:GetAvailableSlots()
	local name = SaveGameIndex:GetSaveIndexName()
	-- load the saveindex for this backup
	print(string.format("Check for available saveindex slots from %s", name))
	local totalSlots = {}

	local data = SaveGameIndex.data
	-- check the slots
	if data.slots then
		for index, slot in pairs(data.slots) do										
			print(string.format("   Checking slot %s",tostring(index)))
			local hasFiles = false
			for j,k in pairs(slot.modes) do
				if k.files then
					for n,m in pairs(k.files) do
						local name = m
						if isValidSlotFile(name) then
							print(string.format("      Found file %s",name))
							hasFiles = true
						end
					end
				end
				if k.file then
					local name = k.file
					if isValidSlotFile(name) then
						hasFiles = true
						print(string.format("      Found file %s",name))														
					end
				end
			end
			if hasFiles then
				print("      Slot has files")
			else
				print("      Slot has no files")
				totalSlots[#totalSlots + 1] = index
			end
		end
					
	end
	return totalSlots
end

function SaveGameMigrator:GetSaveGameNameReplacement(name, fromslot, toslot)
	local tail = "_"..fromslot
	if self.frombranch ~= "release" then
		tail = tail.."_"..self.frombranch
	end

	local name_tail = name:sub(#name - #tail + 1)
	assert(name_tail == tail)
	local name_head = name:sub(1,#name - #tail)

	local savename = name_head.."_"..toslot
	
	if BRANCH ~= "release" then
		savename = savename .. "_" .. BRANCH
	end
	return savename
end

function SaveGameMigrator:GetResurrectorNameReplacement(name, fromslot, toslot)
	local columnpos = string.find(name, ":", 1, true)
	assert(columnpos)
	local origtail = name:sub(columnpos)
	name = name:sub(1,columnpos-1)

	local tail = "_"..fromslot
	if self.frombranch ~= "release" then
		tail = tail.."_"..self.frombranch
	end

	local name_tail = name:sub(#name - #tail + 1)
	assert(name_tail == tail)
	local name_head = name:sub(1,#name - #tail)

	local resurrectorname = name_head.."_"..toslot
	
	if BRANCH ~= "release" then
		resurrectorname = resurrectorname .. "_" .. BRANCH
	end
	resurrectorname = resurrectorname..origtail
	return resurrectorname
end

function SaveGameMigrator:MigrateResurrectors(slot, fromslot, toslot)
	print(string.format("Migrate resurrectors from slot %d to slot %d",fromslot,toslot))
	-- rename the resurrectors to match the new slot
	local newResurrectors = {}
	for name,value in pairs(slot.resurrectors) do
		local newname = self:GetResurrectorNameReplacement(name, fromslot, toslot)
		newResurrectors[newname] = value		
	end
	-- and apply
	slot.resurrectors = newResurrectors
end

function SaveGameMigrator:MigrateSlot(fromslot, toslot)
	if not fromslot or not toslot then
		print("Error, you need to pass in fromslot and toslot")
		return
	end
	local name = self:GetMigrateSaveIndexName()
	local postfix = "";
	-- load the saveindex for this backup
	local saveIndexBackupName = name
	print(string.format("Migrate slot %s from %s to slot %d", tostring(fromslot), self.frombranch, tostring(toslot)))

        TheSim:GetPersistentString(saveIndexBackupName, function(load_success, str)
							     	if load_success then
									print(string.format("SaveIndex %s loaded, migrate slot %s", saveIndexBackupName, tostring(fromslot)))
									local success, savedata = RunInSandbox(str)
									-- If we are on steam cloud this will stop a currupt saveindex file from 
									-- ruining everyones day.. 
									if success and string.len(str) > 0 and savedata ~= nil then
										local data = savedata
										print("   loaded "..saveIndexBackupName)
										-- delete the files that are currently in this slot
										print("   Removing current files")
										if SaveGameIndex.data.slots[toslot] then
											local slot = SaveGameIndex.data.slots[toslot]
											-- copy the world files
											if slot.modes then
												for j,k in pairs(slot.modes) do
													if k.files then
														for n,m in pairs(k.files) do
															print(string.format("      Removing %s",m))
															self:DeleteSingleFile(m)
														end
													elseif k.file then
														print(string.format("      Removing %s",k.file))
														self:DeleteSingleFile(k.file)
													end
												end
											end
										end
										print("   Migrating files")
										if data.slots[fromslot] then
											local slot = data.slots[fromslot]
											local filesToRemove = {}
											for j,k in pairs(slot.modes) do
												if k.files then
													local newfiles = {}
													for n,m in pairs(k.files) do
														local name = m
														print(string.format("      Copying %s",name))
														local newname = self:GetSaveGameNameReplacement(name, fromslot, toslot)
														print(string.format("            to %s",newname))
														-- for renaming in the slot data
														table.insert(newfiles,newname)
														filesToRemove[name] = newname
													end
													-- and assign
													k.files = newfiles
												end
												if k.file then
													local name = k.file
													print(string.format("      Copying (2) %s",tostring(name)))
													local newname = self:GetSaveGameNameReplacement(name, fromslot, toslot)
													print(string.format("            to %s",newname))
													-- and rename in the slot data
													k.file = newname
													filesToRemove[name] = newname
												end
											end
											for i,j in pairs(filesToRemove) do
												print(string.format("Migrate %s to %s",i, j))
												self:MigrateSingleFile(i,j)
											end

										end
										-- Now copy in the slot, leave the files where they are
										if data.slots[fromslot] then
											local slot = data.slots[fromslot]
											self:MigrateResurrectors(slot, fromslot, toslot)
											-- update the saveindex
											SaveGameIndex.data.slots[toslot] = slot
											-- and save it
											print("Writing saveindex")
											SaveGameIndex:Save(function () print(string.format("Slot %s migrated from %s to slot %d",tostring(fromslot),self.frombranch,tostring(toslot))) end)
										end
									else
										print ("Data corrupt for "..saveIndexBackupName)
									end
								else
									print(string.format("Failed to load %s, not restoring", saveIndexBackupName))
							        end
							end)
end

function SaveGameMigrator:MigrateSingleFile(oldname, newname)
	print(string.format("   Migrate file %s to %s",oldname, newname))
        -- modify the filename to not have forward slashes
	--oldname = string.gsub(oldname,"/","\\\\")
	--print("is now",oldname)
    TheSim:GetPersistentString(oldname,
        function(load_success, str) 
			if load_success then
				TheSim:SetPersistentString(newname, str, ENCODE_SAVES, function()
					print(string.format("      Copied %s to %s", oldname, newname))
				end)

			end
        end)    
end
