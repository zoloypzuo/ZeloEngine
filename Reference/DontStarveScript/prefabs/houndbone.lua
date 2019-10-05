local assets =
{
    Asset("ANIM", "anim/hound_base.zip"),
}

local names = {"piece1","piece2","piece3","piece4"}

local function onsave(inst, data)
	data.anim = inst.animname
end

local function onload(inst, data)
    if data and data.anim then
        inst.animname = data.anim
	    inst.AnimState:PlayAnimation(inst.animname)
	end
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBuild("hound_base")
    inst.AnimState:SetBank("houndbase")
    inst.animname = names[math.random(#names)]
    inst.AnimState:PlayAnimation(inst.animname)

    inst:AddTag("bone")

    -------------------
    inst:AddComponent("inspectable")
    
	--MakeSnowCovered(inst)
    inst.OnSave = onsave 
    inst.OnLoad = onload 
	return inst
end

return Prefab( "forest/monsters/houndbone", fn, assets) 

