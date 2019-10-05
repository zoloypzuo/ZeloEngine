local PopupDialogScreen = require "screens/popupdialog"

local assets =
{
	Asset("ANIM", "anim/diviningrod.zip"),
    Asset("SOUND", "sound/common.fsb"),
    Asset("ANIM", "anim/diviningrod_maxwell.zip")
}

local prefabs = 
{
    "diviningrodstart",
}

local function OnUnlock(inst, key, doer)
    inst.AnimState:PlayAnimation("idle_full")
    inst.throne = TheSim:FindFirstEntityWithTag("maxwellthrone")
    inst.throne.lock = inst
	local character = GetPlayer().profile:GetValue("characterinthrone") or "wilson"
    GetPlayer().components.playercontroller:Enable(false)
    SetPause(true)

    local title =  STRINGS.UI.UNLOCKMAXWELL.TITLE
    local body =  STRINGS.UI.UNLOCKMAXWELL.BODY1..(STRINGS.CHARACTER_NAMES[character] or STRINGS.UI.UNLOCKMAXWELL.THEM)..string.format(STRINGS.UI.UNLOCKMAXWELL.BODY2, (STRINGS.UI.GENDERSTRINGS[GetGenderStrings(character)].TWO or STRINGS.UI.UNLOCKMAXWELL.THEIR)   )
    local popup = PopupDialogScreen(title, body,
            {
                {text=STRINGS.UI.UNLOCKMAXWELL.YES, cb = function()
                    TheFrontEnd:PopScreen() 
                    SetPause(false)
                    inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_add_divining")
                    inst.throne.startthread(inst.throne)
                    
                end},

                {text=STRINGS.UI.UNLOCKMAXWELL.NO, cb = function()
                    TheFrontEnd:PopScreen()               
                    SetPause(false)
                    GetPlayer().components.playercontroller:Enable(true)
                    inst.components.lock:Lock(doer)
                    inst:PushEvent("notfree")  
                end}
            }
        )

    TheFrontEnd:PushScreen(  popup  )
end

local function OnLock(inst, doer)
    inst.AnimState:PlayAnimation("idle_empty")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("diviningrod")
    anim:SetBuild("diviningrod_maxwell")
    anim:PlayAnimation("activate_loop", true)
    
    inst:AddComponent("inspectable")

    inst:AddTag("maxwelllock")

    inst:AddComponent("lock")
    inst.components.lock.locktype = "maxwell"
    inst.components.lock:SetOnUnlockedFn(OnUnlock)
    inst.components.lock:SetOnLockedFn(OnLock)

    return inst
end

return Prefab( "common/maxwelllock", fn, assets, prefabs) 
