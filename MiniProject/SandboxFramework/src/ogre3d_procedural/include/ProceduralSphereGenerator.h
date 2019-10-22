/*
-----------------------------------------------------------------------------
This source file is part of ogre-procedural

For the latest info, see http://code.google.com/p/ogre-procedural/

Copyright (c) 2010 Michael Broutin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
-----------------------------------------------------------------------------
*/
#ifndef PROCEDURAL_SPHERE_GENERATOR_INCLUDED
#define PROCEDURAL_SPHERE_GENERATOR_INCLUDED

#include "ProceduralMeshGenerator.h"
#include "ProceduralPlatform.h"

namespace Procedural
{
/** Builds an UV sphere mesh
 */
class _ProceduralExport SphereGenerator : public MeshGenerator<SphereGenerator>
{
	Ogre::Real mRadius;
	unsigned int mNumRings;
	unsigned int mNumSegments;

public:
	/// Constructor with arguments
	SphereGenerator(Ogre::Real radius = 1.f, int numRings = 16, int numSegments = 16) : 
	  mRadius(radius),mNumRings(numRings), mNumSegments(numSegments)

	{}

	/** Sets the radius of the sphere (default=1) */
	inline SphereGenerator & setRadius(Ogre::Real radius)
	{
		mRadius = radius;
		return *this;
	}

	/** Sets the number of rings (default=16) */
	inline SphereGenerator & setNumRings(unsigned int numRings)
	{
		mNumRings = numRings;
		return *this;
	}

	/** Sets the number of segments (default=16) */
	inline SphereGenerator & setNumSegments(unsigned int numSegments)
	{
		mNumSegments = numSegments;
		return *this;
	}
	
	/**
	 * Builds the mesh into the given TriangleBuffer
	 * @param buffer The TriangleBuffer on where to append the mesh.
	 */
	void addToTriangleBuffer(TriangleBuffer& buffer) const;

};
}
#endif
