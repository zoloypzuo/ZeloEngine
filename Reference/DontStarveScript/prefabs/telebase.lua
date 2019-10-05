local assets =
{
	Asset("ANIM", "anim/staff_purple_base_ground.zip"),
}

local prefabs =
{
	"gemsocket",
}

local function teleport_target(inst)
	for k,v in pairs(inst.components.objectspawner.objects) do
		if v.DestroyGemFn then
			v.DestroyGemFn(v)
		end
	end
end

local function validteleporttarget(inst)
	for k,v in pairs(inst.components.objectspawner.objects) do
		if v.components.pickable and not v.components.pickable.caninteractwith then
			return false
		end
	end
	return true
end

local function getstatus(inst)
	if validteleporttarget(inst) then
		return "VALID"
	else
		return "GEMS"
	end
end

local telebase_parts = {

	{part = "gemsocket", x= -1.6, z=-1.6},
	{part = "gemsocket", x=2.7, z=-0.8},
	{part = "gemsocket", x=-0.8, z= 2.7},
}

local function removesockets(inst)
	for k,v in pairs(inst.components.objectspawner.objects) do
		v:Remove()
	end
end

local function ondestroyed(inst)
	for k,v in pairs(inst.components.objectspawner.objects) do
		if v.components.pickable and v.components.pickable.caninteractwith then
			inst.components.lootdropper:AddChanceLoot("purplegem", 1)	
		end
	end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst)
	for k,v in pairs(inst.components.objectspawner.objects) do
		if v.components.pickable and v.components.pickable.caninteractwith then
			v.AnimState:PlayAnimation("hit_full")
			v.AnimState:PushAnimation("idle_full_loop")
		else
			v.AnimState:PlayAnimation("hit_empty")
			v.AnimState:PushAnimation("idle_empty")
		end
	end
end

local function OnGemChange(inst)
	if validteleporttarget(inst) then
		for k,v in pairs(inst.components.objectspawner.objects) do
    		v.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
		end
	else
		for k,v in pairs(inst.components.objectspawner.objects) do
    		v.AnimState:ClearBloomEffectHandle()
		end
	end
end

local function NewObject(inst, obj)
	inst:ListenForEvent("trade", function() OnGemChange(inst) end, obj)
	inst:ListenForEvent("picked", function() OnGemChange(inst) end, obj)

	OnGemChange(inst)
end

local function commonfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("telebase.png")

    MakeInventoryPhysics(inst)

    inst:AddTag("telebase")

    anim:SetBuild("staff_purple_base_ground")
    anim:SetBank("staff_purple_base_ground")
    anim:PlayAnimation("idle")
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
	trans:SetRotation( 45 )

	inst.onteleto = teleport_target
	inst.canteleto = validteleporttarget

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnWorkCallback(onhit)
	inst.components.workable:SetOnFinishCallback(ondestroyed)

	inst:AddComponent("lootdropper")
    
    inst:AddComponent("objectspawner")
    inst.components.objectspawner.onnewobjectfn = NewObject

    inst:ListenForEvent("onbuilt", function()

	    local pos = inst:GetPosition()         
	    for k,v in pairs(telebase_parts) do
			local part = inst.components.objectspawner:SpawnObject(v.part)
			part.Transform:SetPosition(pos.x + v.x, 0, pos.z + v.z)
	    end 

    	for k,v in pairs(inst.components.objectspawner.objects) do
    		v:Hide()
    		v:DoTaskInTime(math.random() * 0.5, function() v:Show() v.AnimState:PlayAnimation("place")
    		v.AnimState:PushAnimation("idle_empty") end)
    	end
	end)

	inst:ListenForEvent("onremove", removesockets)

	return inst
end

return Prefab( "common/inventory/telebase", commonfn, assets, prefabs),
	   MakePlacer( "common/telebase_placer", "staff_purple_base_ground", "staff_purple_base_ground", "idle" ) 