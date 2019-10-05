
local function makeassetlist(bankname, buildname)
    return {
        Asset("ANIM", "anim/"..buildname..".zip"),
        Asset("ANIM", "anim/"..bankname..".zip"),
    }
end

local function makefn(bankname, buildname, animname)
    local function fn(Sim)
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        inst:AddTag("DECOR")
        
        anim:SetBank(bankname)
        anim:SetBuild(buildname)
        anim:PlayAnimation(animname)
        
        return inst
    end
    return fn
end    


local function item(name, bankname, buildname, animname)
    return Prefab( "forest/objects/farmdecor/"..name, makefn(bankname, buildname, animname), makeassetlist(bankname, buildname) )
end
    
return item("farmrock", "farm_decor", "farm_decor", "1"),
	   item("farmrocktall", "farm_decor", "farm_decor", "2"),
	   item("farmrockflat", "farm_decor", "farm_decor", "8"),
	   item("stick", "farm_decor", "farm_decor", "3"),
	   item("stickright", "farm_decor", "farm_decor", "6"),
	   item("stickleft", "farm_decor", "farm_decor", "7"),
	   item("signleft", "farm_decor", "farm_decor", "4"),
	   item("fencepost", "farm_decor", "farm_decor", "5"),
	   item("fencepostright", "farm_decor", "farm_decor", "9"),
	   item("signright", "farm_decor", "farm_decor", "10") 
