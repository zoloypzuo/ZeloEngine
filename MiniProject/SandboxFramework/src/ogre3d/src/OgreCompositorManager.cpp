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
#include "OgreCompositorManager.h"
#include "OgreCompositor.h"
#include "OgreCompositorChain.h"
#include "OgreCompositionPass.h"
#include "OgreCustomCompositionPass.h"
#include "OgreCompositionTargetPass.h"
#include "OgreCompositionTechnique.h"
#include "OgreRoot.h"
#include "OgreScriptCompiler.h"

namespace Ogre {

template<> CompositorManager* Singleton<CompositorManager>::msSingleton = 0;
CompositorManager* CompositorManager::getSingletonPtr(void)
{
	return msSingleton;
}
CompositorManager& CompositorManager::getSingleton(void)
{  
	assert( msSingleton );  return ( *msSingleton );  
}//-----------------------------------------------------------------------
CompositorManager::CompositorManager():
	mRectangle(0)
{
	initialise();

	// Loading order (just after materials)
	mLoadOrder = 110.0f;

	// Resource type
	mResourceType = "Compositor";

	// Register with resource group manager
	ResourceGroupManager::getSingleton()._registerResourceManager(mResourceType, this);

}
//-----------------------------------------------------------------------
CompositorManager::~CompositorManager()
{
    freeChains();
	freePooledTextures(false);
	OGRE_DELETE mRectangle;

	// Resources cleared by superclass
	// Unregister with resource group manager
	ResourceGroupManager::getSingleton()._unregisterResourceManager(mResourceType);
	ResourceGroupManager::getSingleton()._unregisterScriptLoader(this);
}
//-----------------------------------------------------------------------
Resource* CompositorManager::createImpl(const String& name, ResourceHandle handle,
    const String& group, bool isManual, ManualResourceLoader* loader,
    const NameValuePairList* params)
{
    return OGRE_NEW Compositor(this, name, handle, group, isManual, loader);
}
//-----------------------------------------------------------------------
CompositorPtr CompositorManager::create (const String& name, const String& group,
								bool isManual, ManualResourceLoader* loader,
								const NameValuePairList* createParams)
{
	return createResource(name,group,isManual,loader,createParams).staticCast<Compositor>();
}
//-----------------------------------------------------------------------
CompositorPtr CompositorManager::getByName(const String& name, const String& groupName)
{
	return getResourceByName(name, groupName).staticCast<Compositor>();
}
//-----------------------------------------------------------------------
void CompositorManager::initialise(void)
{
}
//-----------------------------------------------------------------------
void CompositorManager::parseScript(DataStreamPtr& stream, const String& groupName)
{
	ScriptCompilerManager::getSingleton().parseScript(stream, groupName);
}
//-----------------------------------------------------------------------
CompositorChain *CompositorManager::getCompositorChain(Viewport *vp)
{
    Chains::iterator i=mChains.find(vp);
    if(i != mChains.end())
    {
        return i->second;
    }
    else
    {
        CompositorChain *chain = OGRE_NEW CompositorChain(vp);
        mChains[vp] = chain;
        return chain;
    }
}
//-----------------------------------------------------------------------
bool CompositorManager::hasCompositorChain(Viewport *vp) const
{
    return mChains.find(vp) != mChains.end();
}
//-----------------------------------------------------------------------
void CompositorManager::removeCompositorChain(Viewport *vp)
{
    Chains::iterator i = mChains.find(vp);
    if (i != mChains.end())
    {
        OGRE_DELETE  i->second;
        mChains.erase(i);
    }
}
//-----------------------------------------------------------------------
void CompositorManager::removeAll(void)
{
	freeChains();
	ResourceManager::removeAll();
}
//-----------------------------------------------------------------------
void CompositorManager::freeChains()
{
    Chains::iterator i, iend=mChains.end();
    for(i=mChains.begin(); i!=iend;++i)
    {
        OGRE_DELETE  i->second;
    }
    mChains.clear();
}
//-----------------------------------------------------------------------
Renderable *CompositorManager::_getTexturedRectangle2D()
{
	if(!mRectangle)
	{
		/// 2D rectangle, to use for render_quad passes
		mRectangle = OGRE_NEW Rectangle2D(true, HardwareBuffer::HBU_DYNAMIC_WRITE_ONLY_DISCARDABLE);
	}
	RenderSystem* rs = Root::getSingleton().getRenderSystem();
	Viewport* vp = rs->_getViewport();
	Real hOffset = rs->getHorizontalTexelOffset() / (0.5f * vp->getActualWidth());
	Real vOffset = rs->getVerticalTexelOffset() / (0.5f * vp->getActualHeight());
	mRectangle->setCorners(-1 + hOffset, 1 - vOffset, 1 + hOffset, -1 - vOffset);
	return mRectangle;
}
//-----------------------------------------------------------------------
CompositorInstance *CompositorManager::addCompositor(Viewport *vp, const String &compositor, int addPosition)
{
	CompositorPtr comp = getByName(compositor);
	if(comp.isNull())
		return 0;
	CompositorChain *chain = getCompositorChain(vp);
	return chain->addCompositor(comp, addPosition==-1 ? CompositorChain::LAST : (size_t)addPosition);
}
//-----------------------------------------------------------------------
void CompositorManager::removeCompositor(Viewport *vp, const String &compositor)
{
	CompositorChain *chain = getCompositorChain(vp);
	for(size_t pos=0; pos < chain->getNumCompositors(); ++pos)
	{
		CompositorInstance *instance = chain->getCompositor(pos);
		if(instance->getCompositor()->getName() == compositor)
		{
			chain->removeCompositor(pos);
			break;
		}
	}
}
//-----------------------------------------------------------------------
void CompositorManager::setCompositorEnabled(Viewport *vp, const String &compositor, bool value)
{
	CompositorChain *chain = getCompositorChain(vp);
	for(size_t pos=0; pos < chain->getNumCompositors(); ++pos)
	{
		CompositorInstance *instance = chain->getCompositor(pos);
		if(instance->getCompositor()->getName() == compositor)
		{
			chain->setCompositorEnabled(pos, value);
			break;
		}
	}
}
//---------------------------------------------------------------------
void CompositorManager::_reconstructAllCompositorResources()
{
	// In order to deal with shared resources, we have to disable *all* compositors
	// first, that way shared resources will get freed
	typedef vector<CompositorInstance*>::type InstVec;
	InstVec instancesToReenable;
	for (Chains::iterator i = mChains.begin(); i != mChains.end(); ++i)
	{
		CompositorChain* chain = i->second;
		CompositorChain::InstanceIterator instIt = chain->getCompositors();
		while (instIt.hasMoreElements())
		{
			CompositorInstance* inst = instIt.getNext();
			if (inst->getEnabled())
			{
				inst->setEnabled(false);
				instancesToReenable.push_back(inst);
			}
		}
	}

	//UVs are lost, and will never be reconstructed unless we do them again, now
	if( mRectangle )
		mRectangle->setDefaultUVs();

	for (InstVec::iterator i = instancesToReenable.begin(); i != instancesToReenable.end(); ++i)
	{
		CompositorInstance* inst = *i;
		inst->setEnabled(true);
	}
}
//---------------------------------------------------------------------
TexturePtr CompositorManager::getPooledTexture(const String& name, 
	const String& localName,
	size_t w, size_t h, PixelFormat f, uint aa, const String& aaHint, bool srgb, 
	CompositorManager::UniqueTextureSet& texturesAssigned, 
	CompositorInstance* inst, CompositionTechnique::TextureScope scope)
{
	if (scope == CompositionTechnique::TS_GLOBAL) 
	{
		OGRE_EXCEPT(Exception::ERR_INVALIDPARAMS,
			"Global scope texture can not be pooled.",
			"CompositorManager::getPooledTexture");
	}

	TextureDef def(w, h, f, aa, aaHint, srgb);

	if (scope == CompositionTechnique::TS_CHAIN)
	{
		StringPair pair = std::make_pair(inst->getCompositor()->getName(), localName);
		TextureDefMap& defMap = mChainTexturesByDef[pair];
		TextureDefMap::iterator it = defMap.find(def);
		if (it != defMap.end())
		{
			return it->second;
		}
		// ok, we need to create a new one
		TexturePtr newTex = TextureManager::getSingleton().createManual(
			name, 
			ResourceGroupManager::INTERNAL_RESOURCE_GROUP_NAME, TEX_TYPE_2D, 
			(uint)w, (uint)h, 0, f, TU_RENDERTARGET, 0,
			srgb, aa, aaHint);
		defMap.insert(TextureDefMap::value_type(def, newTex));
		return newTex;
	}

	TexturesByDef::iterator i = mTexturesByDef.find(def);
	if (i == mTexturesByDef.end())
	{
		TextureList* texList = OGRE_NEW_T(TextureList, MEMCATEGORY_GENERAL);
		i = mTexturesByDef.insert(TexturesByDef::value_type(def, texList)).first;
	}
	CompositorInstance* previous = inst->getChain()->getPreviousInstance(inst);
	CompositorInstance* next = inst->getChain()->getNextInstance(inst);

	TexturePtr ret;
	TextureList* texList = i->second;
	// iterate over the existing textures and check if we can re-use
	for (TextureList::iterator t = texList->begin(); t != texList->end(); ++t)
	{
		TexturePtr& tex = *t;
		// check not already used
		if (texturesAssigned.find(tex.get()) == texturesAssigned.end())
		{
			bool allowReuse = true;
			// ok, we didn't use this one already
			// however, there is an edge case where if we re-use a texture
			// which has an 'input previous' pass, and it is chained from another
			// compositor, we can end up trying to use the same texture for both
			// so, never allow a texture with an input previous pass to be 
			// shared with its immediate predecessor in the chain
			if (isInputPreviousTarget(inst, localName))
			{
				// Check whether this is also an input to the output target of previous
				// can't use CompositorInstance::mPreviousInstance, only set up
				// during compile
				if (previous && isInputToOutputTarget(previous, tex))
					allowReuse = false;
			}
			// now check the other way around since we don't know what order they're bound in
			if (isInputToOutputTarget(inst, localName))
			{
				
				if (next && isInputPreviousTarget(next, tex))
					allowReuse = false;
			}
			
			if (allowReuse)
			{
				ret = tex;
				break;
			}

		}
	}

	if (ret.isNull())
	{
		// ok, we need to create a new one
		ret = TextureManager::getSingleton().createManual(
			name, 
			ResourceGroupManager::INTERNAL_RESOURCE_GROUP_NAME, TEX_TYPE_2D, 
			(uint)w, (uint)h, 0, f, TU_RENDERTARGET, 0,
			srgb, aa, aaHint); 

		texList->push_back(ret);

	}

	// record that we used this one in the requester's list
	texturesAssigned.insert(ret.get());


	return ret;
}
//---------------------------------------------------------------------
bool CompositorManager::isInputPreviousTarget(CompositorInstance* inst, const Ogre::String& localName)
{
	CompositionTechnique::TargetPassIterator tpit = inst->getTechnique()->getTargetPassIterator();
	while(tpit.hasMoreElements())
	{
		CompositionTargetPass* tp = tpit.getNext();
		if (tp->getInputMode() == CompositionTargetPass::IM_PREVIOUS &&
			tp->getOutputName() == localName)
		{
			return true;
		}

	}

	return false;

}
//---------------------------------------------------------------------
bool CompositorManager::isInputPreviousTarget(CompositorInstance* inst, TexturePtr tex)
{
	CompositionTechnique::TargetPassIterator tpit = inst->getTechnique()->getTargetPassIterator();
	while(tpit.hasMoreElements())
	{
		CompositionTargetPass* tp = tpit.getNext();
		if (tp->getInputMode() == CompositionTargetPass::IM_PREVIOUS)
		{
			// Don't have to worry about an MRT, because no MRT can be input previous
			TexturePtr t = inst->getTextureInstance(tp->getOutputName(), 0);
			if (!t.isNull() && t.get() == tex.get())
				return true;
		}

	}

	return false;

}
//---------------------------------------------------------------------
bool CompositorManager::isInputToOutputTarget(CompositorInstance* inst, const Ogre::String& localName)
{
	CompositionTargetPass* tp = inst->getTechnique()->getOutputTargetPass();
	CompositionTargetPass::PassIterator pit = tp->getPassIterator();

	while(pit.hasMoreElements())
	{
		CompositionPass* p = pit.getNext();
		for (size_t i = 0; i < p->getNumInputs(); ++i)
		{
			if (p->getInput(i).name == localName)
				return true;
		}
	}

	return false;

}
//---------------------------------------------------------------------()
bool CompositorManager::isInputToOutputTarget(CompositorInstance* inst, TexturePtr tex)
{
	CompositionTargetPass* tp = inst->getTechnique()->getOutputTargetPass();
	CompositionTargetPass::PassIterator pit = tp->getPassIterator();

	while(pit.hasMoreElements())
	{
		CompositionPass* p = pit.getNext();
		for (size_t i = 0; i < p->getNumInputs(); ++i)
		{
			TexturePtr t = inst->getTextureInstance(p->getInput(i).name, 0);
			if (!t.isNull() && t.get() == tex.get())
				return true;
		}
	}

	return false;

}
//---------------------------------------------------------------------
void CompositorManager::freePooledTextures(bool onlyIfUnreferenced)
{
	if (onlyIfUnreferenced)
	{
		for (TexturesByDef::iterator i = mTexturesByDef.begin(); i != mTexturesByDef.end(); ++i)
		{
			TextureList* texList = i->second;
			for (TextureList::iterator j = texList->begin(); j != texList->end();)
			{
				// if the resource system, plus this class, are the only ones to have a reference..
				// NOTE: any material references will stop this texture getting freed (e.g. compositor demo)
				// until this routine is called again after the material no longer references the texture
				if (j->useCount() == ResourceGroupManager::RESOURCE_SYSTEM_NUM_REFERENCE_COUNTS + 1)
				{
					TextureManager::getSingleton().remove((*j)->getHandle());
					j = texList->erase(j);
				}
				else
					++j;
			}
		}
		for (ChainTexturesByDef::iterator i = mChainTexturesByDef.begin(); i != mChainTexturesByDef.end(); ++i)
		{
			TextureDefMap& texMap = i->second;
			for (TextureDefMap::iterator j = texMap.begin(); j != texMap.end();) 
			{
				const TexturePtr& tex = j->second;
				if (tex.useCount() == ResourceGroupManager::RESOURCE_SYSTEM_NUM_REFERENCE_COUNTS + 1)
				{
					TextureManager::getSingleton().remove(tex->getHandle());
					texMap.erase(j++);
				}
				else
					++j;
			}
		}
	}
	else
	{
		// destroy all
		for (TexturesByDef::iterator i = mTexturesByDef.begin(); i != mTexturesByDef.end(); ++i)
		{
			OGRE_DELETE_T(i->second, TextureList, MEMCATEGORY_GENERAL);
		}
		mTexturesByDef.clear();
		mChainTexturesByDef.clear();
	}

}
//---------------------------------------------------------------------
void CompositorManager::registerCompositorLogic(const String& name, CompositorLogic* logic)
{	
	if (name.empty()) 
	{
		OGRE_EXCEPT(Exception::ERR_INVALIDPARAMS,
			"Compositor logic name must not be empty.",
			"CompositorManager::registerCompositorLogic");
	}
	if (mCompositorLogics.find(name) != mCompositorLogics.end())
	{
		OGRE_EXCEPT(Exception::ERR_DUPLICATE_ITEM,
			"Compositor logic '" + name + "' already exists.",
			"CompositorManager::registerCompositorLogic");
	}
	mCompositorLogics[name] = logic;
}
//---------------------------------------------------------------------
void CompositorManager::unregisterCompositorLogic(const String& name)
{
	CompositorLogicMap::iterator itor = mCompositorLogics.find(name);
	if( itor == mCompositorLogics.end() )
	{
		OGRE_EXCEPT(Exception::ERR_ITEM_NOT_FOUND,
			"Compositor logic '" + name + "' not registered.",
			"CompositorManager::unregisterCompositorLogic");
	}

	mCompositorLogics.erase( itor );
}
//---------------------------------------------------------------------
CompositorLogic* CompositorManager::getCompositorLogic(const String& name)
{
	CompositorLogicMap::iterator it = mCompositorLogics.find(name);
	if (it == mCompositorLogics.end())
	{
		OGRE_EXCEPT(Exception::ERR_ITEM_NOT_FOUND,
			"Compositor logic '" + name + "' not registered.",
			"CompositorManager::getCompositorLogic");
	}
	return it->second;
}
//---------------------------------------------------------------------
void CompositorManager::registerCustomCompositionPass(const String& name, CustomCompositionPass* logic)
{	
	if (name.empty()) 
	{
		OGRE_EXCEPT(Exception::ERR_INVALIDPARAMS,
			"Custom composition pass name must not be empty.",
			"CompositorManager::registerCustomCompositionPass");
	}
	if (mCustomCompositionPasses.find(name) != mCustomCompositionPasses.end())
	{
		OGRE_EXCEPT(Exception::ERR_DUPLICATE_ITEM,
			"Custom composition pass  '" + name + "' already exists.",
			"CompositorManager::registerCustomCompositionPass");
	}
	mCustomCompositionPasses[name] = logic;
}
//---------------------------------------------------------------------
CustomCompositionPass* CompositorManager::getCustomCompositionPass(const String& name)
{
	CustomCompositionPassMap::iterator it = mCustomCompositionPasses.find(name);
	if (it == mCustomCompositionPasses.end())
	{
		OGRE_EXCEPT(Exception::ERR_ITEM_NOT_FOUND,
			"Custom composition pass '" + name + "' not registered.",
			"CompositorManager::getCustomCompositionPass");
	}
	return it->second;
}
//-----------------------------------------------------------------------
}
