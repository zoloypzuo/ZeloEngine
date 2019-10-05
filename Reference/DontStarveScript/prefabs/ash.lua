local assets=
{
	Asset("ANIM", "anim/ash.zip"),
}


-- NOTE:
-- You have to add a custom DESCRIBE for each item you
-- mark as nonpotatable
local function GetStatus(inst)
	if inst.components.named.name ~= nil then
		local mod = "REMAINS_"..inst.components.named.name
		mod = string.gsub(mod, " ", "_")
		print(mod)
		return mod
	end
end


local function BlowAway(inst)
    inst.blowawaytask = nil
    inst.persists = false
    inst:RemoveComponent("inventoryitem")
    inst:RemoveComponent("inspectable")
	inst.SoundEmitter:PlaySound("dontstarve/common/dust_blowaway")
	inst.AnimState:PlayAnimation("disappear")
	inst:ListenForEvent("animover", function() inst:Remove() end)
end

local function StopBlowAway(inst)
	if inst.blowawaytask then
		inst.blowawaytask:Cancel()
		inst.blowawaytask = nil
	end
end
		
local function PrepareBlowAway(inst)
	StopBlowAway(inst)
	inst.blowawaytask = inst:DoTaskInTime(25+math.random()*10, BlowAway)
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("ashes")
    inst.AnimState:SetBuild("ash")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    ---------------------       
    
    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(StopBlowAway)

	inst:AddComponent("named")
	inst.components.named.nameformat = STRINGS.NAMES.ASH_REMAINS
	inst:ListenForEvent("stacksizechange", function(inst, stackdata)
		if stackdata.stacksize and stackdata.stacksize > 1 then
			inst.components.named:SetName(nil)
		end
	end)
   
	inst:ListenForEvent("ondropped",  PrepareBlowAway)
	PrepareBlowAway(inst)

    return inst
end

return Prefab( "common/inventory/ash", fn, assets) 

