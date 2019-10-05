require "prefabutil"

local assets=
{
	Asset("ANIM", "anim/player_basic.zip"),
    Asset("ANIM", "anim/wes.zip"),
	Asset("ANIM", "anim/player_mime.zip"),    
}

local function removewes(inst)
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function Unlock(inst)
	print("wes unlocked!")

	local player = GetPlayer()
	player.profile:UnlockCharacter("wes")
	player.profile.dirty = true
	player.profile:Save()
	inst.AnimState:PlayAnimation("death", false)
	inst:DoTaskInTime(2.5, removewes)
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wes")
    inst.AnimState:PlayAnimation("mime6",true)
    
    inst:AddComponent("inspectable")


    inst.onguardsdead = Unlock

    return inst
end

return Prefab( "common/lockedwes", fn, assets) 
