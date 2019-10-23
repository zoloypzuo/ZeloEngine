local Eater = Class(function(self, inst)
    self.inst = inst
    self.eater = false
    self.strongstomach = false
    self.foodprefs = { "GENERIC" }
    self:SetOmnivore()
    self.oneatfn = nil
    self.lasteattime = nil
    self.ignoresspoilage = false
    self.eatwholestack = false

    self.healthabsorption = 1
    self.hungerabsorption = 1
    self.sanityabsorption = 1
end)

function Eater:SetAbsorptionModifiers(health, hunger, sanity)
    self.healthabsorption = health
    self.hungerabsorption = hunger
    self.sanityabsorption = sanity
end

function Eater:SetVegetarian()
    self.foodprefs = { "VEGGIE", "ROUGHAGE" }
end

function Eater:SetCarnivore()
    self.foodprefs = { "MEAT" }
end

function Eater:SetInsectivore()
    self.foodprefs = { "INSECT" }
end

function Eater:SetBird()
    self.foodprefs = { "SEEDS" }
end

function Eater:SetBeaver()
    self.foodprefs = { "WOOD", "ROUGHAGE" }
end

function Eater:SetElemental()
    self.foodprefs = { "ELEMENTAL" }
end

function Eater:TimeSinceLastEating()
    if self.lasteattime then
        return GetTime() - self.lasteattime
    end
end

function Eater:OnSave()
    if self.lasteattime then
        return { time_since_eat = self:TimeSinceLastEating() }
    end
end

function Eater:OnLoad(data)
    if data.time_since_eat then
        self.lasteattime = GetTime() - data.time_since_eat
    end
end

function Eater:SetCanEatHorrible()
    table.insert(self.foodprefs, "HORRIBLE")
end

function Eater:SetOmnivore()
    self.foodprefs = { "MEAT", "VEGGIE", "INSECT", "SEEDS", "GENERIC" }
end

function Eater:SetOnEatFn(fn)
    self.oneatfn = fn
end

function Eater:SetCanEatTestFn(fn)
    self.caneattest = fn
end

function Eater:Eat(food)
    if self:CanEat(food) then
        local stack_mult = self.eatwholestack and food.components.stackable ~= nil and food.components.stackable:StackSize() or 1

        if self.inst.components.health then
            if food.components.edible.healthvalue > 0 or not self.strongstomach then
                self.inst.components.health:DoDelta(food.components.edible:GetHealth(self.inst), nil, food.prefab)
            end
        end

        if self.inst.components.hunger then
            self.inst.components.hunger:DoDelta(food.components.edible:GetHunger(self.inst))
        end

        if self.inst.components.sanity then
            self.inst.components.sanity:DoDelta(food.components.edible:GetSanity(self.inst))
        end

        self.inst:PushEvent("oneat", { food = food })
        if self.oneatfn then
            self.oneatfn(self.inst, food)
        end

        if food.components.edible then
            food.components.edible:OnEaten(self.inst)
        end

        if food.components.stackable and food.components.stackable.stacksize > 1 and not self.eatwholestack then
            food.components.stackable:Get():Remove()
        else
            food:Remove()
        end

        self.lasteattime = GetTime()

        self.inst:PushEvent("oneatsomething", { food = food })

        return true
    end
end

function Eater:CanEat(inst)
    if inst and inst.components.edible then
        for k, v in pairs(self.foodprefs) do
            if v == inst.components.edible.foodtype then
                if self.caneattest then
                    return self.caneattest(self.inst, inst)
                end
                return true
            end
        end
    end
end

return Eater