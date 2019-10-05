
local prefabs =
{
    "thulecite",
    "rocks",
    "cutstone",
    "trinket_6",
    "gears",
    "nightmarefuel",
    "greengem",
    "orangegem",
    "yellowgem",
}    

SetSharedLootTable( 'smashables',
{
    {'rocks',      0.80},
    {'cutstone',   0.10},
    {'trinket_6',  0.05}, -- frayed wires
})

local function makeassetlist(buildname)
    return {
        Asset("ANIM", "anim/"..buildname..".zip"),
        Asset("MINIMAP_IMAGE", "relic"),
    }
end

local function OnDeath(inst)
    --play smash sound
    inst.SoundEmitter:PlaySound(inst.smashsound or "dontstarve/common/destroy_pot")
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.AnimState:PlayAnimation("broken")
    inst.components.lootdropper:DropLoot()
    inst:Remove()
    
end

local function OnRepaired(inst)
    if inst.components.health:GetPercent() >= 1 then
        local player = GetPlayer()
        inst.AnimState:PushAnimation("idle")
        player.components.sanity:DoDelta(TUNING.SANITY_MEDLARGE)
        inst:RemoveComponent("repairable")
        inst.components.inspectable.nameoverride = "relic"
        inst.components.named:SetName(STRINGS.NAMES["RELIC"])
        inst.components.health:SetPercent(1)
        inst.rubble = false
        inst.SoundEmitter:PlaySound("dontstarve/common/fixed_stonefurniture")
    else
        inst.SoundEmitter:PlaySound("dontstarve/common/repair_stonefurniture")        
        inst.AnimState:PlayAnimation("repair")
        inst.AnimState:PushAnimation("broken")
    end
end

-- local function HealthDelta(inst,old,new)
--     if inst.components.health.currenthealth <= 1 then
--         OnDeath(inst)
--     end
-- end

local function OnHit(inst)
    if not inst.rubble and inst.components.health:GetPercent() >= .5 then
        inst.AnimState:PlayAnimation("hit")
    end
end

local function OnLoad(inst, data)
    if not data then
        return
    end
	inst.rubble = data.rubble
	if not inst.rubble then
        inst.components.inspectable.nameoverride = "relic"
        inst.components.named:SetName(STRINGS.NAMES["RELIC"])
        if inst.components.health:GetPercent() >= .5 then
            inst.AnimState:PlayAnimation("idle")
        else
            inst.AnimState:PlayAnimation("broken")
        end
        if inst.components.repairable then
            inst:RemoveComponent("repairable")
        end
	end
end

local function OnSave(inst, data)
	if inst.rubble then
		data.rubble = inst.rubble
	end
end

