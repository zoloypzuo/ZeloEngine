local function OnCreate(inst, scenariorunner)
	if inst.components.burnable then
		inst.components.burnable:Ignite()
	end
end

--local function OnLoad(inst, scenariorunner)
--end

return {
	    OnCreate=OnCreate, 
        --OnLoad=OnLoad
	   }

