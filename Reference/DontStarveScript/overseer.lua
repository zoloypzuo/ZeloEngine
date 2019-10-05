
--[[
    Functions to perform local analysis of the player's game
    and keep track of accumulated stats (to reduce amount of data sent)
--]]

local timeTrackersStats = {}

function DumpTimeTrackerStats()
end

-- time gets reset moving into and out of caves
function TimeTrackerTransitionIntoCave()
end
function TimeTrackerTransitionOutOfCave()
end


--[[
    Track time related events and activities.
    Do whatever time-series and statistical analysis on the fly with the data
    and give it to the stats system
--]]

TIMETRACKER_TYPE = {
                        CUMULATIVE_ONLY = "CumulativeOnly",
                        ONSET_ONLY      = "OnsetOnly",
                        FIRST_AND_LAST  = "FirstAndLast"
                    }

TimeTracker = Class(function(self, name, subtable, stat, type, bufsize)
    
    assert(name ~= nil)

    timeTrackerStats[#timeTrackerStats+1] = self

    self.name = name
    self.subtable = subtable or "time"
    self.stat = stat or "TimeTracker"
    self.type = type or TIMETRACKER_TYPE.CUMULATIVE_ONLY

    self.startTime = 0
    self.endTime = 0
    self.lastUpdateTime = 0
    self.lastDuration = 0
    self.updates = 0
    self.firstCall = nil
    self.realTime = false   -- track even when game paused

    self.buffsize = RingBuffer(bufsize or 25)

end)

-- Pass in a function to process any data values on update
-- function will be called as    
--          fn(self,value)
-- where "value" is a single item passed to   TimeTracker:UpdateTime(value)
-- The function should return a single item which will be recorded as the current value
-- and/or appended to the stored time-series

function TimeTracker:DataFunction( fn )
    assert( type(fn) == "function", "TimeTracker - needs function" )
    self.processData = fn
end

function TimeTracker:Start()
    local t = GetTime()

    self.firstCall = self.firstCall or t
    self.startTime = t
    self.lastUpdateTime = t
    self.lastDuration = 0
    self.updates = 0
    self.buffer:Clear() -- should any old data be dumped?

    if self.type == TIMETRACKER_TYPE.ONSET_ONLY then
        return
    end

end

function TimeTracker:Reset()

    self.firstCall = nil
    self.startTime = nil
    self.lastUpdateTime = nil
    self.lastDuration = 0
    self.updates = 0
    self.buffer:Clear() -- should any old data be dumped?

    if self.type == TIMETRACKER_TYPE.ONSET_ONLY then
        return
    end

end

function TimeTracker:UpdateTime(value)
    local t = GetTime()
    local lastUpdate = self.lastUpdateTime

    self.firstCall = self.firstCall or t
    self.lastDuration = t - self.lastUpdateTime
    self.lastUpdateTime = t
    self.endTime = t
    self.lastRawValue = self.value
    self.rawValue = value

    if self.type == TIMETRACKER_TYPE.ONSET_ONLY then
        return lastIdleDuration
    end

    -- Process the data if necessary
    self.updates = self.updates + 1
    if self.processData then
        value = self.processData(self,value)
    end

    self.value = value

    -- Do cumulative tracking here

    -- Add time-series info
    self.buffer:Add({time=t,duration=self.lastInterval,value=value})

    return lastIdleDuration
end

function TimeTracker:End(value)
    self:UpdateTime(value)
end


local AFK_TIME = 10
local lastInputTime = 0
local lastIdleDuration = 0
local pauseScreenStart = 0
local pauseDuration = 0
local pauseReason = ""
local isAFK = true

-- Do something when player pauses the game
function OverseerPauseCheck(reason)
    --dprint("OverseerPauseCheck")
    RecordPauseStats(reason)
end

local function UpdateInputTime()
    if IsPaused() then
        -- dprint("HUDPAUSED InputUpdate")
        local t = GetTime()
        if t > lastInputTime then  -- means this is the first time into the paused HUD
            lastIdleDuration = t - lastInputTime
            lastInputTime = t
        end
        if pauseReason == "minimap" then
            pauseDuration = (GetTimeReal()/1000) - pauseScreenStart
            -- The sim is paused during the minimap display, but I don't want to put a callback
            -- into WallUpdate to be called every few frames, so here I check to see if the
            -- time between inputs was long enough to be considered AFK and 
            if pauseDuration > AFK_TIME and GetPlayer()then
                dprint("============================= AFK during minimap",pauseDuration)
                GetPlayer():PushEvent("minimapAFK",pauseDuration)
                -- Add stat about AFK during minimap
            end
            pauseScreenStart = GetTimeReal()/1000
            lastIdleDuration = pauseDuration
        else
            -- dprint("some other reason")
        end
        return lastIdleDuration
    end
    local t = GetTime()
    lastIdleDuration = t - lastInputTime
    lastInputTime = t
    if isAFK and GetPlayer() then  -- Player not instantiated at first
        dprint("++++++++++++++++++++++++++++++++++ return to game")
        GetPlayer():PushEvent("returntogame")
    end
    isAFK = false
    return lastIdleDuration
end

global("PlayerPauseCheck")  -- drf Hmmm... don't think I need to do this to handle previous forward decl in mainfunctions.lua

PlayerPauseCheck = function(paused,reason)
    if paused then
        pauseScreenStart = GetTimeReal()/1000
        pauseDuration = 0
        pauseReason = reason or ""
        OverseerPauseCheck(reason)
    else
        local p = UpdateInputTime() -- updates pauseDuration
        -- dprint("Pausecheck=",p)
    end
end

IdlePlayerCheck = function()
    -- dprint("IdlePlayerCheck:")
    local id = GetTime()-lastInputTime
    if id > AFK_TIME then
        if not isAFK and GetPlayer() then  -- Player not instantiated at first
            dprint("---------------------------------- is AFK")
            GetPlayer():PushEvent("awayfromgame")
        end
        isAFK = true
    end
    return isAFK,id
end

local function MoveCheck()
    if TheInput:IsControlPressed(CONTROL_PRIMARY) then
        UpdateInputTime()
    end
end

function IsAwayFromKeyBoard()
    return isAFK , (GetTime() - lastInputTime)
end

TheInput:AddTextInputHandler( UpdateInputTime )
TheInput:AddKeyHandler( UpdateInputTime )
TheInput:AddControlHandler( CONTROL_PRIMARY, UpdateInputTime )
TheInput:AddControlHandler( CONTROL_ZOOM_IN, UpdateInputTime )
TheInput:AddControlHandler( CONTROL_ZOOM_OUT, UpdateInputTime )
TheInput:AddMoveHandler( MoveCheck )

scheduler:ExecutePeriodic(AFK_TIME/2, IdlePlayerCheck, nil, 0)

