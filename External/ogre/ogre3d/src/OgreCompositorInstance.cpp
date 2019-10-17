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
#include "OgreCompositorInstance.h"
#include "OgreCompositorChain.h"
#include "OgreCompositorManager.h"
#include "OgreCompositionTargetPass.h"
#include "OgreCompositionPass.h"
#include "OgreCompositionTechnique.h"
#include "OgreCustomCompositionPass.h"
#include "OgreTechnique.h"
#include "OgrePass.h"
#include "OgreTexture.h"
#include "OgreLogManager.h"
#include "OgreMaterialManager.h"
#include "OgreTextureManager.h"
#include "OgreSceneManager.h"
#include "OgreStringConverter.h"
#include "OgreException.h"
#include "OgreHardwarePixelBuffer.h"
#include "OgreCamera.h"
#include "OgreRoot.h"
#include "OgreRenderSystem.h"
#include "OgreHardwareBufferManager.h"
#include "OgreCompositorLogic.h"

namespace Ogre {
CompositorInstance::CompositorInstance(CompositionTechnique *technique,
    CompositorChain *chain):
    mCompositor(technique->getParent()), mTechnique(technique), mChain(chain),
		mEnabled(false),
		mAlive(false)
{
	mEnabled = false;
	const String& logicName = mTechnique->getCompositorLogicName();
	if (!logicName.empty())
	{
		CompositorManager::getSingleton().
			getCompositorLogic(logicName)->compositorInstanceCreated(this);
	}
}
//-----------------------------------------------------------------------
CompositorInstance::~CompositorInstance()
{
	const String& logicName = mTechnique->getCompositorLogicName();
	if (!logicName.empty())
	{
		CompositorManager::getSingleton().
			getCompositorLogic(logicName)->compositorInstanceDestroyed(this);
	}

    freeResources(false, true);
}
//-----------------------------------------------------------------------
void CompositorInstance::setEnabled(bool value)
{
	if (mEnabled != value)
    {
        mEnabled = value;

	    //Probably first time enabling, create resources.
	    if( mEnabled && !mAlive )
    		setAlive( true );

		/// Notify chain state needs recompile.
        mChain->_markDirty();
	}
}
//-----------------------------------------------------------------------
void CompositorInstance::setAlive(bool value)
{
    if (mAlive != value)
    {
        mAlive = value;

        // Create of free resource.
        if (value)
        {
            createResources(false);
        }
        else
        {
            freeResources(false, true);
			setEnabled(false);
        }

		/// Notify chain state needs recompile.
        mChain->_markDirty();
    }
}
//-----------------------------------------------------------------------

/** Clear framebuffer RenderSystem operation
 */
class RSClearOperation: public CompositorInstance::RenderSystemOperation
{
public:
	RSClearOperation(uint32 inBuffers, ColourValue inColour, Real inDepth, unsigned short inStencil):
		buffers(inBuffers), colour(inColour), depth(inDepth), stencil(inStencil)
	{}
	/// Which buffers to clear (FrameBufferType)
	uint32 buffers;
	/// Colour to clear in case FBT_COLOUR is set
	ColourValue colour;
	/// Depth to set in case FBT_DEPTH is set
	Real depth;
	/// Stencil value to set in case FBT_STENCIL is set
	unsigned short stencil;

	virtual void execute(SceneManager *sm, RenderSystem *rs)
	{
		rs->clearFrameBuffer(buffers, colour, depth, stencil);
	}
};

/** "Set stencil state" RenderSystem operation
 */
class RSStencilOperation: public CompositorInstance::RenderSystemOperation
{
public:
	RSStencilOperation(bool inStencilCheck, CompareFunction inFunc, uint32 inRefValue, uint32 inMask,
		StencilOperation inStencilFailOp, StencilOperation inDepthFailOp, StencilOperation inPassOp,
		bool inTwoSidedOperation):
		stencilCheck(inStencilCheck), func(inFunc), refValue(inRefValue), mask(inMask),
		stencilFailOp(inStencilFailOp), depthFailOp(inDepthFailOp), passOp(inPassOp),
		twoSidedOperation(inTwoSidedOperation)
	{}
	bool stencilCheck;
	CompareFunction func; 
    uint32 refValue;
	uint32 mask;
    StencilOperation stencilFailOp;
    StencilOperation depthFailOp;
    StencilOperation passOp;
    bool twoSidedOperation;

	virtual void execute(SceneManager *sm, RenderSystem *rs)
	{
		rs->setStencilCheckEnabled(stencilCheck);
		rs->setStencilBufferParams(func, refValue, mask, 0xFFFFFFFF, stencilFailOp, depthFailOp, passOp, twoSidedOperation);
	}
};

/** "Render quad" RenderSystem operation
 */
class RSQuadOperation: public CompositorInstance::RenderSystemOperation
{
public:
	RSQuadOperation(CompositorInstance *inInstance, uint32 inPass_id, MaterialPtr inMat):
	  mat(inMat), instance(inInstance), pass_id(inPass_id),
      mQuadCornerModified(false),
      mQuadFarCorners(false),
      mQuadFarCornersViewSpace(false),
      mQuadLeft(-1),
      mQuadTop(1),
      mQuadRight(1),
      mQuadBottom(-1)
	{
		mat->load();
		instance->_fireNotifyMaterialSetup(pass_id, mat);
		technique = mat->getTechnique(0);
		assert(technique);
	}
	MaterialPtr mat;
	Technique *technique;
	CompositorInstance *instance;
	uint32 pass_id;

    bool mQuadCornerModified, mQuadFarCorners, mQuadFarCornersViewSpace;
    Real mQuadLeft;
    Real mQuadTop;
    Real mQuadRight;
    Real mQuadBottom;

