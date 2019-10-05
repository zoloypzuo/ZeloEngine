local assets =
{
	Asset("IMAGE", "images/colour_cubes/day05_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/dusk03_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/night03_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/snow_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/snowdusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/night04_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/insane_day_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/insane_dusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/insane_night_cc.tex"),

	Asset("SHADER", "shaders/flood.ksh"),


	Asset("FILE", "images/motd.xml"),

    Asset("ANIM", "anim/snow.zip"),
    Asset("ANIM", "anim/lightning.zip"),
    Asset("ANIM", "anim/splash_ocean.zip"),
    Asset("ANIM", "anim/frozen.zip"),

    Asset("SOUND", "sound/forest_stream.fsb"),
	Asset("IMAGE", "levels/textures/snow.tex"),
	Asset("IMAGE", "images/wave.tex"),

	-- More dependency things
	Asset("SCRIPT", "scripts/prefabs/brokenwalls.lua"),
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset("SCRIPT", "scripts/prefabs/paired_maxwelllight.lua"),
	Asset("SCRIPT", "scripts/prefabs/phonograph.lua"),
	Asset("SCRIPT", "scripts/prefabs/unlockable_players.lua"),
	Asset("SCRIPT", "scripts/prefabs/devtool.lua"),
	Asset("SCRIPT", "scripts/prefabs/nightlight_flame.lua"),
	Asset("SCRIPT", "scripts/prefabs/stairs.lua"),
	Asset("SCRIPT", "scripts/prefabs/tree_clump.lua"),
	Asset("SCRIPT", "scripts/prefabs/devtool.lua"),
	Asset("SCRIPT", "scripts/prefabs/researchmachine.lua"),
	Asset("SCRIPT", "scripts/prefabs/ruin.lua"),

	-- References added for prefabs that don't have the INV_IMAGE
	-- automatically recognized
	Asset("INV_IMAGE", "bag"),
	Asset("INV_IMAGE", "clothes"),
	Asset("INV_IMAGE", "bucket"),
	Asset("INV_IMAGE", "snowball"),
	Asset("INV_IMAGE", "truffle"),
	Asset("INV_IMAGE", "scarecrow"),
	Asset("INV_IMAGE", "stopwatch"),
	Asset("INV_IMAGE", "skull_wallace"),
	Asset("INV_IMAGE", "skull_waverly"),
	Asset("INV_IMAGE", "skull_webber"),
	Asset("INV_IMAGE", "skull_wilbur"),
	Asset("INV_IMAGE", "skull_wilton"),
	Asset("INV_IMAGE", "skull_winnie"),
	Asset("INV_IMAGE", "skull_wortox"),
	Asset("INV_IMAGE", "phonograph"),
	Asset("INV_IMAGE", "record_01"),
	Asset("INV_IMAGE", "record_02"),
	Asset("INV_IMAGE", "record_03"),

	-- ROG references for the atlas building process to work properly
	Asset("INV_IMAGE", "acorn"),
	Asset("INV_IMAGE", "acorn_cooked"),
	Asset("INV_IMAGE", "armordragonfly"),
	Asset("INV_IMAGE", "bearger_fur"),
	Asset("INV_IMAGE", "beargervest"),
	Asset("INV_IMAGE", "bell"),
	Asset("INV_IMAGE", "boneshard"),
	Asset("INV_IMAGE", "cactus_flower"),
	Asset("INV_IMAGE", "cactus_meat"),
	Asset("INV_IMAGE", "cactus_meat_cooked"),
	Asset("INV_IMAGE", "catcoonhat"),
	Asset("INV_IMAGE", "coldfire"),
	Asset("INV_IMAGE", "coldfirepit"),
	Asset("INV_IMAGE", "coontail"),
	Asset("INV_IMAGE", "dragon_scales"),
	Asset("INV_IMAGE", "dragonflychest"),
	Asset("INV_IMAGE", "dug_cactus"),
	Asset("INV_IMAGE", "eyebrella"),
	Asset("INV_IMAGE", "eyebrellahat"),
	Asset("INV_IMAGE", "featherfan"),
	Asset("INV_IMAGE", "fertilizer"),
	Asset("INV_IMAGE", "firesuppressor"),
	Asset("INV_IMAGE", "flowersalad"),
	Asset("INV_IMAGE", "glommerflower"),
	Asset("INV_IMAGE", "glommerflower_dead"),
	Asset("INV_IMAGE", "glommerfuel"),
	Asset("INV_IMAGE", "glommerwings"),
	Asset("INV_IMAGE", "goatmilk"),
	Asset("INV_IMAGE", "goose_feather"),
	Asset("INV_IMAGE", "grass_umbrella"),
	Asset("INV_IMAGE", "guacamole"),
	Asset("INV_IMAGE", "hawaiianshirt"),
	Asset("INV_IMAGE", "hotchili"),
	Asset("INV_IMAGE", "ice"),
	Asset("INV_IMAGE", "icecream"),
	Asset("INV_IMAGE", "icehat"),
	Asset("INV_IMAGE", "icepack"),
	Asset("INV_IMAGE", "lightninggoathorn"),
	Asset("INV_IMAGE", "mole"),
	Asset("INV_IMAGE", "molehat"),
	Asset("INV_IMAGE", "nightstick"),
	Asset("INV_IMAGE", "raincoat"),
	Asset("INV_IMAGE", "rainhat"),
	Asset("INV_IMAGE", "reflectivevest"),
	Asset("INV_IMAGE", "siestahut"),
	Asset("INV_IMAGE", "spear_wathgrithr"),
	Asset("INV_IMAGE", "staff_tornado"),
	Asset("INV_IMAGE", "trailmix"),
	Asset("INV_IMAGE", "transistor"),
	Asset("INV_IMAGE", "turf_deciduous"),
	Asset("INV_IMAGE", "turf_desertdirt"),
	Asset("INV_IMAGE", "turf_fungus_green"),
	Asset("INV_IMAGE", "turf_fungus_red"),
	Asset("INV_IMAGE", "turf_webbing"),
	Asset("INV_IMAGE", "watermelon"),
	Asset("INV_IMAGE", "watermelon_cooked"),
	Asset("INV_IMAGE", "watermelon_seeds"),
	Asset("INV_IMAGE", "watermelonhat"),
	Asset("INV_IMAGE", "watermelonicle"),
	Asset("INV_IMAGE", "wathgrithrhat"),

	Asset("MINIMAP_IMAGE", "Willow"),
	Asset("MINIMAP_IMAGE", "Wilton"),
	Asset("MINIMAP_IMAGE", "buzzard"),
	Asset("MINIMAP_IMAGE", "cactus"),
	Asset("MINIMAP_IMAGE", "catcoonden"),
	Asset("MINIMAP_IMAGE", "parrot_pirate"),
	Asset("MINIMAP_IMAGE", "wathgrithr"),
	Asset("MINIMAP_IMAGE", "webber"),
	Asset("MINIMAP_IMAGE", "wheat"),
	Asset("MINIMAP_IMAGE", "winnie"),
	Asset("MINIMAP_IMAGE", "wortox"),
	Asset("MINIMAP_IMAGE", "coldfirepit"),
	Asset("MINIMAP_IMAGE", "dragonflychest"),
	Asset("MINIMAP_IMAGE", "firesuppressor"),
	Asset("MINIMAP_IMAGE", "glommer"),
	Asset("MINIMAP_IMAGE", "iceboulder"),
	Asset("MINIMAP_IMAGE", "icepack"),
	Asset("MINIMAP_IMAGE", "siestahut"),
	Asset("MINIMAP_IMAGE", "statue_glommer"),
	Asset("MINIMAP_IMAGE", "tree_leaf"),
	Asset("MINIMAP_IMAGE", "phonograph"),


}

