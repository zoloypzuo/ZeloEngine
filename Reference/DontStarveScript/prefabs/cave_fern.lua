local assets=
{
	Asset("ANIM", "anim/cave_ferns.zip"),
}

local prefabs =
{
	"foliage",
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
	inst:Remove()
end


local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	
	inst.entity:AddAnimState()
    inst.AnimState:SetBank("ferns")
    inst.animname = names[math.random(#names)]
    inst.AnimState:SetBuild("cave_ferns")
    inst.AnimState:PlayAnimation(inst.animname)
    inst.AnimState:SetRayTestOnBB(true);    
  
    inst:AddComponent("inspectable")   

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
    inst.components.pickable:SetUp("foliage", 10)
	inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.quickpick = true 
   
	MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    --------SaveLoad
    inst.OnSave = onsave 
    inst.OnLoad = onload 
    
    return inst
end

return Prefab( "cave/objects/cave_fern", fn, assets, prefabs) 