    void setQuadCorners(Real left,Real top,Real right,Real bottom)
    {
        mQuadLeft = left;
        mQuadTop = top;
        mQuadRight = right;
        mQuadBottom = bottom;
        mQuadCornerModified=true;
    }

	void setQuadFarCorners(bool farCorners, bool farCornersViewSpace)
	{
		mQuadFarCorners = farCorners;
		mQuadFarCornersViewSpace = farCornersViewSpace;
	}
   
	virtual void execute(SceneManager *sm, RenderSystem *rs)
	{
		// Fire listener
		instance->_fireNotifyMaterialRender(pass_id, mat);

        Viewport* vp = rs->_getViewport();
		Rectangle2D *rect = static_cast<Rectangle2D*>(CompositorManager::getSingleton()._getTexturedRectangle2D());

		if (mQuadCornerModified)
		{
			// insure positions are using peculiar render system offsets 
			Real hOffset = rs->getHorizontalTexelOffset() / (0.5f * vp->getActualWidth());
			Real vOffset = rs->getVerticalTexelOffset() / (0.5f * vp->getActualHeight());
			rect->setCorners(mQuadLeft + hOffset, mQuadTop - vOffset, mQuadRight + hOffset, mQuadBottom - vOffset);
		}

		if(mQuadFarCorners)
		{
			const Ogre::Vector3 *corners = vp->getCamera()->getWorldSpaceCorners();
			if(mQuadFarCornersViewSpace)
			{
				const Ogre::Matrix4 &viewMat = vp->getCamera()->getViewMatrix(true);
				rect->setNormals(viewMat*corners[5], viewMat*corners[6], viewMat*corners[4], viewMat*corners[7]);
			}
			else
			{
				rect->setNormals(corners[5], corners[6], corners[4], corners[7]);
			}
		}

		// Queue passes from mat
		Technique::PassIterator i = technique->getPassIterator();
		while(i.hasMoreElements())
		{
			sm->_injectRenderWithPass(
				i.getNext(), 
				rect,
				false // don't allow replacement of shadow passes
				);
		}
	}
};

/** "Set material scheme" RenderSystem operation
 */
class RSSetSchemeOperation: public CompositorInstance::RenderSystemOperation
{
public:
	RSSetSchemeOperation(const String& schemeName) : mPreviousLateResolving(false), mSchemeName(schemeName) {}
	
	String mPreviousScheme;
	bool mPreviousLateResolving;

	String mSchemeName;

	virtual void execute(SceneManager *sm, RenderSystem *rs)
	{
		MaterialManager& matMgr = MaterialManager::getSingleton();
		mPreviousScheme = matMgr.getActiveScheme();
		matMgr.setActiveScheme(mSchemeName);

		mPreviousLateResolving = sm->isLateMaterialResolving();
		sm->setLateMaterialResolving(true);
	}

	const String& getPreviousScheme() const { return mPreviousScheme; }
	bool getPreviousLateResolving() const { return mPreviousLateResolving; }
};

/** Restore the settings changed by the set scheme operation */
class RSRestoreSchemeOperation: public CompositorInstance::RenderSystemOperation
{
public:
	RSRestoreSchemeOperation(const RSSetSchemeOperation* setOperation) : 
	  mSetOperation(setOperation) {}
	
	const RSSetSchemeOperation* mSetOperation;

