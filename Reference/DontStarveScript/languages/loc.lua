require "constants"

local localizations = 
{
    {id = LANGUAGE.FRENCH,          alt_id = nil,                   strings = "french.po",         code = "fr",    scale = 1.0,  in_steam_menu = false, in_console_menu = true,  shrink_to_fit_word = true },
    {id = LANGUAGE.SPANISH,         alt_id = LANGUAGE.SPANISH_LA,   strings = "spanish.po",        code = "es",    scale = 1.0,  in_steam_menu = false, in_console_menu = true,  shrink_to_fit_word = true },
  --{id = LANGUAGE.SPANISH_LA,      alt_id = nil,                   strings = "spanish_mex.po",    code = "mex",   scale = 1.0,  in_steam_menu = false, in_console_menu = false, shrink_to_fit_word = true },
    {id = LANGUAGE.GERMAN,          alt_id = nil,                   strings = "german.po",         code = "de",    scale = 1.0,  in_steam_menu = false, in_console_menu = true,  shrink_to_fit_word = true },
    {id = LANGUAGE.ITALIAN,         alt_id = nil,                   strings = "italian.po",        code = "it",    scale = 1.0,  in_steam_menu = false, in_console_menu = true,  shrink_to_fit_word = true },  
    {id = LANGUAGE.PORTUGUESE_BR,   alt_id = LANGUAGE.PORTUGUESE,   strings = "portuguese_br.po",  code = "pt",    scale = 1.0,  in_steam_menu = false, in_console_menu = true,  shrink_to_fit_word = true },
    {id = LANGUAGE.POLISH,          alt_id = nil,                   strings = "polish.po",         code = "pl",    scale = 1.0,  in_steam_menu = false, in_console_menu = true,  shrink_to_fit_word = true },
    {id = LANGUAGE.RUSSIAN,         alt_id = nil,                   strings = "russian.po",        code = "ru",    scale = 0.8,  in_steam_menu = false, in_console_menu = true,  shrink_to_fit_word = true }, -- Russian strings are very long (often the longest), and the characters in the font are big. Bad combination.
    {id = LANGUAGE.KOREAN,          alt_id = nil,                   strings = "korean.po",         code = "ko",    scale = 0.85, in_steam_menu = false, in_console_menu = true,  shrink_to_fit_word = false },
    {id = LANGUAGE.CHINESE_S,       alt_id = LANGUAGE.CHINESE_T,    strings = "chinese_s.po",      code = "zh",    scale = 0.85, in_steam_menu = true,  in_console_menu = true,  shrink_to_fit_word = false, use_unicode = true },
    {id = LANGUAGE.CHINESE_S_RAIL,  alt_id = nil,                   strings = "chinese_r.po",      code = "zhr",   scale = 0.85, in_steam_menu = false, in_console_menu = false, shrink_to_fit_word = false, use_unicode = true },
    --{id = LANGUAGE.JAPANESE,      alt_id = nil,                   strings = "japanese.po",     code = "ja",    scale = 0.85, in_console_menu = true},
    --{id = LANGUAGE.CHINESE_T,     alt_id = nil,                   strings = "chinese_t.po",    code = "zh",    scale = 0.85, in_console_menu = true},  
}

local LOC_ROOT_DIR = ""
local EULE_FILENAME = "eula_english.txt"
--if IsXB1() then
--	LOC_ROOT_DIR = "data/scripts/languages/"
--	EULE_FILENAME = "eula_english_x.txt"
--else
	LOC_ROOT_DIR = "scripts/languages/"
	EULE_FILENAME = "eula_english_p.txt"
--end

local LOCALE = { CurrentLocale = nil }

function LOCALE.GetLocaleByCode(lang_code)
    if lang_code == nil then
        return nil
    end

    local locale = nil
    for _, loc in pairs(localizations) do
        if lang_code == loc.code then
            locale = loc
        end
    end
    return locale
end

function LOCALE.SetCurrentLocale(locale)
	LOCALE.CurrentLocale = locale
end

function LOCALE.GetLanguages()
    local lang_options = {}
    table.insert(lang_options, LANGUAGE.ENGLISH)
    for _, loc in pairs(localizations) do
        if IsConsole() then
            if loc.in_console_menu then
                table.insert(lang_options, loc.id)
            end
        elseif not IsRail() then
            if loc.in_steam_menu then
                table.insert(lang_options, loc.id)
            end
        end
    end
    return lang_options
end

function LOCALE.GetLocale(lang_id)
    if lang_id == nil then
        return LOCALE.CurrentLocale
    end

    local locale = nil
    for _, loc in pairs(localizations) do
        if lang_id == loc.id or lang_id == loc.alt_id then
            locale = loc
        end
    end
    return locale
end

function LOCALE.GetLocaleCode(lang_id)
	local locale = LOCALE.GetLocale(lang_id)
	if locale then
		return locale.code
	else
		return "en"
	end
end

function LOCALE.GetLanguage()
    if LOCALE.CurrentLocale then
        return LOCALE.CurrentLocale.id
    else
        return LANGUAGE.ENGLISH
    end
end

function LOCALE.IsLocalized()
	return nil ~= LOCALE.CurrentLocale
end

function LOCALE.GetStringFile(lang_id)
	local locale = LOCALE.GetLocale(lang_id)
	local file = nil
	if nil ~= locale then
		file = LOC_ROOT_DIR .. locale.strings
	end
	
	return file
end

function LOCALE.GetEulaFilename()
    local eula_file = LOC_ROOT_DIR .. EULE_FILENAME
    return eula_file
end

function LOCALE.SwapLanguage(lang_id)
    local locale =  LOCALE.GetLocale(lang_id)
    if nil ~= locale then
        LanguageTranslator:LoadPOFile(LOC_ROOT_DIR .. locale.strings, locale.code)    
    end
    TranslateStringTable( STRINGS )
end

function LOCALE.GetTextScale()
    if nil == LOCALE.CurrentLocale then
        return 1.0
    else
        return LOCALE.CurrentLocale.scale
    end
end

function LOCALE.GetShouldTextFit()
	if LOCALE.CurrentLocale then
		return LOCALE.CurrentLocale.shrink_to_fit_word
	else
		return true
	end
end

function LOCALE.GetUseUnicode()
	if LOCALE.CurrentLocale then
		return LOCALE.CurrentLocale.use_unicode
	else
		return true
	end
end

function LOCALE.GetNamesImageSuffix()
    if LOCALE.CurrentLocale then
        if LOCALE.CurrentLocale.id == LANGUAGE.CHINESE_S or LOCALE.CurrentLocale.id == LANGUAGE.CHINESE_S_RAIL then
            return "_cn"
        end
	end
    return ""
end

return LOCALE