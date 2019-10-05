local assets=
{
	Asset("ANIM", "anim/pig_king.zip"),
	Asset("SOUND", "sound/pig.fsb"),
}


local prefabs = 
{
	"goldnugget",
}

local function OnGetItemFromPlayer(inst, giver, item)
    if item.components.tradable.goldvalue > 0 then
        inst.AnimState:PlayAnimation("cointoss")
        inst.AnimState:PushAnimation("happy")
        inst.AnimState:PushAnimation("idle", true)
        inst:DoTaskInTime(20/30, function() 
            inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingThrowGold")
            
            for k = 1, item.components.tradable.goldvalue do
                local nug = SpawnPrefab("goldnugget")
                local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,4.5,0)
                
                nug.Transform:SetPosition(pt:Get())
                local down = TheCamera:GetDownVec()
                local angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
                --local angle = (-TUNING.CAM_ROT-90 + math.random()*60-30)/180*PI
                local sp = math.random()*4+2
                nug.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
            end
        end)
        inst:DoTaskInTime(1.5, function() 
            inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingHappy")
        end)
        inst.happy = true
        if inst.endhappytask then
            inst.endhappytask:Cancel()
        end
        inst.endhappytask = inst:DoTaskInTime(5, function()
            inst.happy = false
            inst.endhappytask = nil
        end)
    end
end

local function OnRefuseItem(inst, giver, item)
	inst.SoundEmitter:PlaySound("dontstarve/pig/PigKingReject")
    inst.AnimState:PlayAnimation("unimpressed")
	inst.AnimState:PushAnimation("idle", true)
	inst.happy = false
end

local function fn(Sim)
    
	local inst = CreateEntity()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon( "pigking.png" )
	minimap:SetPriority( 1 )

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.DynamicShadow:SetSize( 10, 5 )
    
    MakeObstaclePhysics(inst, 2, .5)
    --inst.Transform:SetScale(1.5,1.5,1.5)
    
    inst:AddTag("king")
    inst.AnimState:SetBank("Pig_King")
    inst.AnimState:SetBuild("Pig_King")
    inst.AnimState:PlayAnimation("idle", true)
    
    inst:AddComponent("inspectable")

    inst:AddComponent("trader")

	inst.components.trader:SetAcceptTest(
		function(inst, item)
			return item.components.tradable.goldvalue > 0
		end)

    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem

	inst:ListenForEvent( "nighttime", function(global, data)  
        inst.components.trader:Disable()
        inst.AnimState:PlayAnimation("sleep_pre")
        inst.AnimState:PushAnimation("sleep_loop", true)    
    end, GetWorld())
    
	inst:ListenForEvent( "daytime", function(global, data)
        inst.components.trader:Enable()
        inst.AnimState:PlayAnimation("sleep_pst")
        inst.AnimState:PushAnimation("idle", true)    
    end, GetWorld())
    
    return inst
end

return Prefab( "common/objects/pigking", fn, assets, prefabs) 
