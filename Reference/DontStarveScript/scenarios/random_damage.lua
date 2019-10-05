
local function OnCreate(inst, scenariorunner)
	if inst then
        if inst.components.health then
            inst.components.health:DoDelta(math.random(-inst.components.health.maxhealth * .75, 0), 0, "dev")
        elseif inst.components.finiteuses then
            inst.components.finiteuses.current = math.random(inst.components.finiteuses.total * .1, inst.components.finiteuses.total * .75)
            if inst.components.finiteuses.current <= 0 and inst.components.finiteuses.total >= 1 then
                inst.components.finiteuses.current = 1
            end
        elseif inst.components.condition then
            inst.components.condition.current = math.random(inst.components.condition.maxcondition * .1, inst.components.condition.maxcondition * .75)
        elseif inst.components.armor then
            inst.components.armor.condition = math.random(inst.components.armor.maxcondition * .1, inst.components.armor.maxcondition * .75)
       elseif inst.components.fueled then
            inst.components.fueled.currentfuel = math.random(inst.components.fueled.maxfuel * .1, inst.components.fueled.maxfuel * .75)
        end
    end
end

return
{
	OnCreate = OnCreate
}