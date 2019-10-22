/*
-----------------------------------------------------------------------------
This source file is part of OGRE
(Object-oriented Graphics Rendering Engine)
For the latest info, see http://www.ogre3d.org/

Copyright (c) 2000-2013 Torus Knot Software Ltd

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
#include "OgreStableHeaders.h"
#include "OgreInstanceBatchHW.h"
#include "OgreSubMesh.h"
#include "OgreRenderOperation.h"
#include "OgreHardwareBufferManager.h"
#include "OgreInstancedEntity.h"
#include "OgreMaterial.h"
#include "OgreTechnique.h"
#include "OgreRoot.h"

namespace Ogre
{
	InstanceBatchHW::InstanceBatchHW( InstanceManager *creator, MeshPtr &meshReference,
										const MaterialPtr &material, size_t instancesPerBatch,
										const Mesh::IndexMap *indexToBoneMap, const String &batchName ) :
				InstanceBatch( creator, meshReference, material, instancesPerBatch,
								indexToBoneMap, batchName ),
				mKeepStatic( false )
	{
		//Override defaults, so that InstancedEntities don't create a skeleton instance
		mTechnSupportsSkeletal = false;
	}

	InstanceBatchHW::~InstanceBatchHW()
	{
	}

	//-----------------------------------------------------------------------
	size_t InstanceBatchHW::calculateMaxNumInstances( const SubMesh *baseSubMesh, uint16 flags ) const
	{
		size_t retVal = 0;

		RenderSystem *renderSystem = Root::getSingleton().getRenderSystem();
		const RenderSystemCapabilities *capabilities = renderSystem->getCapabilities();

		if( capabilities->hasCapability( RSC_VERTEX_BUFFER_INSTANCE_DATA ) )
		{
			//This value is arbitrary (theorical max is 2^30 for D3D9) but is big enough and safe
			retVal = 65535;
		}

		return retVal;
	}
	//-----------------------------------------------------------------------
	void InstanceBatchHW::buildFrom( const SubMesh *baseSubMesh, const RenderOperation &renderOperation )
	{
		InstanceBatch::buildFrom( baseSubMesh, renderOperation );

		//We need to clone the VertexData (but just reference all buffers, except the last one)
		//because last buffer contains data specific to this batch, we need a different binding
		mRenderOperation.vertexData	= mRenderOperation.vertexData->clone( false );
		VertexData *thisVertexData		= mRenderOperation.vertexData;
		const unsigned short lastSource	= thisVertexData->vertexDeclaration->getMaxSource();
		HardwareVertexBufferSharedPtr vertexBuffer =
										HardwareBufferManager::getSingleton().createVertexBuffer(
										thisVertexData->vertexDeclaration->getVertexSize(lastSource),
										mInstancesPerBatch,
										HardwareBuffer::HBU_STATIC_WRITE_ONLY );
		thisVertexData->vertexBufferBinding->setBinding( lastSource, vertexBuffer );
		vertexBuffer->setIsInstanceData( true );
		vertexBuffer->setInstanceDataStepRate( 1 );
	}
	//-----------------------------------------------------------------------
	void InstanceBatchHW::setupVertices( const SubMesh* baseSubMesh )
	{
		mRenderOperation.vertexData = baseSubMesh->vertexData->clone();
		mRemoveOwnVertexData = true; //Raise flag to remove our own vertex data in the end (not always needed)
		
		VertexData *thisVertexData = mRenderOperation.vertexData;

		//No skeletal animation support in this technique, sorry
		removeBlendData();

		//Modify the declaration so it contains an extra source, where we can put the per instance data
		size_t offset				= 0;
		unsigned short nextTexCoord	= thisVertexData->vertexDeclaration->getNextFreeTextureCoordinate();
		const unsigned short newSource = thisVertexData->vertexDeclaration->getMaxSource() + 1;
		for( unsigned char i=0; i<3 + mCreator->getNumCustomParams(); ++i )
		{
			thisVertexData->vertexDeclaration->addElement( newSource, offset, VET_FLOAT4,
															VES_TEXTURE_COORDINATES, nextTexCoord++ );
			offset = thisVertexData->vertexDeclaration->getVertexSize( newSource );
		}

		//Create the vertex buffer containing per instance data
		HardwareVertexBufferSharedPtr vertexBuffer =
										HardwareBufferManager::getSingleton().createVertexBuffer(
										thisVertexData->vertexDeclaration->getVertexSize(newSource),
										mInstancesPerBatch,
										HardwareBuffer::HBU_STATIC_WRITE_ONLY );
		thisVertexData->vertexBufferBinding->setBinding( newSource, vertexBuffer );
		vertexBuffer->setIsInstanceData( true );
		vertexBuffer->setInstanceDataStepRate( 1 );
	}
	//-----------------------------------------------------------------------
	void InstanceBatchHW::setupIndices( const SubMesh* baseSubMesh )
	{
		//We could use just a reference, but the InstanceManager will in the end attampt to delete
		//the pointer, and we can't give it something that doesn't belong to us.
		mRenderOperation.indexData = baseSubMesh->indexData->clone( true );
		mRemoveOwnIndexData = true;	//Raise flag to remove our own index data in the end (not always needed)
	}
	//-----------------------------------------------------------------------
	void InstanceBatchHW::removeBlendData()
	{
		VertexData *thisVertexData = mRenderOperation.vertexData;

		unsigned short safeSource = 0xFFFF;
		const VertexElement* blendIndexElem = thisVertexData->vertexDeclaration->findElementBySemantic(
																				VES_BLEND_INDICES );
		if( blendIndexElem )
		{
			//save the source in order to prevent the next stage from unbinding it.
			safeSource = blendIndexElem->getSource();
			// Remove buffer reference
			thisVertexData->vertexBufferBinding->unsetBinding( blendIndexElem->getSource() );
		}
		// Remove blend weights
		const VertexElement* blendWeightElem = thisVertexData->vertexDeclaration->findElementBySemantic(
																				VES_BLEND_WEIGHTS );
		if( blendWeightElem && blendWeightElem->getSource() != safeSource )
		{
			// Remove buffer reference
			thisVertexData->vertexBufferBinding->unsetBinding( blendWeightElem->getSource() );
		}

		thisVertexData->vertexDeclaration->removeElement(VES_BLEND_INDICES);
		thisVertexData->vertexDeclaration->removeElement(VES_BLEND_WEIGHTS);
		thisVertexData->closeGapsInBindings();
	}
	//-----------------------------------------------------------------------
	bool InstanceBatchHW::checkSubMeshCompatibility( const SubMesh* baseSubMesh )
	{
		//Max number of texture coordinates is _usually_ 8, we need at least 3 available
		if( baseSubMesh->vertexData->vertexDeclaration->getNextFreeTextureCoordinate() > 8-2 )
		{
			OGRE_EXCEPT(Exception::ERR_NOT_IMPLEMENTED, "Given mesh must have at "
														"least 3 free TEXCOORDs",
						"InstanceBatchHW::checkSubMeshCompatibility");
		}
		if( baseSubMesh->vertexData->vertexDeclaration->getNextFreeTextureCoordinate() >
			8-2-mCreator->getNumCustomParams() ||
			3 + mCreator->getNumCustomParams() >= 8 )
		{
			OGRE_EXCEPT(Exception::ERR_INVALIDPARAMS, "There are not enough free TEXCOORDs to hold the "
														"custom parameters (required: " +
														Ogre::StringConverter::toString( 3 + mCreator->
														getNumCustomParams() ) + "). See InstanceManager"
														"::setNumCustomParams documentation",
						"InstanceBatchHW::checkSubMeshCompatibility");
		}

		return InstanceBatch::checkSubMeshCompatibility( baseSubMesh );
	}
	//-----------------------------------------------------------------------
	size_t InstanceBatchHW::updateVertexBuffer( Camera *currentCamera )
	{
		size_t retVal = 0;

		//Now lock the vertex buffer and copy the 4x3 matrices, only those who need it!
		const size_t bufferIdx = mRenderOperation.vertexData->vertexBufferBinding->getBufferCount()-1;
		float *pDest = static_cast<float*>(mRenderOperation.vertexData->vertexBufferBinding->
											getBuffer(bufferIdx)->lock( HardwareBuffer::HBL_DISCARD ));

		InstancedEntityVec::const_iterator itor = mInstancedEntities.begin();
		InstancedEntityVec::const_iterator end  = mInstancedEntities.end();

		unsigned char numCustomParams			= mCreator->getNumCustomParams();
		size_t customParamIdx					= 0;

		while( itor != end )
		{
			//Cull on an individual basis, the less entities are visible, the less instances we draw.
			//No need to use null matrices at all!
			if( (*itor)->findVisible( currentCamera ) )
			{
				const size_t floatsWritten = (*itor)->getTransforms3x4( pDest );

				if( mManager->getCameraRelativeRendering() )
					makeMatrixCameraRelative3x4( pDest, floatsWritten );

				pDest += floatsWritten;

				//Write custom parameters, if any
				for( unsigned char i=0; i<numCustomParams; ++i )
				{
					*pDest++ = mCustomParams[customParamIdx+i].x;
					*pDest++ = mCustomParams[customParamIdx+i].y;
					*pDest++ = mCustomParams[customParamIdx+i].z;
					*pDest++ = mCustomParams[customParamIdx+i].w;
				}

				++retVal;
			}
			++itor;

			customParamIdx += numCustomParams;
		}

		mRenderOperation.vertexData->vertexBufferBinding->getBuffer(bufferIdx)->unlock();

		return retVal;
	}
	//-----------------------------------------------------------------------
	void InstanceBatchHW::_boundsDirty(void)
	{
		//Don't update if we're static, but still mark we're dirty
		if( !mBoundsDirty && !mKeepStatic )
			mCreator->_addDirtyBatch( this );
		mBoundsDirty = true;
	}
	//-----------------------------------------------------------------------
	void InstanceBatchHW::setStaticAndUpdate( bool bStatic )
	{
		//We were dirty but didn't update bounds. Do it now.
		if( mKeepStatic && mBoundsDirty )
			mCreator->_addDirtyBatch( this );

		mKeepStatic = bStatic;
		if( mKeepStatic )
		{
			//One final update, since there will be none from now on
			//(except further calls to this function). Pass NULL because
			//we want to include only those who were added to the scene
			//but we don't want to perform culling
			mRenderOperation.numberOfInstances = updateVertexBuffer( 0 );
		}
	}
	//-----------------------------------------------------------------------
	void InstanceBatchHW::getWorldTransforms( Matrix4* xform ) const
	{
		*xform = Matrix4::IDENTITY;
	}
	//-----------------------------------------------------------------------
	unsigned short InstanceBatchHW::getNumWorldTransforms(void) const
	{
		return 1;
	}
	//-----------------------------------------------------------------------
	void InstanceBatchHW::_updateRenderQueue( RenderQueue* queue )
	{
		if( !mKeepStatic )
		{
			//Completely override base functionality, since we don't cull on an "all-or-nothing" basis
			//and we don't support skeletal animation
			if( (mRenderOperation.numberOfInstances = updateVertexBuffer( mCurrentCamera )) )
				queue->addRenderable( this, mRenderQueueID, mRenderQueuePriority );
		}
		else
		{
			if( mManager->getCameraRelativeRendering() )
			{
				OGRE_EXCEPT(Exception::ERR_INVALID_STATE, "Camera-relative rendering is incompatible"
					" with Instancing's static batches. Disable at least one of them",
					"InstanceBatch::_updateRenderQueue");
			}

			//Don't update when we're static
			if( mRenderOperation.numberOfInstances )
				queue->addRenderable( this, mRenderQueueID, mRenderQueuePriority );
		}
	}
}
