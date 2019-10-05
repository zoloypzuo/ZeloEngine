local assets = 
{
	Asset("ANIM", "anim/phonograph.zip"),
	Asset("SOUND", "sound/maxwell.fsb"),
	Asset("SOUND", "sound/music.fsb"),
	Asset("SOUND", "sound/gramaphone.fsb")
}

local function play(inst)
	inst.AnimState:PlayAnimation("play_loop", true)
   	inst.SoundEmitter:PlaySound(inst.songToPlay, "ragtime")
   	if inst.components.playerprox then
   		inst:RemoveComponent("playerprox")
   	end
   	inst:PushEvent("turnedon")
end

local function stop(inst)
	inst.AnimState:PlayAnimation("idle")
    inst.SoundEmitter:KillSound("ragtime")
    inst.SoundEmitter:PlaySound("dontstarve/music/gramaphone_end")

    inst:PushEvent("turnedoff")
end

local function fn()

		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		local sound = inst.entity:AddSoundEmitter()
	    MakeObstaclePhysics(inst, 0.1)
		anim:SetBank("phonograph")
		anim:SetBuild("phonograph")		
		anim:PlayAnimation("idle")

		inst.songToPlay = "dontstarve/maxwell/ragtime"

		inst:AddTag("maxwellphonograph")

		inst:AddComponent("inspectable")

		inst:AddComponent("machine")
		inst.components.machine.turnonfn = play
		inst.components.machine.turnofffn = stop

		inst.entity:SetCanSleep(false)
		
		inst:AddComponent("playerprox")
		inst.components.playerprox:SetDist(600, 615)
		inst.components.playerprox:SetOnPlayerNear(function() inst.components.machine:TurnOn() end)

	return inst
end

return Prefab("common/objects/maxwellphonograph", fn, assets) 
