// ZeloSingleton.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_ZELOSINGLETON_H
#define ZELOENGINE_ZELOSINGLETON_H

#include "ZeloPrerequisites.h"


#if ZELO_COMPILER == ZELO_COMPILER_MSVC
#   pragma warning (push)
#   pragma warning ( disable: 4661)
#endif

/** Template class for creating single-instance global classes.
 *
 * This implementation slightly derives from the textbook pattern, by requiring
 * manual instantiation, instead of implicitly doing it in #getSingleton. This is useful for classes that
 * want to do some involved initialization, which should be done at a well defined time-point or need some
 * additional parameters in their constructor.
 *
 * It also allows you to manage the singleton lifetime through RAII.
 *
 * @note Be aware that #getSingleton will fail before the global instance is created. (check via
 * #getSingletonPtr)
 */
template<typename T>
class Singleton {
private:
    /** @brief Explicit private copy constructor. This is a forbidden operation.*/
    Singleton(const Singleton<T> &);

    /** @brief Private operator= . This is a forbidden operation. */
    Singleton &operator=(const Singleton<T> &);

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
/** @} */
/** @} */

#if ZELO_COMPILER == ZELO_COMPILER_MSVC
#   pragma warning (pop)
#endif


#endif //ZELOENGINE_ZELOSINGLETON_H