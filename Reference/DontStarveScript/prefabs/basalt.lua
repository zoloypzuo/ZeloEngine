local assets=
{
	Asset("ANIM", "anim/blocker.zip"),
}

local function onsave(inst, data)
	data.anim = inst.animname
end

local function onload(inst, data)
    if data and data.anim then
        inst.animname = data.anim
	    inst.AnimState:PlayAnimation(inst.animname)
	end
end

local function makebasalt(anims)
    local function fn()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        
        MakeObstaclePhysics(inst, 1.)

        inst.animname = anims[math.random(#anims)]
        anim:SetBank("blocker")
        anim:SetBuild("blocker")
        anim:PlayAnimation(inst.animname)
        local color = 0.5 + math.random() * 0.5
        anim:SetMultColour(color, color, color, 1)
       
        local minimap = inst.entity:AddMiniMapEntity()
        minimap:SetIcon( "basalt.png" )

        inst:AddComponent("inspectable")
        inst.components.inspectable.nameoverride = "BASALT"
	    MakeSnowCovered(inst, .01)        
        return inst
    end
    return fn
end
   
return Prefab("forest/objects/basalt", makebasalt({"block1", "block4", "block2"}), assets),
       Prefab("forest/objects/basalt_pillar", makebasalt({"block3"}), assets) 
