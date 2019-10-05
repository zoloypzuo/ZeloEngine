local assets=
{
	Asset("ANIM", "anim/trap_teeth.zip"),
	Asset("ANIM", "anim/trap_teeth_maxwell.zip"),
	Asset("INV_IMAGE", "trap_teeth"),
	Asset("MINIMAP_IMAGE", "toothtrap"),
}


local function onfinished_normal(inst)
    inst:RemoveComponent("inventoryitem")
    inst:RemoveComponent("mine")
    inst.persists = false
    inst.AnimState:PushAnimation("used", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:DoTaskInTime(3, function() inst:Remove() end )
end

local function onfinished_maxwell(inst)
    inst:RemoveComponent("mine")
    inst.persists = false
	inst:DoTaskInTime(1.25, function()
		inst.AnimState:PlayAnimation("used", false)
		inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
		inst:DoTaskInTime(3, function() inst:Remove() end )
	end)
end

local function OnExplode(inst, target)
    inst.AnimState:PlayAnimation("trap")
    if target then
        inst.SoundEmitter:PlaySound("dontstarve/common/trap_teeth_trigger")
	    target.components.combat:GetAttacked(inst, TUNING.TRAP_TEETH_DAMAGE)
        if METRICS_ENABLED then
			FightStat_TrapSprung(inst,target,TUNING.TRAP_TEETH_DAMAGE)
		end
    end
    if inst.components.finiteuses then
	    inst.components.finiteuses:Use(1)
    end
end

local function OnReset(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/trap_teeth_reset")
	inst.AnimState:PlayAnimation("reset")
	inst.AnimState:PushAnimation("idle", false)
end

local function OnResetMax(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/trap_teeth_reset")
	inst.AnimState:PlayAnimation("idle")
	--inst.AnimState:PushAnimation("idle", false)
end


local function SetSprung(inst)
    inst.AnimState:PlayAnimation("trap_idle")
end

local function SetInactive(inst)
    inst.AnimState:PlayAnimation("inactive")
end

local function OnDropped(inst)
	inst.components.mine:Deactivate()
end

local function ondeploy(inst, pt, deployer)
	inst.components.mine:Reset()
	inst.Physics:Teleport(pt:Get())
end

--legacy save support - mines used to start out activated
local function onload(inst, data)
	if not data or not data.mine then
		inst.components.mine:Reset()
	end
end

local function MakeTeethTrapNormal()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "toothtrap.png" )
   
	anim:SetBank("trap_teeth")
	anim:SetBuild("trap_teeth")
	anim:PlayAnimation("idle")
	
	inst:AddTag("trap")
	
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.nobounce = true
	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
	
	inst:AddComponent("mine")
	inst.components.mine:SetRadius(TUNING.TRAP_TEETH_RADIUS)
	inst.components.mine:SetAlignment("player")
	inst.components.mine:SetOnExplodeFn(OnExplode)
	inst.components.mine:SetOnResetFn(OnReset)
	inst.components.mine:SetOnSprungFn(SetSprung)
	inst.components.mine:SetOnDeactivateFn(SetInactive)
	--inst.components.mine:StartTesting()
	
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.TRAP_TEETH_USES)
	inst.components.finiteuses:SetUses(TUNING.TRAP_TEETH_USES)
	inst.components.finiteuses:SetOnFinished( onfinished_normal )
	
    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable.min_spacing = .75
	
	inst.components.mine:Deactivate()
	inst.OnLoad = onload
	return inst
end

local function MakeTeethTrapMaxwell()
	local inst = MakeTeethTrapNormal()

	inst.AnimState:SetBank("trap_teeth_maxwell")
	inst.AnimState:SetBuild("trap_teeth_maxwell")

	inst:RemoveComponent("inventoryitem")

	inst.components.mine:SetAlignment("nobody")
	inst.components.mine:SetOnResetFn(OnResetMax)
	inst.components.finiteuses:SetMaxUses(1)
	inst.components.finiteuses:SetUses(1)
	inst.components.finiteuses:SetOnFinished( onfinished_maxwell )
	
	inst.components.mine:Reset()
	inst.AnimState:PlayAnimation("idle")

	return inst
end

return Prefab( "common/inventory/trap_teeth", MakeTeethTrapNormal, assets),
		MakePlacer("common/trap_teeth_placer", "trap_teeth", "trap_teeth", "idle"),
	   Prefab( "common/inventory/trap_teeth_maxwell", MakeTeethTrapMaxwell, assets) 

