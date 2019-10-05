--This file is separate from strings.lua so that UTF-8 strings won't be in that file causing problems with encoding in certain editors.

--From constants.lua, manually including here to minimize require dependencies in strings pipeline.
local _LANGUAGE = 
{
    ENGLISH = 0,
    ENGLISH_UK = 1,
    FRENCH = 2,
    FRENCH_CA = 3,
    SPANISH = 4,
    SPANISH_LA = 5,
    GERMAN = 6,
    ITALIAN = 7,
    PORTUGUESE = 8,
    PORTUGUESE_BR = 9,
    DUTCH = 10,
    FINNISH = 11,
    SWEDISH = 12,
    DANISH = 13,
    NORWEGIAN = 14,
    POLISH = 15,
    RUSSIAN = 16,
    TURKISH = 17,
    ARABIC = 18,
    KOREAN = 19,
    JAPANESE = 20,
    CHINESE_T = 21,
    CHINESE_S = 22,
    CHINESE_S_RAIL = 23,
}

STRINGS.PRETRANSLATED =
{
    LANGUAGES =
    {
        [_LANGUAGE.ENGLISH] = "English",
        [_LANGUAGE.FRENCH] = "Français (French)",
        [_LANGUAGE.SPANISH] = "Español (Spanish)",
        [_LANGUAGE.SPANISH_LA] = "Español - América Latina\n(Spanish - Latin America)",
        [_LANGUAGE.GERMAN] = "Deutsch (German)",
        [_LANGUAGE.ITALIAN] = "Italiano (Italian)",
        [_LANGUAGE.PORTUGUESE_BR] = "Português (Portuguese)",
        [_LANGUAGE.POLISH] = "Polski (Polish)",
        [_LANGUAGE.RUSSIAN] = "Русский (Russian)",
        [_LANGUAGE.KOREAN] = "한국어 (Korean)",
        [_LANGUAGE.CHINESE_S] = "简体中文 (Simplified Chinese)",
    },
    
    LANGUAGES_TITLE =
    {
        [_LANGUAGE.ENGLISH] = "Translation Option",
        [_LANGUAGE.FRENCH] = "Option de traduction",
        [_LANGUAGE.SPANISH] = "Opción de traducción",
        [_LANGUAGE.SPANISH_LA] = "Opción de traducción",
        [_LANGUAGE.GERMAN] = "Übersetzungsoption",
        [_LANGUAGE.ITALIAN] = "Opzione di traduzione",
        [_LANGUAGE.PORTUGUESE_BR] = "Opção de Tradução",
        [_LANGUAGE.POLISH] = "Opcja tłumaczenia",
        [_LANGUAGE.RUSSIAN] = "Вариант перевода",
        [_LANGUAGE.KOREAN] = "번역 옵션",
        [_LANGUAGE.CHINESE_S] = "语言设定",
    }, 

	LANGUAGES_BODY =
    {
        [_LANGUAGE.ENGLISH] = "Your interface language is set to English. Would you like to enable the translation for your language?",
        [_LANGUAGE.FRENCH] = "Votre langue d'interface est définie sur Français. Voulez-vous activer la traduction pour votre langue?",
        [_LANGUAGE.SPANISH] = "El idioma de la interfaz está configurado a español. ¿Quieres permitir la traducción a tu idioma?",
        [_LANGUAGE.SPANISH_LA] = "El idioma de la interfaz está configurado a español. ¿Quieres permitir la traducción a tu idioma?",
        [_LANGUAGE.GERMAN] = "Deine Sprache ist auf Deutsch eingestellt. Möchtest du die Übersetzung für deine Sprache aktivieren?",
        [_LANGUAGE.ITALIAN] = "La lingua dell'interfaccia è impostata su italiano. Vorresti abilitare la traduzione per la tua lingua?",
        [_LANGUAGE.PORTUGUESE_BR] = "O idioma da interface está definido como português. Gostaria de habilitar a tradução para o seu idioma?",
        [_LANGUAGE.POLISH] = "Język interfejsu został określony jako: polski. Czy życzysz sobie włączyć tłumaczenie na twój język?",
        [_LANGUAGE.RUSSIAN] = "В качестве языка интерфейса выбран русский. Вам требуется перевод на ваш язык?",
        [_LANGUAGE.KOREAN] = "인터페이스 언어가 한국어로 설정되어 있습니다. 해당 언어의 번역을 사용 하시겠습니까?",
        [_LANGUAGE.CHINESE_S] = "是否把语言设定为中文？",
    },
	
	LANGUAGES_YES =
    {
        [_LANGUAGE.ENGLISH] = "Yes",
        [_LANGUAGE.FRENCH] = "Oui",
        [_LANGUAGE.SPANISH] = "Sí",
        [_LANGUAGE.SPANISH_LA] = "Sí",
        [_LANGUAGE.GERMAN] = "Ja",
        [_LANGUAGE.ITALIAN] = "Sì",
        [_LANGUAGE.PORTUGUESE_BR] = "Sim",
        [_LANGUAGE.POLISH] = "Tak",
        [_LANGUAGE.RUSSIAN] = "Да",
        [_LANGUAGE.KOREAN] = "예",
        [_LANGUAGE.CHINESE_S] = "是",
    },	
	
	LANGUAGES_NO =
    {
        [_LANGUAGE.ENGLISH] = "No",
        [_LANGUAGE.FRENCH] = "Non",
        [_LANGUAGE.SPANISH] = "No",
        [_LANGUAGE.SPANISH_LA] = "No",
        [_LANGUAGE.GERMAN] = "Nein",
        [_LANGUAGE.ITALIAN] = "No",
        [_LANGUAGE.PORTUGUESE_BR] = "Não",
        [_LANGUAGE.POLISH] = "Nie",
        [_LANGUAGE.RUSSIAN] = "Нет",
        [_LANGUAGE.KOREAN] = "아니",
        [_LANGUAGE.CHINESE_S] = "否",
    },
}

if IsConsole() then
	STRINGS.PRETRANSLATED.LANGUAGES[_LANGUAGE.SPANISH] = "Español - España\n(Spanish - Spain)"
end