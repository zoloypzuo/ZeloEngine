local assets =
{
	Asset("ANIM", "anim/batcave.zip"),
}

local prefabs =
{
	"bat"
}


local function ReturnChildren(inst)
	for k,child in pairs(inst.components.childspawner.childrenoutside) do
		if child.components.homeseeker then
			child.components.homeseeker:GoHome()
		end
		child:PushEvent("gohome")
	end
end

local function onnear(inst)
	if inst.components.childspawner.childreninside >= inst.components.childspawner.maxchildren then
		inst.components.childspawner:StartSpawning()
		inst.components.childspawner:StopRegen()
	end
end


local function onfar(inst)
	ReturnChildren(inst)
	inst.components.childspawner:StopSpawning()
	inst.components.childspawner:StartRegen()
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeObstaclePhysics( inst, 1.95)

    anim:SetBuild("batcave")
    anim:SetBank("batcave")
    anim:PlayAnimation("idle")
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

	inst:AddComponent( "childspawner" )
	inst.components.childspawner:SetRegenPeriod(60)
	inst.components.childspawner:SetSpawnPeriod(.1)
	inst.components.childspawner:SetMaxChildren(6)
	inst.components.childspawner.childname = "bat"

    inst:AddComponent("inspectable")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)
    inst.components.playerprox:SetDist(20, 40)

	return inst
end

return Prefab( "cave/objects/batcave", fn, assets, prefabs)  
