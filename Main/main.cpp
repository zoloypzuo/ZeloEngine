#include "Zelo.h"

#ifdef DetectMemoryLeak
#include "Foundation/ZeloMemoryLeak.h"
#endif

#include "Foundation/ZeloStackTrace.h"

int main() {
    Zelo::Engine().start();
    return 0;
}
