// ZeloStringUtil.cpp
// created on 2021/10/26
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ZeloStringUtil.h"

using namespace std;

namespace Zelo {
bool BeginsWithCaseInsensitive(const std::string &s, const std::string &beginsWith) {
    // Note that we don't want to convert the whole s string to lower case, simply because
    // it might not be very efficient (imagine a string that has, e.g., 2 Mb chars), so we take
    // only a substring that we need to compare with the given prefix.
    return BeginsWith(ToLower(s.substr(0, beginsWith.length())), ToLower(beginsWith));
}

bool BeginsWith(const char *s, const char *beginsWith) {
    return strncmp(s, beginsWith, strlen(beginsWith)) == 0;
}

std::string Append(char const *a, std::string const &b) {
    std::string r;
    size_t asz = strlen(a);
    r.reserve(asz + b.size());
    r.assign(a, asz);
    r.append(b);
    return r;
}

std::string Append(char const *a, char const *b) {
    std::string r;
    size_t asz = strlen(a);
    size_t bsz = strlen(b);
    r.reserve(asz + bsz);
    r.assign(a, asz);
    r.append(b, bsz);
    return r;
}

std::string Append(std::string const &a, char const *b) {
    std::string r;
    size_t bsz = strlen(b);
    r.reserve(a.size() + bsz);
    r.assign(a);
    r.append(b, bsz);
    return r;
}

std::string Trim(const std::string &input, const std::string &ws) {
    size_t startPos = input.find_first_not_of(
            ws); // Find the first character position after excluding leading blank spaces
    size_t endPos = input.find_last_not_of(ws); // Find the first character position from reverse af

    // if all spaces or empty return an empty string
    if ((string::npos == startPos) || (string::npos == endPos)) {
        return std::string(); // empty string
    } else {
        return input.substr(startPos, endPos - startPos + 1);
    }
}

void Split(const std::string &s, char splitChar, std::vector<std::string> &parts) {
    size_t n = 0;
    while (1) {
        size_t n1 = s.find(splitChar, n);
        std::string p = s.substr(n, n1 - n);
        if (p.length()) {
            parts.push_back(p);
        }
        if (n1 == std::string::npos)
            break;

        n = n1 + 1;
    }
}

void Split(const std::string &s, const char *splitChars, std::vector<std::string> &parts) {
    size_t n = 0;
    while (1) {
        size_t n1 = s.find_first_of(splitChars, n);
        std::string p = s.substr(n, n1 - n);
        if (p.length()) {
            parts.push_back(p);
        }
        if (n1 == std::string::npos)
            break;

        n = n1 + 1;
    }
}

}