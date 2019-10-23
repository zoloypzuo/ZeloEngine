local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("ANIM", "anim/wagstaff.zip"),
    Asset("ANIM", "anim/player_wagstaff.zip"),
    Asset("ANIM", "anim/wagstaff_face_swap.zip"),
    Asset("ANIM", "anim/player_mount_wagstaff.zip"),
    Asset("SOUNDPACKAGE", "sound/dontstarve_wagstaff.fev"),
    Asset("SOUND", "sound/dontstarve_wagstaff.fsb"),
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs = {

}

local start_inv = { "gogglesnormalhat" }

local function oneat(inst, data)
    -- TODO: say something about the food                    
    if data.food:HasTag("preparedfood") or data.food.components.edible.foodstate == "COOKED" then
        inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "GENERIC"))
    else
        inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_BAD_STOMACH"))
        inst.components.health:DoDelta(-TUNING.HEALING_SMALL)
    end
end

local function checkfilters(inst)
    local health = inst.components.health:GetPercent()

    inst.AnimState:SetFilmGrainStrength(Remap(health, 1, 0, 0, 2))
    --inst.AnimState:SetFilmGrainScale(10)
    inst.AnimState:SetDesaturation(Remap(health, 1, 0, 0, 1))
    inst.AnimState:SetSepia(Remap(health, 1, 0, 0, 0.3))
end

local fn = function(inst)
    inst.soundsname = "wagstaff"
    inst.talker_path_override = "dontstarve_wagstaff/characters/"

    local tinkertab = { str = "TINKER", sort = 999, icon = "tab_fabricate.tex" }
    inst.components.builder:AddRecipeTab(tinkertab)

    inst.AnimState:AddOverrideBuild("player_wagstaff")
    inst:AddTag("wagstaff_inventor")

    inst.components.vision.nearsighted = true

    inst:AddTag("outofworldprojected")
    inst:AddTag("weakstomach")
    inst:AddTag("hasvoiceintensity_health")

    Recipe("gogglesnormalhat", { Ingredient("goldnugget", 1), Ingredient("pigskin", 1) }, tinkertab, { SCIENCE = 0, MAGIC = 0, ANCIENT = 0 })
    Recipe("gogglesheathat", { Ingredient("gogglesnormalhat", 1), Ingredient("transistor", 1), Ingredient("torch", 2) }, tinkertab, { SCIENCE = 0, MAGIC = 0, ANCIENT = 0 })
    Recipe("gogglesarmorhat", { Ingredient("gogglesnormalhat", 1), Ingredient("cutstone", 1) }, tinkertab, { SCIENCE = 0, MAGIC = 0, ANCIENT = 0 })
    Recipe("gogglesshoothat", { Ingredient("gogglesnormalhat", 1), Ingredient("redgem", 1) }, tinkertab, { SCIENCE = 0, MAGIC = 0, ANCIENT = 0 })

    Recipe("telebrella", { Ingredient("transistor", 1), Ingredient("grass_umbrella", 1) }, tinkertab, { SCIENCE = 0, MAGIC = 0, ANCIENT = 0 })

    if not IsDLCEnabled(CAPY_DLC) and not IsDLCEnabled(PORKLAND_DLC) then
        Recipe("telipad", { Ingredient("gears", 1), Ingredient("transistor", 1), Ingredient("cutstone", 2) }, tinkertab, { SCIENCE = 0, MAGIC = 0, ANCIENT = 0 }, "telipad_placer")
        Recipe("thumper", { Ingredient("gears", 1), Ingredient("flint", 6), Ingredient("hammer", 2) }, tinkertab, { SCIENCE = 0, MAGIC = 0, ANCIENT = 0 }, "thumper_placer")
    else
        Recipe("telipad", { Ingredient("gears", 1), Ingredient("transistor", 1), Ingredient("cutstone", 2) }, tinkertab, { SCIENCE = 0, MAGIC = 0, ANCIENT = 0 }, RECIPE_GAME_TYPE.COMMON, "telipad_placer")
        Recipe("thumper", { Ingredient("gears", 1), Ingredient("flint", 6), Ingredient("hammer", 2) }, tinkertab, { SCIENCE = 0, MAGIC = 0, ANCIENT = 0 }, RECIPE_GAME_TYPE.COMMON, "thumper_placer")
    end

    if not IsDLCEnabled(REIGN_OF_GIANTS) and not IsDLCEnabled(CAPY_DLC) and not IsDLCEnabled(PORKLAND_DLC) then
        Recipe("transistor", { Ingredient("goldnugget", 2), Ingredient("cutstone", 1) }, tinkertab, { SCIENCE = 0, MAGIC = 0, ANCIENT = 0 })
    end

    -- makes the parasol always available to wagstaff
    -- Force a merge of the recipe table before modifying an individual recipe
    GetAllRecipes(true)
    local umbrella = GetRecipe("grass_umbrella")
    if umbrella then
        umbrella.level = TECH.NONE
    else
        Recipe("grass_umbrella", { Ingredient("twigs", 4), Ingredient("cutgrass", 3), Ingredient("petals", 6) }, RECIPETABS.SURVIVAL, TECH.NONE, RECIPE_GAME_TYPE.COMMON)
    end

    inst.AnimState:SetFilmGrainStrength(0) --2
    inst.AnimState:SetFilmGrainScale(10)
    inst.AnimState:SetDesaturation(0) -- 1
    inst.AnimState:SetSepia(0) -- 0.1

    inst.oneat = oneat
    inst:ListenForEvent("oneatsomething", inst.oneat)
    inst:ListenForEvent("healthdelta", function()
        checkfilters(inst)
    end)

    inst.checkfilters = checkfilters

    inst.components.hunger:SetMax(TUNING.WILSON_HUNGER * 1.5)
    inst.components.sanity:SetMax(TUNING.WILSON_SANITY * .75)
end

if Profile then
    Profile:UnlockCharacter("wagstaff")
end

return MakePlayerCharacter("wagstaff", prefabs, assets, fn, start_inv)