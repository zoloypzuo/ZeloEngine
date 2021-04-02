//%module(package="zelo", directors="1") zelo
%module(directors="1") zelo

%{
#include "Component.h"
#include "Engine.h"
#include "Entity.h"
#include "Game.h"
#include "Input.h"
#include "Transform.h"
#include "Window.h"
#include "ZeloPlatform.h"
// #include "ZeloPreCompiledHeader.h"
#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
%}

%include std_shared_ptr.i
%include std_string.i
%include std_pair.i
%include std_map.i
#ifdef SWIGPYTHON
%include std_multimap.i
%include std_list.i
#endif
%include std_vector.i
%include exception.i
%include typemaps.i

// so swig correctly resolves "using std::*" declarations
%inline %{
using namespace std;
%}

%feature("autodoc", "1");
%feature("director") *Listener;
%feature("director") *::Listener;

%ignore *::operator=;  // needs rename to wrap
%ignore *::setUserAny; // deprecated
%ignore *::getUserAny; // deprecated
%ignore *::getSingletonPtr; // only expose the non ptr variant

#ifdef SWIG_DIRECTORS
%feature("director:except") {
    if ($error != NULL) {
        throw Swig::DirectorMethodException();
    }
}
#endif

// convert c++ exceptions to language native exceptions
// %exception {
//     try {
//         $action
//     }
// #ifdef SWIGPYTHON
//     catch (Swig::DirectorException &e) { 
//         SWIG_fail;
//     }
// #endif
//     catch (const std::exception& e) {
//         SWIG_exception(SWIG_RuntimeError, e.what());
//     }
// }

// connect operator<< to tp_repr
%ignore ::operator<<;
%feature("python:slot", "tp_repr", functype="reprfunc") *::__repr__;

#ifdef SWIGJAVA
#define REPRFUNC toString
#elif defined(SWIGCSHARP)
#define REPRFUNC ToString
#else
#define REPRFUNC __repr__
#endif

%define ADD_REPR(classname)
%extend Ogre::classname {
    const std::string REPRFUNC() {
        std::ostringstream out;
        out << *$self;
        return out.str();
    }
}
%enddef

%define SHARED_PTR(classname)
// %shared_ptr(type);
%template(classname ## Ptr) Ogre::SharedPtr<Ogre::classname >;
%enddef

// connect operator[] to __getitem__
%feature("python:slot", "sq_item", functype="ssizeargfunc") *::operator[];
%rename(__getitem__) *::operator[];
%ignore Ogre::Matrix3::operator[];
%ignore Ogre::Matrix4::operator[];
%ignore Ogre::ColourValue::operator[];

// stringinterface internal
%rename("$ignore", regextarget=1) "^Cmd+";

#ifdef SWIGPYTHON
    #define XSTR(x) #x
    #define STR(x) XSTR(x)
    #define __version__ STR(OGRE_VERSION_MAJOR) "." STR(OGRE_VERSION_MINOR) "." STR(OGRE_VERSION_PATCH)
    #undef STR
    #undef XSTR
#endif

%include "ZeloPrerequisites.h"
%include "ZeloPlatform.h"
%include "Engine.h"
%include "Component.h"
%include "Engine.h"
%include "Entity.h"
%include "Game.h"
%include "Input.h"
%include "Transform.h"
%include "Window.h"
%include "ZeloPrerequisites.h"
%include "ZeloSingleton.h"
