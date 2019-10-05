

local XP_PER_DAY = 20

local XP_levels = 
{   
    XP_PER_DAY*8,  
    XP_PER_DAY*16, 
    XP_PER_DAY*32,  
    XP_PER_DAY*48,
    XP_PER_DAY*64,
    XP_PER_DAY*80,
    --50000, --
    --100000, --
}

--Wes & Maxwell unlocked through other means.
local Level_rewards = {'willow', 'wolfgang', 'wendy', 'wx78', 'wickerbottom', 'woodie'} 
local Level_cap = #XP_levels

local function GetLevelForXP(xp)
    local last = 0
    for k,v in ipairs(XP_levels) do
        if xp < v then
            local percent = ((xp - last) / (v - last))
            return k-1, percent
        end
        last = v
    end
    --at cap!
    return #XP_levels, 0
end

    
return 
{
	GetXPCap = function()
		return XP_levels[#XP_levels]
	end,
	
    GetRewardsForTotalXP = function(xp)
        local level = math.min(GetLevelForXP(xp), Level_cap)
        
        local rewards = {}
        if level > 0 then
            for k = 1, math.min(level, #Level_rewards) do
                table.insert(rewards, Level_rewards[k])
            end
        end
        return rewards
    end,
    
    GetRewardForLevel = function(level)
        level = level + 1
        if level > 0 and level <= #Level_rewards then
            return Level_rewards[level]
        end
    end,
    
    GetXPForDays = function(days)
		return XP_PER_DAY*days
    end,

    GetXPForLevel = function(level)
        if level == 0 then
            return 0, XP_levels[1]
        end
        if level <= #XP_levels then
            return XP_levels[level], level + 1 <= #XP_levels and (XP_levels[level + 1] - XP_levels[level]) or 0
        end
        
    end,

    GetLevelForXP = function (xp)
        return GetLevelForXP(xp)
    end, 

    IsCappedXP = function(xp)
        return xp >= XP_levels[#XP_levels]
    end
}
