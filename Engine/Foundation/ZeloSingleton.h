// ZeloSingleton.h
// created on 2021/3/28
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

#if ZELO_COMPILER == ZELO_COMPILER_MSVC
#   pragma warning (push)
#   pragma warning ( disable: 4661)
#endif

namespace Zelo {
/// template class for creating single-instance global classes
/// class instance needs manual initialization, allows you to manage singleton lifetime through RAII
/// thread safe
/// \tparam T
template<typename T>
class Singleton {
public:
    Singleton(const Singleton &) = delete;

    Singleton(Singleton &&) = delete;

    Singleton &operator=(const Singleton &) = delete;

    Singleton &operator=(Singleton &&) = delete;

protected:
    static T *msSingleton;

public:
    Singleton() {
        assert(!msSingleton && "There can be only one singleton");
        msSingleton = static_cast<T *>(this);
    }

    ~Singleton() {
        assert(msSingleton);
        msSingleton = 0;
    }

    /// Get the singleton instance
    static T &getSingleton() {
        assert(msSingleton);
        return (*msSingleton);
    }

    /// @copydoc getSingleton
    static T *getSingletonPtr() { return msSingleton; }
};
}

#if ZELO_COMPILER == ZELO_COMPILER_MSVC
#   pragma warning (pop)
#endif
