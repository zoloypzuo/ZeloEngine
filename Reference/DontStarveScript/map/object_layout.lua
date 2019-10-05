
require("map/placement")
require("constants")

local StaticLayout = function(items, args)
	local positions = {}
	
	for current_prefab, pos_list in pairs(items) do
		for i, pos in pairs(pos_list) do
			-- Note! The third position in the list can hold arbitrary save data for that prefab.
			table.insert(positions, {prefab=current_prefab, x=pos.x, y=pos.y, properties=pos.properties})
		end
	end
	
	return positions
end

local TranslateFunction = function(items, fn, args)
	local positions = {}
	
	local count = 0
	for current_prefab, it_count in pairs(items) do
		count = count + it_count
	end
	
	local pp = fn(count, args)
	
	local pp_cnt = 1
	for current_prefab, it_count in pairs(items) do
		for i=1, it_count do
			table.insert(positions, {prefab=current_prefab, x= pp[pp_cnt].x, y=pp[pp_cnt].y})
			
			pp_cnt = pp_cnt + 1
		end
	end
	
	return positions
end

local CircleEdgeLayout = function(items, args)
	return TranslateFunction(items, placement.posfnCircEdge, args)
end

local CircleFillLayout = function(items, args)
	return TranslateFunction(items, placement.posfnCirc, args)
end


local GetGridPositions = function(num, args)
	
	if args == nil then
		args = {width=3}
	end
	
	local positions = {}
	local height = math.ceil(num / args.width) --args.height or args.width
	
	for i = 1, num do
		table.insert(positions, {x=(-args.width/2.0)+(i % args.width), y=(-height/2.0)+math.floor(i / args.width)})
	end
	
	return positions
end

local GetRectangleEdgePositions = function(num, args)

	if args == nil then
		args = {width=3, height=3}
	end
	
	local total_edge_length = args.width*2+args.height*2
	local dist_per_item = total_edge_length/num
	local positions = {}
	for i = 1, num do
	   	local current_pos = i * dist_per_item

	   	if current_pos < args.width then
	   		table.insert(positions, {x=-args.width/2.0+current_pos, y=-args.height/2.0})
		else
			current_pos = current_pos - args.width
	   		if current_pos < args.height then
	   			table.insert(positions, {x=args.width/2.0, y=-args.height/2.0+current_pos})
			else
				current_pos = current_pos - args.height
				
			   	if current_pos < args.width then
			   		table.insert(positions, {x=args.width/2.0-current_pos, y=args.height/2.0})
				else
					current_pos = current_pos - args.width
			   		table.insert(positions, {x=-args.width/2.0, y=args.height/2.0-current_pos})
				end
			end
		end
	end
	
	return positions
end


local GridLayout = function(items, args)
	return TranslateFunction(items, GetGridPositions, args)
end

local RectangleEdgeLayout = function(items, args)
	return TranslateFunction(items, GetRectangleEdgePositions, args)
end


local LAYOUT_FUNCTIONS =
{
	[LAYOUT.STATIC] = 			StaticLayout,
	[LAYOUT.CIRCLE_EDGE] = 		CircleEdgeLayout,
	[LAYOUT.CIRCLE_RANDOM] = 	CircleFillLayout,
	[LAYOUT.GRID] = 			GridLayout,
	[LAYOUT.RECTANGLE_EDGE] =	RectangleEdgeLayout,
}


local function MinBoundingBox(items)
	local extents = {xmin=1000000, ymin=1000000, xmax=-1000000, ymax=-1000000}	

	for k,pos in pairs(items) do
	
		if pos[1] < extents.xmin then
			extents.xmin = pos[1]
		end
		if pos[1] > extents.xmax then
			extents.xmax = pos[1]
		end
		
		if pos[2] < extents.ymin then
			extents.ymin = pos[2]
		end
		if pos[2] > extents.ymax then
			extents.ymax = pos[2]
		end
	end
	
	return extents
end

local function LayoutForDefinition(name, choices)
	assert(name~=nil)

	local objs = require("map/layouts")
	local traps = require("map/traps")
	local pois = require("map/pointsofinterest")
	local protres = require("map/protected_resources")
	local boons = require("map/boons")
	local maze_rooms = require("map/maze_layouts")

	local layout = {}
	
	if objs.Layouts[name] == nil and traps.Layouts[name] == nil 
		and pois.Layouts[name] == nil and protres.Layouts[name] == nil  
		and boons.Layouts[name] == nil and maze_rooms.Layouts[name] == nil then
		print("No layout available for", name)
		return
	else
		if objs.Layouts[name] ~= nil then
			layout = deepcopy(objs.Layouts[name])
		elseif traps.Layouts[name] ~= nil then
			layout = deepcopy(traps.Layouts[name])
		elseif protres.Layouts[name] ~= nil then
			layout = deepcopy(protres.Layouts[name])
		elseif boons.Layouts[name] ~= nil then
			layout = deepcopy(boons.Layouts[name])
		elseif maze_rooms.Layouts[name] ~= nil then
			if choices ~= nil then
				layout = deepcopy(maze_rooms.AllLayouts[GetRandomItem(choices)][name])
			else
				layout = deepcopy(GetRandomItem(maze_rooms.AllLayouts)[name])
			end
		else 
			layout = deepcopy(pois.Layouts[name])
		end

		layout.name = name
	end
	return layout
