// ImGuiStorage.cpp.cc
// created on 2021/6/12
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImGuiStorage.h"

void ImGuiStorage::Clear() {
    Data.clear();
}

// std::lower_bound but without the bullshit
ImVector<ImGuiStorage::Pair>::iterator LowerBound(ImVector<ImGuiStorage::Pair> &data, ImU32 key) {
    ImVector<ImGuiStorage::Pair>::iterator first = data.begin();
    ImVector<ImGuiStorage::Pair>::iterator last = data.end();
    int count = last - first;
    while (count > 0) {
        int count2 = count / 2;
        ImVector<ImGuiStorage::Pair>::iterator mid = first + count2;
        if (mid->key < key) {
            first = ++mid;
            count -= count2 + 1;
        } else {
            count = count2;
        }
    }
    return first;
}

int *ImGuiStorage::Find(ImU32 key) {
    ImVector<Pair>::iterator it = LowerBound(Data, key);
    if (it == Data.end())
        return NULL;
    if (it->key != key)
        return NULL;
    return &it->val;
}

int ImGuiStorage::GetInt(ImU32 key, int default_val) {
    int *pval = Find(key);
    if (!pval)
        return default_val;
    return *pval;
}

// FIXME-OPT: We are wasting time because all SetInt() are preceeded by GetInt() calls so we should have the result from lower_bound already in place.
// However we only use SetInt() on explicit user action (so that's maximum once a frame) so the optimisation isn't much needed.
void ImGuiStorage::SetInt(ImU32 key, int val) {
    ImVector<Pair>::iterator it = LowerBound(Data, key);
    if (it != Data.end() && it->key == key) {
        it->val = val;
    } else {
        Pair pair_key{};
        pair_key.key = key;
        pair_key.val = val;
        Data.insert(it, pair_key);
    }
}

void ImGuiStorage::SetAllInt(int v) {
    for (size_t i = 0; i < Data.size(); i++)
        Data[i].val = v;
}