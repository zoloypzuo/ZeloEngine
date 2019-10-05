require("constants")

local StaticLayout = require("map/static_layout")

local ruins_areas = 
{
	rubble = function(area) return nil end,
	debris = function(area) return PickSomeWithDups( 0.25 * area
	, {"rocks"}) end,
}

local function GetLayoutsForType( name )
	local layouts = 
		{
			["SINGLE_NORTH"] = 	StaticLayout.Get("map/static_layouts/rooms/"..name.."/one",	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.NORTH}),
			["SINGLE_EAST"] = 	StaticLayout.Get("map/static_layouts/rooms/"..name.."/one",	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.EAST}),
			["L_NORTH"] = 		StaticLayout.Get("map/static_layouts/rooms/"..name.."/two", 	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.NORTH}),
			["SINGLE_SOUTH"] = 	StaticLayout.Get("map/static_layouts/rooms/"..name.."/one",	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.SOUTH}),
			["TUNNEL_NS"] = 	StaticLayout.Get("map/static_layouts/rooms/"..name.."/long", 	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.NORTH}),
			["L_EAST"] = 		StaticLayout.Get("map/static_layouts/rooms/"..name.."/two",	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.EAST}),
			["THREE_WAY_N"] = 	StaticLayout.Get("map/static_layouts/rooms/"..name.."/three", 	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.NORTH}),
			["SINGLE_WEST"] = 	StaticLayout.Get("map/static_layouts/rooms/"..name.."/one",	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.WEST}),
			["L_WEST"] = 		StaticLayout.Get("map/static_layouts/rooms/"..name.."/two",	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.WEST}),
			["TUNNEL_EW"] = 	StaticLayout.Get("map/static_layouts/rooms/"..name.."/long",	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.EAST}),
			["THREE_WAY_W"] = 	StaticLayout.Get("map/static_layouts/rooms/"..name.."/three",	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.WEST}),
			["L_SOUTH"] = 		StaticLayout.Get("map/static_layouts/rooms/"..name.."/two",	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.SOUTH}),
			["THREE_WAY_S"] = 	StaticLayout.Get("map/static_layouts/rooms/"..name.."/three",	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.SOUTH}),
			["THREE_WAY_E"] = 	StaticLayout.Get("map/static_layouts/rooms/"..name.."/three",	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.EAST}),
			["FOUR_WAY"] = 		StaticLayout.Get("map/static_layouts/rooms/"..name.."/four", 	{
				areas = ruins_areas,
				force_rotation = LAYOUT_ROTATION.NORTH}),
		}
	return layouts
end

return {
		Layouts = GetLayoutsForType("room"),
		AllLayouts = {
			["default"] = GetLayoutsForType("room"), 
			["hallway"] = GetLayoutsForType("hallway"), 
			["hallway_armoury"] = GetLayoutsForType("hallway_armoury"), 
			["hallway_residential"] = GetLayoutsForType("hallway_residential"), 
			["hallway_residential_two"] = GetLayoutsForType("hallway_residential_two"),
			--["hallway_shop"] = GetLayoutsForType("hallway_shop"), 
			-- ["default"] = GetLayoutsForType("room_shop"), 
			["room_armoury"] = GetLayoutsForType("room_armoury"), 
			["room_armoury_two"] = GetLayoutsForType("room_armoury_two"),
			["room_residential"] = GetLayoutsForType("room_residential"), 
			["room_residential_two"] = GetLayoutsForType("room_residential_two"),
			["room_open"] = GetLayoutsForType("room_open"),
		},
	}
