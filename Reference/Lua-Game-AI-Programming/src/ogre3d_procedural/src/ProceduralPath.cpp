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
#include "ProceduralPath.h"
#include "ProceduralGeometryHelpers.h"

using namespace Ogre;

namespace Procedural
{
	Path Path::mergeKeysWithTrack(const Track& track) const
	{
		if (!track.isInsertPoint() || track.getAddressingMode() == Track::AM_POINT)
			return *this;
		Real totalLength=getTotalLength();
		
		Real lineicPos = 0;
		Real pathLineicPos = 0;
		Path outputPath;
		outputPath.addPoint(getPoint(0));
		for (unsigned int i = 1; i < mPoints.size(); )
		{
			Real nextLineicPos = pathLineicPos + (mPoints[i] - mPoints[i-1]).length();

			std::map<Real,Real>::const_iterator it = track._getKeyValueAfter(lineicPos, lineicPos/totalLength, i-1);

			Real nextTrackPos = it->first;
			if (track.getAddressingMode() == Track::AM_RELATIVE_LINEIC)
				nextTrackPos *= totalLength;

			// Adds the closest point to the curve, being either from the path or the track
			if (nextLineicPos<=nextTrackPos || lineicPos>=nextTrackPos)
			{
				outputPath.addPoint(mPoints[i]);
				i++;				
				lineicPos = nextLineicPos;
				pathLineicPos = nextLineicPos;
			}
			else
			{
				outputPath.addPoint(getPosition(i-1, (nextTrackPos-pathLineicPos)/(nextLineicPos-pathLineicPos)));
				lineicPos = nextTrackPos;
			}
		}
		return outputPath;
	}

	Ogre::MeshPtr Path::realizeMesh(const std::string& name)
	{
		Ogre::SceneManager *smgr = Ogre::Root::getSingleton().getSceneManagerIterator().begin()->second;
		Ogre::ManualObject * manual = smgr->createManualObject();
		manual->begin("BaseWhiteNoLighting", Ogre::RenderOperation::OT_LINE_STRIP);			   
		
		for (std::vector<Ogre::Vector3>::iterator itPos = mPoints.begin(); itPos != mPoints.end();itPos++)		
			manual->position(*itPos);		
		if (mClosed)
			manual->position(*(mPoints.begin()));
		manual->end();
				
		Ogre::MeshPtr mesh;
		if (name=="")
			mesh = manual->convertToMesh(Utils::getName());
		else
	 		mesh = manual->convertToMesh(name);

		return mesh;
	}

	Ogre::Vector3 Path::getPosition(Ogre::Real coord) const
	{
		assert(mPoints.size()>=2 && "The path must at least contain 2 points");
		unsigned int i=0;
		while(true)
		{
			Ogre::Real nextLen = (getPoint(i+1) - getPoint(i)).length();
			if (coord>nextLen)
				coord-=nextLen;
			else
				return getPosition(i, coord/nextLen);
			if (!mClosed && i>= mPoints.size() - 2)
				return mPoints.back();
			i++;
		}
	}

	Ogre::Real Path::getTotalLength() const
	{
		Ogre::Real length = 0;
		for (unsigned int i = 0; i < mPoints.size() - 1; ++i)
			length+=(mPoints[i+1]-mPoints[i]).length();
		if (mClosed)
			length+=(mPoints.back()-*mPoints.begin()).length();
		return length;
	}
}
