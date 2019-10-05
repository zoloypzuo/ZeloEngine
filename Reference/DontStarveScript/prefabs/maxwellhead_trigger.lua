--This prefab is an empty object. The only function it serves is to spawn a maxwell head
--when the player approaches and tell that head which speech to say.

local assets = {}

local prefabs = 
{
	"maxwellhead",
}

local function onnear(inst)
	--spawn head, kill self.
	local pt = Vector3(inst.Transform:GetWorldPosition())
	local maxhead = SpawnPrefab("maxwellhead")	
	maxhead.components.maxwelltalker:SetSpeech(inst.speech)
	maxhead.Transform:SetPosition(pt.x, pt.y, pt.z)
	inst:Remove()
end

local function onload(inst, data)	
	if data then		
		if data.speech then			
			inst.speech = data.speech
		end
	end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(13, 15)	
	inst.components.playerprox:SetOnPlayerNear(onnear)
	inst.OnLoad = onload
	return inst
end

return Prefab("forest/objects/maxwellhead_trigger", fn, assets, prefabs) 