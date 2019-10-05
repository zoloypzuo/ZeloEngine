local assets =
{
	Asset("ANIM", "anim/gravestones.zip"),
}

local prefabs = 
{
	"ghost",
	"amulet",
	"redgem",
	"gears",
	"bluegem",
	"nightmarefuel",
}

for k= 1,NUM_TRINKETS do
    table.insert(prefabs, "trinket_"..tostring(k) )
end

local function onfinishcallback(inst, worker)

    inst.AnimState:PlayAnimation("dug")
    inst:RemoveComponent("workable")

	if worker then
		if worker.components.sanity then
			worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
		end		
		if math.random() < .1 then
			local ghost = SpawnPrefab("ghost")
			local pos = Point(inst.Transform:GetWorldPosition())
			pos.x = pos.x -.3
			pos.z = pos.z -.3
			if ghost then
				ghost.Transform:SetPosition(pos.x, pos.y, pos.z)
			end
		elseif worker.components.inventory then
			local item = nil
			if math.random() < .5 then
				local loots = 
				{
					nightmarefuel = 1,
					amulet = 1,
					gears = 1,
					redgem = 5,
					bluegem = 5,
				}
				item = weighted_random_choice(loots)
			else
				item = "trinket_"..tostring(math.random(NUM_TRINKETS))
			end

			
			if item then
				inst.components.lootdropper:SpawnLootPrefab(item)
			end
		end
	end	
end

  
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    
    anim:SetBank("gravestone")
    anim:SetBuild("gravestones")
    anim:PlayAnimation("gravedirt")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        if not inst.components.workable then        	
            return "DUG"
        end
    end

    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
	inst:AddComponent("lootdropper")
        
    inst.components.workable:SetOnFinishCallback(onfinishcallback)      
    
    inst.OnSave = function(inst, data)
        if not inst.components.workable then
            data.dug = true
        end
    end        
    
    inst.OnLoad = function(inst, data)
        if data and data.dug or not inst.components.workable then
            inst:RemoveComponent("workable")
            inst.AnimState:PlayAnimation("dug")
        end
    end           
    
    
    return inst
end

return Prefab( "common/objects/mound", fn, assets, prefabs ) 
