--Here is where you can select a language file to override the default english strings
--The game currently only supports ASCII (sadly), so not all languages can be supported at this time.

require "translator"

--Uncomment this for french!
--LanguageTranslator:LoadPOFile("scripts/languages/french.po", "fr")

if APP_REGION == "SCEJ" then
	LanguageTranslator:LoadPOFile("scripts/languages/japanese.po", "jp")
end

local USE_LONGEST_LOCS = false
LanguageTranslator:UseLongestLocs(USE_LONGEST_LOCS)

function GetCurrentLocale()
    local locale = nil
    if IsRail() then
        local lang_id = LANGUAGE.CHINESE_S_RAIL
        locale =  LOC.GetLocale(lang_id)
    else
        local lang_id = Profile:GetLanguageID()
        locale =  LOC.GetLocale(lang_id)
    end

    return locale
end

LOC.SetCurrentLocale(GetCurrentLocale())

if USE_LONGEST_LOCS then
	for _, id in pairs(LOC.GetLanguages()) do
		local file = LOC.GetStringFile(id)
		local code = LOC.GetLocaleCode(id)
		if file and code then
			LanguageTranslator:LoadPOFile(file, code)
			TheSim:SetUseUnicode(LOC:GetUseUnicode())
		end
	end
else
	local currentLocale = LOC.GetLocale()
    if nil ~= currentLocale then
		local file = LOC.GetStringFile(currentLocale.id)
		if file then
			LanguageTranslator:LoadPOFile(file, currentLocale.code)    
			TheSim:SetUseUnicode(LOC:GetUseUnicode())
		end
    end
end
