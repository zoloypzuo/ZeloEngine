// Singleton.h
// created on 2019/10/13
// author @zoloypzuo

#ifndef ZELOENGINE_SINGLETON_H
#define ZELOENGINE_SINGLETON_H

// 参考 OgreSingleton.h
// 单独拿出来，移除ogre宏检查等依赖，变成独立的头文件
//
// 使用方法
// 继承这个类，然后添加下面两个函数（照着写）
// 在cpp里添加这个指针，和函数实现
// 使用时直接调用静态的getSingleton（指针引用无所谓）
// 初始化：找个初始化的地方，new一个局部变量即可，Ogre::LogManager* const logManager = new Ogre::LogManager();
//
// 简单说明
// 确实，这样写有重复代码，但是可以接受，如果你广泛使用，就习惯了
//
// TODO 是否要写这两个函数需要考证，因为vs resharper提示他是隐藏了基类的getSingleton，有道理的，那么就不需要这个了
//
//template<> LogManager* Singleton<LogManager>::msSingleton = 0;
//LogManager* LogManager::getSingletonPtr(void)
//{
//    return msSingleton;
//}
//LogManager& LogManager::getSingleton(void)
//{
//    assert( msSingleton );  return ( *msSingleton );
//}

/** Template class for creating single-instance global classes.
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
    Singleton(void) {
        assert(!msSingleton);
#if defined( _MSC_VER ) && _MSC_VER < 1200
        int offset = (int)(T*)1 - (int)(Singleton <T>*)(T*)1;
            msSingleton = (T*)((int)this + offset);
#else
        msSingleton = static_cast< T * >( this );
#endif
    }

    ~Singleton(void) {
        assert(msSingleton);
        msSingleton = 0;
    }

    static T &getSingleton(void) {
        assert(msSingleton);
        return (*msSingleton);
    }

    static T *getSingletonPtr(void) { return msSingleton; }
};


#endif //ZELOENGINE_SINGLETON_H