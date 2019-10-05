local assets =
{
	--Asset("ANIM", "anim/arrow_indicator.zip"),
}

local prefabs = 
{
    "bird_egg",
}

local function InMood(inst)
    -- dprint("::::::::::::::::::::::::::::::Penguinherd enters egg-laying season")
    if inst.components.periodicspawner then
        inst.components.periodicspawner:Start()
    end
    if inst.components.herd then
        for k,v in pairs(inst.components.herd.members) do
            k:PushEvent("entermood")
        end
    end
end

local function LeaveMood(inst)
    -- dprint("::::::::::::::::::::::::::::::Penguinherd LEAVES egg-laying season")
    if inst.components.periodicspawner then
        inst.components.periodicspawner:Stop()
    end
    if inst.components.herd then
        for k,v in pairs(inst.components.herd.members) do
            k:PushEvent("leavemood")
        end
    end
end

local function AddMember(inst, member)
    if inst.components.mood then
        if inst.components.mood:IsInMood() then
            member:PushEvent("entermood")
        else
            member:PushEvent("leavemood")
        end
    end
end

local function OnEmpty(inst)
    inst:Remove()
end

local function OnFull(inst)
end
   
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    
    inst:AddTag("herd")
    
    inst:AddComponent("herd")
    inst.components.herd:SetMemberTag("penguin")
    inst.components.herd:SetGatherRange(40)
    inst.components.herd:SetUpdateRange(20)
    inst.components.herd:SetOnEmptyFn(OnEmpty)
    inst.components.herd:SetOnFullFn(OnFull)
    inst.components.herd:SetAddMemberFn(AddMember)
    inst.components.herd:GatherNearbyMembers()
    
    local season = GetSeasonManager()
    if season then
        local wait
        inst:AddComponent("mood")
        if season:IsWinter() then
            wait = TUNING.PENGUIN_MATING_SEASON_WAIT - season:GetDaysIntoSeason()
        else
            wait = TUNING.PENGUIN_MATING_SEASON_WAIT + season:GetDaysLeftInSeason()
        end
        --inst.components.mood:SetMoodTimeInDays(TUNING.PENGUIN_MATING_SEASON_LENGTH, wait)
        inst.components.mood:SetMoodTimeInDays(TUNING.PENGUIN_MATING_SEASON_LENGTH, 0)
        inst.components.mood:SetInMoodFn(InMood)
        inst.components.mood:SetLeaveMoodFn(LeaveMood)
        inst.components.mood:CheckForMoodChange()
    end
    
    return inst
end

return Prefab( "forest/animals/penguinherd", fn, assets, prefabs) 
