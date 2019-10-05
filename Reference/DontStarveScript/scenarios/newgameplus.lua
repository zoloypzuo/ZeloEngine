local function OnCreate(inst, scenariorunner)

	--make all of the spider dens scary!
	for k,v in pairs(Ents) do
		if v:HasTag("spiderden") and v.components.growable then
			v.components.growable:SetStage(math.random() < .25 and 3 or 2)
		end
	end
	
end

return 
{
	OnCreate = OnCreate
}
