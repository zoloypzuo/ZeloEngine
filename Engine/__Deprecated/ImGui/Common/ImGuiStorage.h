// ImGuiStorage.h
// created on 2021/6/12
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/ImGui/ImGuiPrerequisites.h"

// Helper: Key->value storage
// - Store collapse state for a tree
// - Store color edit options, etc.
// Typically you don't have to worry about this since a storage is held within each Window.
// Declare your own storage if you want to manipulate the open/close state of a particular sub-tree in your interface.
struct ImGuiStorage {
    struct Pair {
        ImU32 key;
        int val;
    };
    ImVector<Pair> Data;

    void Clear();

    int GetInt(ImU32 key, int default_val = 0);

    void SetInt(ImU32 key, int val);

    void SetAllInt(int val);

    int *Find(ImU32 key);
//    void	Insert(ImU32 key, int val);
};
