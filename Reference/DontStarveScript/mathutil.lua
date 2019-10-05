--Returns a sine wave based on game time. Mod will modify the period of the wave and abs is wether or not you want
-- the abs value of the wave
function GetSineVal(mod, abs, inst, timemod)
    local time = ((inst and inst:GetTimeAlive() or GetTime()) + (timemod or 0)) * (mod or 1)
    local val = math.sin(PI * time)
    if abs then
        return math.abs(val)
    else
        return val
    end
end

--Lerp a number from a to b over t
function Lerp(a,b,t)
    return a + (b - a) * t
end

--Remap a value (i) from one range (a - b) to another (x - y)
function Remap(i, a, b, x, y)
    return (((i - a)/(b - a)) * (y - x)) + x
end

--Round a number to idp decimal points. Rounds up.
function RoundUp(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function RoundDown(num, idp)
    local mult = 10^(idp or 0)
    return math.ceil(num * mult - 0.5) / mult
end

--Rounds numToRound to the nearest multiple of "mutliple"
function RoundToNearest(numToRound, multiple)
    local half = multiple/2
    return numToRound+half - (numToRound+half) % multiple
end

--Clamps a number between two values
function math.clamp(num, min, max)
    
    num = math.min(num, max)
    num = math.max(num, min)

    return num
    
end

function math.rerange(num, oldmin, oldmax, newmin, newmax)
    return (newmax-newmin) * (num-oldmin)/(oldmax-oldmin) + newmin
end

--Checks if direction vector tar is between vec1 and vec2
function isbetween(tar, vec1, vec2)
    return ((vec2.x - vec1.x) * (tar.z - vec1.z) - (vec2.z - vec1.z)*(tar.x-vec1.x)) > 0
end

function IsNumberEven(num)
    return (num % 2) == 0
end

function Sign(num)
    local retval = 0
    if(num > 0) then 
        retval = 1
    end 
    if(num < 0) then 
        retval = -1
    end 
    return retval 
end