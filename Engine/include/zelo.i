%module(directors="1") zelo

%{
#include "Engine.h"
//#include "zelo.h"
//using namespace zelo;
%}

//%include "typemaps.i"
//%include "std_vector.i"
//%template(ParticleVector) std::vector<cyclone::Particle*>;

namespace zelo
{
//%ignore Vector3::operator [];
//%feature("director") ParticleContactGenerator;
//%feature("director") ParticleForceGenerator;
}
%feature("director") Engine;


//%include "carrays.i"
//%array_functions(int,intArray)
//%array_functions(float,floatArray)
//%array_functions(double,doubleArray)
//%array_functions(double,realArray)


%include "Engine.h"
//%include "zelo.h"
//