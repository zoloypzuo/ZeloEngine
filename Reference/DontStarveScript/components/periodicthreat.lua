--Simple way to have basic events of stuff spawning around wilson on a timer.

local PeriodicThreat = Class(function(self, inst)
	self.inst = inst
	--To see all variables you can set look at the AddThreat function.
	self.threats =	{}
	self.inst:StartUpdatingComponent(self)
end)


function PeriodicThreat:AddThreat(name, data)
	if not name or not data then
		print("PeriodicThreat:AddThreat - Missing NAME or DATA when attempting to add a PeriodicThreat!")
		return
	end

	self.threats[name] = {}
	local t = self.threats[name]

	--[[You will typically leave these set to nil for a new timer. 
	Default behaviour will start in the WAIT stage and use the waittimer variable to set the initial timer.
	Only set these if you wish the timer to behave differently.]]
	t.timer = data.timer or nil
	t.state = data.state or nil
	--

	t.prefab = data.prefab or nil --Function or string. Which prefab will spawn near the player.
	t.radius = data.radius or  25 --Function or #. The radius around the player that the prefab will spawn in.
	--Function to override the default location selection of a prefab when spawning. Leave nil if you wish to use the default behaviours
	t.spawnfn = data.spawnposfn or nil
	
	--[[Function. Called on prefab when it's spawned. Passes in itself.
	If you have trackspawns set to true, this function is also called on each prefab when the game is loaded.]]
	t.onspawn = data.onspawn or nil 
	t.warnsound = data.warnsound or nil -- String. The sound to be played on each warn.
	t.numtospawnfn = data.numtospawnfn or function() return 1 end --Function. How many monsters will be spawned.
	t.numtospawn = nil

	--[[Uses this to determine if the spawner should spawn more. 
	For shorter cycles, see the listenfordeath variable below.]]
	t.numspawned = 0

	t.trackspawns = data.trackspawns or true --If you want the spawner to track the monsters it has spawned.
	t.spawns = nil
	
	--[[If you want the spawner to care about entity deaths.
	Using this will cause the numspawned to not be reset each time event is finished, but rather update it based
	on how many alive entities are being tracked in the spawns table.
	Note that trackspawns must be true to use this.]]
	t.listenfordeath = data.listenfordeath or false 

	--Setting up the table structure for specific states.
	t.state_variables = {}
	t.state_variables.statetimer = nil
	t.state_variables["wait"] = {}
	t.state_variables["warn"] = {}
	t.state_variables["event"] = {}

	-- Function or Number. Total time of the each state.
	-- Set to 0 if you wish the state to never happen.
	t.state_variables["wait"].time = data.waittime or 2
	t.state_variables["warn"].time = data.warntime or 2
	t.state_variables["event"].time = data.eventtime or 2

	--[[Function or Number. Time between each call of the state's fn, sets the value of statetimer. 
	This timer will handle how often warning sounds are played during the warn phase 
	or how often monsters are spawned during the event phase.]]
	t.state_variables["wait"].timer = data.waittimer or 1
	t.state_variables["warn"].timer = data.warntimer or 1
	t.state_variables["event"].timer = data.eventtimer or 1

	--[[The state's function. This is called along with the default function each time statetimer reaches 0.
	This passes through the entire table of the threat, letting you access every variable listed here.

	The best use of this I can think of is to manipulate spawned monsters by accessing the spawns table, but I'm sure
	there are other uses too.]]
	t.state_variables["wait"].fn = data.waitfn or nil
	t.state_variables["warn"].fn = data.warnfn or nil
	t.state_variables["event"].fn = data.eventfn or nil

end

function PeriodicThreat:GetDebugString()
	local str = "\n"
		for k,v in pairs(self.threats) do
			str = str.."	--"..k.."\n"
			str = str..string.format("		--timer %f \n", v.timer or 0)
			str = str..string.format("		--state %s \n", v.state or "NIL")
			str = str..string.format("		--state timer %f \n", v.state_variables.statetimer or 0)
			str = str..string.format("		--num spawns %f \n", v.numspawned or 0)
		end
	return str
