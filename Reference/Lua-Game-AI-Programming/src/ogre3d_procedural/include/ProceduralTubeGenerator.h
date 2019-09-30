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
#ifndef PROCEDURAL_TUBE_GENERATOR_INCLUDED
#define PROCEDURAL_TUBE_GENERATOR_INCLUDED

#include "ProceduralMeshGenerator.h"
#include "ProceduralPlatform.h"

namespace Procedural
{
/// Builds an Y-axis tube mesh, i.e. an emptied cylinder
class _ProceduralExport TubeGenerator : public MeshGenerator<TubeGenerator>
{
	int mNumSegBase;
	int mNumSegHeight;
	Ogre::Real mOuterRadius;
	Ogre::Real mInnerRadius;
	Ogre::Real mHeight;

public:
	/// Constructor with arguments
	TubeGenerator(Ogre::Real outerRadius=2.f, Ogre::Real innerRadius=1.f, Ogre::Real height=1.f, int numSegBase=16, int numSegHeight=1) : 
	    mNumSegBase(numSegBase),
		mNumSegHeight(numSegHeight),
		mOuterRadius(outerRadius),
		mInnerRadius(innerRadius),
		mHeight(height) {}

	/**
	 * Builds the mesh into the given TriangleBuffer
	 * @param buffer The TriangleBuffer on where to append the mesh.
	 */
	void addToTriangleBuffer(TriangleBuffer& buffer) const;

	/** Sets the number of segments when rotating around the tube's axis (default=16) */	
	inline TubeGenerator & setNumSegBase(int numSegBase)
	{
		mNumSegBase = numSegBase;
		return *this;
	}

	/** Sets the number of segments along the height of the cylinder (default=1) */
	inline TubeGenerator & setNumSegHeight(int numSegHeight)
	{
		mNumSegHeight = numSegHeight;
		return *this;
	}

	/** Sets the outer radius of the tube (default=2)*/
	inline TubeGenerator & setOuterRadius(Ogre::Real outerRadius)
	{
		mOuterRadius = outerRadius;
		return *this;
	}

	/** Sets the inner radius of the tube (default=1)*/
	inline TubeGenerator & setInnerRadius(Ogre::Real innerRadius)
	{
		mInnerRadius = innerRadius;
		return *this;
	}

	/** Sets the height of the tube (default=1) */
	inline TubeGenerator & setHeight(Ogre::Real height)
	{
		mHeight = height;
		return *this;
	}
};
}
#endif
