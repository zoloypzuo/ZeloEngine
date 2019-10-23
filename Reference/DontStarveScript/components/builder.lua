local Builder = Class(function(self, inst)
    self.inst = inst
    self.recipes = {}
    self.recipe_count = 0
    self.accessible_tech_trees = TECH.NONE
    self.inst:StartUpdatingComponent(self)
    self.current_prototyper = nil
    self.buffered_builds = {}
    self.bonus_tech_level = 0
    self.science_bonus = 0
    self.magic_bonus = 0
    self.ancient_bonus = 0
    self.lost_bonus = 0
    self.custom_tabs = {}
    self.ingredientmod = 1

end)

function Builder:ActivateCurrentResearchMachine()
    if self.current_prototyper and
            self.current_prototyper.components.prototyper and
            self.current_prototyper:IsValid() then
        self.current_prototyper.components.prototyper:Activate()
    end
end

function Builder:AddRecipeTab(tab)
    table.insert(self.custom_tabs, tab)
end

function Builder:OnSave()
    local data = {
        buffered_builds = self.buffered_builds
    }

    data.recipes = self.recipes

    return data
end

function Builder:OnLoad(data)


    if data.buffered_builds then
        self.buffered_builds = data.buffered_builds
    end

    if data.recipes then
        for k, v in pairs(data.recipes) do
            self:AddRecipe(v)
        end
    end
end

function Builder:IsBuildBuffered(recipe)
    return self.buffered_builds[recipe] == true
end

function Builder:BufferBuild(recipe)
    self:RemoveIngredients(recipe)
    self.buffered_builds[recipe] = true
end

function Builder:OnUpdate(dt)
    self:EvaluateTechTrees()
end

function Builder:GiveAllRecipes()
    if self.freebuildmode then
        self.freebuildmode = false
    else
        self.freebuildmode = true
    end
    self.inst:PushEvent("unlockrecipe")
end

function Builder:UnlockRecipesForTech(tech)

    local propertech = function(recipetree, buildertree)
        for k, v in pairs(recipetree) do
            if buildertree[tostring(k)] and recipetree[tostring(k)] and
                    recipetree[tostring(k)] > buildertree[tostring(k)] then
                return false
            end
        end
        return true
    end

    local recipes = GetAllRecipes()
    for k, v in pairs(recipes) do
        if propertech(v.level, tech) then
            self:UnlockRecipe(v.name)
        end
    end
end

function Builder:CanBuildAtPoint(pt, recipe)

    local ground = GetWorld()
    local tile = GROUND.GRASS
    if ground and ground.Map then
        tile = ground.Map:GetTileAtPoint(pt:Get())
    end

    if tile == GROUND.IMPASSABLE then
        return false
    else
        local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 6, nil, { 'player', 'fx', 'NOBLOCK' }) -- or we could include a flag to the search?
        for k, v in pairs(ents) do
            if v ~= self.inst and (not v.components.placer) and v.entity:IsVisible() and not (v.components.inventoryitem and v.components.inventoryitem.owner) then
                local min_rad = recipe.min_spacing or 2 + 1.2
                --local rad = (v.Physics and v.Physics:GetRadius() or 1) + 1.25

                --stupid finalling hack because it's too late to change stuff
                if recipe.name == "treasurechest" and v.prefab == "pond" then
                    min_rad = min_rad + 1
                end

                local dsq = distsq(Vector3(v.Transform:GetWorldPosition()), pt)
                if dsq <= min_rad * min_rad then
                    return false
                end
            end
        end
    end

    return true
end

function Builder:EvaluateTechTrees()
    local pos = self.inst:GetPosition()
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.RESEARCH_MACHINE_DIST, { "prototyper" })

    local old_accessible_tech_trees = deepcopy(self.accessible_tech_trees or TECH.NONE)
    local old_prototyper = self.current_prototyper
    self.current_prototyper = nil

    local prototyper_active = false
    for k, v in pairs(ents) do
        if v.components.prototyper then
            if not prototyper_active then
                --activate the first machine in the list. This will be the one you're closest to.
                v.components.prototyper:TurnOn()
                self.accessible_tech_trees = v.components.prototyper:GetTechTrees()
                prototyper_active = true
                self.current_prototyper = v
            else
                --you've already activated a machine. Turn all the other machines off.
                v.components.prototyper:TurnOff()
            end
        end
    end

    --add any character specific bonuses to your current tech levels.
    if not prototyper_active then
        self.accessible_tech_trees.SCIENCE = self.science_bonus
        self.accessible_tech_trees.MAGIC = self.magic_bonus
        self.accessible_tech_trees.ANCIENT = self.ancient_bonus
    else
        self.accessible_tech_trees.SCIENCE = self.accessible_tech_trees.SCIENCE + self.science_bonus
        self.accessible_tech_trees.MAGIC = self.accessible_tech_trees.MAGIC + self.magic_bonus
        self.accessible_tech_trees.ANCIENT = self.accessible_tech_trees.ANCIENT + self.ancient_bonus
    end

    local trees_changed = false

    for k, v in pairs(old_accessible_tech_trees) do
        if v ~= self.accessible_tech_trees[k] then
            trees_changed = true
            break
        end
    end
    if not trees_changed then
        for k, v in pairs(self.accessible_tech_trees) do
            if v ~= old_accessible_tech_trees[k] then
                trees_changed = true
                break
            end
        end
    end

    if old_prototyper and old_prototyper.components.prototyper and old_prototyper:IsValid() and old_prototyper ~= self.current_prototyper then
        old_prototyper.components.prototyper:TurnOff()
    end

    if trees_changed then
        self.inst:PushEvent("techtreechange", { level = self.accessible_tech_trees })
    end
