#ifdef DetectMemoryLeak
#include "Foundation/ZeloMemoryLeak.h"
#endif

#include "Zelo.h"

#include "backward.hpp"

int main() {
    Zelo::Engine().start();
    return 0;
}
