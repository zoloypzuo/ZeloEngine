    
local assets =
{
	Asset("ANIM", "anim/sign_home.zip"),
	Asset("MINIMAP_IMAGE", "sign"),
}

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("idle")
end


    
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	   
    MakeObstaclePhysics(inst, .2)    
    
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "sign.png" )
    
    anim:SetBank("sign_home")
    anim:SetBuild("sign_home")
    anim:PlayAnimation("idle")
    
    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper") 
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
 	MakeSnowCovered(inst, .01)	
   	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/sign/place")

    return inst
end

return Prefab( "common/objects/homesign", fn, assets),
		MakePlacer( "common/homesign_placer", "sign_home", "sign_home", "idle" ) 
