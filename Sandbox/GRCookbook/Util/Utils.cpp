#if !defined(_CRT_SECURE_NO_WARNINGS)
#	define _CRT_SECURE_NO_WARNINGS 1
#endif // _CRT_SECURE_NO_WARNINGS

#include <malloc.h>
#include <string.h>
#include <string>

#include "Utils.h"

int endsWith(const char *s, const char *part) {
    return (strstr(s, part) - s) == (strlen(s) - strlen(part));
}

