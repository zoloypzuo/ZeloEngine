require "tuning"

local cookerrecipes = {}
function AddCookerRecipe(cooker, recipe)
	if not cookerrecipes[cooker] then
		cookerrecipes[cooker] = {}
	end
	cookerrecipes[cooker][recipe.name] = recipe
end

local ingredients = {}
function AddIngredientValues(names, tags, cancook, candry)
	for _,name in pairs(names) do
		ingredients[name] = { tags= {}}

		if cancook then
			ingredients[name.."_cooked"] = {tags={}}
		end

		if candry then
			ingredients[name.."_dried"] = {tags={}}
		end

		for tagname,tagval in pairs(tags) do
			ingredients[name].tags[tagname] = tagval
			--print(name,tagname,tagval,ingtable[name].tags[tagname])

			if cancook then
				ingredients[name.."_cooked"].tags.precook = 1
				ingredients[name.."_cooked"].tags[tagname] = tagval
			end
			if candry then
				ingredients[name.."_dried"].tags.dried = 1
				ingredients[name.."_dried"].tags[tagname] = tagval
			end
		end
	end
end

function IsModCookingProduct(cooker, name)
	local enabledmods = ModManager:GetEnabledModNames()
    for i,v in ipairs(enabledmods) do
        local mod = ModManager:GetMod(v)
        if mod.cookerrecipes and mod.cookerrecipes[cooker] and table.contains(mod.cookerrecipes[cooker], name) then
            return true
        end
    end
    return false
end


local fruits = {"pomegranate", "dragonfruit", "cave_banana"}
AddIngredientValues(fruits, {fruit=1}, true)

AddIngredientValues({"berries"}, {fruit=.5}, true)
AddIngredientValues({"durian"}, {fruit=1, monster=1}, true)

AddIngredientValues({"honey", "honeycomb"}, {sweetener=1}, true)

local veggies = {"carrot", "corn", "pumpkin", "eggplant", "cutlichen"}
AddIngredientValues(veggies, {veggie=1}, true)

local mushrooms = {"red_cap", "green_cap", "blue_cap"}
AddIngredientValues(mushrooms, {veggie=.5}, true)

AddIngredientValues({"meat"}, {meat=1}, true, true)
AddIngredientValues({"monstermeat"}, {meat=1, monster=1}, true, true)
AddIngredientValues({"froglegs", "drumstick"}, {meat=.5}, true)
AddIngredientValues({"smallmeat"}, {meat=.5}, true, true)

AddIngredientValues({"fish", "eel"}, {meat=.5,fish=1}, true)


AddIngredientValues({"mandrake"}, {veggie=1, magic=1}, true)
AddIngredientValues({"egg"}, {egg=1}, true)
AddIngredientValues({"tallbirdegg"}, {egg=4}, true)
AddIngredientValues({"bird_egg"}, {egg=1}, true)
AddIngredientValues({"butterflywings"}, {decoration=2})
AddIngredientValues({"butter"}, {fat=1, dairy=1})
AddIngredientValues({"twigs"}, {inedible=1})
AddIngredientValues({"twigs"}, {inedible=1})



--our naming conventions aren't completely consistent, sadly
local aliases=
{
	cookedsmallmeat = "smallmeat_cooked",
	cookedmonstermeat = "monstermeat_cooked",
	cookedmeat = "meat_cooked"
}

local function IsCookingIngredient(prefabname)
	local name = aliases[prefabname] or prefabname
	if ingredients[name] then
		return true
	end

end

local null_ingredient = {tags={}}
local function GetIngredientData(prefabname)
	local name = aliases.prefabname or prefabname

	return ingredients[name] or null_ingredient
end


local foods = require("preparedfoods")
for k,recipe in pairs (foods) do
	AddCookerRecipe("cookpot", recipe)
end

local function GetIngredientValues(prefablist)
	local prefabs = {}
	local tags = {}
	for k,v in pairs(prefablist) do
		local name = aliases[v] or v
		prefabs[name] = prefabs[name] and prefabs[name] + 1 or 1
		local data = GetIngredientData(name)

		if data then

			for kk, vv in pairs(data.tags) do

				tags[kk] = tags[kk] and tags[kk] + vv or vv
			end
		end
	end

	return {tags = tags, names = prefabs}
end



function GetCandidateRecipes(cooker, ingdata)

	local recipes = cookerrecipes[cooker] or {}
	local candidates = {}

	--find all potentially valid recipes
	for k,v in pairs(recipes) do
		if v.test(cooker, ingdata.names, ingdata.tags) then
			table.insert(candidates, v)
		end
	end

	table.sort( candidates, function(a,b) return (a.priority or 0) > (b.priority or 0) end )
	if #candidates > 0 then
		--find the set of highest priority recipes
		local top_candidates = {}
		local idx = 1
		local val = candidates[1].priority or 0

		for k,v in ipairs(candidates) do
			if k > 1 and (v.priority or 0) < val then
				break
			end
			table.insert(top_candidates, v)
		end
		return top_candidates
	end

	return candidates
end



local function CalculateRecipe(cooker, names)


	local ingdata = GetIngredientValues(names)
	local candidates = GetCandidateRecipes(cooker, ingdata)

	table.sort( candidates, function(a,b) return (a.weight or 1) > (b.weight or 1) end )
	local total = 0
	for k,v in pairs(candidates) do
		total = total + (v.weight or 1)
	end

	local val = math.random()*total
	local idx = 1
	while idx <= #candidates do
		val = val - candidates[idx].weight
		if val <= 0 then
			return candidates[idx].name, candidates[idx].cooktime or 1
		end

		idx = idx+1
	end

end



local function TestRecipes(cooker, prefablist)
	local ingdata = GetIngredientValues(prefablist)

	print ("Ingredients:")
	for k,v in pairs(prefablist) do
		if not IsCookingIngredient(v) then
			print ("NOT INGREDIENT:", v)
		end
	end

	for k,v in pairs(ingdata.names) do
		print (v,k)
	end

	print ("\nIngredient tags:")
	for k,v in pairs(ingdata.tags) do
		print (tostring(v), k)
	end

	print ("\nPossible recipes:")
	local candidates = GetCandidateRecipes(cooker, ingdata)
	for k,v in pairs(candidates) do
		print("\t"..v.name, v.weight or 1)
	end

	local recipe = CalculateRecipe(cooker, prefablist)
	print ("Make:", recipe)


	print ("total health:", foods[recipe].health)
	print ("total hunger:", foods[recipe].hunger)

end

--TestRecipes("cookpot", {"tallbirdegg","meat","carrot","meat"})


return { CalculateRecipe = CalculateRecipe, IsCookingIngredient = IsCookingIngredient, recipes = cookerrecipes, ingredients=ingredients}

