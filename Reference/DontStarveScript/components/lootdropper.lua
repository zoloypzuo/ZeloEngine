local LootDropper = Class(function(self, inst)
    self.inst = inst
    self.numrandomloot = nil
    self.randomloot = nil
    self.chancerandomloot = nil
    self.totalrandomweight = nil
    self.chanceloot = nil
    self.ifnotchanceloot = nil
    self.droppingchanceloot = false
    self.loot = nil
    self.chanceloottable = nil

end)

LootTables = {}
function SetSharedLootTable(name, table)
    LootTables[name] = table
end

function LootDropper:SetChanceLootTable(name)
    self.chanceloottable = name
end

function LootDropper:SetLoot(loots)
    self.loot = loots
    self.chanceloot = nil
    self.randomloot = nil
    self.numrandomloot = nil
end

function LootDropper:AddRandomLoot(prefab, weight)
    if not self.randomloot then
        self.randomloot = {}
        self.totalrandomweight = 0
    end

    table.insert(self.randomloot, { prefab = prefab, weight = weight })
    self.totalrandomweight = self.totalrandomweight + weight
end

function LootDropper:AddChanceLoot(prefab, chance)
    if not self.chanceloot then
        self.chanceloot = {}
    end
    table.insert(self.chanceloot, { prefab = prefab, chance = chance })
end

function LootDropper:AddIfNotChanceLoot(prefab)
    if not self.ifnotchanceloot then
        self.ifnotchanceloot = {}
    end
    table.insert(self.ifnotchanceloot, { prefab = prefab })
end

function LootDropper:PickRandomLoot()
    if self.totalrandomweight and self.totalrandomweight > 0 and self.randomloot then
        local rnd = math.random() * self.totalrandomweight
        for k, v in pairs(self.randomloot) do
            rnd = rnd - v.weight
            if rnd <= 0 then
                return v.prefab
            end
        end
    end
end

function LootDropper:GenerateLoot()
    local loots = {}

    if self.numrandomloot and math.random() <= (self.chancerandomloot or 1) then
        for k = 1, self.numrandomloot do
            local loot = self:PickRandomLoot()
            if loot then
                table.insert(loots, loot)
            end
        end
    end

    if self.chanceloot then
        for k, v in pairs(self.chanceloot) do
            if math.random() < v.chance then
                table.insert(loots, v.prefab)
                self.droppingchanceloot = true
            end
        end
    end

    if self.chanceloottable then
        local loot_table = LootTables[self.chanceloottable]
        if loot_table then
            for i, entry in ipairs(loot_table) do
                local prefab = entry[1]
                local chance = entry[2]
                if math.random() <= chance then
                    table.insert(loots, prefab)
                    self.droppingchanceloot = true
                end
            end
        end
    end

    if not self.droppingchanceloot and self.ifnotchanceloot then
        self.inst:PushEvent("ifnotchanceloot")
        for k, v in pairs(self.ifnotchanceloot) do
            table.insert(loots, v.prefab)
        end
    end

    if self.loot then
        for k, v in ipairs(self.loot) do
            table.insert(loots, v)
        end
    end

    local recipe = GetRecipe(self.inst.prefab)

    if recipe then


        local percent = 1

        if self.inst.components.finiteuses then
            percent = self.inst.components.finiteuses:GetPercent()
        end

        for k, v in ipairs(recipe.ingredients) do
            local amt = math.ceil((v.amount * TUNING.HAMMER_LOOT_PERCENT) * percent)
            for n = 1, amt do
                table.insert(loots, v.type)
            end
        end
    end

    return loots
end

