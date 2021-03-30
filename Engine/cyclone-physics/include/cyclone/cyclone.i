%module(directors="1") cyclone

%{
#include "cyclone/cyclone.h"
#include "cyclone/precision.h"
#include "cyclone/core.h"
#include "cyclone/random.h"
#include "cyclone/particle.h"
#include "cyclone/body.h"
#include "cyclone/pcontacts.h"
#include "cyclone/plinks.h"
#include "cyclone/pfgen.h"
#include "cyclone/pworld.h"
#include "cyclone/collide_fine.h"
#include "cyclone/contacts.h"
#include "cyclone/fgen.h"
#include "cyclone/joints.h"
#include "cyclone/contacts.h"
using namespace cyclone;
%}

%include "typemaps.i"
%include "std_vector.i"
%template(ParticleVector) std::vector<cyclone::Particle*>;

namespace cyclone
{
%ignore Vector3::operator [];
%feature("director") ParticleContactGenerator;
%feature("director") ParticleForceGenerator;
}


%include "carrays.i"
%array_functions(int,intArray)
%array_functions(float,floatArray)
%array_functions(double,doubleArray)
%array_functions(double,realArray)


%include "precision.h"
%include "core.h"
%include "random.h"
%include "particle.h"
%include "body.h"
%include "pcontacts.h"
%include "plinks.h"
%include "pfgen.h"
%include "pworld.h"
%include "collide_fine.h"
%include "contacts.h"
%include "fgen.h"
%include "joints.h"
%include "contacts.h"
