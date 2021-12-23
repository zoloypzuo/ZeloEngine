#include "Foundation/ZeloWindows.h"
#include "Zelo.h"

#ifdef DETECT_MEMORY_LEAK

#include "Foundation/ZeloMemoryLeak.h"

#endif

#include "Foundation/ZeloStackTrace.h"

int main() {
    Zelo::SignalHandling sh;  // catch uncaught exceptions
    Zelo::Engine().start();
    return 0;
}
