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

//%include std_shared_ptr.i
%include std_string.i
%include std_pair.i
%include std_map.i
%include std_vector.i
%include exception.i
%include typemaps.i

// so swig correctly resolves "using std::*" declarations
%inline %{
using namespace std;
%}

%feature("autodoc", "1");
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
%exception {
    try {
        $action
    }
#ifdef SWIGPYTHON
    catch (Swig::DirectorException &e) { 
        SWIG_fail;
    }
#endif
    catch (const std::exception& e) {
        SWIG_exception(SWIG_RuntimeError, e.what());
    }
}

// stringinterface internal
%rename("$ignore", regextarget=1) "^Cmd+";

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