local function makefn(name, asset, smashsound, rubble, tag)
    local function fn()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        
        local minimap = inst.entity:AddMiniMapEntity()
        minimap:SetIcon("relic.png")

        MakeObstaclePhysics(inst, .25)   

        anim:SetBank(asset)
        anim:SetBuild(asset)

        inst.rubble = rubble
        inst.rubbleName = name

        if rubble then
            anim:PlayAnimation("broken")
        else
            anim:PlayAnimation("idle")
        end

        inst.OnLoad = OnLoad
        inst.OnSave = OnSave

        inst:AddComponent("combat")
		inst.components.combat.onhitfn = OnHit

        inst:AddComponent("health")
        inst.components.health.canmurder = false
        --inst.components.health.ondelta = HealthDelta
        --inst.components.health:SetMinHealth(1)

        inst:ListenForEvent("death", OnDeath)

        inst.components.health:SetMaxHealth(GetRandomWithVariance(90,20))

        inst:AddTag("smashable")
        inst:AddTag("object")

        if tag then
            inst:AddTag(tag)
        end
        -- inst:ListenForEvent("death", OnDeath)

        inst:AddComponent("lootdropper")
        if not string.find(name,"bowl") and not string.find(name,"plate") then
            if string.find(name,"vase") then
                local trinket = GetRandomItem({"tinket_1","trinket_3","trinket_9","tinket_12","tinket_6"})
                inst.components.lootdropper:AddChanceLoot(trinket          , 0.10)

                inst.components.lootdropper.numrandomloot = 1
                inst.components.lootdropper.chancerandomloot = 0.05  -- drop some random item X% of the time
                inst.components.lootdropper:AddRandomLoot("silk"           , 0.1) -- Weighted average
                inst.components.lootdropper:AddRandomLoot(trinket          , 0.1)
                inst.components.lootdropper:AddRandomLoot("thulecite"      , 0.1)
                inst.components.lootdropper:AddRandomLoot("sewing_kit"     , 0.1)
                inst.components.lootdropper:AddRandomLoot("spider_hider"   , 0.05)
                inst.components.lootdropper:AddRandomLoot("spider_spitter" , 0.05)
                inst.components.lootdropper:AddRandomLoot("monkey"         , 0.05)
                if GetWorld() and GetWorld():IsCave() and GetWorld().topology.level_number == 2 then  -- ruins
                    inst.components.lootdropper:AddChanceLoot("thulecite"  , 0.05)
                end
            else
                inst.components.lootdropper:SetChanceLootTable('smashables')
                inst.components.lootdropper.numrandomloot = 1
                inst.components.lootdropper.chancerandomloot = 0.01  -- drop some random item 1% of the time
                inst.components.lootdropper:AddRandomLoot("gears"         , 0.01)
                inst.components.lootdropper:AddRandomLoot("greengem"      , 0.01)
                inst.components.lootdropper:AddRandomLoot("yellowgem"     , 0.01)
                inst.components.lootdropper:AddRandomLoot("orangegem"     , 0.01)
                inst.components.lootdropper:AddRandomLoot("nightmarefuel" , 0.01)
                if GetWorld() and GetWorld():IsCave() and GetWorld().topology.level_number == 2 then  -- ruins
                    inst.components.lootdropper:AddRandomLoot("thulecite" , 0.02)
                end
            end
        end
	
        inst:AddComponent("inspectable")
        inst:AddComponent("named")

        if rubble then
            inst.components.health:SetPercent(.2)
            inst.components.inspectable.nameoverride = "ruins_rubble"
            inst.components.named:SetName(STRINGS.NAMES["RUINS_RUBBLE"])

		    inst:AddComponent("repairable")
            inst.components.repairable.repairmaterial = "stone"
            inst.components.repairable.onrepaired = OnRepaired
        else
            inst.components.health:SetPercent(.8)
            inst.components.inspectable.nameoverride = "relic"
            inst.components.named:SetName(STRINGS.NAMES["RELIC"])
        end

        inst:AddComponent("workable")
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable.savestate = true
        inst.components.workable:SetOnFinishCallback(OnDeath)
	    inst.components.workable:SetWorkAction(ACTIONS.MINE)
		inst.components.workable:SetOnWorkCallback(OnHit) 

        if smashsound then
            inst.smashsound = smashsound
        end
        return inst
    end
    return fn
end    

local function item(name, sound)
    return Prefab( "cave/objects/smashables/"..name, makefn(name, name, sound, false), makeassetlist(name), prefabs )
end
local function rubble(name, assetname, sound, rubble)
    return Prefab( "cave/objects/smashables/"..name, makefn(name, assetname, sound, rubble), makeassetlist(assetname), prefabs )
end
    
return  item("ruins_plate"),
        item("ruins_bowl"),
        item("ruins_chair", "dontstarve/wilson/rock_break"),
        item("ruins_chipbowl"),
        item("ruins_vase"),
        item("ruins_table", "dontstarve/wilson/rock_break"),
        rubble("ruins_rubble_table", "ruins_table", "dontstarve/wilson/rock_break", true, "stone"),
        rubble("ruins_rubble_chair", "ruins_chair", "dontstarve/wilson/rock_break", true, "stone"),
        rubble("ruins_rubble_vase",  "ruins_vase",  nil, true, "stone")

