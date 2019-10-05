local function createassets(name)
	local assets = 
	{
		Asset("ANIM", "anim/"..name..".zip"),
        Asset("ANIM", "anim/player_basic.zip"),
        Asset("ANIM", "anim/player_throne.zip")
	}
	return assets
end

local function createpuppet(name)
	local create = function()
	    local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		local sound = inst.entity:AddSoundEmitter()	
		MakeObstaclePhysics(inst, 2)
		inst.Transform:SetFourFaced()
		anim:SetBank("wilson")
		anim:SetBuild(name)
		anim:PlayAnimation("throne_loop", true)
		inst.AnimState:Hide("ARM_carry") 
        inst.AnimState:Show("ARM_normal")
        inst:AddComponent("named")
        inst:AddComponent("inspectable")
        inst.components.named:SetName(STRINGS.CHARACTER_NAMES[name])

			if name == "wilson" or
			name == "woodie" or
			name == "waxwell" or
			name == "wolfgang" or
			name == "wes" then
				inst.components.inspectable.nameoverride = "male_puppet"
			elseif name == "willow" or
			name == "wendy" or
			name == "wickerbottom" then
				inst.components.inspectable.nameoverride = "fem_puppet"
			elseif name == "wx78" then
				inst.components.inspectable.nameoverride = "robot_puppet"
			else
				inst.components.inspectable.nameoverride = "male_puppet"
			end

		return inst
	end
	return create
end

local prefabs = {}

local charlist = GetActiveCharacterList and GetActiveCharacterList() or MAIN_CHARACTERLIST
for i,name in ipairs(charlist) do
	if name ~= "unknown" and name ~= "waxwell" and name ~= "webber" then
		table.insert(prefabs, Prefab("characters/puppet_"..name, createpuppet(name), createassets(name))) 
	end
end
return unpack(prefabs) 
