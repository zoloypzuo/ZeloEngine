require "constants"

local GROUND_PROPERTIES = {
	{ GROUND.ROAD,		{ name = "cobblestone",	noise_texture = "images/square.tex",								runsound="dontstarve/movement/run_dirt",		walksound="dontstarve/movement/walk_dirt",		snowsound="dontstarve/movement/run_ice"		} },
	{ GROUND.MARSH,		{ name = "marsh",		noise_texture = "levels/textures/Ground_noise_marsh.tex",			runsound="dontstarve/movement/run_marsh",		walksound="dontstarve/movement/walk_marsh",		snowsound="dontstarve/movement/run_ice"		} },
	{ GROUND.ROCKY,		{ name = "rocky",		noise_texture = "levels/textures/noise_rocky.tex",					runsound="dontstarve/movement/run_dirt",		walksound="dontstarve/movement/walk_dirt",		snowsound="dontstarve/movement/run_ice"		} },
	{ GROUND.SAVANNA,	{ name = "yellowgrass",	noise_texture = "levels/textures/Ground_noise_grass_detail.tex",	runsound="dontstarve/movement/run_tallgrass",	walksound="dontstarve/movement/walk_tallgrass",	snowsound="dontstarve/movement/run_snow"	} },
	{ GROUND.FOREST,	{ name = "forest",		noise_texture = "levels/textures/Ground_noise.tex",					runsound="dontstarve/movement/run_woods",		walksound="dontstarve/movement/walk_woods",		snowsound="dontstarve/movement/run_snow"	} },
	{ GROUND.GRASS,		{ name = "grass",		noise_texture = "levels/textures/Ground_noise.tex",					runsound="dontstarve/movement/run_grass",		walksound="dontstarve/movement/walk_grass",		snowsound="dontstarve/movement/run_snow"	} },
	{ GROUND.DIRT,		{ name = "dirt",		noise_texture = "levels/textures/Ground_noise_dirt.tex",			runsound="dontstarve/movement/run_dirt",		walksound="dontstarve/movement/walk_dirt",		snowsound="dontstarve/movement/run_snow"	} },
	{ GROUND.WOODFLOOR,	{ name = "blocky",		noise_texture = "levels/textures/noise_woodfloor.tex",				runsound="dontstarve/movement/run_wood",		walksound="dontstarve/movement/walk_wood",		snowsound="dontstarve/movement/run_ice"		} },
	{ GROUND.CHECKER,	{ name = "blocky",		noise_texture = "levels/textures/noise_checker.tex",				runsound="dontstarve/movement/run_marble",		walksound="dontstarve/movement/walk_marble",	snowsound="dontstarve/movement/run_ice"		} },
	{ GROUND.CARPET,	{ name = "carpet",		noise_texture = "levels/textures/noise_carpet.tex",					runsound="dontstarve/movement/run_carpet",		walksound="dontstarve/movement/walk_carpet",	snowsound="dontstarve/movement/run_snow"	} },

	{ GROUND.CAVE,		{ name = "cave",		noise_texture = "levels/textures/noise_cave.tex",					runsound="dontstarve/movement/run_dirt",		walksound="dontstarve/movement/walk_dirt",		snowsound="dontstarve/movement/run_ice"		} },
	{ GROUND.FUNGUS,	{ name = "cave",		noise_texture = "levels/textures/noise_fungus.tex",					runsound="dontstarve/movement/run_moss",		walksound="dontstarve/movement/walk_moss",		snowsound="dontstarve/movement/run_ice"		} },
	{ GROUND.FUNGUSRED,	{ name = "cave",		noise_texture = "levels/textures/noise_fungus_red.tex",					runsound="dontstarve/movement/run_moss",		walksound="dontstarve/movement/walk_moss",		snowsound="dontstarve/movement/run_ice"		} },
	{ GROUND.FUNGUSGREEN,{ name = "cave",		noise_texture = "levels/textures/noise_fungus_green.tex", 				runsound="dontstarve/movement/run_moss",		walksound="dontstarve/movement/walk_moss",		snowsound="dontstarve/movement/run_ice"		} },
	
	{ GROUND.SINKHOLE,	{ name = "cave",		noise_texture = "levels/textures/noise_sinkhole.tex",				runsound="dontstarve/movement/run_dirt",		walksound="dontstarve/movement/walk_dirt",		snowsound="dontstarve/movement/run_snow"	} },
	{ GROUND.UNDERROCK,	{ name = "cave",		noise_texture = "levels/textures/noise_rock.tex",					runsound="dontstarve/movement/run_dirt",		walksound="dontstarve/movement/walk_dirt",		snowsound="dontstarve/movement/run_ice"		} },
	{ GROUND.MUD,		{ name = "cave",		noise_texture = "levels/textures/noise_mud.tex",					runsound="dontstarve/movement/run_mud",			walksound="dontstarve/movement/walk_mud",		snowsound="dontstarve/movement/run_snow"	} },

	{ GROUND.BRICK_GLOW,{ name = "cave",		noise_texture = "levels/textures/noise_ruinsbrick.tex",				runsound="dontstarve/movement/run_dirt",		walksound="dontstarve/movement/walk_dirt",		snowsound="dontstarve/movement/run_ice"		} },
	{ GROUND.BRICK,		{ name = "cave",		noise_texture = "levels/textures/noise_ruinsbrickglow.tex",			runsound="dontstarve/movement/run_moss",		walksound="dontstarve/movement/walk_moss",		snowsound="dontstarve/movement/run_ice"		} },
	{ GROUND.TILES_GLOW,{ name = "cave",		noise_texture = "levels/textures/noise_ruinstile.tex",				runsound="dontstarve/movement/run_dirt",		walksound="dontstarve/movement/walk_dirt",		snowsound="dontstarve/movement/run_snow"	} },
	{ GROUND.TILES,		{ name = "cave",		noise_texture = "levels/textures/noise_ruinstileglow.tex",			runsound="dontstarve/movement/run_dirt",		walksound="dontstarve/movement/walk_dirt",		snowsound="dontstarve/movement/run_ice"		} },
	{ GROUND.TRIM_GLOW,	{ name = "cave",		noise_texture = "levels/textures/noise_ruinstrim.tex",				runsound="dontstarve/movement/run_dirt",		walksound="dontstarve/movement/walk_dirt",		snowsound="dontstarve/movement/run_snow"	} },
	{ GROUND.TRIM,		{ name = "cave",		noise_texture = "levels/textures/noise_ruinstrimglow.tex",			runsound="dontstarve/movement/run_dirt",		walksound="dontstarve/movement/walk_dirt",		snowsound="dontstarve/movement/run_ice"		} },
}


