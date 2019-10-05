require "prefabutil"

function MakeWallType(data)

	local assets =
	{
		Asset("ANIM", "anim/wall.zip"),
		Asset("ANIM", "anim/wall_".. data.name..".zip"),
	}

	local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst:AddTag("wall")

		anim:SetBank("wall")
		anim:SetBuild("wall_"..data.name)
	    anim:PlayAnimation("0", false)
	    
		inst:AddComponent("inspectable")
		
		for k,v in ipairs(data.tags) do
		    inst:AddTag(v)
		end
		
		MakeSnowCovered(inst)
		
		return inst
	end

	return Prefab( "common/brokenwall_"..data.name, fn, assets)
end

local wallprefabs = {}

--6 rock, 8 wood, 4 straw
--NOTE: Stacksize is now set in the actual recipe for the item.
local walldata = 
{
	{name = "stone", tags={"stone"}, loot = "rocks", maxloots = 2, maxhealth=TUNING.STONEWALL_HEALTH, buildsound="dontstarve/common/place_structure_stone", destroysound="dontstarve/common/destroy_stone"},
	{name = "wood", tags={"wood"}, loot = "log", maxloots = 2, maxhealth=TUNING.WOODWALL_HEALTH, flammable = true, buildsound="dontstarve/common/place_structure_wood", destroysound="dontstarve/common/destroy_wood"},
	{name = "hay", tags={"grass"}, loot = "cutgrass", maxloots = 2, maxhealth=TUNING.HAYWALL_HEALTH, flammable = true, buildsound="dontstarve/common/place_structure_straw", destroysound="dontstarve/common/destroy_straw"},
	{name = "ruins", tags={"stone"}, loot = "rocks", maxloots = 2, maxhealth=TUNING.STONEWALL_HEALTH, buildsound="dontstarve/common/place_structure_stone", destroysound="dontstarve/common/destroy_stone"},
}


for k,v in pairs(walldata) do
	local wall, item, placer = MakeWallType(v)
	table.insert(wallprefabs, wall)
end

return unpack(wallprefabs) 
