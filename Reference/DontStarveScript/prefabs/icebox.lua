require "prefabutil"

local assets=
{
	Asset("ANIM", "anim/ice_box.zip"),
	Asset("ANIM", "anim/ui_chest_3x3.zip"),
	
}

local function onopen(inst) 
	inst.AnimState:PlayAnimation("open") 
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/icebox_open")	
end 

local function onclose(inst) 
	inst.AnimState:PlayAnimation("close") 
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/icebox_close")		
end 

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	inst.components.container:DropEverything()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.components.container:DropEverything()
	inst.AnimState:PushAnimation("closed", false)
	inst.components.container:Close()
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/ice_box")
end

local slotpos = {}

for y = 2, 0, -1 do
	for x = 0, 2 do
		table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
	end
end

local function itemtest(inst, item, slot)
	return (item.components.edible and item.components.perishable) or item.prefab == "spoiled_food" or item.prefab == "rottenegg"
end

		
local function fn(Sim)
	local inst = CreateEntity()
	
	inst:AddTag("fridge")
    inst:AddTag("structure")
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "icebox.png" )
	
    inst.AnimState:SetBank("icebox")
    inst.AnimState:SetBuild("ice_box")
    inst.AnimState:PlayAnimation("closed")
    
    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container.itemtestfn = itemtest
    inst.components.container:SetNumSlots(#slotpos)
    
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 160
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit) 
	
    inst:ListenForEvent( "onbuilt", onbuilt)
	MakeSnowCovered(inst, .01)	
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/icebox_LP", "loop")
    return inst
end

return Prefab( "common/icebox", fn, assets),
		MakePlacer("common/icebox_placer", "icebox", "ice_box", "closed") 

