#pragma once

#include <stdexcept>
#include <string>

namespace ExceptionsStacktrace {
/**
    The main exception which we throw.
*/
class Exception : public std::runtime_error {
    using std::runtime_error::runtime_error;
};

inline void throwIfFalse(bool expression, const std::string &message) {
    if (!expression) {
        throw Exception(message);
    }
}
}

