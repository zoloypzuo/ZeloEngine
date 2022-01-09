#include "Foundation/ZeloWindows.h"
#include "Zelo.h"
#include "ProjectHub.h"

#ifdef DETECT_MEMORY_LEAK

#include "Foundation/ZeloMemoryLeak.h"

#endif

#include "Foundation/ZeloStackTrace.h"

int main() {
    Zelo::SignalHandling sh;  // catch uncaught exceptions
    Zelo::ProjectHub().start();
    Zelo::Engine().start();
    return 0;
}