end
  
function PeriodicThreat:StartWarn(key)
	--print("StartWarn ",key)
end

function PeriodicThreat:StartEvent(key)	
	--print("StartEvent ",key)
	local t = self.threats[key]
	t.numtospawn = t.numtospawnfn() --Set up how many will spawn @ event start
end

function PeriodicThreat:StartWait(key)	
	--print("StartWait ",key)
	local t = self.threats[key]

	t.numtospawn = nil

	if not t.listenfordeath then
		t.numspawned = 0
	end
end

function PeriodicThreat:DoPeriodicWait(key)
	self:DoPeriodicFn(key)
end

function PeriodicThreat:DoPeriodicWarn(key)
	--Play warning sound
	self:DoPeriodicFn(key)	
	self:PlayWarnSound(key)
end

function PeriodicThreat:DoPeriodicEvent(key)
	--Spawn creature
	self:DoPeriodicFn(key)
	self:Spawn(key)	
end

function PeriodicThreat:DoPeriodicFn(key)
	if self.threats[key].state_variables[self.threats[key].state].fn then
		self.threats[key].state_variables[self.threats[key].state].fn(self.threats[key])
	end
end

function PeriodicThreat:SetStateTimer(key)
	local t = self.threats[key]
	if t.state_variables.statetimer then
		return 
	end

	if type(t.state_variables[t.state].timer) == "function" then
		t.state_variables.statetimer = t.state_variables[t.state].timer(t)
	else
		t.state_variables.statetimer = t.state_variables[t.state].timer
	end

end

function PeriodicThreat:GoToNextState(key)
	local s = self.threats[key].state
	local ns = nil

	if s == "wait" then
		ns = "warn"
		self:StartWarn(key)
	elseif s == "warn" then
		ns = "event"
		self:StartEvent(key)
	else
		ns = "wait"
		self:StartWait(key)
	end

	if ns then
		self.threats[key].state = ns
		self:OnStateChange(key, ns)
	end
end

function PeriodicThreat:OnStateChange(key, newstate)
	local t = self.threats[key]
	local t_var = t.state_variables[newstate]

	if t_var.fn then
		t_var.fn(self.inst)
	end

	if not t.timer then
		if type(t_var.time) == "function" then
			t.timer = t_var.time()
		else
			t.timer = t_var.time
		end
	end

	self:SetStateTimer(key)
end

function PeriodicThreat:PlayWarnSound(key)
    local player = GetPlayer()
    if not player or not self.threats[key].warnsound then return end
    player.SoundEmitter:PlaySound(self.threats[key].warnsound)	
end

function PeriodicThreat:Spawn(key)
	local t = self.threats[key]

	if not t.numtospawn or t.numspawned >= t.numtospawn then
		return 
	end

	local tospawn = nil
	if type(t.prefab) == "function" then
		tospawn = t.prefab()
	else
		tospawn = t.prefab
	end

	if not tospawn then return end

	local prefab = SpawnPrefab(tospawn)

	local pos = (t.spawnposfn and t.spawnposfn(key)) or self:GetSpawnPoint(key)

	if pos and prefab then
		prefab.Transform:SetPosition(pos.x, pos.y, pos.z)
	end

	if prefab and t.onspawnfn then
		t.onspawnfn(prefab)
	end

	t.numspawned = t.numspawned + 1

	if t.trackspawns and prefab then
		self:TakeOwnership(key, prefab)
	end
end

function PeriodicThreat:GetSpawnPoint(key)
    local player = GetPlayer()
    if not player then return end
    
    local theta = math.random() * 2 * PI
    local pt = player:GetPosition()
    local radius = self.threats[key].radius

    if type(radius) == "function" then
    	radius = radius()
    end

	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	if offset then
		return pt+offset
	end