local WALL_PROPERTIES =
{
	{ GROUND.UNDERGROUND,	{ name = "falloff", noise_texture = "images/square.tex" } },
	{ GROUND.WALL_MARSH,	{ name = "walls", 	noise_texture = "images/square.tex" } },--"levels/textures/wall_marsh_01.tex" } },
	{ GROUND.WALL_ROCKY,	{ name = "walls", 	noise_texture = "images/square.tex" } },--"levels/textures/wall_rock_01.tex" } },
	{ GROUND.WALL_DIRT,		{ name = "walls", 	noise_texture = "images/square.tex" } },--"levels/textures/wall_dirt_01.tex" } },

	{ GROUND.WALL_CAVE,		{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_cave_01.tex" } },
	{ GROUND.WALL_FUNGUS,	{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_fungus_01.tex" } },
	{ GROUND.WALL_SINKHOLE, { name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_sinkhole_01.tex" } },
	{ GROUND.WALL_MUD,		{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_mud_01.tex" } },
	{ GROUND.WALL_TOP,		{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/cave_topper.tex" } },
	{ GROUND.WALL_WOOD,		{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/cave_topper.tex" } },

	{ GROUND.WALL_HUNESTONE_GLOW,		{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_cave_01.tex" } },
	{ GROUND.WALL_HUNESTONE,	{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_fungus_01.tex" } },
	{ GROUND.WALL_STONEEYE_GLOW, { name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_sinkhole_01.tex" } },
	{ GROUND.WALL_STONEEYE,		{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_mud_01.tex" } },
}

local underground_layers =
{
	{ GROUND.UNDERGROUND, { name = "falloff", noise_texture = "images/square.tex" } },
}

local GROUND_CREEP_PROPERTIES = {
	{ 1, { name = "web", noise_texture = "levels/textures/web_noise.tex" } },
}


function GroundImage( name )
	return "levels/tiles/" .. name .. ".tex"
end

function GroundAtlas( name )
	return "levels/tiles/" .. name .. ".xml"
end

local function AddAssets( assets, layers )
	for i, data in ipairs( layers ) do
		local tile_type, properties = unpack( data )
		table.insert( assets, Asset( "IMAGE", properties.noise_texture ) )
		table.insert( assets, Asset( "IMAGE", GroundImage( properties.name ) ) )
		table.insert( assets, Asset( "FILE", GroundAtlas( properties.name ) ) )
	end
end

local assets = {}
AddAssets( assets, WALL_PROPERTIES )
AddAssets( assets, GROUND_PROPERTIES )
AddAssets( assets, underground_layers ) 
AddAssets( assets, GROUND_CREEP_PROPERTIES )



function GetTileInfo( tile )
	for k, data in ipairs( GROUND_PROPERTIES ) do
		local tile_type, tile_info = unpack( data )
		if tile == tile_type then
			return tile_info
		end
	end
	return nil
end


local WEB_FOOTSTEP_SOUNDS = {
	[CREATURE_SIZE.SMALL]	=	{ runsound = "dontstarve/movement/run_web_small",		walksound = "dontstarve/movement/walk_web_small" },
	[CREATURE_SIZE.MEDIUM]	=	{ runsound = "dontstarve/movement/run_web",				walksound = "dontstarve/movement/walk_web" },
	[CREATURE_SIZE.LARGE]	=	{ runsound = "dontstarve/movement/run_web_large",		walksound = "dontstarve/movement/walk_web_large" },
}


function PlayFootstep(inst, volume)
	volume = volume or 1
	
    local sound = inst.SoundEmitter
    if sound then
        local tile, tileinfo = inst:GetCurrentTileType()
        
        if tile and tileinfo then
			local x, y, z = inst.Transform:GetWorldPosition()
			local oncreep = GetWorld().GroundCreep:OnCreep( x, y, z )
			local onsnow = GetSeasonManager() and GetSeasonManager():GetSnowPercent() > 0.15
			
			--this is only for playerd for the time being because isonroad is suuuuuuuper slow.
			local onroad = inst:HasTag("player") and RoadManager ~= nil and RoadManager:IsOnRoad( x, 0, z )
			if onroad then
				tile = GROUND.ROAD
				tileinfo = GetTileInfo( GROUND.ROAD )
			end

			local creature_size = CREATURE_SIZE.MEDIUM
			local size_affix = ""
			if inst:HasTag("smallcreature") then
				creature_size = CREATURE_SIZE.SMALL
				size_affix = "_small"
			elseif inst:HasTag("largecreature") then
				creature_size = CREATURE_SIZE.LARGE
				size_affix = "_large"
			end
			
			if onsnow then
				sound:PlaySound(tileinfo.snowsound .. size_affix, nil, volume)
			else
				if inst.sg and inst.sg:HasStateTag("running") then
					sound:PlaySound(tileinfo.runsound .. size_affix, nil, volume)
				else
					sound:PlaySound(tileinfo.walksound .. size_affix, nil, volume)
				end
			end

			if oncreep then
				sound:PlaySound( WEB_FOOTSTEP_SOUNDS[ creature_size ].runsound, nil, volume)
			end           
        end
    end
end

return 
{
	ground = GROUND_PROPERTIES,
	creep = GROUND_CREEP_PROPERTIES,
	wall = WALL_PROPERTIES,
	underground = underground_layers,
	assets = assets,
}
