require "prefabutil"

local cooking = require("cooking")

local assets=
{
	Asset("ANIM", "anim/cook_pot.zip"),
	Asset("ANIM", "anim/cook_pot_food.zip"),
}

local prefabs = {"collapse_small"}
for k,v in pairs(cooking.recipes.cookpot) do
	table.insert(prefabs, v.name)
end

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	if not inst:HasTag("burnt") and inst.components.stewer and inst.components.stewer.product and inst.components.stewer.done then
		inst.components.lootdropper:AddChanceLoot(inst.components.stewer.product, 1)
	end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit_empty")
		
		if inst.components.stewer.cooking then
			inst.AnimState:PushAnimation("cooking_loop")
		elseif inst.components.stewer.done then
			inst.AnimState:PushAnimation("idle_full")
		else
			inst.AnimState:PushAnimation("idle_empty")
		end
	end
end

local slotpos = {	Vector3(0,64+32+8+4,0), 
					Vector3(0,32+4,0),
					Vector3(0,-(32+4),0), 
					Vector3(0,-(64+32+8+4),0)}

local widgetbuttoninfo = {
	text = STRINGS.ACTIONS.COOK.GENERIC,
	position = Vector3(0, -165, 0),
	fn = function(inst)
		inst.components.stewer:StartCooking()	
	end,
	
	validfn = function(inst)
		return inst.components.stewer:CanCook()
	end,
}

local function itemtest(inst, item, slot)
	if not inst:HasTag("burnt") then
		if cooking.IsCookingIngredient(item.prefab) then
			return true
		end
	end
end

--anim and sound callbacks

local function ShowProduct(inst)
	if not inst:HasTag("burnt") then
		local product = inst.components.stewer.product
	    if IsModCookingProduct(inst.prefab, product) then
	        inst.AnimState:OverrideSymbol("swap_cooked", product, product)
	    else
			inst.AnimState:OverrideSymbol("swap_cooked", "cook_pot_food", product)
		end
	end
end

local function startcookfn(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("cooking_loop", true)
		--play a looping sound
		inst.SoundEmitter:KillSound("snd")
		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
		inst.Light:Enable(true)
	end
end


local function onopen(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("cooking_pre_loop", true)
		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open", "open")
		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot", "snd")
	end
end

local function onclose(inst)
	if not inst:HasTag("burnt") then
		if not inst.components.stewer.cooking then
			inst.AnimState:PlayAnimation("idle_empty")
			inst.SoundEmitter:KillSound("snd")
		end
		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close", "close")
	end
end

local function spoilfn(inst)
	if not inst:HasTag("burnt") then
		inst.components.stewer.product = inst.components.stewer.spoiledproduct
		ShowProduct(inst)
	end
end

local function donecookfn(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("cooking_pst")
		inst.AnimState:PushAnimation("idle_full")
		ShowProduct(inst)
		inst.SoundEmitter:KillSound("snd")
		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish", "snd")
		inst.Light:Enable(false)
		--play a one-off sound
	end
end

local function continuedonefn(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("idle_full")
		ShowProduct(inst)
	end
end

local function continuecookfn(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("cooking_loop", true)
		--play a looping sound
		inst.Light:Enable(true)

		inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
	end
end

local function harvestfn(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("idle_empty")
	end
end

local function getstatus(inst)
	if inst:HasTag("burnt") then
		return "BURNT"
	elseif inst.components.stewer.cooking and inst.components.stewer:GetTimeToCook() > 15 then
		return "COOKING_LONG"
	elseif inst.components.stewer.cooking then
		return "COOKING_SHORT"
	elseif inst.components.stewer.done then
		return "DONE"
	else
		return "EMPTY"
	end
end

local function onfar(inst)
	if inst.components.container then
		inst.components.container:Close()
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle_empty")
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/cook_pot")
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
	if data and data.burnt then
        inst.components.burnable.onburnt(inst)
        inst.Light:Enable(false)
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "cookpot.png" )
	
    local light = inst.entity:AddLight()
    inst.Light:Enable(false)
	inst.Light:SetRadius(.6)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235/255,62/255,12/255)
    --inst.Light:SetColour(1,0,0)
    
    inst:AddTag("structure")
    MakeObstaclePhysics(inst, .5)
    
    inst.AnimState:SetBank("cook_pot")
    inst.AnimState:SetBuild("cook_pot")     
    inst.AnimState:PlayAnimation("idle_empty")

    inst:AddComponent("stewer")
    inst.components.stewer.onstartcooking = startcookfn
    inst.components.stewer.oncontinuecooking = continuecookfn
    inst.components.stewer.oncontinuedone = continuedonefn
    inst.components.stewer.ondonecooking = donecookfn
    inst.components.stewer.onharvest = harvestfn
    inst.components.stewer.onspoil = spoilfn
    
    
    
    inst:AddComponent("container")
    inst.components.container.itemtestfn = itemtest
    inst.components.container:SetNumSlots(4)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_cookpot_1x4"
    inst.components.container.widgetanimbuild = "ui_cookpot_1x4"
    inst.components.container.widgetpos = Vector3(200,0,0)
    inst.components.container.side_align_tip = 100
    inst.components.container.widgetbuttoninfo = widgetbuttoninfo
    inst.components.container.acceptsstacks = false
    inst.components.container.type = "cooker"

    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose


    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus


    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerFar(onfar)


    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	MakeSnowCovered(inst, .01)    
	inst:ListenForEvent( "onbuilt", onbuilt)

	MakeMediumBurnable(inst, nil, nil, true)
	MakeSmallPropagator(inst)

	inst.OnSave = onsave 
   	inst.OnLoad = onload

    return inst
end

return Prefab( "common/cookpot", fn, assets, prefabs),
		MakePlacer( "common/cookpot_placer", "cook_pot", "cook_pot", "idle_empty" ) 
