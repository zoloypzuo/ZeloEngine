%module(directors="1") Zelo

%{
#include "ZeloPreCompiledHeader.h"
#include "Zelo.h"
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
    catch (const std::exception& e) {
        SWIG_exception(SWIG_RuntimeError, e.what());
    }
}

// stringinterface internal
%rename("$ignore", regextarget=1) "^Cmd+";

%include "ZeloPrerequisites.h"
%include "ZeloPlatform.h"
%include "ZeloSingleton.h"
%include "Engine.h"



%template(SingletonEngine) Singleton<Engine>;