function LootDropper:SpawnLootPrefab(lootprefab, pt)
    if lootprefab then
        local loot = SpawnPrefab(lootprefab)
        if loot then
            if not pt then
                pt = Point(self.inst.Transform:GetWorldPosition())
            end

            loot.Transform:SetPosition(pt.x, pt.y, pt.z)

            if loot.Physics then

                local angle = math.random() * 2 * PI
                loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))

                if loot and loot.Physics and self.inst and self.inst.Physics then
                    pt = pt + Vector3(math.cos(angle), 0, math.sin(angle)) * ((loot.Physics:GetRadius() or 1) + (self.inst.Physics:GetRadius() or 1))
                    loot.Transform:SetPosition(pt.x, pt.y, pt.z)
                end

                loot:DoTaskInTime(1,
                        function()
                            if not (loot.components.inventoryitem and loot.components.inventoryitem:IsHeld()) then
                                if not loot:IsOnValidGround() then
                                    local fx = SpawnPrefab("splash_ocean")
                                    local pos = loot:GetPosition()
                                    fx.Transform:SetPosition(pos.x, pos.y, pos.z)
                                    --PlayFX(loot:GetPosition(), "splash", "splash_ocean", "idle")
                                    if loot:HasTag("irreplaceable") then
                                        loot.Transform:SetPosition(GetPlayer().Transform:GetWorldPosition())
                                    else
                                        loot:Remove()
                                    end
                                end
                            end
                        end)
            end

            return loot
        end
    end
end

function LootDropper:DropLoot(pt)
    local prefabs = self:GenerateLoot()
    if not self.inst.components.fueled and self.inst.components.burnable and self.inst.components.burnable:IsBurning() then
        for k, v in pairs(prefabs) do
            local cookedAfter = v .. "_cooked"
            local cookedBefore = "cooked" .. v
            if PrefabExists(cookedAfter) then
                prefabs[k] = cookedAfter
            elseif PrefabExists(cookedBefore) then
                prefabs[k] = cookedBefore
            else
                prefabs[k] = "ash"
            end
        end
    end
    for k, v in pairs(prefabs) do
        self:SpawnLootPrefab(v, pt)
    end
end

local function SplashOceanLoot(loot, cb)
    if loot.components.inventoryitem == nil or not loot.components.inventoryitem:IsHeld() then
        local x, y, z = loot.Transform:GetWorldPosition()
        if not loot:IsOnValidGround() then
            SpawnPrefab("splash_ocean").Transform:SetPosition(x, y, z)
            if loot:HasTag("irreplaceable") then
                loot.Transform:SetPosition(FindSafeSpawnLocation(x, y, z))
            else
                loot:Remove()
            end
            return
        end
    end
    if cb ~= nil then
        cb(loot)
    end
end

function LootDropper:FlingItem(loot, pt, bouncedcb)
    if loot ~= nil then
        if pt == nil then
            pt = self.inst:GetPosition()
        end

        loot.Transform:SetPosition(pt:Get())

        if loot.Physics ~= nil then
            local angle = self.flingtargetpos ~= nil and GetRandomWithVariance(self.inst:GetAngleToPoint(self.flingtargetpos), self.flingtargetvariance or 0) * DEGREES or math.random() * 2 * PI
            local speed = math.random() * 2
            if loot:IsAsleep() then
                local radius = .5 * speed + (self.inst.Physics ~= nil and loot:GetPhysicsRadius(1) + self.inst:GetPhysicsRadius(1) or 0)
                loot.Transform:SetPosition(
                        pt.x + math.cos(angle) * radius,
                        0,
                        pt.z - math.sin(angle) * radius
                )

                SplashOceanLoot(loot, bouncedcb)
            else
                local sinangle = math.sin(angle)
                local cosangle = math.cos(angle)
                loot.Physics:SetVel(speed * cosangle, GetRandomWithVariance(8, 4), speed * -sinangle)

                if self.inst ~= nil and self.inst.Physics ~= nil then
                    local radius = loot:GetPhysicsRadius(1) + self.inst:GetPhysicsRadius(1)
                    loot.Transform:SetPosition(
                            pt.x + cosangle * radius,
                            pt.y,
                            pt.z - sinangle * radius
                    )
                end

                loot:DoTaskInTime(1, SplashOceanLoot, bouncedcb)
            end
        end
    end
end

return LootDropper