local forest_prefabs = 
{
	"world",
	"adventure_portal",
	"resurrectionstone",
    "deerclops",
    "gravestone",
    "flower",
    "animal_track",
    "dirtpile",
    "beefaloherd",
    "beefalo",
    "penguinherd",
    "penguin_ice",
    "penguin",
    "koalefant_summer",
    "koalefant_winter",
    "beehive",
	"wasphive",
    "walrus_camp",
    "pighead",
    "mermhead",
    "rabbithole",
    "carrot_planted",
    "tentacle",
	"wormhole",
    "cave_entrance",
	"teleportato_base",
	"teleportato_ring",
	"teleportato_box",
	"teleportato_crank",
	"teleportato_potato",
	"pond", 
	"marsh_tree", 
	"marsh_bush", 
	"reeds", 
	"mist",
	"snow",
	"rain",
	"maxwellthrone",
	"maxwellendgame",
	"maxwelllight",
	"horizontal_maxwelllight",	
	"vertical_maxwelllight",	
	"quad_maxwelllight",	
	"area_maxwelllight",
	"maxwelllock",
	"maxwellphonograph",
	"puppet_wilson",
	"puppet_willow",
	"puppet_wendy",
	"puppet_wickerbottom",
	"puppet_wolfgang",
	"puppet_wx78",
	"puppet_wes",
	"marblepillar",
	"marbletree",
	"statueharp",
	"statuemaxwell",
	"eyeplant",
	"lureplant",
	"purpleamulet",
	"monkey",
	"livingtree",
    "sunken_boat",
    "flotsam",

    -- Added here due to dependency issues
    "accomplishment_shrine",
    "anim_test",
    "bonfire",
    "brokenwalls",
    "deadlyfeast",
    "dropperweb",
    "lanternfire",
  	"lavalight",
  	"lightning",
  	"maxwellhead",
	"maxwellhead_trigger",
	"maxwellintro",
	"maxwellkey",
	"mistarea",
	"nightmare_flame",
	"paired_maxwelllight",
	"phonograph",
	"plant_normal",
	"player_common",
	"portal_home",
	"portal_level",
	"researchmachine",
	"rubble",
  	"ruin",
  	"sinkhole",
  	"sounddebugicon",
  	"staff_castinglight",
  	"stairs",
  	"sunkboat",
	"teamleader",
	"teleportato_checkmate",
	"teleportlocation",
	"tree_clump",
	"unlockable_players",
	"nightlight_flame",

	"spat",
	"transistor",
}

