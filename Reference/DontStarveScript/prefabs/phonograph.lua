local function makeassetlist()
    return {
		Asset("ANIM", "anim/phonograph.zip"),
		Asset("INV_IMAGE", "phonograph"),
		Asset("INV_IMAGE", "record_01"),
		Asset("INV_IMAGE", "record_02"),
		Asset("INV_IMAGE", "record_03"),
		Asset("MINIMAP_IMAGE", "phonograph"),
    }
end

local WORLD_UNLOCK_DB_RECORD = "d9ney"

local function makefn(name, frame, description)
    local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
	    MakeInventoryPhysics(inst)
	    local minimap = inst.entity:AddMiniMapEntity()
	    minimap:SetIcon( "phonograph.png" )

		anim:SetBank("phonograph")
		anim:SetBuild("phonograph")
		
		anim:PlayAnimation(frame, false)

        inst:AddComponent("inspectable")
        inst.components.inspectable:SetDescription( function() return description end)
        
	    inst:AddComponent("inventoryitem")
	    
	    if name ~= "phonograph_complete" then
		    local statName = name
		    local localInst = inst
		    inst.components.inventoryitem:SetOnPickupFn(function() 
		    															ProfileStatsAddItemChunk("collect:"..WORLD_UNLOCK_DB_RECORD,statName)
		    															localInst:Remove()
		    															
		    															local stats = json.encode({title="Found!", name=name, description=description})
		    															TheSim:SendUITrigger(stats)
		    															return true
		    											end)
		end
        
        print("Making phono: ",name, frame, description)
       	return inst
	end
    return fn
end

local function Phonograph(name, frame, description)
    return Prefab( "common/objects/treasure/" .. name,makefn(name, frame, description), makeassetlist())
end

return Phonograph( "phonograph_gears", "gears", "This looks like it might be useful to make something fun."),
		Phonograph( "phonograph_box", "box", "Mysteriouser and mysteriouser... maybe I should keep it for later."),
		Phonograph( "phonograph_crank", "crank", "I wonder what this is for? Probably part of some nefarious doomsday device."),
		Phonograph( "phonograph_cone", "cone", "Its either a fnny shaped trumpet or a hearing aid for a person signignificantly hard of hearing."),
		Phonograph( "phonograph_complete", "complete", "A fully assempled phonograph! Good times ahead!") 

