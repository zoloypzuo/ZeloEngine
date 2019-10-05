MAIN_GAME = 0
REIGN_OF_GIANTS = 1
CAPY_DLC = 2
PORKLAND_DLC = 3

NO_DLC_TABLE = {REIGN_OF_GIANTS=false, CAPY_DLC=false, PORKLAND_DLC = false}
ALL_DLC_TABLE = {REIGN_OF_GIANTS=true, CAPY_DLC = true, PORKLAND_DLC = true}
DLC_LIST = {REIGN_OF_GIANTS, CAPY_DLC, PORKLAND_DLC}

RegisteredDLC = {}
ActiveDLC = {}

-----------------------  locals ------------------------------------------

local function AddPrefab(prefabName)
   for i,v in pairs(PREFABFILES) do
      if v==prefabName then
         return
      end
   end
   PREFABFILES[#PREFABFILES+1] = prefabName
end


local function GetDLCPrefabFiles(filename)
    --bargle = foo * foo
    print("Load "..filename)
    local fn, r = loadfile(filename)
    assert(fn, "Could not load file ".. filename)
    if type(fn) == "string" then
        assert(false, "Error loading file "..filename.."\n"..fn)
    end
    assert( type(fn) == "function", "Prefab file doesn't return a callable chunk: "..filename)
    local ret = fn()
    return ret
end


local function RegisterPrefabs(index)
    local dlcPrefabFilename = string.format("scripts/DLC%03d_prefab_files",index)
    local dlcprefabfiles = GetDLCPrefabFiles(dlcPrefabFilename)

    for i,v in pairs(dlcprefabfiles) do   
        AddPrefab(v)
    end
end

-- Load the base prefablist and merge in all additional prefabs for the DLCs
local function ReloadPrefabList()
    for i,v in pairs(RegisteredDLC) do
            RegisterPrefabs(i)
    end
end


-----------------------  globals ------------------------------------------

function RegisterAllDLC()
    for i=1,10 do
        local filename = string.format("scripts/DLC%04d",i)
        local fn, r = loadfile(filename)
        if (type(fn) == "function") then
             local ret = fn()
             RegisteredDLC[i] = ret
        else
             RegisteredDLC[i] = nil
        end
    end
    ReloadPrefabList()
end

-- This one is somewhat important, it can be used to load prefabs that are not referenced by any prefab and thus not loaded
function InitAllDLC()
    for i,v in pairs(RegisteredDLC) do
        if v.Setup then
            v.Setup()
        end
    end
end

function GetOfficialCharacterList()
    local list = MAIN_CHARACTERLIST

    if IsDLCEnabled(REIGN_OF_GIANTS) then
        list = JoinArrays(list, ROG_CHARACTERLIST)
    end
    if IsDLCEnabled(CAPY_DLC) then
        if IsDLCInstalled(REIGN_OF_GIANTS) then
            list = JoinArrays(list, ROG_CHARACTERLIST)
        end
        list = JoinArrays(list, SHIPWRECKED_CHARACTERLIST)
    end
    if IsDLCEnabled(PORKLAND_DLC) then
        if IsDLCInstalled(REIGN_OF_GIANTS) then
            list = JoinArrays(list, ROG_CHARACTERLIST)
        end
        if IsDLCInstalled(CAPY_DLC) then
            list = JoinArrays(list, SHIPWRECKED_CHARACTERLIST)
        end          
        list = JoinArrays(list, PORKLAND_CHARACTERLIST)
    end    
    return list
end

function GetActiveCharacterListForSelection()
    local list = MAIN_CHARACTERLIST

    if IsDLCEnabled(REIGN_OF_GIANTS) then
        list = JoinArrays(list, ROG_CHARACTERLIST)
        if IsDLCEnabledAndInstalled(CAPY_DLC) then
            list = JoinArrays(list, SHIPWRECKED_CHARACTERLIST)
        end
        if IsDLCEnabledAndInstalled(PORKLAND_DLC) then
            list = JoinArrays(list, PORKLAND_CHARACTERLIST)
        end         
    end
    if IsDLCEnabled(CAPY_DLC) then
        if IsDLCInstalled(REIGN_OF_GIANTS) then
            list = JoinArrays(list, ROG_CHARACTERLIST)
        end
        if IsDLCEnabledAndInstalled(PORKLAND_DLC) then
            list = JoinArrays(list, PORKLAND_CHARACTERLIST)
        end        
        list = JoinArrays(list, SHIPWRECKED_CHARACTERLIST)
    end

    if IsDLCEnabled(PORKLAND_DLC) then
        if IsDLCInstalled(REIGN_OF_GIANTS) then
            list = JoinArrays(list, ROG_CHARACTERLIST)
        end
        if IsDLCInstalled(CAPY_DLC) then
            list = JoinArrays(list, SHIPWRECKED_CHARACTERLIST)
        end
        
        list = JoinArrays(list, PORKLAND_CHARACTERLIST)
    end

    for i=#list,1,-1 do
        for t,rchar in ipairs(RETIRED_CHARACTERLIST)do
            if rchar == list[i] then
                table.remove(list,i)
            end
        end
    end        

    return JoinArrays(list, MODCHARACTERLIST)
end


function GetActiveCharacterList()
    return JoinArrays(GetOfficialCharacterList(), MODCHARACTERLIST)
end

function DisableDLC(index)
    TheSim:SetDLCEnabled(index,false)
end

function EnableDLC(index)
    TheSim:SetDLCEnabled(index,true)
end

function IsDLCEnabled(index)
    return TheSim:IsDLCEnabled(index)
end

function IsDLCInstalled(index)
    return TheSim:IsDLCInstalled(index)
end

function IsDLCEnabledAndInstalled(index)
    return IsDLCInstalled(index) and IsDLCEnabled(index)
end

function EnableAllDLC()
    for i,v in pairs(DLC_LIST) do
        EnableDLC(v)
    end
end

function DisableAllDLC()
    for i,v in pairs(DLC_LIST) do
        DisableDLC(v)
    end 
end

function SetManualBGColor(bg, dlc)
    local dlc_colours = 
    {
        MAIN_GAME = BGCOLOURS.RED,
        REIGN_OF_GIANTS = BGCOLOURS.PURPLE,
        CAPY_DLC = BGCOLOURS.TEAL,
        PORKLAND_DLC = BGCOLOURS.GREEN,
    }

    local selected_colour = dlc_colours[dlc] or BGCOLOURS.GREEN
    bg:SetTint(selected_colour[1], selected_colour[2], selected_colour[3], 1)
end

function SetBGcolor(bg, scripterror)
    if IsDLCEnabled(PORKLAND_DLC) then
        if scripterror then            
            bg:SetTint(BGCOLOURS.GREEN[1]*0.4,BGCOLOURS.GREEN[2]*0.4,BGCOLOURS.GREEN[3]*0.4, 1)
        else
            bg:SetTint(BGCOLOURS.GREEN[1],BGCOLOURS.GREEN[2],BGCOLOURS.GREEN[3], 1)
        end
    elseif IsDLCEnabled(CAPY_DLC) then
        bg:SetTint(BGCOLOURS.TEAL[1],BGCOLOURS.TEAL[2],BGCOLOURS.TEAL[3], 1)
    elseif IsDLCEnabled(REIGN_OF_GIANTS) then
        bg:SetTint(BGCOLOURS.PURPLE[1],BGCOLOURS.PURPLE[2],BGCOLOURS.PURPLE[3], 1)
    else
        bg:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 1)
    end
end