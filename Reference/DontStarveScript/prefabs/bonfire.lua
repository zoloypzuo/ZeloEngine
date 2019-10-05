local assets =
{
	Asset("ANIM", "anim/bonfire.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local INTENSITY = 16

local function FadeIn( inst )
	local sin = math.sin
	local min = math.min

	local fade_time = 4
	local start_tick = TheSim:GetTick()
	local tick_time = TheSim:GetTickTime()
    inst.Light:Enable(true)
	while true do
		local tick = GetTick()
		local flicker = ( sin( tick ) + sin( tick + 2 ) + sin( tick + 0.7777 ) ) / 3.0 -- range = [-1 , 1]
		flicker = ( 1.0 + flicker ) / 2.0 -- range = 0:1
		
		local lerp = min( 1, ( 1 + TheSim:GetTick() - start_tick ) * tick_time / fade_time )
		flicker = lerp * flicker

		inst.Light:SetFalloff( 0.05 * flicker + 0.4 )

		Sleep(0.1)
	end
end

local function FadeOut( inst )
	local sin = math.sin
	local min = math.min

	local fade_time = 6
	local start_tick = TheSim:GetTick()
	local tick_time = TheSim:GetTickTime()

	local fully_lerped = false

	while true do
		local tick = GetTick()
		local flicker = ( sin( tick ) + sin( tick + 2 ) + sin( tick + 0.7777 ) ) / 3.0 -- range = [-1 , 1]
		flicker = ( 1.0 + flicker ) / 2.0 -- range = 0:1

		local lerp = min( 1, ( 1 + TheSim:GetTick() - start_tick ) * tick_time / fade_time )
		flicker = ( 1.0 - lerp ) * flicker
		
		inst.Light:SetFalloff( 0.05 * flicker + 0.4 + lerp * 20 )

		Sleep(0.1)

		if lerp == 1 then
			fully_lerped = true
			inst.AnimState:PlayAnimation( "off" )
			inst:RemoveTag(ITEMTAG.FIRE)
			inst.Light:SetIntensity(0)
			inst.SoundEmitter:KillSound( "burning")
            inst.Light:Enable(false)
			break
		end
	end
end

local function StartDay( inst )
	if inst.light_task ~= nil then
		KillThread( inst.light_task )
	end
	inst.light_task = inst:StartThread( function() FadeOut( inst ) end )
end

local function StartNight( inst )
	if inst.light_task ~= nil then
		KillThread( inst.light_task )
	end
	inst.light_task = inst:StartThread( function() FadeIn( inst ) end )
	inst.AnimState:PlayAnimation( "on", true )
    inst:AddTag(ITEMTAG.FIRE)
    inst.Light:SetIntensity(INTENSITY)
    inst.SoundEmitter:PlaySound("dontstarve/common/campfire", "burning")
end
 
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	local light = inst.entity:AddLight()
	local sound = inst.entity:AddSoundEmitter()

    
    MakeObstaclePhysics(inst, .3)    
    
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "village.png" )

	inst.Light:SetIntensity(INTENSITY)
	inst.Light:SetColour(222/255,197/255,103/255);
	inst.Light:Enable(false)
    
    inst:AddComponent("cooker")

    inst:AddTag("bonfire")
    anim:SetBank("bonfire")
    anim:SetBuild("bonfire")
	anim:PlayAnimation("off")

	local local_inst = inst
	inst:ListenForEvent( "daytime", function(inst, data) StartDay( local_inst ) end, GetWorld())
	inst:ListenForEvent( "nighttime", function(inst, data) StartNight( local_inst ) end, GetWorld())

    return inst
end

return Prefab( "common/objects/bonfire", fn, assets) 

