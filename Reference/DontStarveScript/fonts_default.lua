local RAIL = true

DEFAULTFONT = "opensans"
DIALOGFONT = "opensans"
TITLEFONT = "bp100"
UIFONT = "bp50"
BUTTONFONT="buttonfont"
NUMBERFONT = "stint-ucr"
TALKINGFONT = "talkingfont"
TALKINGFONT_WATHGRITHR = "talkingfont_wathgrithr"
TALKINGFONT_WORMWOOD = "talkingfont_wormwood"
SMALLNUMBERFONT = "stint-small"
BODYTEXTFONT = "stint-ucr"

CONTROLLERS = "controllers"

FALLBACK_FONT = "fallback_font"
FALLBACK_FONT_OUTLINE = "fallback_font_outline"

DEFAULT_FALLBACK_TABLE = {
	CONTROLLERS,
	FALLBACK_FONT,
}

DEFAULT_FALLBACK_TABLE_OUTLINE = {
	CONTROLLERS,
	FALLBACK_FONT_OUTLINE,
}

require "translator"

local font_posfix = ""

if LanguageTranslator then	-- This gets called from the build pipeline too
    local lang = LanguageTranslator.defaultlang 

    -- Some languages need their own font
    local specialFontLangs = {"jp"}

    for i,v in pairs(specialFontLangs) do
        if v == lang then
            font_posfix = "__"..lang
        end
    end
end

FONTS = {
	{ filename = "fonts/talkingfont"..font_posfix..".zip", alias = TALKINGFONT, fallback = DEFAULT_FALLBACK_TABLE_OUTLINE },
	{ filename = "fonts/talkingfont_wathgrithr.zip", alias = TALKINGFONT_WATHGRITHR , fallback = DEFAULT_FALLBACK_TABLE_OUTLINE},
    { filename = "fonts/talkingfont_wormwood.zip", alias = TALKINGFONT_WORMWOOD,  fallback = DEFAULT_FALLBACK_TABLE_OUTLINE},
	{ filename = "fonts/stint-ucr50"..font_posfix..".zip", alias = BODYTEXTFONT , fallback = DEFAULT_FALLBACK_TABLE_OUTLINE},
	{ filename = "fonts/stint-ucr20"..font_posfix..".zip", alias = SMALLNUMBERFONT, fallback = DEFAULT_FALLBACK_TABLE_OUTLINE },
	{ filename = "fonts/opensans50"..font_posfix..".zip", alias = DEFAULTFONT, fallback = DEFAULT_FALLBACK_TABLE_OUTLINE },
	{ filename = "fonts/belisaplumilla50"..font_posfix..".zip", alias = UIFONT, fallback = DEFAULT_FALLBACK_TABLE_OUTLINE, adjustadvance=-2 },
	{ filename = "fonts/belisaplumilla100"..font_posfix..".zip", alias = TITLEFONT, fallback = DEFAULT_FALLBACK_TABLE_OUTLINE },	
	{ filename = "fonts/buttonfont"..font_posfix..".zip", alias = BUTTONFONT, fallback = DEFAULT_FALLBACK_TABLE },	

	{ filename = "fonts/controllers"..font_posfix..".zip", alias = CONTROLLERS},

	{ filename = "fonts/fallback_full_packed"..font_posfix..".zip", alias = FALLBACK_FONT},
	{ filename = "fonts/fallback_full_outline_packed"..font_posfix..".zip", alias = FALLBACK_FONT_OUTLINE},
}
