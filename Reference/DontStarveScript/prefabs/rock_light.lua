require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/rock_light.zip"),
}

local prefabs =
{
    "character_fire",
}    

local MAXWORK = 6
local MEDIUM  = 4
local LOW     = 2

local function SetWorkLevel( inst, workleft )
    dprint(string.format("SetWORKLEVEL: left=%d, state=%d",workleft,inst.state))
    if inst.exploding then
        return
    end
    if workleft == MAXWORK and inst.state == MEDIUM then
        inst.state = MAXWORK
        dprint("MED -> MAX")
        inst.AnimState:PlayAnimation("med_grow")
        inst.components.fueled:MakeEmpty()
    elseif workleft <= MEDIUM and inst.state == MAXWORK then
        inst.state = MEDIUM
        dprint("MAX -> MED")
	    inst.AnimState:PlayAnimation("med")
        inst.components.fueled:ChangeSection(1)
        inst.components.fueled:StartConsuming()
    elseif workleft <= MEDIUM and inst.state == LOW then
        inst.state = MEDIUM
        dprint("LOW -> MED")
        inst.AnimState:PlayAnimation("low_grow")
    elseif workleft <= LOW and inst.state == MEDIUM then
        dprint("MED -> LOW")
        inst.state = LOW
	    inst.AnimState:PlayAnimation("low")
        inst.components.fueled:ChangeSection(1)
    end
    if workleft < 0 then
        inst.components.workable.workleft = 0
    end
end

local function onhammered(inst, worker)
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
    SetWorkLevel( inst, 0 )
end

local function onhit(inst, worker, workleft)
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
    SetWorkLevel( inst, workleft )
end

local function onignite(inst)
end

local function onextinguish(inst)
    if inst.components.fueled then
        inst.components.fueled:MakeEmpty()
    end
end


local function getsanityaura(inst, observer)
    local lightRadius = inst.components.burnable and inst.components.burnable:GetLargestLightRadius()
    if lightRadius and inst:GetDistanceSqToInst(observer) < 0.5*lightRadius then
        local clock = GetNightmareClock()
        if clock and clock:IsCalm() then
            return -TUNING.SANITY_SMALL
        else
            return TUNING.SANITY_SMALL
        end
    end
    return 0
end

local function DoShake(inst)
 --           :Shake(shakeType, duration, speed, scale)
    TheCamera:Shake("FULL", 3.0, 0.05, .2)
end

local function SealUp(rock)
    dprint("SealUp:",rock)
    rock.exploding = false
    rock.components.workable:SetWorkLeft(MAXWORK)
end


function ExplodeRock(rock)
    dprint("Explode:",rock)
    if rock.components.workable.workleft < MAXWORK then
        rock.blastTask = rock:DoTaskInTime(GetRandomWithVariance(120,60), ExplodeRock)
        return
    end
    local x,y,z = rock.Transform:GetWorldPosition()

    rock.exploding = true
    y = y + 2
    rock.lavaLight = SpawnPrefab("lavalight").Transform:SetPosition(x,y,z)
    SpawnPrefab("explode_small").Transform:SetPosition(x,y,z)
    rock.AnimState:PlayAnimation("low")
    DoShake(rock)
    rock:DoTaskInTime(5,SealUp)
end

local function fn(Sim)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

	--local minimap = inst.entity:AddMiniMapEntity()
	--minimap:SetIcon( "rock_light.png" )
	--minimap:SetPriority( 1 )

    anim:SetBuild("rock_light")
    anim:SetBank("rock_light")
    anim:PlayAnimation("full",false)
    inst:AddTag("rocklight")
    inst:AddTag("structure")
    inst:AddTag("stone")
  
    MakeObstaclePhysics(inst, 1)    
    inst.Transform:SetScale(1.0,1.0,1.0)

    -----------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = getsanityaura

    -----------------------
    inst:AddComponent("burnable")
    --inst.components.burnable:SetFXLevel(0,0)
    --  campfirefire character_fire  maxwelllight_flame nightlight_flame
    inst.components.burnable:AddBurnFX("character_fire", Vector3(0,1,0) )
    inst:ListenForEvent("onextinguish", onextinguish)
    inst:ListenForEvent("onignite", onignite)
    
    -------------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(MAXWORK)
    inst.components.workable:SetMaxWork(MAXWORK)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)    

    -------------------------
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = 30  -- TUNING.ROCKLIGHT_FUEL_MAX
    inst.components.fueled.accepting = false
    inst.components.fueled:SetSections(2)
    inst.components.fueled:InitializeFuelLevel(0)
    -- inst.components.fueled.bonusmult = TUNING.FIREPIT_BONUS_MULT
    -- inst.components.fueled.ontakefuelfn = function() inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel") end
    
    inst.components.fueled:SetUpdateFn( function()
        if inst.components.burnable and inst.components.fueled then
            dprint("fuel Update:", inst.components.fueled:GetCurrentSection()," %=", inst.components.fueled:GetSectionPercent())
            inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
        end
    end)
        
    inst.components.fueled:SetSectionCallback( function(section,oldsection)
        dprint(string.format("SectionCallback: old=%d, new=%d, perc=%f",oldsection, section, inst.components.fueled:GetSectionPercent()))
        if section == 0 then
            inst.components.burnable:Extinguish() 
            inst:DoTaskInTime(2, function(inst)
                                     inst.components.workable:SetWorkLeft(MAXWORK)
                                     SetWorkLevel( inst, MAXWORK )
	                                 --inst.AnimState:PlayAnimation("med_grow")
                                     inst.components.burnable:SetFXLevel(0,0) 
                                 end)  
        else
            inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent())
            --if not inst.components.burnable:IsBurning() then
            --    inst.components.burnable:Ignite()
            --end
            if section == 1 then
                SetWorkLevel( inst, MEDIUM )
                if oldsection == 2 then 
                    inst.components.workable:SetWorkLeft(MEDIUM)
                end
            elseif section == 2 then
                inst.components.workable:SetWorkLeft(LOW)
                SetWorkLevel( inst, LOW )
            end
        end
        inst.prev = section
    end)
        
    -----------------------------
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        local sec = inst.components.fueled:GetCurrentSection()
        dprint("get rock status:",sec)
        if sec == 0 then 
            return "OUT"
        elseif sec <= 2 then
            local t = {"LOW","NORMAL","HIGH"}
            return t[sec]
        end
    end
    
    -----------------------------

    inst.blastTask = inst:DoTaskInTime(GetRandomWithVariance(120,60), ExplodeRock)
    inst.state = MAXWORK

    -----------------------------

    return inst
end

return Prefab( "common/objects/rock_light", fn, assets, prefabs)

