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
#ifndef PROCEDURAL_PLANE_GENERATOR_INCLUDED
#define PROCEDURAL_PLANE_GENERATOR_INCLUDED

#include "ProceduralMeshGenerator.h"
#include "ProceduralPlatform.h"

namespace Procedural
{
/// Builds a plane mesh
class _ProceduralExport PlaneGenerator : public MeshGenerator<PlaneGenerator>
{
	int mNumSegX;
	int mNumSegY;
	Ogre::Vector3 mNormal;
	Ogre::Real mSizeX;
	Ogre::Real mSizeY;
public:

	PlaneGenerator(): mNumSegX(1), mNumSegY(1),
		mNormal(Ogre::Vector3::UNIT_Y),
		mSizeX(1), mSizeY(1)
	{}
	
	/**
	 * Builds the mesh into the given TriangleBuffer
	 * @param buffer The TriangleBuffer on where to append the mesh.
	 */
	void addToTriangleBuffer(TriangleBuffer& buffer) const;

	/** Sets the number of segements along local X axis */
	inline PlaneGenerator & setNumSegX(int numSegX)
	{
		mNumSegX = numSegX;
		return *this;
	}

	/** Sets the number of segments along local Y axis */
	inline PlaneGenerator & setNumSegY(int numSegY)
	{
		mNumSegY = numSegY;
		return *this;
	}

	/** Sets the normal of the plane */
	inline PlaneGenerator & setNormal(Ogre::Vector3 normal)
	{
		mNormal = normal;
		return *this;
	}

	/** Sets the size of the plane along local X axis */
	inline PlaneGenerator & setSizeX(Ogre::Real sizeX)
	{
		mSizeX = sizeX;
		return *this;
	}

	/** Sets the size of the plane along local Y axis */
	inline PlaneGenerator & setSizeY(Ogre::Real sizeY)
	{
		mSizeY = sizeY;
		return *this;
	}
};
}
#endif