	virtual void execute(SceneManager *sm, RenderSystem *rs)
	{
		MaterialManager::getSingleton().setActiveScheme(mSetOperation->getPreviousScheme());
		sm->setLateMaterialResolving(mSetOperation->getPreviousLateResolving());
	}
};

void CompositorInstance::collectPasses(TargetOperation &finalState, CompositionTargetPass *target)
{
	/// Here, passes are converted into render target operations
    Pass *targetpass;
    Technique *srctech;
	MaterialPtr mat, srcmat;
	
    CompositionTargetPass::PassIterator it = target->getPassIterator();
    while(it.hasMoreElements())
    {
        CompositionPass *pass = it.getNext();
        switch(pass->getType())
        {
        case CompositionPass::PT_CLEAR:
			queueRenderSystemOp(finalState, OGRE_NEW RSClearOperation(
				pass->getClearBuffers(),
				pass->getClearColour(),
				pass->getClearDepth(),
				(ushort)pass->getClearStencil()
				));
            break;
		case CompositionPass::PT_STENCIL:
			queueRenderSystemOp(finalState, OGRE_NEW RSStencilOperation(
				pass->getStencilCheck(),pass->getStencilFunc(), pass->getStencilRefValue(),
				pass->getStencilMask(), pass->getStencilFailOp(), pass->getStencilDepthFailOp(),
				pass->getStencilPassOp(), pass->getStencilTwoSidedOperation()
				));
            break;
		case CompositionPass::PT_RENDERSCENE: 
		{
			if(pass->getFirstRenderQueue() < finalState.currentQueueGroupID)
			{
				/// Mismatch -- warn user
				/// XXX We could support repeating the last queue, with some effort
				LogManager::getSingleton().logMessage("Warning in compilation of Compositor "
					+mCompositor->getName()+": Attempt to render queue "+
					StringConverter::toString(pass->getFirstRenderQueue())+" before "+
					StringConverter::toString(finalState.currentQueueGroupID), LML_CRITICAL);
			}

			RSSetSchemeOperation* setSchemeOperation = 0;
			if (pass->getMaterialScheme() != StringUtil::BLANK)
			{
				//Add the triggers that will set the scheme and restore it each frame
				finalState.currentQueueGroupID = pass->getFirstRenderQueue();
				setSchemeOperation = OGRE_NEW RSSetSchemeOperation(pass->getMaterialScheme());
				queueRenderSystemOp(finalState, setSchemeOperation);
			}
			
			/// Add render queues
			for(int x=pass->getFirstRenderQueue(); x<=pass->getLastRenderQueue(); ++x)
			{
				assert(x>=0);
				finalState.renderQueues.set(x);
			}
			finalState.currentQueueGroupID = pass->getLastRenderQueue()+1;

			if (setSchemeOperation != 0)
			{
				//Restoring the scheme after the queues have been rendered
				queueRenderSystemOp(finalState, 
					OGRE_NEW RSRestoreSchemeOperation(setSchemeOperation));
			}

			finalState.findVisibleObjects = true;

            break;
		}
		case CompositionPass::PT_RENDERQUAD: {
            srcmat = pass->getMaterial();
			if(srcmat.isNull())
            {
                /// No material -- warn user
				LogManager::getSingleton().logMessage("Warning in compilation of Compositor "
					+mCompositor->getName()+": No material defined for composition pass", LML_CRITICAL);
                break;
            }
			srcmat->load();
			if(srcmat->getNumSupportedTechniques()==0)  
			{
				/// No supported techniques -- warn user
				LogManager::getSingleton().logMessage("Warning in compilation of Compositor "
					+mCompositor->getName()+": material "+srcmat->getName()+" has no supported techniques", LML_CRITICAL);
                break;
			}
			srctech = srcmat->getBestTechnique(0);
			/// Create local material
			MaterialPtr localMat = createLocalMaterial(srcmat->getName());
			/// Copy and adapt passes from source material
			Technique::PassIterator i = srctech->getPassIterator();
			while(i.hasMoreElements())
			{
				Pass *srcpass = i.getNext();
				/// Create new target pass
				targetpass = localMat->getTechnique(0)->createPass();
				(*targetpass) = (*srcpass);
				/// Set up inputs
				for(size_t x=0; x<pass->getNumInputs(); ++x)
				{
					const CompositionPass::InputTex& inp = pass->getInput(x);
					if(!inp.name.empty())
					{
						if(x < targetpass->getNumTextureUnitStates())
						{
							targetpass->getTextureUnitState((ushort)x)->setTextureName(getSourceForTex(inp.name, inp.mrtIndex));
						} 
						else
						{
							/// Texture unit not there
							LogManager::getSingleton().logMessage("Warning in compilation of Compositor "
								+mCompositor->getName()+": material "+srcmat->getName()+" texture unit "
								+StringConverter::toString(x)+" out of bounds", LML_CRITICAL);
						}
					}
				}
			}

            RSQuadOperation * rsQuadOperation = OGRE_NEW RSQuadOperation(this,pass->getIdentifier(),localMat);
            Real left,top,right,bottom;
            if (pass->getQuadCorners(left,top,right,bottom))
                rsQuadOperation->setQuadCorners(left,top,right,bottom);
			rsQuadOperation->setQuadFarCorners(pass->getQuadFarCorners(), pass->getQuadFarCornersViewSpace());
			
			queueRenderSystemOp(finalState,rsQuadOperation);
			}
            break;
		case CompositionPass::PT_RENDERCUSTOM:
			RenderSystemOperation* customOperation = CompositorManager::getSingleton().
				getCustomCompositionPass(pass->getCustomType())->createOperation(this, pass);
			queueRenderSystemOp(finalState, customOperation);
			break;
        }
    }
}
//-----------------------------------------------------------------------
void CompositorInstance::_compileTargetOperations(CompiledState &compiledState)
{
    /// Collect targets of previous state
	if(mPreviousInstance)
	    mPreviousInstance->_compileTargetOperations(compiledState);
    /// Texture targets
    CompositionTechnique::TargetPassIterator it = mTechnique->getTargetPassIterator();
    while(it.hasMoreElements())
    {
        CompositionTargetPass *target = it.getNext();
        
        TargetOperation ts(getTargetForTex(target->getOutputName()));
        /// Set "only initial" flag, visibilityMask and lodBias according to CompositionTargetPass.
        ts.onlyInitial = target->getOnlyInitial();
        ts.visibilityMask = target->getVisibilityMask();
        ts.lodBias = target->getLodBias();
        ts.shadowsEnabled = target->getShadowsEnabled();
        ts.materialScheme = target->getMaterialScheme();
        /// Check for input mode previous
        if(target->getInputMode() == CompositionTargetPass::IM_PREVIOUS)
        {
            /// Collect target state for previous compositor
            /// The TargetOperation for the final target is collected separately as it is merged
            /// with later operations
            mPreviousInstance->_compileOutputOperation(ts);
        }
        /// Collect passes of our own target
        collectPasses(ts, target);
        compiledState.push_back(ts);
    }
}
//-----------------------------------------------------------------------
void CompositorInstance::_compileOutputOperation(TargetOperation &finalState)
{
    /// Final target
    CompositionTargetPass *tpass = mTechnique->getOutputTargetPass();
    
    /// Logical-and together the visibilityMask, and multiply the lodBias
    finalState.visibilityMask &= tpass->getVisibilityMask();
    finalState.lodBias *= tpass->getLodBias();
    finalState.materialScheme = tpass->getMaterialScheme();
    finalState.shadowsEnabled = tpass->getShadowsEnabled();

    if(tpass->getInputMode() == CompositionTargetPass::IM_PREVIOUS)
    {
        /// Collect target state for previous compositor
        /// The TargetOperation for the final target is collected separately as it is merged
        /// with later operations
        mPreviousInstance->_compileOutputOperation(finalState);
    }
    /// Collect passes
    collectPasses(finalState, tpass);
}
//-----------------------------------------------------------------------
Compositor *CompositorInstance::getCompositor()
{
    return mCompositor;
}
//-----------------------------------------------------------------------
CompositionTechnique *CompositorInstance::getTechnique()
{
    return mTechnique;
}
//-----------------------------------------------------------------------
void CompositorInstance::setTechnique(CompositionTechnique* tech, bool reuseTextures)
{
	if (mTechnique != tech)
	{
		if (reuseTextures)
		{
			// make sure we store all (shared) textures in use in our reserve pool
			// this will ensure they don't get destroyed as unreferenced
			// so they're ready to use again later
			CompositionTechnique::TextureDefinitionIterator it = mTechnique->getTextureDefinitionIterator();
			while(it.hasMoreElements())
			{
				CompositionTechnique::TextureDefinition *def = it.getNext();
				if (def->pooled)
				{
					LocalTextureMap::iterator i = mLocalTextures.find(def->name);
					if (i != mLocalTextures.end())
					{
						// overwriting duplicates is fine, we only want one entry per def
						mReserveTextures[def] = i->second;
					}

				}
			}
		}
		// replace technique
		mTechnique = tech;

		if (mAlive)
		{
			// free up resources, but keep reserves if reusing
			freeResources(false, !reuseTextures);
			createResources(false);
			/// Notify chain state needs recompile.
			mChain->_markDirty();
		}

	}
}
//---------------------------------------------------------------------
void CompositorInstance::setScheme(const String& schemeName, bool reuseTextures)
{
	CompositionTechnique* tech = mCompositor->getSupportedTechnique(schemeName);
	if (tech)
	{
		setTechnique(tech, reuseTextures);
	}
}
//-----------------------------------------------------------------------
CompositorChain *CompositorInstance::getChain()
{
	return mChain;
}
//-----------------------------------------------------------------------
const String& CompositorInstance::getTextureInstanceName(const String& name, 
														 size_t mrtIndex)
{
	return getSourceForTex(name, mrtIndex);
}
//---------------------------------------------------------------------
TexturePtr CompositorInstance::getTextureInstance(const String& name, size_t mrtIndex)
{
	// try simple textures first
	LocalTextureMap::iterator i = mLocalTextures.find(name);
	if(i != mLocalTextures.end())
	{
		return i->second;
	}

	// try MRTs - texture (rather than target)
	i = mLocalTextures.find(getMRTTexLocalName(name, mrtIndex));
	if (i != mLocalTextures.end())
	{
		return i->second;
	}

	// not present
	return TexturePtr();

}
//-----------------------------------------------------------------------
MaterialPtr CompositorInstance::createLocalMaterial(const String& srcName)
{
static size_t dummyCounter = 0;
    MaterialPtr mat = 
        MaterialManager::getSingleton().create(
            "c" + StringConverter::toString(dummyCounter) + "/" + srcName,
            ResourceGroupManager::INTERNAL_RESOURCE_GROUP_NAME
        );
    ++dummyCounter;
    /// This is safe, as we hold a private reference
    /// XXX does not compile due to ResourcePtr conversion :
    ///     MaterialManager::getSingleton().remove(mat);
    MaterialManager::getSingleton().remove(mat->getName());
    /// Remove all passes from first technique
    mat->getTechnique(0)->removeAllPasses();
    return mat;
}
//---------------------------------------------------------------------
void CompositorInstance::notifyResized()
{
	freeResources(true, true);
	createResources(true);
}
//-----------------------------------------------------------------------
void CompositorInstance::createResources(bool forResizeOnly)
{
	static size_t dummyCounter = 0;
    /// Create temporary textures
    /// In principle, temporary textures could be shared between multiple viewports
    /// (CompositorChains). This will save a lot of memory in case more viewports
    /// are composited.
    CompositionTechnique::TextureDefinitionIterator it = mTechnique->getTextureDefinitionIterator();
	CompositorManager::UniqueTextureSet assignedTextures;
    while(it.hasMoreElements())
    {
        CompositionTechnique::TextureDefinition *def = it.getNext();
        
		if (!def->refCompName.empty()) {
			//This is a reference, isn't created in this compositor
			continue;
		}
        
        RenderTarget* rendTarget;
		if (def->scope == CompositionTechnique::TS_GLOBAL) {
			//This is a global texture, just link the created resources from the parent
			Compositor* parentComp = mTechnique->getParent();
			if (def->formatList.size() > 1) 
			{
				size_t atch = 0;
				for (PixelFormatList::iterator p = def->formatList.begin(); 
                     p != def->formatList.end(); ++p, ++atch)
				{
					Ogre::TexturePtr tex = parentComp->getTextureInstance(def->name, atch);
					mLocalTextures[getMRTTexLocalName(def->name, atch)] = tex;
				}
				MultiRenderTarget* mrt = static_cast<MultiRenderTarget*>
                (parentComp->getRenderTarget(def->name));
				mLocalMRTs[def->name] = mrt;
                
                rendTarget = mrt;
            } else {
				Ogre::TexturePtr tex = parentComp->getTextureInstance(def->name, 0);
				mLocalTextures[def->name] = tex;
                
                rendTarget = tex->getBuffer()->getRenderTarget();
            }
            
        } else {
            /// Determine width and height
            size_t width = def->width;
            size_t height = def->height;
            uint fsaa = 0;
            String fsaaHint;
            bool hwGamma = false;
            
            // Skip this one if we're only (re)creating for a resize & it's not derived
            // from the target size
            if (forResizeOnly && width != 0 && height != 0)
                continue;
            
            deriveTextureRenderTargetOptions(def->name, &hwGamma, &fsaa, &fsaaHint);
            
            if(width == 0)
                width = static_cast<size_t>(
                                            static_cast<float>(mChain->getViewport()->getActualWidth()) * def->widthFactor);
            if(height == 0)
                height = static_cast<size_t>(
                                             static_cast<float>(mChain->getViewport()->getActualHeight()) * def->heightFactor);
            
            // determine options as a combination of selected options and possible options
            if (!def->fsaa)
            {
                fsaa = 0;
                fsaaHint = StringUtil::BLANK;
            }
            hwGamma = hwGamma || def->hwGammaWrite;
            
            /// Make the tetxure
            if (def->formatList.size() > 1)
            {
                String MRTbaseName = "c" + StringConverter::toString(dummyCounter++) + 
				"/" + def->name + "/" + mChain->getViewport()->getTarget()->getName();
                MultiRenderTarget* mrt = 
				Root::getSingleton().getRenderSystem()->createMultiRenderTarget(MRTbaseName);
                mLocalMRTs[def->name] = mrt;
                
                // create and bind individual surfaces
                size_t atch = 0;
                for (PixelFormatList::iterator p = def->formatList.begin(); 
                     p != def->formatList.end(); ++p, ++atch)
                {
                    
                    String texname = MRTbaseName + "/" + StringConverter::toString(atch);
                    String mrtLocalName = getMRTTexLocalName(def->name, atch);
                    TexturePtr tex;
                    if (def->pooled)
                    {
                        // get / create pooled texture
                        tex = CompositorManager::getSingleton().getPooledTexture(texname,
                                                                                 mrtLocalName, 
                                                                                 width, height, *p, fsaa, fsaaHint,  
                                                                                 hwGamma && !PixelUtil::isFloatingPoint(*p), 
                                                                                 assignedTextures, this, def->scope);
                    }
                    else
                    {
                        tex = TextureManager::getSingleton().createManual(
                                                                          texname, 
                                                                          ResourceGroupManager::INTERNAL_RESOURCE_GROUP_NAME, TEX_TYPE_2D, 
                                                                          (uint)width, (uint)height, 0, *p, TU_RENDERTARGET, 0, 
                                                                          hwGamma && !PixelUtil::isFloatingPoint(*p), fsaa, fsaaHint ); 
                    }
                    
                    RenderTexture* rt = tex->getBuffer()->getRenderTarget();
                    rt->setAutoUpdated(false);
                    mrt->bindSurface(atch, rt);
                    
                    // Also add to local textures so we can look up
                    mLocalTextures[mrtLocalName] = tex;
                    
                }
                
                rendTarget = mrt;
            }
            else
            {
                String texName =  "c" + StringConverter::toString(dummyCounter++) + 
				"/" + def->name + "/" + mChain->getViewport()->getTarget()->getName();
                
                // space in the name mixup the cegui in the compositor demo
                // this is an auto generated name - so no spaces can't hart us.
                std::replace( texName.begin(), texName.end(), ' ', '_' ); 
                
                TexturePtr tex;
                if (def->pooled)
                {
                    // get / create pooled texture
                    tex = CompositorManager::getSingleton().getPooledTexture(texName, 
                                                                             def->name, width, height, def->formatList[0], fsaa, fsaaHint,
                                                                             hwGamma && !PixelUtil::isFloatingPoint(def->formatList[0]), assignedTextures, 
                                                                             this, def->scope);
                }
                else
                {
                    tex = TextureManager::getSingleton().createManual(
                                                                      texName, 
                                                                      ResourceGroupManager::INTERNAL_RESOURCE_GROUP_NAME, TEX_TYPE_2D, 
                                                                      (uint)width, (uint)height, 0, def->formatList[0], TU_RENDERTARGET, 0,
                                                                      hwGamma && !PixelUtil::isFloatingPoint(def->formatList[0]), fsaa, fsaaHint); 
                }
                
                rendTarget = tex->getBuffer()->getRenderTarget();
                mLocalTextures[def->name] = tex;
            }
        }
        
		//Set DepthBuffer pool for sharing
		rendTarget->setDepthBufferPool( def->depthBufferId );
        
        /// Set up viewport over entire texture
        rendTarget->setAutoUpdated( false );
        
		// We may be sharing / reusing this texture, so test before adding viewport
		if (rendTarget->getNumViewports() == 0)
		{
			Viewport* v;
			Camera* camera = mChain->getViewport()->getCamera();
			if (!camera)
			{
				v = rendTarget->addViewport( camera );
			}
			else
			{
				// Save last viewport and current aspect ratio
				Viewport* oldViewport = camera->getViewport();
				Real aspectRatio = camera->getAspectRatio();
                
				v = rendTarget->addViewport( camera );
                
				// Should restore aspect ratio, in case of auto aspect ratio
				// enabled, it'll changed when add new viewport.
				camera->setAspectRatio(aspectRatio);
				// Should restore last viewport, i.e. never disturb user code
				// which might based on that.
				camera->_notifyViewport(oldViewport);
			}
            
			v->setClearEveryFrame( false );
			v->setOverlaysEnabled( false );
			v->setBackgroundColour( ColourValue( 0, 0, 0, 0 ) );
		}
    }
    
	_fireNotifyResourcesCreated(forResizeOnly);
}
//---------------------------------------------------------------------
void CompositorInstance::deriveTextureRenderTargetOptions(
	const String& texname, bool *hwGammaWrite, uint *fsaa, String* fsaaHint)
{
	// search for passes on this texture def that either include a render_scene
	// or use input previous
	bool renderingScene = false;

	CompositionTechnique::TargetPassIterator it = mTechnique->getTargetPassIterator();
	while (it.hasMoreElements())
	{
		CompositionTargetPass* tp = it.getNext();
		if (tp->getOutputName() == texname)
		{
			if (tp->getInputMode() == CompositionTargetPass::IM_PREVIOUS)
			{
				// this may be rendering the scene implicitly
				// Can't check mPreviousInstance against mChain->_getOriginalSceneCompositor()
				// at this time, so check the position
				CompositorChain::InstanceIterator instit = mChain->getCompositors();
				renderingScene = true;
				while(instit.hasMoreElements())
				{
					CompositorInstance* inst = instit.getNext();
					if (inst == this)
						break;
					else if (inst->getEnabled())
					{
						// nope, we have another compositor before us, this will
						// be doing the AA
						renderingScene = false;
					}
				}
				if (renderingScene)
					break;
			}
			else
			{
				// look for a render_scene pass
				CompositionTargetPass::PassIterator pit = tp->getPassIterator();
				while(pit.hasMoreElements())
				{
					CompositionPass* pass = pit.getNext();
					if (pass->getType() == CompositionPass::PT_RENDERSCENE)
					{
						renderingScene = true;
						break;
					}
				}
			}

		}
	}

	if (renderingScene)
	{
		// Ok, inherit settings from target
		RenderTarget* target = mChain->getViewport()->getTarget();
		*hwGammaWrite = target->isHardwareGammaEnabled();
		*fsaa = target->getFSAA();
		*fsaaHint = target->getFSAAHint();
	}
	else
	{
		*hwGammaWrite = false;
		*fsaa = 0;
		*fsaaHint = StringUtil::BLANK;
	}

}
//---------------------------------------------------------------------
String CompositorInstance::getMRTTexLocalName(const String& baseName, size_t attachment)
{
	return baseName + "/" + StringConverter::toString(attachment);
}
//-----------------------------------------------------------------------
void CompositorInstance::freeResources(bool forResizeOnly, bool clearReserveTextures)
{
    // Remove temporary textures 
	// We only remove those that are not shared, shared textures are dealt with
	// based on their reference count.
	// We can also only free textures which are derived from the target size, if
	// required (saves some time & memory thrashing / fragmentation on resize)

	CompositionTechnique::TextureDefinitionIterator it = mTechnique->getTextureDefinitionIterator();
	while(it.hasMoreElements())
	{
		CompositionTechnique::TextureDefinition *def = it.getNext();

		if (!def->refCompName.empty()) 
		{
			//This is a reference, isn't created here
			continue;
		}
		
		// potentially only remove this one if based on size
		if (!forResizeOnly || def->width == 0 || def->height == 0)
		{
			size_t subSurf = def->formatList.size();

			// Potentially many surfaces
			for (size_t s = 0; s < subSurf; ++s)
			{
				String texName = subSurf > 1 ? getMRTTexLocalName(def->name, s)
					: def->name;

				LocalTextureMap::iterator i = mLocalTextures.find(texName);
				if (i != mLocalTextures.end())
				{
					if (!def->pooled && def->scope != CompositionTechnique::TS_GLOBAL)
					{
						// remove myself from central only if not pooled and not global
						TextureManager::getSingleton().remove(i->second->getName());
					}

					// remove from local
					// reserves are potentially cleared later
					mLocalTextures.erase(i);

				}

			} // subSurf

			if (subSurf > 1)
			{
				LocalMRTMap::iterator mrti = mLocalMRTs.find(def->name);
				if (mrti != mLocalMRTs.end())
				{
					if (def->scope != CompositionTechnique::TS_GLOBAL) 
					{
						// remove MRT if not global
						Root::getSingleton().getRenderSystem()->destroyRenderTarget(mrti->second->getName());
					}
					
					mLocalMRTs.erase(mrti);
				}

			}

		} // not for resize or width/height 0
	}

	if (clearReserveTextures)
	{
		if (forResizeOnly)
		{
			// just remove the ones which would be affected by a resize
			for (ReserveTextureMap::iterator i = mReserveTextures.begin();
				i != mReserveTextures.end(); )
			{
				if (i->first->width == 0 || i->first->height == 0)
				{
					mReserveTextures.erase(i++);
				}
				else
					++i;
			}
		}
		else
		{
			// clear all
			mReserveTextures.clear();
		}
	}

	// Now we tell the central list of textures to check if its unreferenced, 
	// and to remove if necessary. Anything shared that was left in the reserve textures
	// will not be released here
	CompositorManager::getSingleton().freePooledTextures(true);
}
//---------------------------------------------------------------------
RenderTarget* CompositorInstance::getRenderTarget(const String& name)
{
	return getTargetForTex(name);
}
//-----------------------------------------------------------------------
RenderTarget *CompositorInstance::getTargetForTex(const String &name)
{
	// try simple texture
	LocalTextureMap::iterator i = mLocalTextures.find(name);
    if(i != mLocalTextures.end())
		return i->second->getBuffer()->getRenderTarget();

	// try MRTs
	LocalMRTMap::iterator mi = mLocalMRTs.find(name);
	if (mi != mLocalMRTs.end())
		return mi->second;
	
	//Try reference : Find the instance and check if it is before us
	CompositionTechnique::TextureDefinition* texDef = mTechnique->getTextureDefinition(name);
	if (texDef != 0 && !texDef->refCompName.empty()) 
	{
 		//This TextureDefinition is reference.
 		//Since referenced TD's have no info except name we have to find original TD
        
 		CompositionTechnique::TextureDefinition* refTexDef = 0;
        
 		//Try chain first
 		if(mChain)
  		{
 			CompositorInstance* refCompInst = mChain->getCompositor(texDef->refCompName);
 			if(refCompInst)
 			{
                refTexDef = refCompInst->getCompositor()->getSupportedTechnique(
                    refCompInst->getScheme())->getTextureDefinition(texDef->refTexName);
                // if the texture with the reference name can not be found, try the name
                if (refTexDef == 0)
                {
 				    refTexDef = refCompInst->getCompositor()->getSupportedTechnique(
                        refCompInst->getScheme())->getTextureDefinition(name);
                }
 			}
			else
			{
				OGRE_EXCEPT(Exception::ERR_ITEM_NOT_FOUND, "Referencing non-existent compositor",
                            "CompositorInstance::getTargetForTex");
			}
  		}
        
 		if(refTexDef == 0)
  		{
 			//Still NULL. Try global search.
            const CompositorPtr &refComp = CompositorManager::getSingleton().getByName(texDef->refCompName);
 			if(!refComp.isNull())
 			{
 				refTexDef = refComp->getSupportedTechnique()->getTextureDefinition(name);
 			}
 		}
        
 		if(refTexDef == 0)
 		{
 			//Still NULL
			OGRE_EXCEPT(Exception::ERR_ITEM_NOT_FOUND, "Referencing non-existent compositor texture",
                        "CompositorInstance::getTargetForTex");
  		}
        
 		switch(refTexDef->scope) 
  		{
 			case CompositionTechnique::TS_CHAIN:
  			{
  				//Find the instance and check if it is before us
  				CompositorInstance* refCompInst = 0;
                OgreAssert(mChain, "Undefined compositor chain");
				CompositorChain::InstanceIterator it = mChain->getCompositors();
				bool beforeMe = true;
				while (it.hasMoreElements())
				{
					CompositorInstance* nextCompInst = it.getNext();
					if (nextCompInst->getCompositor()->getName() == texDef->refCompName)
					{
						refCompInst = nextCompInst;
						break;
					}
					if (nextCompInst == this)
					{
						//We encountered ourselves while searching for the compositor -
						//we are earlier in the chain.
						beforeMe = false;
					}
				}
				
				if (refCompInst == 0 || !refCompInst->getEnabled()) 
				{
					OGRE_EXCEPT(Exception::ERR_INVALID_STATE, "Referencing inactive compositor texture",
						"CompositorInstance::getTargetForTex");
				}
				if (!beforeMe)
				{
					OGRE_EXCEPT(Exception::ERR_INVALID_STATE, "Referencing compositor that is later in the chain",
						"CompositorInstance::getTargetForTex");
				}
				return refCompInst->getRenderTarget(texDef->refTexName);
			}
			case CompositionTechnique::TS_GLOBAL:
			{
				//Chain and global case - the referenced compositor will know how to handle
				const CompositorPtr& refComp = CompositorManager::getSingleton().getByName(texDef->refCompName);
				if(refComp.isNull())
				{
					OGRE_EXCEPT(Exception::ERR_ITEM_NOT_FOUND, "Referencing non-existent compositor",
						"CompositorInstance::getTargetForTex");
				}
				return refComp->getRenderTarget(texDef->refTexName);
			}
			case CompositionTechnique::TS_LOCAL:
			default:
				OGRE_EXCEPT(Exception::ERR_INVALIDPARAMS, "Referencing local compositor texture",
					"CompositorInstance::getTargetForTex");
		}
	}

	OGRE_EXCEPT(Exception::ERR_INVALIDPARAMS, "Non-existent local texture name", 
		"CompositorInstance::getTargetForTex");

}
//-----------------------------------------------------------------------
const String &CompositorInstance::getSourceForTex(const String &name, size_t mrtIndex)
{
  	CompositionTechnique::TextureDefinition* texDef = mTechnique->getTextureDefinition(name);
 	if(texDef == 0)
 	{
 		OGRE_EXCEPT(Exception::ERR_ITEM_NOT_FOUND, "Referencing non-existent TextureDefinition",
                    "CompositorInstance::getSourceForTex");
 	}
    
 	//Check if texture definition is reference
 	if(!texDef->refCompName.empty())
  	{
 		//This TextureDefinition is reference.
 		//Since referenced TD's have no info except name we have to find original TD
 		
 		CompositionTechnique::TextureDefinition* refTexDef = 0;
        
 		//Try chain first
 		if(mChain)
  		{
 			CompositorInstance* refCompInst = mChain->getCompositor(texDef->refCompName);
 			if(refCompInst)
 			{
 				refTexDef = refCompInst->getCompositor()->
                    getSupportedTechnique(refCompInst->getScheme())->getTextureDefinition(texDef->refTexName);
 			}
			else
			{
				OGRE_EXCEPT(Exception::ERR_ITEM_NOT_FOUND, "Referencing non-existent compositor",
                            "CompositorInstance::getSourceForTex");
			}
 		}
        
 		if(refTexDef == 0)
 		{
 			//Still NULL. Try global search.
            const CompositorPtr &refComp = CompositorManager::getSingleton().getByName(texDef->refCompName);
 			if(!refComp.isNull())
 			{
 				refTexDef = refComp->getSupportedTechnique()->getTextureDefinition(texDef->refTexName);
 			}
 		}
        
 		if(refTexDef == 0)
 		{
 			//Still NULL
			OGRE_EXCEPT(Exception::ERR_ITEM_NOT_FOUND, "Referencing non-existent compositor texture",
                        "CompositorInstance::getSourceForTex");
  		}
        
 		switch(refTexDef->scope)
  		{
 			case CompositionTechnique::TS_CHAIN:
  			{
  				//Find the instance and check if it is before us
  				CompositorInstance* refCompInst = 0;
                OgreAssert(mChain, "Undefined compositor chain");
				CompositorChain::InstanceIterator it = mChain->getCompositors();
				bool beforeMe = true;
				while (it.hasMoreElements())
				{
					CompositorInstance* nextCompInst = it.getNext();
					if (nextCompInst->getCompositor()->getName() == texDef->refCompName)
					{
						refCompInst = nextCompInst;
						break;
					}
					if (nextCompInst == this)
					{
						//We encountered ourselves while searching for the compositor -
						//we are earlier in the chain.
						beforeMe = false;
					}
				}
				
				if (refCompInst == 0 || !refCompInst->getEnabled()) 
				{
					OGRE_EXCEPT(Exception::ERR_INVALID_STATE, "Referencing inactive compositor texture",
						"CompositorInstance::getSourceForTex");
				}
				if (!beforeMe)
				{
					OGRE_EXCEPT(Exception::ERR_INVALID_STATE, "Referencing compositor that is later in the chain",
						"CompositorInstance::getSourceForTex");
				}
				return refCompInst->getTextureInstanceName(texDef->refTexName, mrtIndex);
			}
			case CompositionTechnique::TS_GLOBAL:
			{
				//Chain and global case - the referenced compositor will know how to handle
				const CompositorPtr& refComp = CompositorManager::getSingleton().getByName(texDef->refCompName);
				if(refComp.isNull())
				{
					OGRE_EXCEPT(Exception::ERR_ITEM_NOT_FOUND, "Referencing non-existent compositor",
						"CompositorInstance::getSourceForTex");
				}
				return refComp->getTextureInstanceName(texDef->refTexName, mrtIndex);
			}
			case CompositionTechnique::TS_LOCAL:
			default:
				OGRE_EXCEPT(Exception::ERR_INVALIDPARAMS, "Referencing local compositor texture",
					"CompositorInstance::getSourceForTex");
		}

	} // End of handling texture references

	if (texDef->formatList.size() == 1) 
	{
		//This is a simple texture
		LocalTextureMap::iterator i = mLocalTextures.find(name);
		if(i != mLocalTextures.end())
		{
			return i->second->getName();
		}
	}
	else
	{
		// try MRTs - texture (rather than target)
		LocalTextureMap::iterator i = mLocalTextures.find(getMRTTexLocalName(name, mrtIndex));
		if (i != mLocalTextures.end())
		{
			return i->second->getName();
		}
	}
	
	OGRE_EXCEPT(Exception::ERR_INVALIDPARAMS, "Non-existent local texture name", 
		"CompositorInstance::getSourceForTex");
}
//-----------------------------------------------------------------------
void CompositorInstance::queueRenderSystemOp(TargetOperation &finalState, RenderSystemOperation *op)
{
	/// Store operation for current QueueGroup ID
	finalState.renderSystemOperations.push_back(RenderSystemOpPair(finalState.currentQueueGroupID, op));
	/// Tell parent for deletion
	mChain->_queuedOperation(op);
}
//-----------------------------------------------------------------------
void CompositorInstance::addListener(Listener *l)
{
	mListeners.push_back(l);
}
//-----------------------------------------------------------------------
void CompositorInstance::removeListener(Listener *l)
{
	mListeners.erase(std::find(mListeners.begin(), mListeners.end(), l));
}
//-----------------------------------------------------------------------
void CompositorInstance::_fireNotifyMaterialSetup(uint32 pass_id, MaterialPtr &mat)
{
	Listeners::iterator i, iend=mListeners.end();
	for(i=mListeners.begin(); i!=iend; ++i)
		(*i)->notifyMaterialSetup(pass_id, mat);
}
//-----------------------------------------------------------------------
void CompositorInstance::_fireNotifyMaterialRender(uint32 pass_id, MaterialPtr &mat)
{
	Listeners::iterator i, iend=mListeners.end();
	for(i=mListeners.begin(); i!=iend; ++i)
		(*i)->notifyMaterialRender(pass_id, mat);
}
//-----------------------------------------------------------------------
void CompositorInstance::_fireNotifyResourcesCreated(bool forResizeOnly)
{
	Listeners::iterator i, iend=mListeners.end();
	for(i=mListeners.begin(); i!=iend; ++i)
		(*i)->notifyResourcesCreated(forResizeOnly);
}
//-----------------------------------------------------------------------
void CompositorInstance::notifyCameraChanged(Camera* camera)
{
	// update local texture's viewports.
	LocalTextureMap::iterator localTexIter = mLocalTextures.begin();
	LocalTextureMap::iterator localTexIterEnd = mLocalTextures.end();
	while (localTexIter != localTexIterEnd)
	{
		RenderTexture* target = localTexIter->second->getBuffer()->getRenderTarget();
		// skip target that has no viewport (this means texture is under MRT)
		if (target->getNumViewports() == 1)
		{
			target->getViewport(0)->setCamera(camera);
		}
		++localTexIter;
	}

	// update MRT's viewports.
	LocalMRTMap::iterator localMRTIter = mLocalMRTs.begin();
	LocalMRTMap::iterator localMRTIterEnd = mLocalMRTs.end();
	while (localMRTIter != localMRTIterEnd)
	{
		MultiRenderTarget* target = localMRTIter->second;
		target->getViewport(0)->setCamera(camera);
		++localMRTIter;
	}
}
//-----------------------------------------------------------------------
CompositorInstance::RenderSystemOperation::~RenderSystemOperation()
{
}
//-----------------------------------------------------------------------
CompositorInstance::Listener::~Listener()
{
}
void CompositorInstance::Listener::notifyMaterialSetup(uint32 pass_id, MaterialPtr &mat)
{
}
void CompositorInstance::Listener::notifyMaterialRender(uint32 pass_id, MaterialPtr &mat)
{
}
void CompositorInstance::Listener::notifyResourcesCreated(bool forResizeOnly)
{
}

}
