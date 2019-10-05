local assets =
{
  --FE

    Asset("ANIM", "anim/credits.zip"),
    Asset("ANIM", "anim/credits2.zip"),

    Asset("ATLAS", "bigportraits/locked.xml"),
    Asset("IMAGE", "bigportraits/locked.tex"),
    
    Asset("IMAGE", "images/customisation.tex" ),
    Asset("ATLAS", "images/customisation.xml" ),
    
	Asset("ATLAS", "images/selectscreen_portraits.xml"),
	Asset("IMAGE", "images/selectscreen_portraits.tex"),
	
    Asset("ANIM", "anim/portrait_frame.zip"),

    --Asset("ANIM", "anim/build_status.zip"),
	Asset("ANIM",  "anim/corner_dude.zip"),    
    Asset("ANIM", "anim/savetile.zip"),
    Asset("ANIM", "anim/savetile_small.zip"),
}

if PLATFORM == "PS4" then
    table.insert(assets, Asset("ATLAS", "images/ps4.xml"))
    table.insert(assets, Asset("IMAGE", "images/ps4.tex"))
    table.insert(assets, Asset("ATLAS", "images/ps4_controllers.xml"))
    table.insert(assets, Asset("IMAGE", "images/ps4_controllers.tex"))
    table.insert(assets, Asset("ANIM", "anim/animated_title.zip"))
    table.insert(assets, Asset("ANIM", "anim/title_fire.zip"))
end


-- Add all the characters by name
local charlist = GetActiveCharacterList and GetActiveCharacterList() or MAIN_CHARACTERLIST
for i,char in ipairs(charlist) do
	table.insert(assets, Asset("ATLAS", "bigportraits/"..char..".xml"))
	table.insert(assets, Asset("IMAGE", "bigportraits/"..char..".tex"))
	--table.insert(assets, Asset("IMAGE", "images/selectscreen_portraits/"..char..".tex"))
	--table.insert(assets, Asset("IMAGE", "images/selectscreen_portraits/"..char.."_silho.tex"))
end

--we don't actually instantiate this prefab. It's used for controlling asset loading
local function fn(Sim)
    return CreateEntity()
end

return Prefab( "UI/interface/frontend", fn, assets) 