end

function Builder:AddRecipe(rec)
    if table.contains(self.recipes, rec) == false then
        table.insert(self.recipes, rec)
        self.recipe_count = self.recipe_count + 1
    end
end

function Builder:UnlockRecipe(recname)
    local recipe = GetRecipe(recname)

    if recipe ~= nil and not recipe.nounlock then
        --print("Unlocking: ", recname)
        if self.inst.components.sanity then
            self.inst.components.sanity:DoDelta(TUNING.SANITY_MED)
        end

        self:AddRecipe(recname)
        self.inst:PushEvent("unlockrecipe", { recipe = recname })
    end
end

function Builder:RemoveIngredients(recname)
    local recipe = GetRecipe(recname)
    self.inst:PushEvent("consumeingredients", { recipe = recipe })
    if recipe then
        for k, v in pairs(recipe.ingredients) do
            local amt = math.max(1, RoundUp(v.amount * self.ingredientmod))
            self.inst.components.inventory:ConsumeByName(v.type, amt)
        end
    end
end

function Builder:OnSetProfile(profile)
end

function Builder:MakeRecipe(recipe, pt, onsuccess)
    if recipe then
        self.inst:PushEvent("makerecipe", { recipe = recipe })
        pt = pt or Point(self.inst.Transform:GetWorldPosition())
        if self:IsBuildBuffered(recipe.name) or self:CanBuild(recipe.name) then
            self.inst.components.locomotor:Stop()
            local buffaction = BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, pt, recipe.name, 1)
            if onsuccess then
                buffaction:AddSuccessAction(onsuccess)
            end

            self.inst.components.locomotor:PushAction(buffaction, true)

            return true
        end
    end
    return false
end

function Builder:DoBuild(recname, pt)
    local recipe = GetRecipe(recname)
    local buffered = self:IsBuildBuffered(recname)

    if recipe and self:IsBuildBuffered(recname) or self:CanBuild(recname) then

        if self.buffered_builds[recname] then
            self.buffered_builds[recname] = nil
        else
            self:RemoveIngredients(recname)
        end

        local prod = SpawnPrefab(recipe.product)
        if prod then
            if prod.components.inventoryitem then
                if self.inst.components.inventory then

                    --self.inst.components.inventory:GiveItem(prod)
                    self.inst:PushEvent("builditem", { item = prod, recipe = recipe })
                    ProfileStatsAdd("build_" .. prod.prefab)

                    if prod.components.equippable and not self.inst.components.inventory:GetEquippedItem(prod.components.equippable.equipslot) then
                        --The item is equippable. Equip it.
                        self.inst.components.inventory:Equip(prod)

                        if recipe.numtogive > 1 then
                            --Looks like the recipe gave more than one item! Spawn in the rest and give them to the player.
                            for i = 2, recipe.numtogive do
                                local addt_prod = SpawnPrefab(recipe.product)
                                self.inst.components.inventory:GiveItem(addt_prod, nil, TheInput:GetScreenPosition())
                            end
                        end

                    else

                        if recipe.numtogive > 1 and prod.components.stackable then
                            --The item is stackable. Just increase the stack size of the original item.
                            prod.components.stackable:SetStackSize(recipe.numtogive)
                            self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
                        elseif recipe.numtogive > 1 and not prod.components.stackable then
                            --We still need to give the player the original product that was spawned, so do that.
                            self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
                            --Now spawn in the rest of the items and give them to the player.
                            for i = 2, recipe.numtogive do
                                local addt_prod = SpawnPrefab(recipe.product)
                                self.inst.components.inventory:GiveItem(addt_prod, nil, TheInput:GetScreenPosition())
                            end
                        else
                            --Only the original item is being received.
                            self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
                        end
                    end

                    if self.onBuild then
                        self.onBuild(self.inst, prod)
                    end
                    prod:OnBuilt(self.inst)

                    return true
                end
            else

                pt = pt or Point(self.inst.Transform:GetWorldPosition())
                prod.Transform:SetPosition(pt.x, pt.y, pt.z)
                self.inst:PushEvent("buildstructure", { item = prod, recipe = recipe })
                prod:PushEvent("onbuilt")
                ProfileStatsAdd("build_" .. prod.prefab)

                if self.onBuild then
                    self.onBuild(self.inst, prod)
                end

                prod:OnBuilt(self.inst)

                if buffered then
                    GetPlayer().HUD.controls.crafttabs:UpdateRecipes()
                end

                return true
            end

        end
    end


end

function Builder:KnowsRecipe(recname)
    local recipe = GetRecipe(recname)

    if recipe and recipe.level.ANCIENT <= self.ancient_bonus and recipe.level.MAGIC <= self.magic_bonus and recipe.level.SCIENCE <= self.science_bonus and recipe.level.LOST <= self.lost_bonus then
        return true
    end

    return self.freebuildmode or table.contains(self.recipes, recname)
end

function Builder:CanBuild(recname)

    if self.freebuildmode then
        return true
    end

    local recipe = GetRecipe(recname)
    if recipe then
        for ik, iv in pairs(recipe.ingredients) do
            local amt = math.max(1, RoundUp(iv.amount * self.ingredientmod))
            if not self.inst.components.inventory:Has(iv.type, amt) then
                return false
            end
        end
        return true
    end

    return false
end

return Builder
