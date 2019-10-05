local Terraformer = Class(function(self, inst)
    self.inst = inst
end)


local GROUND_TURFS =
{
	[GROUND.ROCKY]		= "turf_rocky",
	[GROUND.ROAD]		= "turf_road",
	[GROUND.DIRT]		= "turf_dirt",
	[GROUND.SAVANNA]	= "turf_savanna",
	[GROUND.GRASS]		= "turf_grass",
	[GROUND.FOREST]		= "turf_forest",
	[GROUND.MARSH]		= "turf_marsh",
	[GROUND.WOODFLOOR]	= "turf_woodfloor",
	[GROUND.CARPET]		= "turf_carpetfloor",
	[GROUND.CHECKER]	= "turf_checkerfloor",
	
	[GROUND.CAVE]		= "turf_cave",
	[GROUND.FUNGUS]		= "turf_fungus",
	[GROUND.FUNGUSRED]	= "turf_fungus_red",
	[GROUND.FUNGUSGREEN]= "turf_fungus_green",
	
	[GROUND.SINKHOLE]	= "turf_sinkhole",
	[GROUND.UNDERROCK]	= "turf_underrock",
	[GROUND.MUD]		= "turf_mud",

	webbing				= "turf_webbing",
}


function Terraformer:CanTerraformPoint(pt)
    local ground = GetWorld()
    if ground then
		local tile = ground.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
		return tile ~= GROUND.IMPASSIBLE and tile ~= GROUND.DIRT and tile < GROUND.UNDERGROUND
	end
	return false
end

function Terraformer:CollectPointActions(doer, pos, actions, right)
    if right then
		local valid = true
		-- if RoadManager then
		-- 	valid = not RoadManager:IsOnRoad( pos.x, 0, pos.z )
		-- end
		
		if valid and self:CanTerraformPoint(pos) then
			table.insert(actions, ACTIONS.TERRAFORM)
		end
	end
end

local function SpawnTurf( turf, pt )
	if turf then
		local loot = SpawnPrefab(turf)
		loot.Transform:SetPosition(pt.x, pt.y, pt.z)
		if loot.Physics then
			local angle = math.random()*2*PI
			loot.Physics:SetVel(2*math.cos(angle), 10, 2*math.sin(angle))
		end
	end
end

function Terraformer:Terraform(pt)
	if self:CanTerraformPoint(pt) == false then
		return false
	end

    local ground = GetWorld()
    if ground then
		local tile = ground.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
		if tile ~= GROUND.DIRT then
			local original_tile_type = ground.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
			local x, y = ground.Map:GetTileCoordsAtPoint(pt.x, pt.y, pt.z)

			ground.Map:SetTile( x, y, GROUND.DIRT )
			ground.Map:RebuildLayer( original_tile_type, x, y )
			ground.Map:RebuildLayer( GROUND.DIRT, x, y )
			
			local minimap = TheSim:FindFirstEntityWithTag("minimap")
			if minimap then
				minimap.MiniMap:RebuildLayer( original_tile_type, x, y )
				minimap.MiniMap:RebuildLayer( GROUND.DIRT, x, y )
			end
			
			SpawnTurf( GROUND_TURFS[tile], pt )
			return true
		end
	end
end


return Terraformer

