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
#include "ProceduralStableHeaders.h"
#include "ProceduralBoxGenerator.h"
#include "ProceduralPlaneGenerator.h"
#include "ProceduralUtils.h"

using namespace Ogre;

namespace Procedural
{
void BoxGenerator::addToTriangleBuffer(TriangleBuffer& buffer) const
{
	assert(mNumSegX>0 && mNumSegY>0 && mNumSegZ>0 && "Num seg must be positive integers");
	assert(mSizeX>0. && mSizeY>0. && mSizeZ>0. && "Sizes must be positive");

	PlaneGenerator pg;
	pg.setUTile(mUTile).setVTile(mVTile);
	if (mTransform)
	{
		pg.setScale(mScale);
		pg.setOrientation(mOrientation);
	}
	pg.setNumSegX(mNumSegY).setNumSegY(mNumSegX).setSizeX(mSizeY).setSizeY(mSizeX)
	  .setNormal(Vector3::NEGATIVE_UNIT_Z)
	  .setPosition(mPosition+.5f*mSizeZ*(mOrientation*Vector3::NEGATIVE_UNIT_Z))
	  .addToTriangleBuffer(buffer);
	pg.setNumSegX(mNumSegY).setNumSegY(mNumSegX).setSizeX(mSizeY).setSizeY(mSizeX)
	  .setNormal(Vector3::UNIT_Z)
	  .setPosition(mPosition+.5f*mSizeZ*(mOrientation*Vector3::UNIT_Z))
	  .addToTriangleBuffer(buffer);
	pg.setNumSegX(mNumSegZ).setNumSegY(mNumSegX).setSizeX(mSizeZ).setSizeY(mSizeX)
	  .setNormal(Vector3::NEGATIVE_UNIT_Y)
	  .setPosition(mPosition+.5f*mSizeY*(mOrientation*Vector3::NEGATIVE_UNIT_Y))
	  .addToTriangleBuffer(buffer);
	pg.setNumSegX(mNumSegZ).setNumSegY(mNumSegX).setSizeX(mSizeZ).setSizeY(mSizeX)
	  .setNormal(Vector3::UNIT_Y)
	  .setPosition(mPosition+.5f*mSizeY*(mOrientation*Vector3::UNIT_Y))
	  .addToTriangleBuffer(buffer);
	pg.setNumSegX(mNumSegZ).setNumSegY(mNumSegY).setSizeX(mSizeZ).setSizeY(mSizeY)
	  .setNormal(Vector3::NEGATIVE_UNIT_X)
	  .setPosition(mPosition+.5f*mSizeX*(mOrientation*Vector3::NEGATIVE_UNIT_X))
	  .addToTriangleBuffer(buffer);
	pg.setNumSegX(mNumSegZ).setNumSegY(mNumSegY).setSizeX(mSizeZ).setSizeY(mSizeY)
	  .setNormal(Vector3::UNIT_X)
	  .setPosition(mPosition+.5f*mSizeX*(mOrientation*Vector3::UNIT_X))
	  .addToTriangleBuffer(buffer);
}
}
