local function getcharacterstring(tab, item, modifier)
    if modifier then
		modifier = string.upper(modifier)
	end

    if tab then
        local topic_tab = tab[item]
        if topic_tab then
            if type(topic_tab) == "string" then
		        return topic_tab
            elseif type(topic_tab) == "table" then
                if modifier and topic_tab[modifier] then
                    return topic_tab[modifier]
                end

                if topic_tab['GENERIC'] then
                    return topic_tab['GENERIC']
                end

				if #topic_tab > 0 then
					return topic_tab[math.random(#topic_tab)]
				end
            end
        end
    end
end

function GetGenderStrings(charactername)
    if table.contains(CHARACTER_GENDERS.MALE, charactername) then
        return "MALE"
    elseif table.contains(CHARACTER_GENDERS.FEMALE, charactername) then
        return "FEMALE"
    elseif table.contains(CHARACTER_GENDERS.ROBOT, charactername) then
        return "ROBOT"
    else
        return "MALE"
    end
end

function GetSpecialCharacterString(character)
    character = string.lower(character)
    if character == "wilton" then

		local sayings =
		{
			"Ehhhhhhhhhhhhhh.",
			"Eeeeeeeeeeeer.",
			"Rattle.",
			"click click click click",
			"Hissss!",
			"Aaaaaaaaa.",
			"mooooooooooooaaaaan.",
			"...",
		}

		return sayings[math.random(#sayings)]
    elseif character == "wes" then
		return ""
    end
end

function GetString(character, stringtype, modifier)
    character = character and string.upper(character)
    stringtype = stringtype and string.upper(stringtype)
    modifier = modifier and string.upper(modifier)
    
    local ret = GetSpecialCharacterString(character) or
			    getcharacterstring(STRINGS.CHARACTERS[character], stringtype, modifier) or
                getcharacterstring(STRINGS.CHARACTERS["GENERIC"], stringtype, modifier)
    if ret then
        return ret
    end

    return "UNKNOWN STRING: "..( character or "") .." ".. (stringtype or "") .." ".. (modifier or "")
end

function GetActionString(action, modifier)
    return getcharacterstring(STRINGS.ACTIONS, action, modifier) or "ACTION"
end

function GetDescription(character, item, modifier)
    character = character and string.upper(character)
    local itemname = item.components.inspectable.nameoverride or item.prefab
    itemname = itemname and string.upper(itemname)
    modifier = modifier and string.upper(modifier)

    local ret = GetSpecialCharacterString(character)

    if not ret then
        if STRINGS.CHARACTERS[character] then
            ret = getcharacterstring(STRINGS.CHARACTERS[character].DESCRIBE, itemname, modifier)
        end

        if not ret and STRINGS.CHARACTERS.GENERIC then
            ret = getcharacterstring(STRINGS.CHARACTERS.GENERIC.DESCRIBE, itemname, modifier)
        end

        if not ret then
            ret = STRINGS.CHARACTERS.GENERIC.DESCRIBE_GENERIC
        end
    end

    if ret and item and item.components.repairable and item.components.repairable:NeedsRepairs() and item.components.repairable.announcecanfix then
        local repair = nil
        if STRINGS.CHARACTERS[character] and STRINGS.CHARACTERS[character].DESCRIBE then
            repair = getcharacterstring(STRINGS.CHARACTERS[character], "ANNOUNCE_CANFIX", modifier)
        end
    
        if not repair and STRINGS.CHARACTERS.GENERIC then
            repair = getcharacterstring(STRINGS.CHARACTERS.GENERIC, "ANNOUNCE_CANFIX", modifier)
        end

        if repair then 
            ret = ret..repair
        end
    end  

    return ret 
end

function GetActionFailString(inst, action, reason)
    local character =
        type(inst) == "string"
        and inst
        or (inst ~= nil and inst.prefab or nil)

    local ret = nil

	local ret = GetSpecialCharacterString(character)
	if ret then
		return ret
	end

    if STRINGS.CHARACTERS[character] then
        ret = getcharacterstring(STRINGS.CHARACTERS[character].ACTIONFAIL, action, reason)
    end

    if not ret then
        ret = getcharacterstring(STRINGS.CHARACTERS.GENERIC.ACTIONFAIL, action, reason)
    end

    if ret then
       return ret
    end
    return STRINGS.CHARACTERS.GENERIC.ACTIONFAIL_GENERIC
end

function TrimString( s )
     return string.match( s, "^()%s*$" ) and "" or string.match( s, "^%s*(.*%S)" )
end

-- usage:
-- subfmt("this is my {adjective} string, read it {number} times!", {adjective="cool", number="five"})
-- => "this is my cool string, read it five times"
function subfmt(s, tab)
    return (s:gsub('(%b{})', function(w) return tab[w:sub(2, -2)] or w end))
end
