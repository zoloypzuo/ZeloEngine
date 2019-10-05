local assets=
{
	Asset("ANIM", "anim/diviningrod.zip"),
}

local prefabs = 
{
    "diviningrod",
}

local function onpickedfn(inst, picker, loot)
    inst.persists = false
	inst.AnimState:PlayAnimation("idle_empty")
	inst:RemoveComponent("inspectable")
	inst:RemoveTag("diviningrod")
	RemovePhysicsColliders(inst)
	if loot and inst.disabled then
	    loot.disabled = true
	end
	inst:DoTaskInTime(3, function()
	    local tick_time = TheSim:GetTickTime()
	    local time_to_erode = 2
	    inst:StartThread( function()
		    local ticks = 0
		    while ticks * tick_time < time_to_erode do
			    local erode_amount = ticks * tick_time / time_to_erode
			    inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
			    ticks = ticks + 1
			    Yield()
		    end
		    inst:Remove()
	    end)
	end)
end

local function OnSave(inst, data)
    data.disabled = inst.disabled
end

local function OnLoad(inst, data)
	if data then
	    inst.disabled = data.disabled
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeObstaclePhysics(inst, .5)
	inst.entity:AddSoundEmitter()
	
	inst:AddTag("diviningrod")
	inst:AddTag("irreplaceable")
    
    anim:SetBank("diviningrod")
    anim:SetBuild("diviningrod")
    anim:PlayAnimation("idle_full")
    
    inst:AddComponent("inspectable")

    inst:AddComponent("pickable")
    inst.components.pickable:SetUp("diviningrod", nil)
	inst.components.pickable.onpickedfn = onpickedfn
	
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	
    return inst
end


return Prefab( "common/diviningrodstart", fn, assets) 

