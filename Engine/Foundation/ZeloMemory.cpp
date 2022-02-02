// ZeloMemory.cpp
// created on 2021/10/27
// author @zoloypzuo
#include "ZeloMemory.h"
#include <mimalloc-new-delete.h>

namespace Zelo {
MemoryJanitor::MemoryJanitor() {
    mi_version();
    mi_stats_reset();
}

MemoryJanitor::~MemoryJanitor() {
    mi_collect(true);
    mi_stats_print(NULL);
}
}
