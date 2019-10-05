require "prefabutil"

local assets=
{
	Asset("ANIM", "anim/cave_ferns_potted.zip"),
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


local function onhammered(inst, worker)
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.components.lootdropper:DropLoot()
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_pot")
    inst:Remove()
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
	inst.entity:AddAnimState()
    inst.AnimState:SetBank("ferns_potted")

    inst.animname = names[math.random(#names)]
    inst.AnimState:SetBuild("cave_ferns_potted")
    inst.AnimState:PlayAnimation(inst.animname)
    inst.AnimState:SetRayTestOnBB(true);    
  
    inst:AddComponent("inspectable")
  
	MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("lootdropper")

    --------SaveLoad
    inst.OnSave = onsave 
    inst.OnLoad = onload 
    
    return inst
end

return Prefab( "cave/objects/pottedfern", fn, assets),
    MakePlacer( "common/pottedfern_placer", "ferns_potted", "cave_ferns_potted", "f1")
