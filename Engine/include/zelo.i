%module(directors="1") zelo

%{
#include "zelo.h"
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


%include "carrays.i"
%array_functions(int,intArray)
%array_functions(float,floatArray)
%array_functions(double,doubleArray)
%array_functions(double,realArray)


%include "zelo.h"
