#include <cstdio>
#include <spdlog/spdlog.h>
#include "zelo.h"

int main() {
    printf("shit");
    printf("%d", add(1, 2));
    spdlog::set_level(spdlog::level::debug);
    spdlog::debug("shit");
    spdlog::debug("{}", add(1, 2));
    return 0;
}