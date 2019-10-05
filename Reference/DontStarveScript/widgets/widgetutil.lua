
function ShouldHintRecipe(recipetree, buildertree)
    for k,v in pairs(recipetree) do
        if buildertree[tostring(k)] and recipetree[tostring(k)] and
        recipetree[tostring(k)] > buildertree[tostring(k)] + 1 then
            return false
        end
    end
    return true
end

function CanPrototypeRecipe(recipetree, buildertree)
    for k,v in pairs(recipetree) do
        if buildertree[tostring(k)] and recipetree[tostring(k)] and
        recipetree[tostring(k)] > buildertree[tostring(k)] then
                return false
        end
    end
    return true
end

function DoRecipeClick(owner, recipe)
    
    if recipe and owner and owner.components.builder then
        local knows = owner.components.builder:KnowsRecipe(recipe.name)
        local can_build = owner.components.builder:CanBuild(recipe.name)
        
        if not can_build then
            owner:PushEvent("cantbuild", {owner = owner, recipe = recipe})
            --You might have the materials now. Check again.
            can_build = owner.components.builder:CanBuild(recipe.name)
        end

        local buffered = owner.components.builder:IsBuildBuffered(recipe.name)
        
        if knows then
            if buffered then
                --TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                --owner.HUD.controls.crafttabs.tabs:DeselectAll()
                if recipe.placer then
                    owner.components.playercontroller:StartBuildPlacementMode(recipe, function(pt) return owner.components.builder:CanBuildAtPoint(pt, recipe) end)
                else
                    owner.components.builder:MakeRecipe(recipe)
                end
            elseif can_build then
                --TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")           
                if recipe.placer then
                    --owner.HUD.controls.crafttabs.tabs:DeselectAll()
                    owner.components.builder:BufferBuild(recipe.name)
                    owner.components.playercontroller:StartBuildPlacementMode(recipe, function(pt) return owner.components.builder:CanBuildAtPoint(pt, recipe) end)
                else
                    owner.components.builder:MakeRecipe(recipe)
                    return true
                end
            else
                return true
            end
        else
            local tech_level = owner.components.builder.accessible_tech_trees
            
            if can_build and CanPrototypeRecipe(recipe.level, tech_level) then
                owner.SoundEmitter:PlaySound("dontstarve/HUD/research_unlock")
                
                
                local onsuccess = function()
                    owner.components.builder:ActivateCurrentResearchMachine()
                    owner.components.builder:UnlockRecipe(recipe.name)
                end                 
                
                if recipe.placer then
                    onsuccess()
                    owner.components.builder:BufferBuild(recipe.name)
                    owner.components.playercontroller:StartBuildPlacementMode(recipe, function(pt) return owner.components.builder:CanBuildAtPoint(pt, recipe) end)
                else
                    owner.components.builder:MakeRecipe(recipe, nil, onsuccess)
                end
            else
                return true
            end
        end
        
    end
end


