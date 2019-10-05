local assets = 
{
	Asset("ANIM", "anim/marble_pillar.zip"),
}

local prefabs =
{
	"marble",
}

SetSharedLootTable( 'marble_pillar',
{
    {'marble', 1.00},
    {'marble', 1.00},
    {'marble', 0.33},
})

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	MakeObstaclePhysics(inst, 1)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable('marble_pillar')

	anim:SetBank("marble_pillar")
	anim:SetBuild("marble_pillar")
	anim:PlayAnimation("full")


	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon( "marblepillar.png" )

	inst:AddComponent("inspectable")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.MARBLEPILLAR_MINE)
	inst.components.workable:SetOnWorkCallback(          
		function(inst, worker, workleft)
	        local pt = Point(inst.Transform:GetWorldPosition())
	        if workleft <= 0 then
				inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
	            inst.components.lootdropper:DropLoot(pt)
	            inst:Remove()
	        else	            
	            if workleft < TUNING.MARBLEPILLAR_MINE*(1/3) then
	                inst.AnimState:PlayAnimation("low")
	            elseif workleft < TUNING.MARBLEPILLAR_MINE*(2/3) then
	                inst.AnimState:PlayAnimation("med")
	            else
	                inst.AnimState:PlayAnimation("full")
	            end
	        end
	    end)

	MakeSnowCovered(inst, 0.1)
	return inst
end

return Prefab("forest/objects/marblepillar", fn, assets, prefabs) 
