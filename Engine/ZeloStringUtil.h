// ZeloStringUtil.h
// created on 2021/10/26
// author @zoloypzuo
#pragma once

#include <string>
#include <vector>

namespace Zelo {
bool BeginsWithCaseInsensitive(const std::string &s, const std::string &beginsWith);

bool BeginsWith(const char *s, const char *beginsWith);

template<typename StringType>
inline
bool BeginsWith(const StringType &s, const StringType &beginsWith) {
    return BeginsWith(s.c_str(), beginsWith.c_str());
}

template<typename StringType>
inline
bool BeginsWith(const StringType &s, const char *beginsWith) {
    return BeginsWith(s.c_str(), beginsWith);
}

inline bool EndsWith(const char *str, size_t strLen, const char *sub, size_t subLen) {
    return (strLen >= subLen) && (strncmp(str + strLen - subLen, sub, subLen) == 0);
}

template<typename StringType>
inline
bool EndsWith(const StringType &str, const StringType &sub) {
    return EndsWith(str.c_str(), str.size(), sub.c_str(), sub.size());
}

template<typename StringType>
inline
bool EndsWith(const StringType &str, const char *endsWith) {
    return EndsWith(str.c_str(), str.size(), endsWith, strlen(endsWith));
}

inline bool EndsWith(const char *s, const char *endsWith) {
    return EndsWith(s, strlen(s), endsWith, strlen(endsWith));
}

inline char ToLower(char v) {
    if (v >= 'A' && v <= 'Z')
        return static_cast<char>(v | 0x20);
    else
        return v;
}

inline char ToUpper(char v) {
    if (v >= 'a' && v <= 'z')
        return static_cast<char>(v & 0xdf);
    else
        return v;
}

template<typename StringType>
StringType ToUpper(const StringType &input) {
    StringType s = input;
    for (typename StringType::iterator i = s.begin(); i != s.end(); i++)
        *i = ToUpper(*i);
    return s;
}

template<typename StringType>
StringType ToLower(const StringType &input) {
    StringType s = input;
    for (typename StringType::iterator i = s.begin(); i != s.end(); i++)
        *i = ToLower(*i);
    return s;
}

template<typename StringType>
void ToUpperInplace(StringType &input) {
    for (typename StringType::iterator i = input.begin(); i != input.end(); i++)
        *i = ToUpper(*i);
}

template<typename StringType>
void ToLowerInplace(StringType &input) {
    for (typename StringType::iterator i = input.begin(); i != input.end(); i++)
        *i = ToLower(*i);
}

std::string Append(char const *a, std::string const &b);

std::string Append(char const *a, char const *b);

std::string Append(std::string const &a, char const *b);

inline bool IsDigit(char c) { return c >= '0' && c <= '9'; }

inline bool IsAlpha(char c) { return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z'); }

inline bool IsSpace(char c) { return c == '\t' || c == '\n' || c == '\v' || c == '\f' || c == '\r' || c == ' '; }

inline bool IsAlphaNumeric(char c) { return IsDigit(c) || IsAlpha(c); }

template<typename alloc>
void replace_string(std::basic_string<char, std::char_traits<char>, alloc> &target,
                    const std::basic_string<char, std::char_traits<char>, alloc> &search,
                    const std::basic_string<char, std::char_traits<char>, alloc> &replace, size_t startPos = 0) {
    if (search.empty())
        return;

    typename std::basic_string<char, std::char_traits<char>, alloc>::size_type p = startPos;
    while ((p = target.find(search, p)) != std::basic_string<char, std::char_traits<char>, alloc>::npos) {
        target.replace(p, search.size(), replace);
        p += replace.size();
    }
}

template<typename StringType>
void replace_string(StringType &target, const char *search, const StringType &replace, size_t startPos = 0) {
    replace_string(target, StringType(search), replace, startPos);
}

template<typename StringType>
void replace_string(StringType &target, const StringType &search, const char *replace, size_t startPos = 0) {
    replace_string(target, search, StringType(replace), startPos);
}

template<typename StringType>
void replace_string(StringType &target, const char *search, const char *replace, size_t startPos = 0) {
    replace_string(target, StringType(search), StringType(replace), startPos);
}

std::string Trim(const std::string &input, const std::string &ws = " \t");

/// Split a string delimited by splitChar or any character in splitChars into parts.
/// Parts is appended, not cleared.
/// Empty parts are discarded.
void Split(const std::string &s, char splitChar, std::vector<std::string> &parts);

void Split(const std::string &s, const char *splitChars, std::vector<std::string> &parts);

inline std::string QuoteString(const std::string &str) {
    return '"' + str + '"';
}
}
