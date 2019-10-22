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
#ifndef PROCEDURAL_TORUS_GENERATOR_INCLUDED
#define PROCEDURAL_TORUS_GENERATOR_INCLUDED

#include "ProceduralMeshGenerator.h"
#include "ProceduralPlatform.h"

namespace Procedural
{
/** Builds a torus mesh whose axis is Y
 */
class _ProceduralExport TorusGenerator : public MeshGenerator<TorusGenerator>
{
	int mNumSegSection;
	int mNumSegCircle;
	Ogre::Real mRadius;
	Ogre::Real mSectionRadius;
public:
	/// Constructor with arguments
	TorusGenerator(Ogre::Real radius=1.f, Ogre::Real sectionRadius=.2f, int numSegSection=16, int numSegCircle=16) : 
		mNumSegSection(numSegSection),
		mNumSegCircle(numSegCircle),
		mRadius(radius),
		mSectionRadius(sectionRadius) {}

	/**
	 * Builds the mesh into the given TriangleBuffer
	 * @param buffer The TriangleBuffer on where to append the mesh.
	 */
	void addToTriangleBuffer(TriangleBuffer& buffer) const;
	
	/** Sets the number of segments on the section circle */
	inline TorusGenerator & setNumSegSection(int numSegSection)
	{
		mNumSegSection = numSegSection;
		return *this;
	}

	/** Sets the number of segments along the guiding circle */
	inline TorusGenerator & setNumSegCircle(int numSegCircle)
	{
		mNumSegCircle = numSegCircle;
		return *this;
	}

	/** Sets the radius of the guiding circle */
	inline TorusGenerator & setRadius(Ogre::Real radius)
	{
		mRadius = radius;
		return *this;
	}

	/** Sets the radius of the section circle */
	inline TorusGenerator & setSectionRadius(Ogre::Real sectionRadius)
	{
		mSectionRadius = sectionRadius;
		return *this;
	}

};
}
#endif
