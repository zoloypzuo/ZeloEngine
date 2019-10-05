local assets = 
{
	Asset("ANIM", "anim/resurrection_stone.zip"),
	Asset("MINIMAP_IMAGE", "resurrection_stone"),
}

local prefabs =
{
	"rocks",
	"marble",
	"nightmarefuel",
}
local function OnActivate(inst)
	inst.components.resurrector.active = true
    ProfileStatsSet("resurrectionstone_activated", true)
	inst.AnimState:PlayAnimation("activate")
	inst.AnimState:PushAnimation("idle_activate", true)
	inst.SoundEmitter:PlaySound("dontstarve/common/resurrectionstone_activate")

	inst.AnimState:SetLayer( LAYER_WORLD )
	inst.AnimState:SetSortOrder( 0 )

	inst.Physics:CollidesWith(COLLISION.CHARACTERS)	
	inst.components.resurrector:OnBuilt()
end

local function makeactive(inst)
	inst.AnimState:PlayAnimation("idle_activate", true)
	inst.components.activatable.inactive = false
end

local function makeused(inst)
	inst.AnimState:PlayAnimation("idle_broken", true)
end

local function doresurrect(inst, dude)
	inst:AddTag("busy")	
	inst.MiniMapEntity:SetEnabled(false)
    if inst.Physics then
		MakeInventoryPhysics(inst) -- collides with world, but not character
    end
    ProfileStatsSet("resurrectionstone_used", true)

	GetClock():MakeNextDay()
    dude.Transform:SetPosition(inst.Transform:GetWorldPosition())
    dude:Hide()
    TheCamera:SetDistance(12)
	dude.components.hunger:Pause()
	
    scheduler:ExecuteInTime(3, function()
        dude:Show()
        --inst:Hide()

        GetSeasonManager():DoLightningStrike(Vector3(inst.Transform:GetWorldPosition()))


		inst.SoundEmitter:PlaySound("dontstarve/common/resurrectionstone_break")
        inst.components.lootdropper:DropLoot()
        inst:Remove()
        
        if dude.components.hunger then
            dude.components.hunger:SetPercent(2/3)
        end

        if dude.components.health then
            dude.components.health:Respawn(TUNING.RESURRECT_HEALTH)
        end
        
        if dude.components.sanity then
			dude.components.sanity:SetPercent(.5)
        end
        
        dude.components.hunger:Resume()
        
        dude.sg:GoToState("wakeup")
        
        
        dude:DoTaskInTime(3, function(inst) 
		            if dude.HUD then
		                dude.HUD:Show()
		            end
		            TheCamera:SetDefault()
		            inst:RemoveTag("busy")

			--SaveGameIndex:SaveCurrent(function()
			--	end)            
        end)
        
    end)
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	MakeObstaclePhysics(inst, 1)
	inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.WORLD)
	inst.Physics:CollidesWith(COLLISION.ITEMS)



	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"rocks","rocks","marble","nightmarefuel","marble"}) 

	anim:SetBank("resurrection_stone")
	anim:SetBuild("resurrection_stone")
	anim:PlayAnimation("idle_off")
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )


	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon( "resurrection_stone.png" )


	inst:AddComponent("resurrector")
	inst.components.resurrector.makeactivefn = makeactive
	inst.components.resurrector.makeusedfn = makeused
	inst.components.resurrector.doresurrect = doresurrect

	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
	inst.components.activatable.inactive = true
	inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()
	return inst
end

return Prefab("forest/objects/resurrectionstone", fn, assets, prefabs) 
