local assets=
{
	Asset("ANIM", "anim/eyes_darkness.zip"),
}

local names = {"1","2","3"}

local function Blink(inst)
    inst.AnimState:PlayAnimation("blink_"..inst.animname)
    inst.AnimState:PushAnimation("idle_"..inst.animname, true)
    inst.blinktask = inst:DoTaskInTime(0.5 + math.random(), Blink)
end

local function Disappear(inst)
    if inst.blinktask then
        inst.blinktask:Cancel()
        inst.blinktask = nil
    end
    if inst.deathtask then
        inst.deathtask:Cancel()
        inst.deathtask = nil
    end
    inst.AnimState:PushAnimation("disappear_"..inst.animname, false)
    inst:ListenForEvent("animqueueover", function() inst:Remove() end)
end

local function fn()
    
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLightWatcher()
    inst.LightWatcher:SetLightThresh(.2)
    inst.LightWatcher:SetDarkThresh(.19)
    inst:ListenForEvent("enterlight", function(inst) inst:Remove() end)
    inst.persists = false
    inst:AddTag("NOCLICK")
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerNear(Disappear)
   
    inst.AnimState:SetBank("eyes_darkness")
    inst.animname = names[math.random(#names)]
    inst.AnimState:SetBuild("eyes_darkness")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:PlayAnimation("appear_"..inst.animname)
    inst.AnimState:PushAnimation("idle_"..inst.animname, true)
    
    inst.blinktask = inst:DoTaskInTime(1 + math.random(), Blink)
    inst.deathtask = inst:DoTaskInTime(10 + 5*math.random(), Disappear)
    inst.persists = false
    
return inst
end

return Prefab( "common/creepyeyes", fn, assets) 
