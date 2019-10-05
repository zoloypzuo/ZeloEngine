local assets=
{
	Asset("ANIM", "anim/penguin_ice.zip"),
}

local SNOW_THRESH = 0.10


local function OnErodeEnd(inst,dir)
    if dir == "IN" then
        inst.faded = false
        inst.AnimState:SetErosionParams( 0.0, 0.1, 1.0 )
    else
        inst.faded = true
        inst.AnimState:SetErosionParams( 1.0, 0.1, 1.0 )
    end
end


local function OnFaderEnd(inst,val)
    if val <= 0 then
        inst.faded = false
        inst.AnimState:SetErosionParams( 0.0, 0.1, 1.0 )
    else
        inst.faded = true
        inst.AnimState:SetErosionParams( 1.0, 0.1, 1.0 )
        inst.persists = false
        inst:Remove()
    end
end

local function Eroder(inst,time,direction,OnEndFunction)

    if not inst.AnimState then
        return
    end

    if inst.eroder and inst.eroder.dir == direction then
        dprint("repeat eroder")
        return
    end

    dprint("_______________________ ERODER:",inst,time,direction,"\n")

	local time_to_erode = time or 15
	local tick_time = TheSim:GetTickTime()
    local startTick = 0
    local thread
    
	if inst.DynamicShadow then
        inst.DynamicShadow:Enable(false)
    end

    if inst.eroder then
        local t = inst.eroder
        if t.thread then
            KillThread(t.thread)
            startTick =  t.erode_amount  / (tick_time / time_to_erode)
            dprint("KILLING THREAD:",t.thread," NewStart=",startTick," erode=",t.erode_amount)
        end
    end

    inst.eroder = { startTick = startTick, dir = direction, erode_amount = 0, thread = nil, EndFn = OnEndFunction }

	thread = inst:StartThread( function()
                                    local info = inst.eroder
                                    local ticks = info.startTick or 0
                                    local dir = info.dir or "IN"

                                    dprint("New Thread",ticks)
                                    while ticks * tick_time < time_to_erode do
                                        local erode_amount = ticks * tick_time / time_to_erode
                                        if dir == "IN" then
                                            erode_amount = 1 - erode_amount
                                        end
                                        if info.erode_amount then
                                            info.erode_amount = erode_amount
                                        end

                                        IOprint("\rFADER:",inst,string.format("   %.2f  ",erode_amount))
                                        inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
                                        ticks = ticks + 1
                                        Yield()
                                    end
                                    if type(info.EndFn) == "function" then
                                        info.EndFn(inst,dir)
                                    end
                                    dprint("\nERODER done:",inst)
                                    if info then
                                        inst.eroder = nil
                                    end
                                end)
    inst.eroder.thread = thread
end

local function OnEntityWake(inst)
    dprint("ENTITY WAKE",inst)
    if GetSeasonManager():IsSummer() then
        inst.faded = true
        inst.AnimState:SetErosionParams( 1.0, 0.1, 1.0 )
        inst.persists = false
        inst:Remove()
        return
    end
    local snow_cover = GetSeasonManager():GetSnowPercent()

    if snow_cover > SNOW_THRESH then
        inst.faded = false
        inst.AnimState:SetErosionParams( 0.0, 0.1, 1.0 )
    else
        inst.faded = true
        inst.AnimState:SetErosionParams( 1.0, 0.1, 1.0 )
    end
end

local function OnEntitySleep(inst)
    dprint("ENTITY SLEEP",inst)
    inst.components.fader:StopAll()

    if inst.eroder then
        local t = inst.eroder
        if t.thread then
            KillThread(t.thread)
            if type(t.EndFn) == "function" then
                t.EndFn(inst,t.dir)
            end
        end
    end
    if GetSeasonManager():IsSummer() then
        inst.faded = true
        inst.AnimState:SetErosionParams( 1.0, 0.1, 1.0 )
        inst.persists = false
        inst:Remove()
    end
end

local function fn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.AnimState:SetBank("penguin_ice")
    inst.AnimState:SetBuild("penguin_ice")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 1 )
    inst.AnimState:SetErosionParams( 1.0, 0.1, 1.0 )

    inst:AddComponent("fader")

    inst.faded = true

    inst:AddTag("NOCLICK")

    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "penguin.png" )

    local function SnowCover(source)
        local snow_cover = GetSeasonManager():GetSnowPercent()
        dprint("snowcoverchange",string.format("%d",snow_cover*100))
        local Erode = function(val,inst)
                        IOprint(string.format("\r erode: %d : ",val*100))
                        inst.AnimState:SetErosionParams( val, 0.1, 1.0 )
                        end

        if snow_cover > SNOW_THRESH then
            -- Eroder(inst,time,dir,onEndFunction)
            if inst.faded and not (inst.components.fader.numvals > 0) then
                --   Fader:Fade( startval, endval, time, setter, atend )
                inst.components.fader:Fade( 1.0,      0,      5,     Erode, OnFaderEnd )
                --Eroder(inst,15,"IN",OnErodeEnd)
            end
        else
            if not inst.faded and not (inst.components.fader.numvals > 0) then
                inst.components.fader:Fade(0,1,5, Erode, OnFaderEnd)
                --Eroder(inst,15,"OUT",OnErodeEnd)
            end
        end
    end

	inst:ListenForEvent( "daytime", SnowCover, GetWorld() )
	inst:ListenForEvent("snowcoverchange", SnowCover, GetWorld())

    inst.persists = true

    return inst
end

return Prefab( "forest/objects/penguin_ice", fn, assets ) 

