local function OnCreate(inst, scenariorunner)
	if inst.components.fueled then
		local maxfuel = inst.components.fueled.maxfuel
		inst.components.fueled:InitializeFuelLevel(math.random(maxfuel * 0.4, maxfuel * 0.6))
	end
	--Anything that needs to happen only once. IE: Putting loot in a chest.
end


local function OnLoad(inst, scenariorunner)
--Anything that needs to happen every time the game loads.
end


local function OnDestroy(inst)
--Stop any event listeners here.
end

return 
{
	OnCreate = OnCreate,
	OnLoad = OnLoad,
	OnDestroy = OnDestroy
}