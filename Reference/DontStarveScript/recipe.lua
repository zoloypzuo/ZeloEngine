require "class"
require "util"

Ingredient = Class(function(self, type, amount, atlas)
    self.type = type
    self.amount = amount
    self.atlas = (atlas and resolvefilepath(atlas))
            or resolvefilepath("images/inventoryimages.xml")
end)

local num = 0
Recipes = {}

Recipe = Class(function(self, name, ingredients, tab, level, placer, min_spacing, nounlock, numtogive)
    self.name = name
    self.placer = placer
    self.ingredients = ingredients
    self.product = name
    self.tab = tab

    self.atlas = resolvefilepath("images/inventoryimages.xml")

    self.image = name .. ".tex"
    self.sortkey = num
    self.level = level or {}
    self.level.ANCIENT = self.level.ANCIENT or 0
    self.level.MAGIC = self.level.MAGIC or 0
    self.level.SCIENCE = self.level.SCIENCE or 0
    self.level.LOST = self.level.LOST or 0
    self.min_spacing = min_spacing or 3.2

    self.nounlock = nounlock or false

    self.numtogive = numtogive or 1

    num = num + 1
    Recipes[name] = self
end)

function Recipe:GetLevel()
    return self.level
end
function GetAllRecipes()
    return Recipes
end

-- Unlike MergeRecipes this returns the recipes we know about, not just the ones we can craft in this mode
function GetAllKnownRecipes()
    return GetAllRecipes()
end

function GetRecipe(name)
    return Recipes[name]
end
