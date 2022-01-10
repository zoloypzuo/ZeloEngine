#include "Foundation/ZeloWindows.h"  // include windows.h first

#include "G.h"
#include "Zelo.h"
#include "ProjectHub.h"
#include "Foundation/ZeloStackTrace.h"

#ifdef DETECT_MEMORY_LEAK

#include "Foundation/ZeloMemoryLeak.h"

#endif

int main() {
    Zelo::SignalHandling sh;  // catch uncaught exceptions
    Zelo::ProjectHub().start();
    while (!Zelo::G::s_EngineList.empty()) {
        auto &engine = Zelo::G::s_EngineList.front();
        engine->start();
        Zelo::G::s_EngineList.pop_front();
    }
    return 0;
}
