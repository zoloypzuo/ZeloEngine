// IniReader.cpp
// created on 2021/4/5
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "IniReader.h"

#include <algorithm>
#include <cctype>
#include <cstdlib>

INIReader::Section::Section(INIReader *reader, const std::string &name) :
        reader(reader), sectionName(name) {
}

std::string INIReader::Section::GetString(const std::string &name, const std::string &default_value) const {
    return reader->GetString(sectionName, name, default_value);
}

long INIReader::Section::GetInteger(const std::string &name, long default_value) const {
    return reader->GetInteger(sectionName, name, default_value);
}

double INIReader::Section::GetReal(const std::string &name, double default_value) const {
    return reader->GetReal(sectionName, name, default_value);

}

float INIReader::Section::GetFloat(const std::string &name, float default_value) const {
    return reader->GetFloat(sectionName, name, default_value);

}

bool INIReader::Section::GetBoolean(const std::string &name, bool default_value) const {
    return reader->GetBoolean(sectionName, name, default_value);
}

const char *INIReader::Section::GetCString(const std::string &name, const std::string &default_value) const {
    return GetString(name, default_value).c_str();
}

INIReader::INIReader(const std::string &filename) {
    _error = ini_parse(filename.c_str(), ValueHandler, this);
}

INIReader::INIReader(FILE *file) {
    _error = ini_parse_file(file, ValueHandler, this);
}

int INIReader::ParseError() const {
    return _error;
}

const std::set<std::string> &INIReader::Sections() const {
    return _sections;
}

std::string
INIReader::GetString(const std::string &section, const std::string &name, const std::string &default_value) const {
    std::string key = MakeKey(section, name);
    return _values.count(key) ? _values.at(key) : default_value;
}

long INIReader::GetInteger(const std::string &section, const std::string &name, long default_value) const {
    std::string valstr = GetString(section, name, "");
    const char *value = valstr.c_str();
    char *end;
    // This parses "1234" (decimal) and also "0x4D2" (hex)
    long n = strtol(value, &end, 0);
    return end > value ? n : default_value;
}

double INIReader::GetReal(const std::string &section, const std::string &name, double default_value) const {
    std::string valstr = GetString(section, name, "");
    const char *value = valstr.c_str();
    char *end;
    double n = strtod(value, &end);
    return end > value ? n : default_value;
}

float INIReader::GetFloat(const std::string &section, const std::string &name, float default_value) const {
    std::string valstr = GetString(section, name, "");
    const char *value = valstr.c_str();
    char *end;
    float n = strtof(value, &end);
    return end > value ? n : default_value;
}

bool INIReader::GetBoolean(const std::string &section, const std::string &name, bool default_value) const {
    std::string valstr = GetString(section, name, "");
    // Convert to lower case to make string comparisons case-insensitive
    std::transform(valstr.begin(), valstr.end(), valstr.begin(), ::tolower);
    if (valstr == "true" || valstr == "yes" || valstr == "on" || valstr == "1")
        return true;
    else if (valstr == "false" || valstr == "no" || valstr == "off" || valstr == "0")
        return false;
    else
        return default_value;
}

std::string INIReader::MakeKey(const std::string &section, const std::string &name) {
    std::string key = section + "=" + name;
    // Convert to lower case to make section/name lookups case-insensitive
    std::transform(key.begin(), key.end(), key.begin(), ::tolower);
    return key;
}

int INIReader::ValueHandler(void *user, const char *section, const char *name,
                            const char *value) {
    auto *reader = (INIReader *) user;
    std::string key = MakeKey(section, name);
    if (!reader->_values[key].empty())
        reader->_values[key] += "\n";
    reader->_values[key] += value;
    reader->_sections.insert(section);
    return 1;
}

INIReader::Section INIReader::GetSection(const std::string &section) {
    return Section(this, section);
}