end

function PeriodicThreat:TakeOwnership(key, child)
	local t = self.threats[key]
	if not t.spawns then
		t.spawns = {}
	end

	t.spawns[child] = child

	if t.listenfordeath then
		child.periodicthreat_ondeath = function(child)
			print("Child of the ", key, " event died.")
			t.numspawned = t.numspawned - 1
			self.inst:RemoveEventCallback("death", child.periodicthreat_ondeath, child)
			self.inst:RemoveEventCallback("entitysleep", child.periodicthreat_ondeath, child)
			self.inst:RemoveEventCallback("onremove", child.periodicthreat_ondeath, child)
			
		end
		self.inst:ListenForEvent("death", child.periodicthreat_ondeath, child)
		self.inst:ListenForEvent("entitysleep", child.periodicthreat_ondeath, child)
		self.inst:ListenForEvent("onremove", child.periodicthreat_ondeath, child)

	end
end

function PeriodicThreat:GetCurrentState(key)
	return self.threats[key].state
end

function PeriodicThreat:OnUpdate(dt)
	for k,v in pairs(self.threats) do
		if v.timer then
			v.timer = v.timer - dt
			if v.timer <= 0 then
				v.timer = nil
			end
		end

		if v.state_variables.statetimer then
			v.state_variables.statetimer = v.state_variables.statetimer - dt

			if v.state_variables.statetimer <= 0 then
				v.state_variables.statetimer = nil				
			end
		end

		if not v.timer then
			self:GoToNextState(k)
		end

		if not v.state_variables.statetimer then
			if self:GetCurrentState(k) == "wait" then
				self:DoPeriodicWait(k)
			elseif self:GetCurrentState(k) == "warn" then
				self:DoPeriodicWarn(k)
			elseif self:GetCurrentState(k) == "event" then
				self:DoPeriodicEvent(k)
			end
			self:SetStateTimer(k)
		end
	end
end

function PeriodicThreat:LongUpdate(dt)
	self:OnUpdate(dt)
end

function PeriodicThreat:OnSave()
	--print("PeriodicThreat: OnSave")

	local data = {}
	local references = {}

	for k,v in pairs(self.threats) do
		data[k] = {}
		data[k].timer = v.timer
		data[k].state = v.state
		data[k].state_variables = {}		
		data[k].state_variables.statetimer = v.state_variables.statetimer
		data[k].numtospawn = v.numtospawn
		data[k].numspawned = v.numspawned 

		if v.spawns then
			for a,b in pairs(v.spawns) do
				if not data[k].spawns then
					data[k].spawns = {b.GUID}
				else
					table.insert(data[k].spawns, b.GUID)
				end
				table.insert(references, b.GUID)
			end
		end
	end

	return data, references
end

function PeriodicThreat:OnLoad(data)
	--print("PeriodicThreat: OnLoad")
	if data then
		for k,v in pairs(data) do
			--print("Setting Data in event: ", k)
			self.threats[k].timer = v.timer
			self.threats[k].state = v.state
			self.threats[k].state_variables.statetimer = v.state_variables.statetimer
			self.threats[k].numtospawn = v.numtospawn
			self.threats[k].numspawned = v.numspawned
		end
	end

	for k,v in pairs(self.threats) do
		--print("Starting State: ", v.state)
		self:OnStateChange(k, v.state)
	end
end

function PeriodicThreat:LoadPostPass(newents, data)
	--print("PeriodicThreat: LoadPostPass")

	for k,v in pairs(data) do
		if v.spawns then
			for a,b in pairs(v.spawns) do 
				local child = newents[v]
				if child then
					child = child.entity
					
					if self.threats[k].onspawnfn then
						tself.threats[k].onspawnfn(child)
					end

					self:TakeOwnership(k, child)

				end
			end
		end
	end
end


return PeriodicThreat