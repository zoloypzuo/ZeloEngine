local assets =
{
    Asset("ANIM", "anim/statue_ruins_small.zip"),
	Asset("ANIM", "anim/statue_ruins_small_gem.zip"),
    Asset("ANIM", "anim/statue_ruins.zip"),
	Asset("ANIM", "anim/statue_ruins_gem.zip"),
    Asset("MINIMAP_IMAGE", "statue_ruins"),
}

local prefabs = 
{
    "marble",
    "greengem",
    "redgem",
    "bluegem",
    "yellowgem",
    "orangegem",
    "purplegem",
    "nightmarefuel",
}

local gemlist  = 
{
    "greengem",
    "redgem",
    "bluegem",
    "yellowgem",
    "orangegem",
    "purplegem",
}


SetSharedLootTable( 'statue_ruins_no_gem',
{
    {'thulecite',     1.00},
    {'nightmarefuel', 1.00},
    {'thulecite',     0.05},
})

local LIGHT_INTENSITY = .25
local LIGHT_RADIUS = 2.5
local LIGHT_FALLOFF = 5
local FADEIN_TIME = 10

local function turnoff(inst, light)
    if light then
        light:Enable(false)
    end
end


local function DoFx(inst)
    if ExecutingLongUpdate then
        return
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
    
    local fx = SpawnPrefab("statue_transition_2")
    if fx then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx.AnimState:SetScale(1,2,1)
    end
    fx = SpawnPrefab("statue_transition")
    if fx then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx.AnimState:SetScale(1,1.5,1)
    end
end
local function fade_in(inst)
    inst.Light:Enable(true)
    --DoFx(inst)
    inst.components.lighttweener:StartTween(nil, 3, nil, nil, nil, 0.5) 
end

local function fade_out(inst)
    --DoFx(inst)

    inst.components.lighttweener:StartTween(nil, 0, nil, nil, nil, 1, turnoff) 
end

local function ShowState(inst,data)

    if not data then data = {} end

    if inst.fading then return end

    local nclock = GetNightmareClock()

    local suffix = ""
    local workleft = inst.components.workable.workleft

    if inst.small then
        inst.SoundEmitter:PlaySound("dontstarve/common/floating_statue_hum", "hoverloop")
        if inst.gemmed then
            inst.AnimState:OverrideSymbol("swap_gem", "statue_ruins_small_gem", inst.gemmed)
        end
    else
        if inst.gemmed then
            inst.AnimState:OverrideSymbol("swap_gem", "statue_ruins_gem", inst.gemmed)
        end
    end

    if nclock and nclock:IsNightmare() then
        suffix = "_night"
        inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
        if not data.fromwork then
            DoFx(inst)
        end
    end

    if data and data.newphase and inst.phase ~= data.newphase and (data.newphase ~= "nightmare") then
        if data.newphase == "warn" then
            fade_in(inst)
        elseif data.newphase == "calm" then
            fade_out(inst)
        else
            inst.AnimState:ClearBloomEffectHandle()
            DoFx(inst)
        end
        inst.phase = data.newphase
    end

    if workleft < TUNING.MARBLEPILLAR_MINE*(1/3) then
        inst.AnimState:PlayAnimation("hit_low"..suffix, true)
    elseif workleft < TUNING.MARBLEPILLAR_MINE*(2/3) then
        inst.AnimState:PlayAnimation("hit_med"..suffix, true)
    else
        inst.AnimState:PlayAnimation("idle_full"..suffix, true)
    end
end


local function OnWork(inst, worked, workleft)
    local pt = Point(inst.Transform:GetWorldPosition())
    if workleft <= 0 then
        inst.SoundEmitter:KillSound("hoverloop")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
        inst.components.lootdropper:DropLoot(pt)
	    SpawnAt("collapse_small",inst)

        local nclock = GetNightmareClock()
        if nclock and nclock:IsNightmare() then
            if math.random() <= 0.3 then
                if math.random() <= 0.5 then
                    SpawnAt("crawlingnightmare",inst)
                else
                    SpawnAt("nightmarebeak",inst)
                end
            end
        end

        inst:Remove()
    else                
        ShowState(inst, {fromwork = true})
    end
end

local function commonfn(small)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.small = small
    
    inst.fadeout = fade_out
    inst.fadein = fade_in

    MakeObstaclePhysics(inst, 0.66)

    if small then
        anim:SetBank("statue_ruins_small")
        anim:SetBuild("statue_ruins_small")
    else
        anim:SetBank("statue_ruins")
        anim:SetBuild("statue_ruins")
    end

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon( "statue_ruins.png" )

    inst:AddTag("structure")

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "ANCIENT_STATUE"
    inst:AddComponent("named")
    inst.components.named:SetName(STRINGS.NAMES["ANCIENT_STATUE"])

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.MARBLEPILLAR_MINE)
    inst.components.workable:SetOnWorkCallback(OnWork)

    inst:AddComponent("fader")
    
    inst:AddComponent("lighttweener")
    local light = inst.entity:AddLight()
    inst.components.lighttweener:StartTween(light, 1, .9, 0.9, {255/255,255/255,255/255}, 0, turnoff)

    inst:AddComponent("lootdropper")

    if GetNightmareClock() then
	    inst:ListenForEvent( "phasechange",
                                function(source,data)
                                    --dprint("PHASECHANGE:",data.newphase)
                                    ShowState(inst,data)
                                end,
                                GetWorld() )
    end

    inst:DoTaskInTime(1*FRAMES, function()
                            ShowState(inst)
                            end)
    
	--fade_in(inst,0)

    return inst
end

local function gem(small)
    local inst = commonfn(small)
    local gem = GetRandomItem(gemlist)

    inst.gemmed = gem
    if small then
        inst.AnimState:OverrideSymbol("swap_gem", "statue_ruins_small_gem", gem)
    else
        inst.AnimState:OverrideSymbol("swap_gem", "statue_ruins_gem", gem)
    end
    inst.components.lootdropper:SetLoot({"thulecite", gem})
    inst.components.lootdropper:AddChanceLoot("thulecite"  , 0.05)

    return inst
end

local function nogem(small)
    local inst = commonfn(small)
    
    inst.components.lootdropper:SetChanceLootTable('statue_ruins_no_gem')

    return inst
end

return Prefab("cave/objects/ruins_statue_head", function(Sim) return gem(true) end, assets, prefabs),
       Prefab("cave/objects/ruins_statue_head_nogem", function(Sim) return nogem(true) end, assets, prefabs),
       Prefab("cave/objects/ruins_statue_mage", function(Sim) return gem() end, assets, prefabs),
       Prefab("cave/objects/ruins_statue_mage_nogem", function(Sim) return nogem() end, assets, prefabs)

