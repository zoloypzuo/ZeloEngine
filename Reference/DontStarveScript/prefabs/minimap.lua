local shader_filename = "shaders/minimap.ksh"
local fs_shader = "shaders/minimapfs.ksh"
local atlas_filename = "minimap/minimap_atlas.tex"
local atlas_info_filename = "minimap/minimap_data.xml"

local MINIMAP_GROUND_PROPERTIES =
{
	{ GROUND.ROAD,       { name = "map_edge",      noise_texture = "levels/textures/mini_cobblestone_noise.tex" } },
	{ GROUND.MARSH,      { name = "map_edge",      noise_texture = "levels/textures/mini_marsh_noise.tex" } },
	{ GROUND.ROCKY,      { name = "map_edge",	   noise_texture = "levels/textures/mini_rocky_noise.tex" } },
	{ GROUND.SAVANNA,    { name = "map_edge",      noise_texture = "levels/textures/mini_grass2_noise.tex" } },
	{ GROUND.GRASS,      { name = "map_edge",      noise_texture = "levels/textures/mini_grass_noise.tex" } },
	{ GROUND.FOREST,     { name = "map_edge",      noise_texture = "levels/textures/mini_forest_noise.tex" } },
	{ GROUND.DIRT,       { name = "map_edge",      noise_texture = "levels/textures/mini_dirt_noise.tex" } },
	{ GROUND.WOODFLOOR,  { name = "map_edge",      noise_texture = "levels/textures/mini_woodfloor_noise.tex" } },
	{ GROUND.CARPET,  	 { name = "map_edge",      noise_texture = "levels/textures/mini_carpet_noise.tex" } },
	{ GROUND.CHECKER,  	 { name = "map_edge",      noise_texture = "levels/textures/mini_checker_noise.tex" } },

	-- { GROUND.WALL_MARSH, { name = "map_edge",      noise_texture = "levels/textures/mini_marsh_wall_noise.tex" } },
	-- { GROUND.WALL_ROCKY, { name = "map_edge",      noise_texture = "levels/textures/mini_rocky_wall_noise.tex" } },
	-- { GROUND.WALL_DIRT,  { name = "map_edge",      noise_texture = "levels/textures/mini_dirt_wall_noise.tex" } },

	{ GROUND.CAVE,  	 { name = "map_edge",      noise_texture = "levels/textures/mini_cave_noise.tex" } },
	{ GROUND.FUNGUS,  	 { name = "map_edge",      noise_texture = "levels/textures/mini_fungus_noise.tex" } },
	{ GROUND.FUNGUSRED,  { name = "map_edge",      noise_texture = "levels/textures/mini_fungus_red_noise.tex" } },
	{ GROUND.FUNGUSGREEN,{ name = "map_edge",      noise_texture = "levels/textures/mini_fungus_green_noise.tex" } },	
	{ GROUND.SINKHOLE, 	 { name = "map_edge",      noise_texture = "levels/textures/mini_sinkhole_noise.tex" } },
	{ GROUND.UNDERROCK,  { name = "map_edge",      noise_texture = "levels/textures/mini_rock_noise.tex" } },
	{ GROUND.MUD, 	 	 { name = "map_edge",      noise_texture = "levels/textures/mini_mud_noise.tex" } },
	{ GROUND.BRICK, 	 { name = "map_edge",      noise_texture = "levels/textures/mini_ruinsbrick_noise.tex" } },
	{ GROUND.TILES,  	 { name = "map_edge",      noise_texture = "levels/textures/mini_ruinstile_noise.tex" } },
	{ GROUND.TRIM, 	 	 { name = "map_edge",      noise_texture = "levels/textures/mini_ruinstrim_noise.tex" } },

	-- { GROUND.WALL_CAVE,    { name = "map_edge",      noise_texture = "levels/textures/mini_cave_wall_noise.tex" } },
	-- { GROUND.WALL_FUNGUS,  { name = "map_edge",      noise_texture = "levels/textures/mini_fungus_wall_noise.tex" } },
	-- { GROUND.WALL_SINKHOLE,{ name = "map_edge",      noise_texture = "levels/textures/mini_sinkhole_wall_noise.tex" } },
}

local assets =
{
	Asset( "ATLAS", atlas_info_filename ),
	Asset( "IMAGE", atlas_filename ),
	
	Asset( "ATLAS", "images/hud.xml" ),
	Asset( "IMAGE", "images/hud.tex" ),

	Asset( "SHADER", shader_filename ),
	Asset( "SHADER", fs_shader ),
}
    
local function GroundImage( name )
	return "levels/tiles/" .. name .. ".tex"
end

local function GroundAtlas( name )
	return "levels/tiles/" .. name .. ".xml"
end

local function AddAssets( layers )
	for k, data in pairs( layers ) do
		local tile_type, properties = unpack( data )
		table.insert( assets, Asset( "IMAGE", ""..properties.noise_texture ) )
		table.insert( assets, Asset( "IMAGE", ""..GroundImage( properties.name ) ) )
		table.insert( assets, Asset( "FILE", ""..GroundAtlas( properties.name ) ) )
	end
end

AddAssets( MINIMAP_GROUND_PROPERTIES )

local function fn(Sim)
	local inst = CreateEntity()
	local uitrans = inst.entity:AddUITransform()
	local minimap = inst.entity:AddMiniMap() --c side renderer
    inst:AddTag("minimap")
    inst.entity:SetCanSleep(false)

	minimap:SetEffects( shader_filename, fs_shader )

	minimap:AddAtlas( resolvefilepath(atlas_info_filename) )
	for i,atlases in ipairs(ModManager:GetPostInitData("MinimapAtlases")) do
		for i,path in ipairs(atlases) do
			minimap:AddAtlas( resolvefilepath(path) )
		end
	end

	for i, data in pairs( MINIMAP_GROUND_PROPERTIES ) do
		local tile_type, layer_properties = unpack( data )
		local handle =
			MapLayerManager:CreateRenderLayer(
				tile_type,
				resolvefilepath(GroundAtlas( layer_properties.name )),
				resolvefilepath(GroundImage( layer_properties.name )),
				resolvefilepath(layer_properties.noise_texture)
			)
		minimap:AddRenderLayer( handle )
	end

	return inst
end

return Prefab( "common/interface/hud/minimap", fn, assets) 