local function fn(Sim)

	local inst = SpawnPrefab("world")
	inst.prefab = "forest"
	inst.entity:SetCanSleep(false)
	
	
	--add waves
	local waves = inst.entity:AddWaveComponent()
    inst.WaveComponent:SetRegionSize(13.5, 2.5)						-- wave texture u repeat, forward distance between waves
    inst.WaveComponent:SetWaveSize(80, 3.5)							-- wave mesh width and height
	waves:SetWaveTexture( "images/wave.tex" )

	-- See source\game\components\WaveRegion.h
	waves:SetWaveEffect( "shaders/waves.ksh" ) -- texture.ksh
	--waves:SetWaveEffect( "shaders/texture.ksh" ) -- 
    inst:AddComponent("clock")

	inst:AddComponent("seasonmanager")
    inst:AddComponent("birdspawner")
    inst:AddComponent("butterflyspawner")
	inst:AddComponent("hounded")
	inst:AddComponent("basehassler")
	inst:AddComponent("hunter")
	
    inst.components.butterflyspawner:SetButterfly("butterfly")

	inst:AddComponent("frograin")

	inst:AddComponent("lureplantspawner")
	inst:AddComponent("penguinspawner")

	inst:AddComponent("colourcubemanager")
	inst.Map:SetOverlayTexture( "levels/textures/snow.tex" )

    return inst
end

return Prefab( "forest", fn, assets, forest_prefabs) 
