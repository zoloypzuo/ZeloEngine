require("constants")
local StaticLayout = require("map/static_layout")

local Rare = {
	["Dev Graveyard"] = StaticLayout.Get("map/static_layouts/dev_graveyard"),
}

local Forest = {
	["Sleeping Spider"] = StaticLayout.Get("map/static_layouts/trap_sleepingspider"),
	["Chilled Base"] = StaticLayout.Get("map/static_layouts/trap_winter"),
}

local Grasslands = {
}

local Swamp = {
	["Rotted Base"] = StaticLayout.Get("map/static_layouts/trap_spoilfood"),
}

local Rocky = {
}

local Dirt = {
}


local Savanna = {
	["Beefalo Farm"] = StaticLayout.Get("map/static_layouts/beefalo_farm"),
}

local Any = {
	["Ice Hounds"] = StaticLayout.Get("map/static_layouts/trap_icestaff"),
	["Fire Hounds"] = StaticLayout.Get("map/static_layouts/trap_firestaff"),
}

local SandboxModeTraps = {
	["Rare"] = Rare,
	["Any"] = Any,
	[GROUND.ROCKY] = Rocky,
	[GROUND.DIRT] = Dirt,
	[GROUND.SAVANNA] = Savanna,
	[GROUND.GRASS] = Grasslands,
	[GROUND.FOREST] = Forest,
	[GROUND.MARSH] = Swamp,
}

local layouts = {}
for k,area in pairs(SandboxModeTraps) do
	if GetTableSize(area) >0 then
		for name, layout in pairs(area) do
			layouts[name] = layout
		end
	end
end

return {Sandbox = SandboxModeTraps, Layouts = layouts}