end


local function ConvertLayoutToEntitylist(layout)
	assert(layout~=nil, "No layout was provided!")

	if layout.areas ~= nil and layout.layout ~= nil then
	    local to_add = {}
		for current_prefab, v in pairs(layout.layout) do
			for idx, current_prefab_data in ipairs(v) do
				if layout.areas[current_prefab] ~= nil then
					local area_contents = layout.areas[current_prefab]
					if type(area_contents) == "function" then
						area_contents = area_contents(current_prefab_data.width * current_prefab_data.height)
					end

					if area_contents ~= nil then
						for i,r_prefab in ipairs(area_contents) do
							local x = (current_prefab_data.x-current_prefab_data.width/2.0) + (math.random()*current_prefab_data.width)
							local y = (current_prefab_data.y-current_prefab_data.height/2.0) + (math.random()*current_prefab_data.height)
							local properties = current_prefab_data.properties
							if to_add[r_prefab] == nil then
								to_add[r_prefab] = {}
							end
							table.insert(to_add[r_prefab], {x=x, y=y, properties=properties})
						end
					end
				end
			end
		end
		
		for prefab_name,instances in pairs(to_add) do
		    if layout.layout[prefab_name] == nil then
		        layout.layout[prefab_name] = {}
		    end
		    for i,instance in ipairs(instances) do
		        table.insert(layout.layout[prefab_name], instance)
		    end
        end
        
		-- all areas populated now, so remove the areas.
		for k,v in pairs(layout.areas) do
			layout.layout[k] = nil
		end
	end

	if layout.defs ~= nil then
	
		-- for each layout item that appears in defs, replace with one of the choices from defs
		
		if layout.layout ~= nil then
			for current_prefab,v in pairs(layout.layout) do
				if layout.defs[current_prefab] ~= nil then
					local idx = math.random(1, #layout.defs[current_prefab])
					
					layout.layout[layout.defs[current_prefab][idx]] = v
					layout.layout[current_prefab] = nil
				end
			end
		end
		
		if layout.count ~= nil then
			for current_prefab,v in pairs(layout.count) do
				if layout.defs[current_prefab] ~= nil then
					local idx = math.random(1, #layout.defs[current_prefab])
					
					layout.count[layout.defs[current_prefab][idx]] = v
					layout.count[current_prefab] = nil
				end
			end
		end
	end
	
	if layout.scale == nil then
		layout.scale = 1.0
	end
	
	local all_items = {}

	if layout.layout ~= nil then
		local layout_pos = LAYOUT_FUNCTIONS[LAYOUT.STATIC](layout.layout)
		for i,v in ipairs(layout_pos) do
			table.insert(all_items, v)
		end
	end
	if layout.type ~= LAYOUT.STATIC then
		local shape_pos = LAYOUT_FUNCTIONS[layout.type](layout.count)
		for i,v in ipairs(shape_pos) do
			table.insert(all_items, v)
		end
	end

	return all_items
end

local function ReserveAndPlaceLayout(node_id, layout, prefabs, add_entity, position)
	assert(node_id~=nil)
	assert(layout~=nil)
	assert(prefabs~=nil)
	assert(add_entity~=nil)

	-- Calculate min bounding box
	local item_positions = {}
	for i, val in ipairs(prefabs) do
		table.insert(item_positions, {val.x, val.y})
	end
		
	local extents = MinBoundingBox(item_positions)
		
	-- Get the size of the area to reserve
	local e_width = (extents.xmax - extents.xmin)/2.0
	local e_height = (extents.ymax - extents.ymin)/2.0
		 
	local size = e_width
	if size < e_height then
		size = e_height
	end
		
--	elseif layout.count ~= nil then
--		
--		for current_prefab, count in ipairs(layout.count) do
--			for i, pos in pairs(count) do
--				table.insert(all_items)
--			end
--		end

	
	size = layout.scale * size
	local flip_x = 1
	local flip_y = 1
	local switch_xy = false	

	if layout.disable_transform == nil or layout.disable_transform == false then
		switch_xy = GetRandomItem({true,false})--translate[1]
		flip_x =	GetRandomItem({1,-1})--translate[2]
		flip_y =	GetRandomItem({1,-1})--translate[3]
	end

	-- If we specify a rotation then use that instead
	if layout.force_rotation ~= nil then
		--print(node_id, layout, layout.force_rotation)
		local translations = { 
								[LAYOUT_ROTATION.NORTH]={false,	1,	1}, 
								[LAYOUT_ROTATION.EAST]= {true,	-1, 1}, 
								[LAYOUT_ROTATION.SOUTH]={false,	-1,	-1}, 
								[LAYOUT_ROTATION.WEST]=	{true,	1,	-1} 
							 }
							 
		switch_xy  = translations[layout.force_rotation][1]
		flip_x = translations[layout.force_rotation][2]
		flip_y = translations[layout.force_rotation][3]
	end

	local tiles = nil
	if layout.ground ~= nil then
		size = #layout.ground
		tiles = {}
		for row = 1, size do
			for column = 1, size do
				local rw = row
				local clmn = column
				
				if switch_xy == true then
					rw = column
					clmn = row
				end
				
				if flip_x == -1 then
					rw = size - (rw-1)
				end
				if flip_y == -1 then
					clmn = size - (clmn-1)
				end
				--print("rw",rw, "clmn", clmn)
				if layout.ground[clmn][rw] ~= 0 then	
					if position ~= nil then
						--print(position[1] + clmn, position[2] + rw, layout.ground_types[layout.ground[clmn][rw]])
						WorldSim:SetTile(position[1] + column, size+position[2] - row, layout.ground_types[layout.ground[rw][clmn]], 1)
					else
						table.insert(tiles, layout.ground_types[layout.ground[clmn][rw]])
					end
				else
					table.insert(tiles, 0)
				end
			end
		end
		size = size / 2.0
	end

	-- defaults
	layout.start_mask = layout.start_mask or 0
	layout.fill_mask = layout.fill_mask or 0
	layout.layout_position = layout.layout_position or 0

	-- reserve the area
	local rcx = 0
	local rcy = 0
	if position == nil then
		rcx, rcy = WorldSim:ReserveSpace(node_id, size, layout.start_mask, layout.fill_mask, layout.layout_position, tiles)
	else
		rcx = position[1]
		rcy = position[2]
	end
	-- place objects however you like within the reserved loc
	--print ("RESERVED", rcx,rcy, flip_x, flip_y)	
	
	if rcx ~= nil then		
		-- ReserveSpace gives us the bottom left tile, but we orient objects around the center(to ease rotation)
		rcx = rcx + size - 0.5
		rcy = rcy + size - 0.5
	
	
		--if flip_y == -1 then
			--if switch_xy == true then
				--rcx = rcx - 1
			--else
				--rcy = rcy - 1
			--end
			
		--end
		for idx=1, #prefabs do
			local x = prefabs[idx].x* flip_x
			local y = prefabs[idx].y* flip_y 
			
			if switch_xy == true then
				x = prefabs[idx].y* flip_y 
				y = prefabs[idx].x* flip_x
			end
			
			local points_x = rcx + x * layout.scale  --* flip_x
			local points_y = rcy + y * layout.scale  --* flip_y 
				
			--print ("add_entity", prefabs[idx].prefab, points_x, points_y )	
			
			add_entity.fn(prefabs[idx].prefab, {points_x}, {points_y}, 1, add_entity.args.entitiesOut, add_entity.args.width, add_entity.args.height, add_entity.args.debug_prefab_list, prefabs[idx].properties, false)
		end
	else
		print("Warning! Could not find a spot for "..layout.name.." in node "..node_id)
	end

end

-- Convenience function does all three steps at once.
local function Convert(node_id, item, addEntity)
	assert(item and item ~= "", "Must provide a valid layout name, got nothing.")
	local layout = LayoutForDefinition(item)
	local prefabs = ConvertLayoutToEntitylist(layout)
	ReserveAndPlaceLayout(node_id, layout, prefabs, addEntity)
end

local function Place(position, item, addEntity, choices)
	assert(item and item ~= "", "Must provide a valid layout name, got nothing.")
	local layout = LayoutForDefinition(item, choices)
	local prefabs = ConvertLayoutToEntitylist(layout)
	ReserveAndPlaceLayout("POSITIONED", layout, prefabs, addEntity, position)
end

return {
		ConvertLayoutToEntitylist = ConvertLayoutToEntitylist, 
		LayoutForDefinition = LayoutForDefinition, 
		ReserveAndPlaceLayout = ReserveAndPlaceLayout, 
		Convert = Convert,
		Place = Place,
	}
