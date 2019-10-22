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
#ifndef PROCEDURAL_ROUNDED_BOX_GENERATOR_INCLUDED
#define PROCEDURAL_ROUNDED_BOX_GENERATOR_INCLUDED

#include "ProceduralMeshGenerator.h"
#include "ProceduralPlatform.h"

namespace Procedural
{
/** 
 * Builds a rounded box.
 * You can choose the size of the rounded borders to get a sharper or smoother look.
 */
class _ProceduralExport RoundedBoxGenerator : public MeshGenerator<RoundedBoxGenerator>
{
	Ogre::Real mSizeX,mSizeY,mSizeZ;
	unsigned short mNumSegX,mNumSegY,mNumSegZ;
	Ogre::Real mChamferSize;
	unsigned short mChamferNumSeg;
		
public:
	RoundedBoxGenerator() : mSizeX(1.f), mSizeY(1.f), mSizeZ(1.f),
		mNumSegX(1), mNumSegY(1), mNumSegZ(1), mChamferSize(.1f), mChamferNumSeg(8) {}

	/** Sets the size of the box along X axis */
	RoundedBoxGenerator& setSizeX(Ogre::Real sizeX)
	{
		mSizeX = sizeX;
		return *this;
	}

	/** Sets the size of the box along Y axis */
	RoundedBoxGenerator& setSizeY(Ogre::Real sizeY)
	{
		mSizeY = sizeY;
		return *this;
	}

	/** Sets the size of the box along Z axis */
	RoundedBoxGenerator& setSizeZ(Ogre::Real sizeZ)
	{
		mSizeZ = sizeZ;
		return *this;
	}

	/** Sets the number of segments along X axis */
	RoundedBoxGenerator& setNumSegX(unsigned short numSegX)
	{
		mNumSegX = numSegX;
		return *this;
	}

	/** Sets the number of segments along Y axis */
	RoundedBoxGenerator& setNumSegY(unsigned short numSegY)
	{
		mNumSegY = numSegY;
		return *this;
	}

	/** Sets the number of segments along Z axis */
	RoundedBoxGenerator& setNumSegZ(unsigned short numSegZ)
	{
		mNumSegZ = numSegZ;
		return *this;
	}

	/** Sets the size of the chamfer, ie the radius of the rounded part */
	RoundedBoxGenerator& setChamferSize(Ogre::Real chamferSize)
	{
		mChamferSize = chamferSize;
		return *this;
	}

	/**
	 * Builds the mesh into the given TriangleBuffer
	 * @param buffer The TriangleBuffer on where to append the mesh.
	 */
	void addToTriangleBuffer(TriangleBuffer& buffer) const;

private:
	
	/// Internal. Builds an "edge" of the rounded box, ie a quarter cylinder
	void _addEdge(TriangleBuffer& buffer, short xPos, short yPos, short zPos) const;
	
	/// Internal. Builds a "corner" of the rounded box, ie a 1/8th of a sphere
	void _addCorner(TriangleBuffer& buffer, bool isXPositive, bool isYPositive, bool isZPositive) const;

};


}
#endif
