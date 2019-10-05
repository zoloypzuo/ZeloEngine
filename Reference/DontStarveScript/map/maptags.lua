
local function MakeTags()
	local map_data =
		{
			["Chester_Eyebone"] = true,
		}
		
	local map_tags = 
		{
			["Maze"] = function(tagdata)
								return "GLOBALTAG", "Maze"
							end,
			["MazeEntrance"] = function(tagdata)
								return "GLOBALTAG", "MazeEntrance"
							end,
			["Labyrinth"] = function(tagdata)
								return "GLOBALTAG", "Labyrinth"
							end,
			["LabyrinthEntrance"] = function(tagdata)
								return "GLOBALTAG", "LabyrinthEntrance"
							end,
			["OverrideCentroid"] = function(tagdata)
								return "GLOBALTAG", "OverrideCentroid"
							end,
			["RoadPoison"] = function(tagdata)
								return "TAG", "RoadPoison"
							end,
			["ForceConnected"] = function(tagdata)
								return "TAG", "ForceConnected"
							end,
			["ForceDisconnected"] = function(tagdata)
								return "TAG", "ForceDisconnected"
							end,
			["OneshotWormhole"] = function(tagdata)
								return "TAG", "OneshotWormhole"
							end,
			["ExitPiece"] = function(tagdata)
								return "TAG", "ExitPiece"
							end,						
			--["ExitPiece"]	= 	function(tagdata)
									--if #tagdata["ExitPiece"] == 0 then
										--return
									--end
																		
									--local item = GetRandomItem(tagdata["ExitPiece"])
									
									--for idx,v in pairs(tagdata["ExitPiece"]) do
										--if v == item then
											--table.remove(tagdata["ExitPiece"], idx)
											--break
										--end
									--end								
									
									--print("Exit piece adding bit", item)
									--return "STATIC", item	
								--end,
								
			["Town"] =  function(tagdata)
							return "TAG", 0x000001	
						end,
			["Chester_Eyebone"] =	function(tagdata)
										if tagdata["Chester_Eyebone"] == false then
											return
										end
										tagdata["Chester_Eyebone"] = false
										return "ITEM", "chester_eyebone"
									end,
		}
	return {Tag = map_tags, TagData = map_data }
end
return MakeTags
