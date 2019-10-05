local assets =
{
	 --In-game only
    Asset("ATLAS", "images/hud.xml"),
    Asset("IMAGE", "images/hud.tex"),
    
    Asset("ATLAS", "images/fx.xml"),
    Asset("IMAGE", "images/fx.tex"),

    Asset("ANIM", "anim/clock_transitions.zip"),
    Asset("ANIM", "anim/moon_phases_clock.zip"),
    Asset("ANIM", "anim/moon_phases.zip"),

    Asset("ANIM", "anim/ui_chest_3x3.zip"),
    Asset("ANIM", "anim/ui_backpack_2x4.zip"),
    Asset("ANIM", "anim/ui_bundle_2x2.zip"),    
    Asset("ANIM", "anim/ui_piggyback_2x6.zip"),
    Asset("ANIM", "anim/ui_krampusbag_2x8.zip"),
    Asset("ANIM", "anim/ui_cookpot_1x4.zip"), 
    Asset("ANIM", "anim/ui_krampusbag_2x5.zip"),

    Asset("ANIM", "anim/health.zip"),
    Asset("ANIM", "anim/sanity.zip"),
    Asset("ANIM", "anim/sanity_arrow.zip"),
    Asset("ANIM", "anim/effigy_topper.zip"),
    Asset("ANIM", "anim/hunger.zip"),
    Asset("ANIM", "anim/beaver_meter.zip"),
    Asset("ANIM", "anim/hunger_health_pulse.zip"),
    Asset("ANIM", "anim/spoiled_meter.zip"),
    
    Asset("ANIM", "anim/saving.zip"),
    Asset("ANIM", "anim/vig.zip"),
    Asset("ANIM", "anim/fire_over.zip"),
    Asset("ANIM", "anim/clouds_ol.zip"),

    Asset("ANIM", "anim/progressbar.zip"),   
    
    Asset("ATLAS", "images/fx.xml"),
    Asset("IMAGE", "images/fx.tex"),
    
    Asset("ATLAS", "images/fx6.xml"),
    Asset("IMAGE", "images/fx6.tex"),    
    
    Asset("ATLAS", "images/hud.xml"),
    Asset("IMAGE", "images/hud.tex"),
    
    Asset("ATLAS", "images/inventoryimages.xml"),
    Asset("IMAGE", "images/inventoryimages.tex"),    
}


local prefabs = {
	"minimap",
    "gridplacer",

}

--we don't actually instantiate this prefab. It's used for controlling asset loading
local function fn(Sim)
    return CreateEntity()
end

return Prefab( "UI/interface/hud", fn, assets, prefabs, true )
