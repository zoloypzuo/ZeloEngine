Comparing files F:\KLEI\DLC_PORKLAND\DATA\DLC0003\SCRIPTS\mainfunctions.lua and F:\KLEI\DLC_PORKLAND\DATA\SCRIPTS\MAINFUNCTIONS.LUA
***** F:\KLEI\DLC_PORKLAND\DATA\DLC0003\SCRIPTS\mainfunctions.lua
        if LOGSPAWNS or CHECKSPAWNS then
                info = debug.getinfo(2, "lS") or { short_src = "*engine*", currentline = -1 }
                if ent then
                        ent.origspawnedFrom = ent.origSpawnedFrom or {source = info.short_src, line = info.currentline}
                end
***** F:\KLEI\DLC_PORKLAND\DATA\SCRIPTS\MAINFUNCTIONS.LUA
        if LOGSPAWNS or CHECKSPAWNS then
                info = debug.getinfo(2, "lS") or { source = "*engine*" }
                if ent then
                        ent.origspawnedFrom = ent.origSpawnedFrom or info
                end
*****

***** F:\KLEI\DLC_PORKLAND\DATA\DLC0003\SCRIPTS\mainfunctions.lua
        local function printSpawn(info)
                print(string.format("Spawned %s from %s:%d",name,info.source,info.line))
        end
***** F:\KLEI\DLC_PORKLAND\DATA\SCRIPTS\MAINFUNCTIONS.LUA
        local function printSpawn(info)
                if info.what == "Lua" then
                        print(string.format("Spawned %s from %s:%d",name,info.short_src,info.currentline))
                end
        end
*****

***** F:\KLEI\DLC_PORKLAND\DATA\DLC0003\SCRIPTS\mainfunctions.lua
        if LOGSPAWNS then
                printSpawn(ent.origspawnedFrom)
        end
***** F:\KLEI\DLC_PORKLAND\DATA\SCRIPTS\MAINFUNCTIONS.LUA
        if LOGSPAWNS then
                printSpawn(info)
        end
*****

***** F:\KLEI\DLC_PORKLAND\DATA\DLC0003\SCRIPTS\mainfunctions.lua
                                if position:LengthSq() <= 1 then
                                        print("Entity hanging around origin::",position)
                                        printSpawn(ent.origspawnedFrom)
                                end
***** F:\KLEI\DLC_PORKLAND\DATA\SCRIPTS\MAINFUNCTIONS.LUA
                                if position:LengthSq() <= 1 then
                                        print("Entity hanging around origin:",position)
                                        printSpawn(info)
                                end
*****

***** F:\KLEI\DLC_PORKLAND\DATA\DLC0003\SCRIPTS\mainfunctions.lua
        end
        return ent
***** F:\KLEI\DLC_PORKLAND\DATA\SCRIPTS\MAINFUNCTIONS.LUA
        end
        local info = debug.getinfo(2, "n") or { source = "*engine*" }
        return ent
*****

***** F:\KLEI\DLC_PORKLAND\DATA\DLC0003\SCRIPTS\mainfunctions.lua

function PutEntityToSleep(inst)
--[[
        print("PutEntityToSleep",inst,inst.prefab)
        if (inst.origspawnedFrom) then
                print("",string.format("%s:%d",inst.origspawnedFrom.source, inst.origspawnedFrom.line))
        else
                print("","...no spawn info???")
        end
]]
    if inst.OnEntitySleep then
                inst:OnEntitySleep()
    end
        
        inst:StopBrain()        

    if inst.sg then
        SGManager:Hibernate(inst.sg)
    end

        if inst.emitter then
                EmitterManager:Hibernate(inst.emitter)
        end
***** F:\KLEI\DLC_PORKLAND\DATA\SCRIPTS\MAINFUNCTIONS.LUA

function OnEntitySleep(guid)
    local inst = Ents[guid]
    if inst then
        
        if inst.OnEntitySleep then
                        inst:OnEntitySleep()
        end
        
        
                inst:StopBrain()        

        if inst.sg then
            SGManager:Hibernate(inst.sg)
        end
*****

***** F:\KLEI\DLC_PORKLAND\DATA\DLC0003\SCRIPTS\mainfunctions.lua

    for k,v in pairs(inst.components) do
            
        if v.OnEntitySleep then
            v:OnEntitySleep()
        end
    end
***** F:\KLEI\DLC_PORKLAND\DATA\SCRIPTS\MAINFUNCTIONS.LUA

                if inst.emitter then
                        EmitterManager:Hibernate(inst.emitter)
                end

        for k,v in pairs(inst.components) do
            
            if v.OnEntitySleep then
                v:OnEntitySleep()
            end
        end

    end
*****

***** F:\KLEI\DLC_PORKLAND\DATA\DLC0003\SCRIPTS\mainfunctions.lua

function OnEntitySleep(guid)
    local inst = Ents[guid]
***** F:\KLEI\DLC_PORKLAND\DATA\SCRIPTS\MAINFUNCTIONS.LUA

function OnEntityWake(guid)
    local inst = Ents[guid]
*****

***** F:\KLEI\DLC_PORKLAND\DATA\DLC0003\SCRIPTS\mainfunctions.lua
    if inst then
        PutEntityToSleep(inst)
    end
end

function WakeUpEntity(inst)
--[[
        print("WakeUpEntity",tostring(inst),tostring(inst.prefab))
        if (inst.origspawnedFrom) then
                print("",string.format("%s:%d",inst.origspawnedFrom.source, inst.origspawnedFrom.line))
        else
                print("","...no spawn info???")
        end
]]
    if inst.OnEntityWake then
                inst:OnEntityWake()
    end

    if not inst:IsInLimbo() then
                inst:RestartBrain()
                if inst.sg then
                SGManager:Wake(inst.sg)
                end
        end
                
        if inst.emitter then
                EmitterManager:Wake(inst.emitter)
        end
***** F:\KLEI\DLC_PORKLAND\DATA\SCRIPTS\MAINFUNCTIONS.LUA
    if inst then
                if inst.interiorLimbo then
                        -- don't wake up an entity in interiorlimbo, it should be woken up when it leaves interiorlimbo instead

                        return
                end

        if inst.OnEntityWake then
                        inst:OnEntityWake()
        end
*****

***** F:\KLEI\DLC_PORKLAND\DATA\DLC0003\SCRIPTS\mainfunctions.lua

    for k,v in pairs(inst.components) do
        if v.OnEntityWake then
            v:OnEntityWake()
        end
***** F:\KLEI\DLC_PORKLAND\DATA\SCRIPTS\MAINFUNCTIONS.LUA

        if not inst:IsInLimbo() then
                        inst:RestartBrain()
                        if inst.sg then
                    SGManager:Wake(inst.sg)
                        end
                end
                
                if inst.emitter then
                        EmitterManager:Wake(inst.emitter)
                end


        for k,v in pairs(inst.components) do
            if v.OnEntityWake then
                v:OnEntityWake()
            end
        end
*****

***** F:\KLEI\DLC_PORKLAND\DATA\DLC0003\SCRIPTS\mainfunctions.lua

function OnEntityWake(guid)
    local inst = Ents[guid]
        -- don't wake up an entity in interiorlimbo, it should be woken up when it leaves interiorlimbo instead. Does this work
 correctly with entity:SetCanSleep(false)?
    if inst and not inst.interiorLimbo then
                WakeUpEntity(inst)
    end
end

------------------------------
***** F:\KLEI\DLC_PORKLAND\DATA\SCRIPTS\MAINFUNCTIONS.LUA

------------------------------
*****

