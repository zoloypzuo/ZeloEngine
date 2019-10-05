local assets=
{
	Asset("ANIM", "anim/flowers.zip"),
}


local prefabs =
{
    "petals",
}    


local names = {"f1","f2","f3","f4","f5","f6","f7","f8","f9","f10"}

local function onsave(inst, data)
	data.anim = inst.animname
end

local function onload(inst, data)
    if data and data.anim then
        inst.animname = data.anim
	    inst.AnimState:PlayAnimation(inst.animname)
	end
end

local function onpickedfn(inst, picker)
	if picker and picker.components.sanity then
		picker.components.sanity:DoDelta(TUNING.SANITY_TINY)
	end	
	
	inst:Remove()
end



local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	
	inst.entity:AddAnimState()
    inst.AnimState:SetBank("flowers")
    inst.animname = names[math.random(#names)]
    inst.AnimState:SetBuild("flowers")
    inst.AnimState:PlayAnimation(inst.animname)
    inst.AnimState:SetRayTestOnBB(true);
    
    inst:AddTag("flower")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
    inst.components.pickable:SetUp("petals", 10)
	inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.quickpick = true
    
	MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)


    --------SaveLoad
    inst.OnSave = onsave 
    inst.OnLoad = onload 
    
    return inst
end

return Prefab( "forest/objects/flower", fn, assets, prefabs) 
