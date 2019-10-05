local function makeassetlist(name)
    return {
        Asset("ANIM", "anim/"..name..".zip")
    }
end

local function makefn(name, collide)
    local fn = function()
    	local inst = CreateEntity()
    	inst.entity:AddTransform()
    	inst.entity:AddAnimState()
        if collide then
            MakeObstaclePhysics(inst, 2.75)
        end
        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle", true)
        
        return inst
    end

    return fn
end

local function pillar(name, collide)
    return Prefab( "cave/objects/"..name, makefn(name, collide), makeassetlist(name)) 
end

return pillar("pillar_ruins", true), pillar("pillar_algae", true), pillar("pillar_cave", true), pillar("pillar_stalactite")
