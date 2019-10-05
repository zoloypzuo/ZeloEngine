require "prefabutil"

local notags = {'NOBLOCK', 'player', 'FX'}
local function test_ground(inst, pt)
	local tiletype = GetGroundTypeAtPosition(pt)
	local ground_OK = tiletype ~= GROUND.ROCKY and tiletype ~= GROUND.ROAD and tiletype ~= GROUND.IMPASSABLE and
						tiletype ~= GROUND.UNDERROCK and tiletype ~= GROUND.WOODFLOOR and 
						tiletype ~= GROUND.CARPET and tiletype ~= GROUND.CHECKER and tiletype < GROUND.UNDERGROUND
	
	if ground_OK then
	    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, nil, notags) -- or we could include a flag to the search?
		local min_spacing = inst.components.deployable.min_spacing or 2

	    for k, v in pairs(ents) do
			if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
				if distsq( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing*min_spacing then
					return false
				end
			end
		end
		
		return true

	end
	return false
	
end


local function make_plantable(data)

	local name = data.name
	
	local assets =
	{
		Asset("ANIM", "anim/"..name..".zip"),
	}
	if data.build then
		table.insert(assets, Asset("ANIM", "anim/"..data.build..".zip"))
	end

	local function ondeploy(inst, pt, deployer)
		local tree = SpawnPrefab(name) 
		if tree then
			if deployer ~= nil and deployer.SoundEmitter ~= nil then
				inst.SoundEmitter:PlaySound("dontstarve/common/plant")
			end
			tree.Transform:SetPosition(pt.x, pt.y, pt.z) 
			inst.components.stackable:Get():Remove()
			tree.components.pickable:OnTransplant()
		end 
	end
	
	local function fn(Sim)
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		MakeInventoryPhysics(inst)
	    
		inst.AnimState:SetBank(data.bank or data.name)
		inst.AnimState:SetBuild(data.build or data.name)
		inst.AnimState:PlayAnimation("dropped")

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
		
		inst:AddComponent("inspectable")
		inst.components.inspectable.nameoverride = data.inspectoverride or "dug_"..data.name
		inst:AddComponent("inventoryitem")
	    
		inst:AddComponent("fuel")
		inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	    

        MakeMediumBurnable(inst, TUNING.LARGE_BURNTIME)
		MakeSmallPropagator(inst)
		
	    inst:AddComponent("deployable")
	    --inst.components.deployable.test = function() return true end
	    inst.components.deployable.ondeploy = ondeploy
	    inst.components.deployable.test = test_ground
	    inst.components.deployable.min_spacing = data.minspace or 2
	    
	    inst:AddComponent("edible")
	    inst.components.edible.foodtype = "WOOD"
	    inst.components.edible.woodiness = 10

		---------------------  
		return inst      
	end

	return Prefab( "common/objects/dug_"..name, fn, assets)
end

local plantables = 
{
	{name="berrybush", anim="idle_dead", minspace=2},
	{name="berrybush2", bank = "berrybush", inspectoverride = "dug_berrybush", anim = "idle_dead", minspace=2},
	{name="sapling", minspace=1},
	{name="grass", build="grass1", minspace=1},
    {name="marsh_bush", minspace=1},
	--"reeds",
}

local prefabs= {}
for k,v in pairs(plantables) do
	table.insert(prefabs, make_plantable(v))
	table.insert(prefabs, MakePlacer( "common/dug_"..v.name.."_placer", v.bank or v.name, v.build or v.name, v.anim or "idle" ))
end

return unpack(prefabs) 
