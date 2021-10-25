// ZeloAlgorithmUtil.h
// created on 2021/10/25
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include <algorithm>
#include <functional>

namespace Zelo {
template<class C, class Func>
inline Func ForEach(C &c, Func f) {
    return std::for_each(c.begin(), c.end(), f);
}

template<class C, class Func>
inline void EraseIf(C &c, Func f) {
    c.erase(std::remove_if(c.begin(), c.end(), f), c.end());
}

template<class C, class T>
inline void Erase(C &c, const T &t) {
    c.erase(std::remove(c.begin(), c.end(), t), c.end());
}

template<class C, class T>
inline typename C::iterator Find(C &c, const T &value) {
    return std::find(c.begin(), c.end(), value);
}

template<class C, class Pred>
inline typename C::iterator FindIf(C &c, Pred p) {
    return std::find_if(c.begin(), c.end(), p);
}

// Efficient "add or update" for STL maps.
// For more details see item 24 on Effective STL.
// Basically it avoids constructing default value only to
// assign it later.
template<typename MAP, typename K, typename V>
inline bool AddOrUpdate(MAP &m, const K &key, const V &val) {
    typename MAP::iterator lb = m.lower_bound(key);
    if (lb != m.end() && !m.key_comp()(key, lb->first)) {
        // lb points to a pair with the given key, update pair's value
        lb->second = val;
        return false;
    } else {
        // no key exists, insert new pair
        m.insert(lb, std::make_pair(key, val));
        return true;
    }
}
}
