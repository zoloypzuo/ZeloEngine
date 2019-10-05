local assets=
{
	Asset("ANIM", "anim/telebrella.zip"),
	Asset("ANIM", "anim/swap_telebrella.zip"),
    Asset("ANIM", "anim/swap_telebrella_red.zip"),
    Asset("ANIM", "anim/swap_telebrella_green.zip"),
}

local TELEDIST = 40 * 12
  
local function UpdateSound(inst)
    local soundShouldPlay = GetSeasonManager():IsRaining() and inst.components.equippable:IsEquipped()
    if soundShouldPlay ~= inst.SoundEmitter:PlayingSound("umbrellarainsound") then
        if soundShouldPlay then
		    inst.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/teleumbrella_rain_LP", "umbrellarainsound") 
        else
		    inst.SoundEmitter:KillSound("umbrellarainsound")
		end
    end
end  

local function onfinished(inst)
    inst:Remove()
end
    
local function findclosestpad(inst, sourcepad)    
    local target = GetPlayer()
    if sourcepad then
        target = sourcepad
    end
    local pad = nil
    if GetWorld().telipads then
        local dist = TELEDIST * TELEDIST
        for i,testpad in ipairs(GetWorld().telipads) do
            local x,y,z = testpad.Transform:GetWorldPosition()
            local ground = GetWorld()            
            local tile = ground.Map:GetTileAtPoint(x,y,z)
            if tile ~= GROUND.INTERIOR then
                local testdist = target:GetDistanceSqToInst(testpad)
                if testdist < dist and testpad ~= target then
                    pad = testpad
                    dist = testdist
                end
            end
        end
    end
    return pad
end

local function checkconnection(inst) 
    local player = GetPlayer()       
    local pad = findclosestpad(inst)    
    if inst.lastpad then
        inst.lastpad.turnoff(inst.lastpad)        
    end
    if pad then        
        if player:GetDistanceSqToInst(pad) < 2*2 then
            local otherpad = findclosestpad(inst,pad)
            inst.lastpad = pad
            if otherpad then            
                inst.lastpad.turnon(inst.lastpad)
            end
            pad = otherpad            
        end
        return pad        
    end
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_telebrella", "swap_telebrella")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    UpdateSound(inst)

    local INTERVAL = 0.1
    inst.task = inst:DoPeriodicTask(INTERVAL, function() 
            local player = GetPlayer()       
            
            local pad = checkconnection(inst) 
            if pad and not TheCamera.interior then

                inst.flashtime = inst.flashtime + INTERVAL
                local switch = false

                local dist = player:GetDistanceSqToInst(pad)  --(TELEDIST-10) * (TELEDIST-10)

                local period = INTERVAL
                if not inst.red then
                   -- period = Remap(dist, 0, TELEDIST*TELEDIST, 10, 0.2)
                    local max = TELEDIST*TELEDIST
                    if dist > max *0.9 then
                        period = INTERVAL
                    elseif dist > max *0.75 then
                        period = 1
                    elseif dist > max *0.5 then
                        period = 3
                    else 
                        period = 9999999
                    end
                end

                if inst.flashtime > period then
                    switch = true            
                    inst.flashtime = 0
                end
                if switch then
                    if not inst.red then
                        inst.SoundEmitter:PlaySound("dontstarve_wagstaff/characters/wagstaff/teleumbrella_beep")
                        inst.red = true
                    else                 
                        inst.red = nil
                    end                
                end
                if inst.red then
                    player.AnimState:OverrideSymbol("swap_object", "swap_telebrella_red", "swap_telebrella")
                else
                    player.AnimState:OverrideSymbol("swap_object", "swap_telebrella_green", "swap_telebrella")
                end                
            else
                player.AnimState:OverrideSymbol("swap_object", "swap_telebrella", "swap_telebrella")            
            end
        end)
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    UpdateSound(inst)

    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function canteleport(staff, caster, target, pos)
    if checkconnection(staff) and not TheCamera.interior then
        return true
    end    
end

local function teleport(staff)
    local player = GetPlayer() 
    local pad = nil
    if canteleport(staff) then
        pad = checkconnection(staff)
    end
    if pad then
        local pos = pad:GetPosition()
        player.Transform:SetPosition(pos.x, pos.y, pos.z)
        TheCamera:Snap()
        player.components.locomotor:Clear()

        local light = SpawnPrefab("telebrella_glow")
        if light then
            local x,y,z = player.Transform:GetWorldPosition()
            light.Transform:SetPosition(x,y,z)
        end
    end
    staff.components.finiteuses:Use(1)
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()    
    MakeInventoryPhysics(inst)
    
    anim:SetBank("telebrella")
    anim:SetBuild("telebrella")
    anim:PlayAnimation("idle")

    inst:AddTag("telebrella")

    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.TELEBRELLA_USES)
    inst.components.finiteuses:SetUses(TUNING.TELEBRELLA_USES)
    inst.components.finiteuses:SetOnFinished( onfinished) 
    --inst.components.finiteuses:SetConsumption(ACTIONS.TERRAFORM, .125)
    -------
    
    if IsDLCEnabled(REIGN_OF_GIANTS) or IsDLCEnabled(CAPY_DLC) or IsDLCEnabled(PORKLAND_DLC) then
        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALLMED)
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.UMBRELLA_DAMAGE)


    inst.teleport = teleport

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(teleport)
    inst.components.spellcaster:SetSpellTestFn(canteleport)
    inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.canusefrominventory = false
    inst.components.spellcaster.castingstate = "telebrella"
    inst.components.spellcaster.actiontype = "SCIENCE"

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    inst:ListenForEvent("rainstop", function() UpdateSound(inst) end, GetWorld()) 
    inst:ListenForEvent("rainstart", function() UpdateSound(inst) end, GetWorld()) 

    inst:ListenForEvent("startrowing", function() UpdateSound(inst) end)
    inst:ListenForEvent("stoprowing", function() UpdateSound(inst) end)    

    inst.flashtime =0
    return inst
end

local INTENSITY = 1--.75

local function fadein(inst)
    inst.components.fader:StopAll()
    inst.Light:Enable(true)
    if inst:IsAsleep() then
        inst.Light:SetIntensity(INTENSITY)
    else
        inst.Light:SetIntensity(0)
        inst.components.fader:Fade(0, INTENSITY, 0.6, function(v) inst.Light:SetIntensity(v) end)
    end
end

local function fadeout(inst)
    inst.components.fader:StopAll()
    if inst:IsAsleep() then
        inst.Light:SetIntensity(0)
    else
        inst.components.fader:Fade(INTENSITY, 0, 0.6, function(v) inst.Light:SetIntensity(v) end, function() inst.Light:Enable(false) end)
    end
end

local function glowfn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst:AddComponent("fader")
    local light = inst.entity:AddLight()
    light:SetFalloff(.7)
    light:SetIntensity(INTENSITY)
    light:SetRadius(2)
    --light:SetColour(120/255, 120/255, 120/255)
    light:SetColour(220/255, 220/255, 220/255)
    light:Enable(false) 
    inst.fadein = fadein
    inst.fadeout = fadeout
    inst:DoTaskInTime(0,function()    
            fadein(inst)
        end)
    inst:DoTaskInTime(0.6,function()
            fadeout(inst)
        end)
    inst:DoTaskInTime(0.6 * 2,function()
            inst:Remove()
        end)    
    return inst   
end

return  Prefab( "common/inventory/telebrella", fn, assets),
        Prefab( "common/inventory/telebrella_glow", glowfn, assets) 

