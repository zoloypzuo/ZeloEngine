

local function RunCA(id, entities, data)	
	--print(id.." RunCa", data.iterations, data.seed_mode, data.num_random_points)
	WorldSim:RunCA(id, data.iterations, data.seed_mode, data.num_random_points)

	if data.translate ~= nil then
		local points_x, points_y, points_type = WorldSim:GetPointsForSite(id)
		if #points_x == 0 then
			print(id.." RunCA() Cant process points")
			return
		end
		local current_pos_idx = 1
		for current_pos_idx = 1, #points_x do
			if points_type[current_pos_idx]-1 < #data.translate then


				local current_layer = data.translate[points_type[current_pos_idx]-1]
				WorldSim:SetTile(points_x[current_pos_idx], points_y[current_pos_idx], current_layer.tile)
				
				if current_layer.item_count >0 then
					--print("RunCA ", current_layer.items[1], data.width, data.height)
					data.node:AddEntity(current_layer.items[1], points_x, points_y, current_pos_idx, entities, data.width, data.height, {}, {}, true)
					current_layer.item_count = current_layer.item_count -1
				end
			end
		end
	end
	if data.centroid ~= nil then
		local c_x, c_y = WorldSim:GetSiteCentroid(id)
		WorldSim:SetTile(c_x, c_y, data.centroid.tile)
		data.node:AddEntity(data.centroid.items[1], {c_x}, {c_y}, 1, entities, data.width, data.height, {}, {}, true)
	end
end
RUNCA = {GeneratorFunction = RunCA, DefaultArgs = {iterations=6, seed_mode=CA_SEED_MODE.SEED_CENTROID, num_random_points=1} }


local function MyTestTileSetFunction(id, entities, data)
	local LAYOUT_FUNCTIONS = require("map/object_layout").LAYOUT_FUNCTIONS

	-- Place a few light beams and then make rings of plants and tiles around them

	-- FOREST + Tall trees in center
	-- FOREST + shorter trees
	-- GRASS + twigs & berries
	-- SAVANNA + grass
	-- DIRT
	-- ROCK

	local points_x, points_y, points_type = WorldSim:GetPointsForSite(id)
	if #points_x == 0 then
		print(self.id.." SetTilesViaFunction() Cant process points")
		return
	end
	local current_pos_idx = 1

	-- Decide how many beams of light

	-- place beams

	-- get concentric circles around each of the beam locations from outside inwards 
	--		this way we can just overrite what came before

	-- As we go, make sure that each point is within the area or the polygon
	if WorldSim:PointInSite(id, pos.x, pos.z) then
	end


	-- Reserve all the tiles
	-- for current_pos_idx = current_pos_idx, #points_x  do
	-- 	WorldSim:ReserveTile(points_x[current_pos_idx], points_y[current_pos_idx])
	-- end
end

local MyTestTileSetFunction_data = 	{ 
		{tile=GROUND.FOREST, items={"evergreen_tall"}, 		item_count=3},
		{tile=GROUND.FOREST, items={"evergreen_normal"}, 	item_count=5},
		{tile=GROUND.FOREST, items={"evergreen_short"}, 	item_count=7},
		{tile=GROUND.GRASS,  items={"sapling","berrybush"},	item_count=6},
		{tile=GROUND.SAVANNA,items={"grass"}, 				item_count=6},
		{tile=GROUND.DIRT},
		{tile=GROUND.ROCK},
	}
PlaceLightBeam = {GeneratorFunction = MyTestTileSetFunction, DefaultArgs = MyTestTileSetFunction_data}

