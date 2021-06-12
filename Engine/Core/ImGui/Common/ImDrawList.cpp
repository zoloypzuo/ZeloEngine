// ImDrawList.cpp.cc
// created on 2021/6/12
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImDrawList.h"

ImDrawCmd::ImDrawCmd(ImDrawCmdType _cmd_type, int16_t _vtx_count) {
    cmd_type = _cmd_type;
    vtx_count = _vtx_count;
}
