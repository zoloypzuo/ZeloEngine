PlayerDeaths = Class(function(self)
    self.persistdata = {} 
    -- self.totals = {days_survived = 0, deaths = 0}

    self.dirty = true
    self.sort_function =  function(a,b) return (a.days_survived or 1) > (b.days_survived or 1) end
end)


function PlayerDeaths:Reset()
    self.persistdata = {}
	self.dirty = true
	self:Save()
end

function PlayerDeaths:OnDeath(row)
    table.insert(self.persistdata, row)
    self.dirty = true
	self:Save()
end

function PlayerDeaths:GetRows()
	return self.persistdata
end

function PlayerDeaths:Sort(field)
	local sort_function = self.sort_function
	if field ~= nil then
		-- print(type(self.persistdata[1][field]))
		if type(self.persistdata[1][field]) == "string" then
			sort_function =  function(a,b) return (a[field] or "") < (b[field] or "") end
		else
			sort_function =  function(a,b) return (a[field] or 0) > (b[field] or 0) end
		end			
	end
	table.sort( self.persistdata, sort_function )
end

----------------------------

function PlayerDeaths:GetSaveName()
    return "morgue"
end


function PlayerDeaths:Save(callback)
    if self.dirty then
    	self:Sort()
    	if #self.persistdata > 40 then
    		for idx = #self.persistdata, 40, -1 do
    			table.remove(self.persistdata, idx)
    		end
    	end
 		print( "SAVING Morgue", #self.persistdata )
        local str = json.encode(self.persistdata)
        local insz, outsz = SavePersistentString(self:GetSaveName(), str, ENCODE_SAVES, callback)
    else
		if callback then
			callback(true)
		end
    end
end

function PlayerDeaths:Load(callback)
    TheSim:GetPersistentString(self:GetSaveName(),
        function(load_success, str) 
        	-- Can ignore the successfulness cause we check the string
			self:Set( str, callback )
        end, false)    
end

function PlayerDeaths:Set(str, callback)
	if str == nil or string.len(str) == 0 then
		print ("PlayerDeaths could not load ".. self:GetSaveName())
		if callback then
			callback(false)
		end
	else
		print ("PlayerDeaths loaded ".. self:GetSaveName(), #str)

		self.persistdata = TrackedAssert("TheSim:GetPersistentString morgue",  json.decode, str)
		self:Sort()

		-- self.totals = {days_survived = 0, deaths = 0}
		-- for i,v in ipairs(self.persistdata) do
		-- 	self.totals.days_survived = self.totals.days_survived + (v.days_survived or 0)
		-- end

		self.dirty = false
		if callback then
			callback(true)
		end
	end
end
