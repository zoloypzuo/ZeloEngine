/*
-----------------------------------------------------------------------------
This source file is part of OGRE
    (Object-oriented Graphics Rendering Engine)
For the latest info, see http://www.ogre3d.org

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

#include "OgrePass.h"
#include "OgreRoot.h"
#include "OgreTechnique.h"
#include "OgreException.h"
#include "OgreGpuProgramUsage.h"
#include "OgreTextureUnitState.h"
#include "OgreStringConverter.h"

namespace Ogre {

	/** Default pass hash function.
	@remarks
		Tries to minimise the number of texture changes.
	*/
	struct MinTextureStateChangeHashFunc : public Pass::HashFunc
	{
		uint32 operator()(const Pass* p) const
		{
                    OGRE_LOCK_MUTEX(p->mTexUnitChangeMutex);

			_StringHash H;
			uint32 hash = p->getIndex() << 28;
			size_t c = p->getNumTextureUnitStates();

			const TextureUnitState* t0 = 0;
			const TextureUnitState* t1 = 0;
			if (c)
				t0 = p->getTextureUnitState(0);
			if (c > 1)
				t1 = p->getTextureUnitState(1);

			if (t0 && !t0->getTextureName().empty())
				hash += (static_cast<uint32>(H(t0->getTextureName())) 
					% (1 << 14)) << 14;
			if (t1 && !t1->getTextureName().empty())
				hash += (static_cast<uint32>(H(t1->getTextureName()))
					% (1 << 14));

			return hash;
		}
	};
	MinTextureStateChangeHashFunc sMinTextureStateChangeHashFunc;
	/** Alternate pass hash function.
	@remarks
		Tries to minimise the number of GPU program changes.
	*/
	struct MinGpuProgramChangeHashFunc : public Pass::HashFunc
	{
		uint32 operator()(const Pass* p) const
		{
			OGRE_LOCK_MUTEX(p->mGpuProgramChangeMutex);

			_StringHash H;
			uint32 hash = p->getIndex() << 28;
			if (p->hasVertexProgram())
				hash += (static_cast<uint32>(H(p->getVertexProgramName()))
					% (1 << 14)) << 14;
			if (p->hasFragmentProgram())
				hash += (static_cast<uint32>(H(p->getFragmentProgramName()))
					% (1 << 14));
			if (p->hasGeometryProgram())
				hash += (static_cast<uint32>(H(p->getGeometryProgramName()))
						 % (1 << 14));
			if (p->hasTessellationDomainProgram())
				hash += (static_cast<uint32>(H(p->getTessellationDomainProgramName()))
						 % (1 << 14));
			if (p->hasTessellationHullProgram())
				hash += (static_cast<uint32>(H(p->getTessellationHullProgramName()))
						 % (1 << 14));
			if (p->hasComputeProgram())
				hash += (static_cast<uint32>(H(p->getComputeProgramName()))
						 % (1 << 14));

			return hash;
		}
	};
	MinGpuProgramChangeHashFunc sMinGpuProgramChangeHashFunc;
    //-----------------------------------------------------------------------------
	Pass::PassSet Pass::msDirtyHashList;
    Pass::PassSet Pass::msPassGraveyard;
    OGRE_STATIC_MUTEX_INSTANCE(Pass::msDirtyHashListMutex);
    OGRE_STATIC_MUTEX_INSTANCE(Pass::msPassGraveyardMutex);

	Pass::HashFunc* Pass::msHashFunc = &sMinTextureStateChangeHashFunc;
	//-----------------------------------------------------------------------------
	Pass::HashFunc* Pass::getBuiltinHashFunction(BuiltinHashFunction builtin)
	{
		Pass::HashFunc* hashFunc = NULL;

		switch(builtin)
		{
		case MIN_TEXTURE_CHANGE:
			hashFunc = &sMinTextureStateChangeHashFunc;
			break;
		case MIN_GPU_PROGRAM_CHANGE:
			hashFunc = &sMinGpuProgramChangeHashFunc;
			break;
		}

		return hashFunc;
	}
	//-----------------------------------------------------------------------------
	void Pass::setHashFunction(BuiltinHashFunction builtin)
	{
		switch(builtin)
		{
		case MIN_TEXTURE_CHANGE:
			msHashFunc = &sMinTextureStateChangeHashFunc;
			break;
		case MIN_GPU_PROGRAM_CHANGE:
			msHashFunc = &sMinGpuProgramChangeHashFunc;
			break;
		}
	}
    //-----------------------------------------------------------------------------
	Pass::Pass(Technique* parent, unsigned short index)
        : mParent(parent)
		, mIndex(index)
		, mHash(0)
		, mHashDirtyQueued(false)
		, mAmbient(ColourValue::White)
		, mDiffuse(ColourValue::White)
		, mSpecular(ColourValue::Black)
		, mEmissive(ColourValue::Black)
		, mShininess(0)
		, mTracking(TVC_NONE)
		, mSourceBlendFactor(SBF_ONE)
		, mDestBlendFactor(SBF_ZERO)
		, mSourceBlendFactorAlpha(SBF_ONE)
		, mDestBlendFactorAlpha(SBF_ZERO)
		, mSeparateBlend(false)
		, mBlendOperation(SBO_ADD)
		, mAlphaBlendOperation(SBO_ADD)
		, mSeparateBlendOperation(false)
		, mDepthCheck(true)
		, mDepthWrite(true)
		, mDepthFunc(CMPF_LESS_EQUAL)
		, mDepthBiasConstant(0.0f)
		, mDepthBiasSlopeScale(0.0f)
		, mDepthBiasPerIteration(0.0f)
		, mColourWrite(true)
		, mAlphaRejectFunc(CMPF_ALWAYS_PASS)
		, mAlphaRejectVal(0)
		, mAlphaToCoverageEnabled(false)
		, mTransparentSorting(true)
		, mTransparentSortingForced(false)
		, mCullMode(CULL_CLOCKWISE)
		, mManualCullMode(MANUAL_CULL_BACK)
		, mLightingEnabled(true)
		, mMaxSimultaneousLights(OGRE_MAX_SIMULTANEOUS_LIGHTS)
		, mStartLight(0)
		, mIteratePerLight(false)
		, mLightsPerIteration(1)
		, mRunOnlyForOneLightType(false)
		, mOnlyLightType(Light::LT_POINT)
		, mLightMask(0xFFFFFFFF)
		, mShadeOptions(SO_GOURAUD)
		, mPolygonMode(PM_SOLID)
		, mNormaliseNormals(false)
		, mPolygonModeOverrideable(true)
		, mFogOverride(false)
		, mFogMode(FOG_NONE)
		, mFogColour(ColourValue::White)
		, mFogStart(0.0)
		, mFogEnd(1.0)
		, mFogDensity(0.001)
		, mVertexProgramUsage(0)
		, mShadowCasterVertexProgramUsage(0)
        , mShadowCasterFragmentProgramUsage(0)
		, mShadowReceiverVertexProgramUsage(0)
		, mFragmentProgramUsage(0)
		, mShadowReceiverFragmentProgramUsage(0)
        , mGeometryProgramUsage(0)
		, mTessellationHullProgramUsage(0)
		, mTessellationDomainProgramUsage(0)
		, mComputeProgramUsage(0)
		, mQueuedForDeletion(false)
		, mPassIterationCount(1)
		, mPointSize(1.0f)
		, mPointMinSize(0.0f)
		, mPointMaxSize(0.0f)
		, mPointSpritesEnabled(false)
		, mPointAttenuationEnabled(false)
		, mContentTypeLookupBuilt(false)
		, mLightScissoring(false)
		, mLightClipPlanes(false)
		, mIlluminationStage(IS_UNKNOWN)
    {
		mPointAttenuationCoeffs[0] = 1.0f;
		mPointAttenuationCoeffs[1] = mPointAttenuationCoeffs[2] = 0.0f;

        // default name to index
        mName = StringConverter::toString(mIndex);

		// init the hash inline
		_recalculateHash();
   }

    //-----------------------------------------------------------------------------
	Pass::Pass(Technique *parent, unsigned short index, const Pass& oth)
        :mParent(parent), mIndex(index), mVertexProgramUsage(0), mShadowCasterVertexProgramUsage(0), 
		mShadowCasterFragmentProgramUsage(0), mShadowReceiverVertexProgramUsage(0), mFragmentProgramUsage(0), 
		mShadowReceiverFragmentProgramUsage(0), mGeometryProgramUsage(0), mTessellationHullProgramUsage(0)
		, mTessellationDomainProgramUsage(0), mComputeProgramUsage(0), mQueuedForDeletion(false), mPassIterationCount(1)
    {
        *this = oth;
        mParent = parent;
        mIndex = index;
        mQueuedForDeletion = false;

		// init the hash inline
		_recalculateHash();
    }
    //-----------------------------------------------------------------------------
    Pass::~Pass()
    {
		OGRE_DELETE mVertexProgramUsage;
		OGRE_DELETE mFragmentProgramUsage;
		OGRE_DELETE mTessellationHullProgramUsage;
		OGRE_DELETE mTessellationDomainProgramUsage;
		OGRE_DELETE mGeometryProgramUsage;
		OGRE_DELETE mComputeProgramUsage;
		OGRE_DELETE mShadowCasterVertexProgramUsage;
        OGRE_DELETE mShadowCasterFragmentProgramUsage;
		OGRE_DELETE mShadowReceiverVertexProgramUsage;
		OGRE_DELETE mShadowReceiverFragmentProgramUsage;		
    }
    //-----------------------------------------------------------------------------
    Pass& Pass::operator=(const Pass& oth)
    {
        mName = oth.mName;
        mHash = oth.mHash;
	    mAmbient = oth.mAmbient;
        mDiffuse = oth.mDiffuse;
	    mSpecular = oth.mSpecular;
        mEmissive = oth.mEmissive;
	    mShininess = oth.mShininess;
        mTracking = oth.mTracking;

        // Copy fog parameters
        mFogOverride = oth.mFogOverride;
        mFogMode = oth.mFogMode;
        mFogColour = oth.mFogColour;
        mFogStart = oth.mFogStart;
        mFogEnd = oth.mFogEnd;
        mFogDensity = oth.mFogDensity;

	    // Default blending (overwrite)
	    mSourceBlendFactor = oth.mSourceBlendFactor;
	    mDestBlendFactor = oth.mDestBlendFactor;
		mSourceBlendFactorAlpha = oth.mSourceBlendFactorAlpha;
		mDestBlendFactorAlpha = oth.mDestBlendFactorAlpha;
		mSeparateBlend = oth.mSeparateBlend;

		mBlendOperation = oth.mBlendOperation;
		mAlphaBlendOperation = oth.mAlphaBlendOperation;
		mSeparateBlendOperation = oth.mSeparateBlendOperation;

	    mDepthCheck = oth.mDepthCheck;
	    mDepthWrite = oth.mDepthWrite;
		mAlphaRejectFunc = oth.mAlphaRejectFunc;
		mAlphaRejectVal = oth.mAlphaRejectVal;
		mAlphaToCoverageEnabled = oth.mAlphaToCoverageEnabled;
		mTransparentSorting = oth.mTransparentSorting;
		mTransparentSortingForced = oth.mTransparentSortingForced;
        mColourWrite = oth.mColourWrite;
	    mDepthFunc = oth.mDepthFunc;
        mDepthBiasConstant = oth.mDepthBiasConstant;
		mDepthBiasSlopeScale = oth.mDepthBiasSlopeScale;
		mDepthBiasPerIteration = oth.mDepthBiasPerIteration;
	    mCullMode = oth.mCullMode;
	    mManualCullMode = oth.mManualCullMode;
	    mLightingEnabled = oth.mLightingEnabled;
        mMaxSimultaneousLights = oth.mMaxSimultaneousLights;
		mStartLight = oth.mStartLight;
		mIteratePerLight = oth.mIteratePerLight;
		mLightsPerIteration = oth.mLightsPerIteration;
        mRunOnlyForOneLightType = oth.mRunOnlyForOneLightType;
		mNormaliseNormals = oth.mNormaliseNormals;
        mOnlyLightType = oth.mOnlyLightType;
	    mShadeOptions = oth.mShadeOptions;
		mPolygonMode = oth.mPolygonMode;
		mPolygonModeOverrideable = oth.mPolygonModeOverrideable;
        mPassIterationCount = oth.mPassIterationCount;
		mPointSize = oth.mPointSize;
		mPointMinSize = oth.mPointMinSize;
		mPointMaxSize = oth.mPointMaxSize;
		mPointSpritesEnabled = oth.mPointSpritesEnabled;
		mPointAttenuationEnabled = oth.mPointAttenuationEnabled;
		memcpy(mPointAttenuationCoeffs, oth.mPointAttenuationCoeffs, sizeof(Real)*3);
		mShadowContentTypeLookup = oth.mShadowContentTypeLookup;
		mContentTypeLookupBuilt = oth.mContentTypeLookupBuilt;
		mLightScissoring = oth.mLightScissoring;
		mLightClipPlanes = oth.mLightClipPlanes;
		mIlluminationStage = oth.mIlluminationStage;
		mLightMask = oth.mLightMask;

		OGRE_DELETE mVertexProgramUsage;
		if (oth.mVertexProgramUsage)
		{
			mVertexProgramUsage = OGRE_NEW GpuProgramUsage(*(oth.mVertexProgramUsage), this);
		}
		else
		{
		    mVertexProgramUsage = NULL;
		}

		OGRE_DELETE mShadowCasterVertexProgramUsage;
        if (oth.mShadowCasterVertexProgramUsage)
        {
            mShadowCasterVertexProgramUsage = OGRE_NEW GpuProgramUsage(*(oth.mShadowCasterVertexProgramUsage), this);
        }
        else
        {
            mShadowCasterVertexProgramUsage = NULL;
        }

		OGRE_DELETE mShadowCasterFragmentProgramUsage;
        if (oth.mShadowCasterFragmentProgramUsage)
        {
            mShadowCasterFragmentProgramUsage = OGRE_NEW GpuProgramUsage(*(oth.mShadowCasterFragmentProgramUsage), this);
        }
        else
        {
            mShadowCasterFragmentProgramUsage = NULL;
        }

		OGRE_DELETE mShadowReceiverVertexProgramUsage;
        if (oth.mShadowReceiverVertexProgramUsage)
        {
            mShadowReceiverVertexProgramUsage = OGRE_NEW GpuProgramUsage(*(oth.mShadowReceiverVertexProgramUsage), this);
        }
        else
        {
            mShadowReceiverVertexProgramUsage = NULL;
        }

		OGRE_DELETE mFragmentProgramUsage;
		if (oth.mFragmentProgramUsage)
		{
		    mFragmentProgramUsage = OGRE_NEW GpuProgramUsage(*(oth.mFragmentProgramUsage), this);
        }
        else
        {
		    mFragmentProgramUsage = NULL;
        }

		OGRE_DELETE mGeometryProgramUsage;
		if (oth.mGeometryProgramUsage)
		{
		    mGeometryProgramUsage = OGRE_NEW GpuProgramUsage(*(oth.mGeometryProgramUsage), this);
        }
        else
        {
		    mGeometryProgramUsage = NULL;
        }

		OGRE_DELETE mTessellationHullProgramUsage;
		if (oth.mTessellationHullProgramUsage)
		{
		    mTessellationHullProgramUsage = OGRE_NEW GpuProgramUsage(*(oth.mTessellationHullProgramUsage), this);
        }
        else
        {
		    mTessellationHullProgramUsage = NULL;
        }

		OGRE_DELETE mTessellationDomainProgramUsage;
		if (oth.mTessellationDomainProgramUsage)
		{
		    mTessellationDomainProgramUsage = OGRE_NEW GpuProgramUsage(*(oth.mTessellationDomainProgramUsage), this);
        }
        else
        {
		    mTessellationDomainProgramUsage = NULL;
        }

		OGRE_DELETE mComputeProgramUsage;
		if (oth.mComputeProgramUsage)
		{
		    mComputeProgramUsage = OGRE_NEW GpuProgramUsage(*(oth.mComputeProgramUsage), this);
        }
        else
        {
		    mComputeProgramUsage = NULL;
        }

		OGRE_DELETE mShadowReceiverFragmentProgramUsage;
		if (oth.mShadowReceiverFragmentProgramUsage)
		{
			mShadowReceiverFragmentProgramUsage = OGRE_NEW GpuProgramUsage(*(oth.mShadowReceiverFragmentProgramUsage), this);
		}
		else
		{
			mShadowReceiverFragmentProgramUsage = NULL;
		}

		TextureUnitStates::const_iterator i, iend;

        // Clear texture units but doesn't notify need recompilation in the case
        // we are cloning, The parent material will take care of this.
        iend = mTextureUnitStates.end();
        for (i = mTextureUnitStates.begin(); i != iend; ++i)
        {
            OGRE_DELETE *i;
        }

        mTextureUnitStates.clear();

		// Copy texture units
		iend = oth.mTextureUnitStates.end();
		for (i = oth.mTextureUnitStates.begin(); i != iend; ++i)
		{
			TextureUnitState* t = OGRE_NEW TextureUnitState(this, *(*i));
			mTextureUnitStates.push_back(t);
		}

        _dirtyHash();

		return *this;
    }
    //-----------------------------------------------------------------------------
    size_t Pass::calculateSize(void) const
    {
        size_t memSize = 0;

        // Tally up TU states
        TextureUnitStates::const_iterator i, iend;
        iend = mTextureUnitStates.end();
        for (i = mTextureUnitStates.begin(); i != iend; ++i)
        {
            memSize += (*i)->calculateSize();
        }
        if(mVertexProgramUsage)
            memSize += mVertexProgramUsage->calculateSize();
        if(mShadowCasterVertexProgramUsage)
            memSize += mShadowCasterVertexProgramUsage->calculateSize();
        if(mShadowCasterFragmentProgramUsage)
            memSize += mShadowCasterFragmentProgramUsage->calculateSize();
        if(mShadowReceiverVertexProgramUsage)
            memSize += mShadowReceiverVertexProgramUsage->calculateSize();
        if(mFragmentProgramUsage)
            memSize += mFragmentProgramUsage->calculateSize();
        if(mShadowReceiverFragmentProgramUsage)
            memSize += mShadowReceiverFragmentProgramUsage->calculateSize();
        if(mGeometryProgramUsage)
            memSize += mGeometryProgramUsage->calculateSize();
        if(mTessellationHullProgramUsage)
            memSize += mTessellationHullProgramUsage->calculateSize();
        if(mTessellationDomainProgramUsage)
            memSize += mTessellationDomainProgramUsage->calculateSize();
        if(mComputeProgramUsage)
            memSize += mComputeProgramUsage->calculateSize();
        return memSize;
    }
    //-----------------------------------------------------------------------
    void Pass::setName(const String& name)
    {
        mName = name;
    }
    //-----------------------------------------------------------------------
    void Pass::setPointSize(Real ps)
    {
	    mPointSize = ps;
    }
    //-----------------------------------------------------------------------
	void Pass::setPointSpritesEnabled(bool enabled)
	{
		mPointSpritesEnabled = enabled;
	}
    //-----------------------------------------------------------------------
	bool Pass::getPointSpritesEnabled(void) const
	{
		return mPointSpritesEnabled;
	}
    //-----------------------------------------------------------------------
	void Pass::setPointAttenuation(bool enabled,
		Real constant, Real linear, Real quadratic)
	{
		mPointAttenuationEnabled = enabled;
		mPointAttenuationCoeffs[0] = constant;
		mPointAttenuationCoeffs[1] = linear;
		mPointAttenuationCoeffs[2] = quadratic;
	}
    //-----------------------------------------------------------------------
	bool Pass::isPointAttenuationEnabled(void) const
	{
		return mPointAttenuationEnabled;
	}
    //-----------------------------------------------------------------------
	Real Pass::getPointAttenuationConstant(void) const
	{
		return mPointAttenuationCoeffs[0];
	}
    //-----------------------------------------------------------------------
	Real Pass::getPointAttenuationLinear(void) const
	{
		return mPointAttenuationCoeffs[1];
	}
    //-----------------------------------------------------------------------
	Real Pass::getPointAttenuationQuadratic(void) const
	{
		return mPointAttenuationCoeffs[2];
	}
    //-----------------------------------------------------------------------
	void Pass::setPointMinSize(Real min)
	{
		mPointMinSize = min;
	}
    //-----------------------------------------------------------------------
	Real Pass::getPointMinSize(void) const
	{
		return mPointMinSize;
	}
    //-----------------------------------------------------------------------
	void Pass::setPointMaxSize(Real max)
	{
		mPointMaxSize = max;
	}
    //-----------------------------------------------------------------------
	Real Pass::getPointMaxSize(void) const
	{
		return mPointMaxSize;
	}
    //-----------------------------------------------------------------------
    void Pass::setAmbient(Real red, Real green, Real blue)
    {
	    mAmbient.r = red;
	    mAmbient.g = green;
	    mAmbient.b = blue;

    }
    //-----------------------------------------------------------------------
    void Pass::setAmbient(const ColourValue& ambient)
    {
	    mAmbient = ambient;
    }
    //-----------------------------------------------------------------------
    void Pass::setDiffuse(Real red, Real green, Real blue, Real alpha)
    {
	    mDiffuse.r = red;
	    mDiffuse.g = green;
	    mDiffuse.b = blue;
		mDiffuse.a = alpha;
    }
    //-----------------------------------------------------------------------
    void Pass::setDiffuse(const ColourValue& diffuse)
    {
	    mDiffuse = diffuse;
    }
    //-----------------------------------------------------------------------
    void Pass::setSpecular(Real red, Real green, Real blue, Real alpha)
    {
	    mSpecular.r = red;
	    mSpecular.g = green;
	    mSpecular.b = blue;
		mSpecular.a = alpha;
    }
    //-----------------------------------------------------------------------
    void Pass::setSpecular(const ColourValue& specular)
    {
	    mSpecular = specular;
    }
    //-----------------------------------------------------------------------
    void Pass::setShininess(Real val)
    {
	    mShininess = val;
    }
    //-----------------------------------------------------------------------
    void Pass::setSelfIllumination(Real red, Real green, Real blue)
    {
	    mEmissive.r = red;
	    mEmissive.g = green;
	    mEmissive.b = blue;

    }
    //-----------------------------------------------------------------------
    void Pass::setSelfIllumination(const ColourValue& selfIllum)
    {
	    mEmissive = selfIllum;
    }
    //-----------------------------------------------------------------------
    void Pass::setVertexColourTracking(TrackVertexColourType tracking)
    {
        mTracking = tracking;
    }
    //-----------------------------------------------------------------------
    Real Pass::getPointSize(void) const
    {
	    return mPointSize;
    }
    //-----------------------------------------------------------------------
    const ColourValue& Pass::getAmbient(void) const
    {
	    return mAmbient;
    }
    //-----------------------------------------------------------------------
    const ColourValue& Pass::getDiffuse(void) const
    {
	    return mDiffuse;
    }
    //-----------------------------------------------------------------------
    const ColourValue& Pass::getSpecular(void) const
    {
	    return mSpecular;
    }
    //-----------------------------------------------------------------------
    const ColourValue& Pass::getSelfIllumination(void) const
    {
	    return mEmissive;
    }
    //-----------------------------------------------------------------------
    Real Pass::getShininess(void) const
    {
	    return mShininess;
    }
    //-----------------------------------------------------------------------
    TrackVertexColourType Pass::getVertexColourTracking(void) const
    {
        return mTracking;
    }
    //-----------------------------------------------------------------------
    TextureUnitState* Pass::createTextureUnitState(void)
    {
        TextureUnitState *t = OGRE_NEW TextureUnitState(this);
        addTextureUnitState(t);
		mContentTypeLookupBuilt = false;
	    return t;
    }
    //-----------------------------------------------------------------------
    TextureUnitState* Pass::createTextureUnitState(
        const String& textureName, unsigned short texCoordSet)
    {
        TextureUnitState *t = OGRE_NEW TextureUnitState(this);
	    t->setTextureName(textureName);
	    t->setTextureCoordSet(texCoordSet);
        addTextureUnitState(t);
		mContentTypeLookupBuilt = false;
	    return t;
    }
    //-----------------------------------------------------------------------
	void Pass::addTextureUnitState(TextureUnitState* state)
	{
            OGRE_LOCK_MUTEX(mTexUnitChangeMutex);

        assert(state && "state is 0 in Pass::addTextureUnitState()");
        if (state)
        {
            // only attach TUS to pass if TUS does not belong to another pass
            if ((state->getParent() == 0) || (state->getParent() == this))
            {
		        mTextureUnitStates.push_back(state);
				// Notify state
				state->_notifyParent(this);
                // if texture unit state name is empty then give it a default name based on its index
                if (state->getName().empty())
                {
                    // its the last entry in the container so its index is size - 1
                    size_t idx = mTextureUnitStates.size() - 1;
                    
					// allow 8 digit hex number. there should never be that many texture units.
					// This sprintf replaced a call to StringConverter::toString for performance reasons
					char buff[9];
					memset(buff, 0, 9);
					sprintf(buff, "%lx", static_cast<long>(idx));
                    state->setName( buff );
                    
					/** since the name was never set and a default one has been made, clear the alias name
                     so that when the texture unit name is set by the user, the alias name will be set to
                     that name
                    */
                    state->setTextureNameAlias(StringUtil::BLANK);
                }
                // Needs recompilation
                mParent->_notifyNeedsRecompile();
                _dirtyHash();
            }
            else
            {
			    OGRE_EXCEPT(Exception::ERR_INVALIDPARAMS, "TextureUnitState already attached to another pass",
				    "Pass:addTextureUnitState");

            }
			mContentTypeLookupBuilt = false;
        }
	}
    //-----------------------------------------------------------------------
    TextureUnitState* Pass::getTextureUnitState(unsigned short index)
    {
        OGRE_LOCK_MUTEX(mTexUnitChangeMutex);
        assert (index < mTextureUnitStates.size() && "Index out of bounds");
	    return mTextureUnitStates[index];
    }
    //-----------------------------------------------------------------------------
    TextureUnitState* Pass::getTextureUnitState(const String& name)
    {
        OGRE_LOCK_MUTEX(mTexUnitChangeMutex);
        TextureUnitStates::iterator i    = mTextureUnitStates.begin();
        TextureUnitStates::iterator iend = mTextureUnitStates.end();
        TextureUnitState* foundTUS = 0;

        // iterate through TUS Container to find a match
        while (i != iend)
        {
            if ( (*i)->getName() == name )
            {
                foundTUS = (*i);
                break;
            }

            ++i;
        }

        return foundTUS;
    }
	//-----------------------------------------------------------------------
	const TextureUnitState* Pass::getTextureUnitState(unsigned short index) const
	{
            OGRE_LOCK_MUTEX(mTexUnitChangeMutex);
		assert (index < mTextureUnitStates.size() && "Index out of bounds");
		return mTextureUnitStates[index];
	}
	//-----------------------------------------------------------------------------
	const TextureUnitState* Pass::getTextureUnitState(const String& name) const
	{
            OGRE_LOCK_MUTEX(mTexUnitChangeMutex);
		TextureUnitStates::const_iterator i    = mTextureUnitStates.begin();
		TextureUnitStates::const_iterator iend = mTextureUnitStates.end();
		const TextureUnitState* foundTUS = 0;

		// iterate through TUS Container to find a match
		while (i != iend)
		{
			if ( (*i)->getName() == name )
			{
				foundTUS = (*i);
				break;
			}

			++i;
		}

		return foundTUS;
	}

    //-----------------------------------------------------------------------
    unsigned short Pass::getTextureUnitStateIndex(const TextureUnitState* state) const
    {
        OGRE_LOCK_MUTEX(mTexUnitChangeMutex);
        assert(state && "state is 0 in Pass::getTextureUnitStateIndex()");

        // only find index for state attached to this pass
        if (state->getParent() == this)
        {
            TextureUnitStates::const_iterator i =
                std::find(mTextureUnitStates.begin(), mTextureUnitStates.end(), state);
            assert(i != mTextureUnitStates.end() && "state is supposed to attached to this pass");
            return static_cast<unsigned short>(std::distance(mTextureUnitStates.begin(), i));
        }
        else
        {
			OGRE_EXCEPT(Exception::ERR_INVALIDPARAMS, "TextureUnitState is not attached to this pass",
				"Pass:getTextureUnitStateIndex");
        }
    }

    //-----------------------------------------------------------------------
    Pass::TextureUnitStateIterator
        Pass::getTextureUnitStateIterator(void)
    {
        return TextureUnitStateIterator(mTextureUnitStates.begin(), mTextureUnitStates.end());
    }
	//-----------------------------------------------------------------------
	Pass::ConstTextureUnitStateIterator
		Pass::getTextureUnitStateIterator(void) const
	{
		return ConstTextureUnitStateIterator(mTextureUnitStates.begin(), mTextureUnitStates.end());
	}
    //-----------------------------------------------------------------------
    void Pass::removeTextureUnitState(unsigned short index)
    {
        OGRE_LOCK_MUTEX(mTexUnitChangeMutex);
        assert (index < mTextureUnitStates.size() && "Index out of bounds");

        TextureUnitStates::iterator i = mTextureUnitStates.begin() + index;
        OGRE_DELETE *i;
	    mTextureUnitStates.erase(i);
        if (!mQueuedForDeletion)
        {
            // Needs recompilation
            mParent->_notifyNeedsRecompile();
        }
        _dirtyHash();
		mContentTypeLookupBuilt = false;
    }
    //-----------------------------------------------------------------------
    void Pass::removeAllTextureUnitStates(void)
    {
        OGRE_LOCK_MUTEX(mTexUnitChangeMutex);
        TextureUnitStates::iterator i, iend;
        iend = mTextureUnitStates.end();
        for (i = mTextureUnitStates.begin(); i != iend; ++i)
        {
            OGRE_DELETE *i;
        }
        mTextureUnitStates.clear();
        if (!mQueuedForDeletion)
        {
            // Needs recompilation
            mParent->_notifyNeedsRecompile();
        }
        _dirtyHash();
		mContentTypeLookupBuilt = false;
    }
	//-----------------------------------------------------------------------
	void Pass::_getBlendFlags(SceneBlendType type, SceneBlendFactor& source, SceneBlendFactor& dest)
	{
		switch ( type )
		{
	    case SBT_TRANSPARENT_ALPHA:
		    source = SBF_SOURCE_ALPHA;
			dest = SBF_ONE_MINUS_SOURCE_ALPHA;
		    return;
	    case SBT_TRANSPARENT_COLOUR:
		    source = SBF_SOURCE_COLOUR;
			dest = SBF_ONE_MINUS_SOURCE_COLOUR;
		    return;
		case SBT_MODULATE:
			source = SBF_DEST_COLOUR;
			dest = SBF_ZERO;
			return;
	    case SBT_ADD:
		    source = SBF_ONE;
			dest = SBF_ONE;
		    return;
        case SBT_REPLACE:
            source = SBF_ONE;
			dest = SBF_ZERO;
            return;
		}

		// Default to SBT_REPLACE

		source = SBF_ONE;
		dest = SBF_ZERO;
	}
    //-----------------------------------------------------------------------
    void Pass::setSceneBlending(SceneBlendType sbt)
    {
		// Convert type into blend factors

		SceneBlendFactor source;
		SceneBlendFactor dest;
		_getBlendFlags(sbt, source, dest);

		// Set blend factors

		setSceneBlending(source, dest);
    }
	//-----------------------------------------------------------------------
	void Pass::setSeparateSceneBlending( const SceneBlendType sbt, const SceneBlendType sbta )
	{
		// Convert types into blend factors

		SceneBlendFactor source;
		SceneBlendFactor dest;
		_getBlendFlags(sbt, source, dest);

		SceneBlendFactor sourceAlpha;
		SceneBlendFactor destAlpha;
		_getBlendFlags(sbta, sourceAlpha, destAlpha);

		// Set blend factors

		setSeparateSceneBlending(source, dest, sourceAlpha, destAlpha);
	}

    //-----------------------------------------------------------------------
    void Pass::setSceneBlending(SceneBlendFactor sourceFactor, SceneBlendFactor destFactor)
    {
	    mSourceBlendFactor = sourceFactor;
	    mDestBlendFactor = destFactor;

		mSeparateBlend = false;
    }
	//-----------------------------------------------------------------------
	void Pass::setSeparateSceneBlending( const SceneBlendFactor sourceFactor, const SceneBlendFactor destFactor, const SceneBlendFactor sourceFactorAlpha, const SceneBlendFactor destFactorAlpha )
	{
		mSourceBlendFactor = sourceFactor;
		mDestBlendFactor = destFactor;
		mSourceBlendFactorAlpha = sourceFactorAlpha;
		mDestBlendFactorAlpha = destFactorAlpha;

		mSeparateBlend = true;
	}
    //-----------------------------------------------------------------------
    SceneBlendFactor Pass::getSourceBlendFactor(void) const
    {
	    return mSourceBlendFactor;
    }
    //-----------------------------------------------------------------------
    SceneBlendFactor Pass::getDestBlendFactor(void) const
    {
	    return mDestBlendFactor;
    }
    //-----------------------------------------------------------------------
    SceneBlendFactor Pass::getSourceBlendFactorAlpha(void) const
    {
	    return mSourceBlendFactorAlpha;
    }
    //-----------------------------------------------------------------------
    SceneBlendFactor Pass::getDestBlendFactorAlpha(void) const
    {
	    return mDestBlendFactorAlpha;
    }
	//-----------------------------------------------------------------------
	bool Pass::hasSeparateSceneBlending() const
	{
		return mSeparateBlend;
	}
	//-----------------------------------------------------------------------
	void Pass::setSceneBlendingOperation(SceneBlendOperation op)
	{
		mBlendOperation = op;
		mSeparateBlendOperation = false;
	}
	//-----------------------------------------------------------------------
	void Pass::setSeparateSceneBlendingOperation(SceneBlendOperation op, SceneBlendOperation alphaOp)
	{
		mBlendOperation = op;
		mAlphaBlendOperation = alphaOp;
		mSeparateBlendOperation = true;
	}
	//-----------------------------------------------------------------------
	SceneBlendOperation Pass::getSceneBlendingOperation() const
	{
		return mBlendOperation;
	}
	//-----------------------------------------------------------------------
	SceneBlendOperation Pass::getSceneBlendingOperationAlpha() const
	{
		return mAlphaBlendOperation;
	}
	//-----------------------------------------------------------------------
	bool Pass::hasSeparateSceneBlendingOperations() const
	{
		return mSeparateBlendOperation;
	}
    //-----------------------------------------------------------------------
    bool Pass::isTransparent(void) const
    {
		// Transparent if any of the destination colour is taken into account
		if (mDestBlendFactor == SBF_ZERO &&
			mSourceBlendFactor != SBF_DEST_COLOUR &&
			mSourceBlendFactor != SBF_ONE_MINUS_DEST_COLOUR &&
			mSourceBlendFactor != SBF_DEST_ALPHA &&
			mSourceBlendFactor != SBF_ONE_MINUS_DEST_ALPHA)
		{
		    return false;
		}
	    else
		{
		    return true;
		}
    }
    //-----------------------------------------------------------------------
    void Pass::setDepthCheckEnabled(bool enabled)
    {
	    mDepthCheck = enabled;
    }
    //-----------------------------------------------------------------------
    bool Pass::getDepthCheckEnabled(void) const
    {
	    return mDepthCheck;
    }
    //-----------------------------------------------------------------------
    void Pass::setDepthWriteEnabled(bool enabled)
    {
	    mDepthWrite = enabled;
    }
    //-----------------------------------------------------------------------
    bool Pass::getDepthWriteEnabled(void) const
    {
	    return mDepthWrite;
    }
    //-----------------------------------------------------------------------
    void Pass::setDepthFunction( CompareFunction func)
    {
	    mDepthFunc = func;
    }
    //-----------------------------------------------------------------------
    CompareFunction Pass::getDepthFunction(void) const
    {
	    return mDepthFunc;
    }
	//-----------------------------------------------------------------------
	void Pass::setAlphaRejectSettings(CompareFunction func, unsigned char value, bool alphaToCoverage)
	{
		mAlphaRejectFunc = func;
		mAlphaRejectVal = value;
		mAlphaToCoverageEnabled = alphaToCoverage;
	}
	//-----------------------------------------------------------------------
	void Pass::setAlphaRejectFunction(CompareFunction func)
	{
		mAlphaRejectFunc = func;
	}
	//-----------------------------------------------------------------------
	void Pass::setAlphaRejectValue(unsigned char val)
	{
		mAlphaRejectVal = val;
	}
	//---------------------------------------------------------------------
	void Pass::setAlphaToCoverageEnabled(bool enabled)
	{
		mAlphaToCoverageEnabled = enabled;
	}
	//-----------------------------------------------------------------------
	void Pass::setTransparentSortingEnabled(bool enabled)
	{
		mTransparentSorting = enabled;
	}
	//-----------------------------------------------------------------------
	bool Pass::getTransparentSortingEnabled(void) const
	{
		return mTransparentSorting;
	}
	//-----------------------------------------------------------------------
	void Pass::setTransparentSortingForced(bool enabled)
	{
		mTransparentSortingForced = enabled;
	}
	//-----------------------------------------------------------------------
	bool Pass::getTransparentSortingForced(void) const
	{
		return mTransparentSortingForced;
	}
    //-----------------------------------------------------------------------
	void Pass::setColourWriteEnabled(bool enabled)
	{
		mColourWrite = enabled;
	}
    //-----------------------------------------------------------------------
	bool Pass::getColourWriteEnabled(void) const
	{
		return mColourWrite;
	}
    //-----------------------------------------------------------------------
    void Pass::setCullingMode( CullingMode mode)
    {
	    mCullMode = mode;
    }
    //-----------------------------------------------------------------------
    CullingMode Pass::getCullingMode(void) const
    {
	    return mCullMode;
    }
    //-----------------------------------------------------------------------
    void Pass::setLightingEnabled(bool enabled)
    {
	    mLightingEnabled = enabled;
    }
    //-----------------------------------------------------------------------
    bool Pass::getLightingEnabled(void) const
    {
	    return mLightingEnabled;
    }
    //-----------------------------------------------------------------------
    void Pass::setMaxSimultaneousLights(unsigned short maxLights)
    {
        mMaxSimultaneousLights = maxLights;
    }
    //-----------------------------------------------------------------------
    unsigned short Pass::getMaxSimultaneousLights(void) const
    {
        return mMaxSimultaneousLights;
    }
	//-----------------------------------------------------------------------
	void Pass::setStartLight(unsigned short startLight)
	{
		mStartLight = startLight;
	}
	//-----------------------------------------------------------------------
	unsigned short Pass::getStartLight(void) const
	{
		return mStartLight;
	}
	//-----------------------------------------------------------------------
	void Pass::setLightMask(uint32 mask)
	{
		mLightMask = mask;
	}
	//-----------------------------------------------------------------------
	uint32 Pass::getLightMask() const
	{
		return mLightMask;
	}
	//-----------------------------------------------------------------------
	void Pass::setLightCountPerIteration(unsigned short c)
	{
		mLightsPerIteration = c;
	}
	//-----------------------------------------------------------------------
	unsigned short Pass::getLightCountPerIteration(void) const
	{
		return mLightsPerIteration;
	}
    //-----------------------------------------------------------------------
    void Pass::setIteratePerLight(bool enabled,
            bool onlyForOneLightType, Light::LightTypes lightType)
    {
        mIteratePerLight = enabled;
        mRunOnlyForOneLightType = onlyForOneLightType;
        mOnlyLightType = lightType;
    }
    //-----------------------------------------------------------------------
    void Pass::setShadingMode(ShadeOptions mode)
    {
	    mShadeOptions = mode;
    }
    //-----------------------------------------------------------------------
    ShadeOptions Pass::getShadingMode(void) const
    {
	    return mShadeOptions;
    }
	//-----------------------------------------------------------------------
	void Pass::setPolygonMode(PolygonMode mode)
	{
		mPolygonMode = mode;
	}
	//-----------------------------------------------------------------------
	PolygonMode Pass::getPolygonMode(void) const
	{
		return mPolygonMode;
	}
    //-----------------------------------------------------------------------
    void Pass::setManualCullingMode(ManualCullingMode mode)
    {
	    mManualCullMode = mode;
    }
    //-----------------------------------------------------------------------
    ManualCullingMode Pass::getManualCullingMode(void) const
    {
	    return mManualCullMode;
    }
    //-----------------------------------------------------------------------
    void Pass::setFog(bool overrideScene, FogMode mode, const ColourValue& colour, Real density, Real start, Real end)
    {
	    mFogOverride = overrideScene;
	    if (overrideScene)
	    {
		    mFogMode = mode;
		    mFogColour = colour;
		    mFogStart = start;
		    mFogEnd = end;
		    mFogDensity = density;
	    }
    }
    //-----------------------------------------------------------------------
    bool Pass::getFogOverride(void) const
    {
	    return mFogOverride;
    }
    //-----------------------------------------------------------------------
    FogMode Pass::getFogMode(void) const
    {
	    return mFogMode;
    }
    //-----------------------------------------------------------------------
    const ColourValue& Pass::getFogColour(void) const
    {
	    return mFogColour;
    }
    //-----------------------------------------------------------------------
    Real Pass::getFogStart(void) const
    {
	    return mFogStart;
    }
    //-----------------------------------------------------------------------
    Real Pass::getFogEnd(void) const
    {
	    return mFogEnd;
    }
    //-----------------------------------------------------------------------
    Real Pass::getFogDensity(void) const
    {
	    return mFogDensity;
    }
    //-----------------------------------------------------------------------
    void Pass::setDepthBias(float constantBias, float slopeScaleBias)
    {
       mDepthBiasConstant = constantBias;
	   mDepthBiasSlopeScale = slopeScaleBias;
    }
    //-----------------------------------------------------------------------
    float Pass::getDepthBiasConstant(void) const
    {
        return mDepthBiasConstant;
    }
	//-----------------------------------------------------------------------
	float Pass::getDepthBiasSlopeScale(void) const
	{
		return mDepthBiasSlopeScale;
	}
	//---------------------------------------------------------------------
	void Pass::setIterationDepthBias(float biasPerIteration)
	{
		mDepthBiasPerIteration = biasPerIteration;
	}
	//---------------------------------------------------------------------
	float Pass::getIterationDepthBias() const
	{
		return mDepthBiasPerIteration;
	}
    //-----------------------------------------------------------------------
	Pass* Pass::_split(unsigned short numUnits)
	{
		if (mVertexProgramUsage || mGeometryProgramUsage || mFragmentProgramUsage)
		{
			OGRE_EXCEPT(Exception::ERR_INVALIDPARAMS, "Programmable passes cannot be "
				"automatically split, define a fallback technique instead.",
				"Pass:_split");
		}

		if (mTextureUnitStates.size() > numUnits)
		{
			size_t start = mTextureUnitStates.size() - numUnits;

			Pass* newPass = mParent->createPass();

			TextureUnitStates::iterator istart, i, iend;
			iend = mTextureUnitStates.end();
			i = istart = mTextureUnitStates.begin() + start;
			// Set the new pass to fallback using scene blend
			newPass->setSceneBlending(
				(*i)->getColourBlendFallbackSrc(), (*i)->getColourBlendFallbackDest());
			// Fixup the texture unit 0   of new pass   blending method   to replace
			// all colour and alpha   with texture without adjustment, because we
			// assume it's detail texture.
			(*i)->setColourOperationEx(LBX_SOURCE1,   LBS_TEXTURE, LBS_CURRENT);
			(*i)->setAlphaOperation(LBX_SOURCE1, LBS_TEXTURE, LBS_CURRENT);

			// Add all the other texture unit states
			for (; i != iend; ++i)
			{
				// detach from parent first
				(*i)->_notifyParent(0);
				newPass->addTextureUnitState(*i);
			}
			// Now remove texture units from this Pass, we don't need to delete since they've
			// been transferred
			mTextureUnitStates.erase(istart, iend);
			_dirtyHash();
			mContentTypeLookupBuilt = false;
			return newPass;
		}
		return NULL;
	}
	//-----------------------------------------------------------------------------
	void Pass::_notifyIndex(unsigned short index)
	{
		if (mIndex != index)
		{
			mIndex = index;
			_dirtyHash();
		}
	}
    //-----------------------------------------------------------------------
	void Pass::_prepare(void)
	{
		// We assume the Technique only calls this when the material is being
		// prepared

		// prepare each TextureUnitState
		TextureUnitStates::iterator i, iend;
		iend = mTextureUnitStates.end();
		for (i = mTextureUnitStates.begin(); i != iend; ++i)
		{
			(*i)->_prepare();
		}

	}
    //-----------------------------------------------------------------------
	void Pass::_unprepare(void)
	{
		// unprepare each TextureUnitState
		TextureUnitStates::iterator i, iend;
		iend = mTextureUnitStates.end();
		for (i = mTextureUnitStates.begin(); i != iend; ++i)
		{
			(*i)->_unprepare();
		}

	}
    //-----------------------------------------------------------------------
	void Pass::_load(void)
	{
		// We assume the Technique only calls this when the material is being
		// loaded

		// Load each TextureUnitState
		TextureUnitStates::iterator i, iend;
		iend = mTextureUnitStates.end();
		for (i = mTextureUnitStates.begin(); i != iend; ++i)
		{
			(*i)->_load();
		}

		// Load programs
		if (mVertexProgramUsage)
		{
			// Load vertex program
            mVertexProgramUsage->_load();
        }
        if (mShadowCasterVertexProgramUsage)
        {
            // Load vertex program
            mShadowCasterVertexProgramUsage->_load();
        }
        if (mShadowCasterFragmentProgramUsage)
        {
            // Load fragment program
            mShadowCasterFragmentProgramUsage->_load();
        }
        if (mShadowReceiverVertexProgramUsage)
        {
            // Load vertex program
            mShadowReceiverVertexProgramUsage->_load();
        }

		if (mTessellationHullProgramUsage)
		{
			// Load tessellation control program
            mTessellationHullProgramUsage->_load();
        }

		if (mTessellationDomainProgramUsage)
		{
			// Load tessellation evaluation program
            mTessellationDomainProgramUsage->_load();
        }

		if (mGeometryProgramUsage)
		{
			// Load geometry program
            mGeometryProgramUsage->_load();
        }

        if (mFragmentProgramUsage)
        {
			// Load fragment program
            mFragmentProgramUsage->_load();
		}
		if (mShadowReceiverFragmentProgramUsage)
		{
			// Load Fragment program
			mShadowReceiverFragmentProgramUsage->_load();
		}

		if (mComputeProgramUsage)
		{
			// Load compute program
            mComputeProgramUsage->_load();
        }

		if (mHashDirtyQueued)
		{
			_dirtyHash();
		}

	}
    //-----------------------------------------------------------------------
	void Pass::_unload(void)
	{
		// Unload each TextureUnitState
		TextureUnitStates::iterator i, iend;
		iend = mTextureUnitStates.end();
		for (i = mTextureUnitStates.begin(); i != iend; ++i)
		{
			(*i)->_unload();
		}

		// Unload programs
		if (mVertexProgramUsage)
		{
			// TODO
		}
		if (mGeometryProgramUsage)
		{
			// TODO
		}
        if (mFragmentProgramUsage)
        {
            // TODO
        }
		if (mTessellationHullProgramUsage)
		{
			// TODO
		}
		if (mTessellationDomainProgramUsage)
		{
			// TODO
		}
		if (mComputeProgramUsage)
		{
			// TODO
		}
		if (mGeometryProgramUsage)
		{
			// TODO
		}
	}
    //-----------------------------------------------------------------------
	void Pass::setVertexProgram(const String& name, bool resetParams)
	{
        OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);

		if (getVertexProgramName() != name)
		{
			// Turn off vertex program if name blank
			if (name.empty())
			{
				OGRE_DELETE mVertexProgramUsage;
				mVertexProgramUsage = NULL;
			}
			else
			{
				if (!mVertexProgramUsage)
				{
					mVertexProgramUsage = OGRE_NEW GpuProgramUsage(GPT_VERTEX_PROGRAM, this);
				}
				mVertexProgramUsage->setProgramName(name, resetParams);
			}
			// Needs recompilation
			mParent->_notifyNeedsRecompile();

			if( Pass::getHashFunction() == Pass::getBuiltinHashFunction( Pass::MIN_GPU_PROGRAM_CHANGE ) )
			{
				_dirtyHash();
			}

		}
	}
    //-----------------------------------------------------------------------
	void Pass::setVertexProgramParameters(GpuProgramParametersSharedPtr params)
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		if (!mVertexProgramUsage)
        {
            OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
                "This pass does not have a vertex program assigned!",
                "Pass::setVertexProgramParameters");
        }
		mVertexProgramUsage->setParameters(params);
	}
    //-----------------------------------------------------------------------
	void Pass::setFragmentProgram(const String& name, bool resetParams)
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);

		if (getFragmentProgramName() != name)
		{
			// Turn off fragment program if name blank
			if (name.empty())
			{
				OGRE_DELETE mFragmentProgramUsage;
				mFragmentProgramUsage = NULL;
			}
			else
			{
				if (!mFragmentProgramUsage)
				{
					mFragmentProgramUsage = OGRE_NEW GpuProgramUsage(GPT_FRAGMENT_PROGRAM, this);
				}
				mFragmentProgramUsage->setProgramName(name, resetParams);
			}
			// Needs recompilation
			mParent->_notifyNeedsRecompile();

			if( Pass::getHashFunction() == Pass::getBuiltinHashFunction( Pass::MIN_GPU_PROGRAM_CHANGE ) )
			{
				_dirtyHash();
			}
		}
	}
    //-----------------------------------------------------------------------
	void Pass::setFragmentProgramParameters(GpuProgramParametersSharedPtr params)
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		if (!mFragmentProgramUsage)
        {
            OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
                "This pass does not have a fragment program assigned!",
                "Pass::setFragmentProgramParameters");
        }
		mFragmentProgramUsage->setParameters(params);
	}
	//-----------------------------------------------------------------------
	void Pass::setGeometryProgram(const String& name, bool resetParams)
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);

		if (getGeometryProgramName() != name)
		{
			// Turn off geometry program if name blank
			if (name.empty())
			{
				OGRE_DELETE mGeometryProgramUsage;
				mGeometryProgramUsage = NULL;
			}
			else
			{
				if (!mGeometryProgramUsage)
				{
					mGeometryProgramUsage = OGRE_NEW GpuProgramUsage(GPT_GEOMETRY_PROGRAM, this);
				}
				mGeometryProgramUsage->setProgramName(name, resetParams);
			}
			// Needs recompilation
			mParent->_notifyNeedsRecompile();

			if( Pass::getHashFunction() == Pass::getBuiltinHashFunction( Pass::MIN_GPU_PROGRAM_CHANGE ) )
			{
				_dirtyHash();
			}
		}
	}
    //-----------------------------------------------------------------------
	void Pass::setGeometryProgramParameters(GpuProgramParametersSharedPtr params)
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		if (!mGeometryProgramUsage)
        {
            OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
                "This pass does not have a geometry program assigned!",
                "Pass::setGeometryProgramParameters");
        }
		mGeometryProgramUsage->setParameters(params);
	}
	//-----------------------------------------------------------------------
	void Pass::setTessellationHullProgram(const String& name, bool resetParams)
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);

		if (getTessellationHullProgramName() != name)
		{
			// Turn off tessellation Hull program if name blank
			if (name.empty())
			{
				OGRE_DELETE mTessellationHullProgramUsage;
				mTessellationHullProgramUsage = NULL;
			}
			else
			{
				if (!mTessellationHullProgramUsage)
				{
					mTessellationHullProgramUsage = OGRE_NEW GpuProgramUsage(GPT_HULL_PROGRAM, this);
				}
				mTessellationHullProgramUsage->setProgramName(name, resetParams);
			}
			// Needs recompilation
			mParent->_notifyNeedsRecompile();

			if( Pass::getHashFunction() == Pass::getBuiltinHashFunction( Pass::MIN_GPU_PROGRAM_CHANGE ) )
			{
				_dirtyHash();
			}
		}
	}
    //-----------------------------------------------------------------------
	void Pass::setTessellationHullProgramParameters(GpuProgramParametersSharedPtr params)
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		if (!mTessellationHullProgramUsage)
        {
            OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
                "This pass does not have a tessellation Hull program assigned!",
                "Pass::setTessellationHullProgramParameters");
        }
		mTessellationHullProgramUsage->setParameters(params);
	}
	//-----------------------------------------------------------------------
	void Pass::setTessellationDomainProgram(const String& name, bool resetParams)
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);

		if (getTessellationDomainProgramName() != name)
		{
			// Turn off tessellation Domain program if name blank
			if (name.empty())
			{
				OGRE_DELETE mTessellationDomainProgramUsage;
				mTessellationDomainProgramUsage = NULL;
			}
			else
			{
				if (!mTessellationDomainProgramUsage)
				{
					mTessellationDomainProgramUsage = OGRE_NEW GpuProgramUsage(GPT_DOMAIN_PROGRAM, this);
				}
				mTessellationDomainProgramUsage->setProgramName(name, resetParams);
			}
			// Needs recompilation
			mParent->_notifyNeedsRecompile();

			if( Pass::getHashFunction() == Pass::getBuiltinHashFunction( Pass::MIN_GPU_PROGRAM_CHANGE ) )
			{
				_dirtyHash();
			}
		}
	}
    //-----------------------------------------------------------------------
	void Pass::setTessellationDomainProgramParameters(GpuProgramParametersSharedPtr params)
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		if (!mTessellationDomainProgramUsage)
        {
            OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
                "This pass does not have a tessellation Domain program assigned!",
                "Pass::setTessellationDomainProgramParameters");
        }
		mTessellationDomainProgramUsage->setParameters(params);
	}
	//-----------------------------------------------------------------------
	void Pass::setComputeProgram(const String& name, bool resetParams)
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);

		if (getComputeProgramName() != name)
		{
			// Turn off compute program if name blank
			if (name.empty())
			{
				OGRE_DELETE mComputeProgramUsage;
				mComputeProgramUsage = NULL;
			}
			else
			{
				if (!mComputeProgramUsage)
				{
					mComputeProgramUsage = OGRE_NEW GpuProgramUsage(GPT_COMPUTE_PROGRAM, this);
				}
				mComputeProgramUsage->setProgramName(name, resetParams);
			}
			// Needs recompilation
			mParent->_notifyNeedsRecompile();

			if( Pass::getHashFunction() == Pass::getBuiltinHashFunction( Pass::MIN_GPU_PROGRAM_CHANGE ) )
			{
				_dirtyHash();
			}
		}
	}
    //-----------------------------------------------------------------------
	void Pass::setComputeProgramParameters(GpuProgramParametersSharedPtr params)
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		if (!mComputeProgramUsage)
        {
            OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
                "This pass does not have a compute program assigned!",
                "Pass::setComputeProgramParameters");
        }
		mComputeProgramUsage->setParameters(params);
	}
	//-----------------------------------------------------------------------
	const String& Pass::getVertexProgramName(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
        if (!mVertexProgramUsage)
            return StringUtil::BLANK;
        else
		    return mVertexProgramUsage->getProgramName();
	}
	//-----------------------------------------------------------------------
	GpuProgramParametersSharedPtr Pass::getVertexProgramParameters(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		if (!mVertexProgramUsage)
        {
            OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
                "This pass does not have a vertex program assigned!",
                "Pass::getVertexProgramParameters");
        }
		return mVertexProgramUsage->getParameters();
	}
	//-----------------------------------------------------------------------
	const GpuProgramPtr& Pass::getVertexProgram(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		return mVertexProgramUsage->getProgram();
	}
	//-----------------------------------------------------------------------
	const String& Pass::getFragmentProgramName(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
        if (!mFragmentProgramUsage)
            return StringUtil::BLANK;
        else
    		return mFragmentProgramUsage->getProgramName();
	}
	//-----------------------------------------------------------------------
	GpuProgramParametersSharedPtr Pass::getFragmentProgramParameters(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		return mFragmentProgramUsage->getParameters();
	}
	//-----------------------------------------------------------------------
	const GpuProgramPtr& Pass::getFragmentProgram(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		return mFragmentProgramUsage->getProgram();
	}
	//-----------------------------------------------------------------------
	const String& Pass::getGeometryProgramName(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
        if (!mGeometryProgramUsage)
            return StringUtil::BLANK;
        else
    		return mGeometryProgramUsage->getProgramName();
	}
	//-----------------------------------------------------------------------
	GpuProgramParametersSharedPtr Pass::getGeometryProgramParameters(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		return mGeometryProgramUsage->getParameters();
	}
	//-----------------------------------------------------------------------
	const GpuProgramPtr& Pass::getGeometryProgram(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		return mGeometryProgramUsage->getProgram();
	}
	//-----------------------------------------------------------------------
	const String& Pass::getTessellationHullProgramName(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
        if (!mTessellationHullProgramUsage)
            return StringUtil::BLANK;
        else
    		return mTessellationHullProgramUsage->getProgramName();
	}
	//-----------------------------------------------------------------------
	GpuProgramParametersSharedPtr Pass::getTessellationHullProgramParameters(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		return mTessellationHullProgramUsage->getParameters();
	}
	//-----------------------------------------------------------------------
	const GpuProgramPtr& Pass::getTessellationHullProgram(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		return mTessellationHullProgramUsage->getProgram();
	}
	//-----------------------------------------------------------------------
	const String& Pass::getTessellationDomainProgramName(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
        if (!mTessellationDomainProgramUsage)
            return StringUtil::BLANK;
        else
    		return mTessellationDomainProgramUsage->getProgramName();
	}
	//-----------------------------------------------------------------------
	GpuProgramParametersSharedPtr Pass::getTessellationDomainProgramParameters(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		return mTessellationDomainProgramUsage->getParameters();
	}
	//-----------------------------------------------------------------------
	const GpuProgramPtr& Pass::getTessellationDomainProgram(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		return mTessellationDomainProgramUsage->getProgram();
	}
	//-----------------------------------------------------------------------
	const String& Pass::getComputeProgramName(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
        if (!mComputeProgramUsage)
            return StringUtil::BLANK;
        else
    		return mComputeProgramUsage->getProgramName();
	}
	//-----------------------------------------------------------------------
	GpuProgramParametersSharedPtr Pass::getComputeProgramParameters(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		return mComputeProgramUsage->getParameters();
	}
	//-----------------------------------------------------------------------
	const GpuProgramPtr& Pass::getComputeProgram(void) const
	{
            OGRE_LOCK_MUTEX(mGpuProgramChangeMutex);
		return mComputeProgramUsage->getProgram();
	}
	//-----------------------------------------------------------------------
    bool Pass::isLoaded(void) const
    {
        return mParent->isLoaded();
    }
	//-----------------------------------------------------------------------
    void Pass::_recalculateHash(void)
    {
        /* Hash format is 32-bit, divided as follows (high to low bits)
           bits   purpose
            4     Pass index (i.e. max 16 passes!)
           14     Hashed texture name from unit 0
           14     Hashed texture name from unit 1

           Note that at the moment we don't sort on the 3rd texture unit plus
           on the assumption that these are less frequently used; sorting on
           the first 2 gives us the most benefit for now.
       */
        mHash = (*msHashFunc)(this);
    }
    //-----------------------------------------------------------------------
	void Pass::_dirtyHash(void)
	{
		Material* mat = mParent->getParent();
		if (mat->isLoading() || mat->isLoaded())
		{
                    OGRE_LOCK_MUTEX(msDirtyHashListMutex);
			// Mark this hash as for follow up
			msDirtyHashList.insert(this);
			mHashDirtyQueued = false;
		}
		else
		{
			mHashDirtyQueued = true;
		}
	}
	//---------------------------------------------------------------------
	void Pass::clearDirtyHashList(void) 
	{ 
            OGRE_LOCK_MUTEX(msDirtyHashListMutex);
		msDirtyHashList.clear(); 
	}
    //-----------------------------------------------------------------------
    void Pass::_notifyNeedsRecompile(void)
    {
        mParent->_notifyNeedsRecompile();
    }
    //-----------------------------------------------------------------------
    void Pass::setTextureFiltering(TextureFilterOptions filterType)
    {
        OGRE_LOCK_MUTEX(mTexUnitChangeMutex);

        TextureUnitStates::iterator i, iend;
        iend = mTextureUnitStates.end();
        for (i = mTextureUnitStates.begin(); i != iend; ++i)
        {
            (*i)->setTextureFiltering(filterType);
        }
    }
    // --------------------------------------------------------------------
    void Pass::setTextureAnisotropy(unsigned int maxAniso)
    {
        OGRE_LOCK_MUTEX(mTexUnitChangeMutex);
        TextureUnitStates::iterator i, iend;
        iend = mTextureUnitStates.end();
        for (i = mTextureUnitStates.begin(); i != iend; ++i)
        {
            (*i)->setTextureAnisotropy(maxAniso);
        }
    }
	//-----------------------------------------------------------------------
	void Pass::_updateAutoParams(const AutoParamDataSource* source, uint16 mask) const
	{
		if (hasVertexProgram())
		{
			// Update vertex program auto params
			mVertexProgramUsage->getParameters()->_updateAutoParams(source, mask);
		}

		if (hasGeometryProgram())
		{
			// Update geometry program auto params
			mGeometryProgramUsage->getParameters()->_updateAutoParams(source, mask);
		}

		if (hasFragmentProgram())
		{
			// Update fragment program auto params
			mFragmentProgramUsage->getParameters()->_updateAutoParams(source, mask);
		}

		if (hasTessellationHullProgram())
		{
			// Update fragment program auto params
			mTessellationHullProgramUsage->getParameters()->_updateAutoParams(source, mask);
		}

		if (hasTessellationDomainProgram())
		{
			// Update fragment program auto params
			mTessellationDomainProgramUsage->getParameters()->_updateAutoParams(source, mask);
		}

		if (hasComputeProgram())
		{
			// Update fragment program auto params
			mComputeProgramUsage->getParameters()->_updateAutoParams(source, mask);
		}
	}
    //-----------------------------------------------------------------------
    void Pass::processPendingPassUpdates(void)
    {
		{
                    OGRE_LOCK_MUTEX(msPassGraveyardMutex);
			// Delete items in the graveyard
			PassSet::iterator i, iend;
			iend = msPassGraveyard.end();
			for (i = msPassGraveyard.begin(); i != iend; ++i)
			{
				OGRE_DELETE *i;
			}
			msPassGraveyard.clear();
		}
        PassSet tempDirtyHashList;
		{
                    OGRE_LOCK_MUTEX(msDirtyHashListMutex);
			// The dirty ones will have been removed from the groups above using the old hash now
            tempDirtyHashList.swap(msDirtyHashList);
        }
        PassSet::iterator i, iend;
        iend = tempDirtyHashList.end();
        for (i = tempDirtyHashList.begin(); i != iend; ++i)
        {
            Pass* p = *i;
            p->_recalculateHash();
        }
    }
    //-----------------------------------------------------------------------
    void Pass::queueForDeletion(void)
    {
        mQueuedForDeletion = true;

        removeAllTextureUnitStates();
        if (mVertexProgramUsage)
        {
            OGRE_DELETE mVertexProgramUsage;
            mVertexProgramUsage = 0;
        }
        if (mShadowCasterVertexProgramUsage)
        {
            OGRE_DELETE mShadowCasterVertexProgramUsage;
            mShadowCasterVertexProgramUsage = 0;
        }
        if (mShadowCasterFragmentProgramUsage)
        {
            OGRE_DELETE mShadowCasterFragmentProgramUsage;
            mShadowCasterFragmentProgramUsage = 0;
        }
        if (mShadowReceiverVertexProgramUsage)
        {
            OGRE_DELETE mShadowReceiverVertexProgramUsage;
            mShadowReceiverVertexProgramUsage = 0;
        }
        if (mGeometryProgramUsage)
        {
            delete mGeometryProgramUsage;
            mGeometryProgramUsage = 0;
        }
        if (mFragmentProgramUsage)
        {
            OGRE_DELETE mFragmentProgramUsage;
            mFragmentProgramUsage = 0;
        }
		if (mTessellationHullProgramUsage)
        {
            OGRE_DELETE mTessellationHullProgramUsage;
            mTessellationHullProgramUsage = 0;
        }
		if (mTessellationDomainProgramUsage)
        {
            OGRE_DELETE mTessellationDomainProgramUsage;
            mTessellationDomainProgramUsage = 0;
        }
		if (mComputeProgramUsage)
        {
            OGRE_DELETE mComputeProgramUsage;
            mComputeProgramUsage = 0;
        }
		if (mShadowReceiverFragmentProgramUsage)
		{
			OGRE_DELETE mShadowReceiverFragmentProgramUsage;
			mShadowReceiverFragmentProgramUsage = 0;
		}
        // remove from dirty list, if there
		{
                    OGRE_LOCK_MUTEX(msDirtyHashListMutex);
			msDirtyHashList.erase(this);
		}
		{
                    OGRE_LOCK_MUTEX(msPassGraveyardMutex);
			msPassGraveyard.insert(this);
		}
    }
    //-----------------------------------------------------------------------
    bool Pass::isAmbientOnly(void) const
    {
        // treat as ambient if lighting is off, or colour write is off,
        // or all non-ambient (& emissive) colours are black
        // NB a vertex program could override this, but passes using vertex
        // programs are expected to indicate they are ambient only by
        // setting the state so it matches one of the conditions above, even
        // though this state is not used in rendering.
        return (!mLightingEnabled || !mColourWrite ||
            (mDiffuse == ColourValue::Black &&
             mSpecular == ColourValue::Black));
    }
    //-----------------------------------------------------------------------
    void Pass::setShadowCasterVertexProgram(const String& name)
    {
        // Turn off vertex program if name blank
        if (name.empty())
        {
            OGRE_DELETE mShadowCasterVertexProgramUsage;
            mShadowCasterVertexProgramUsage = NULL;
        }
        else
        {
            if (!mShadowCasterVertexProgramUsage)
            {
                mShadowCasterVertexProgramUsage = OGRE_NEW GpuProgramUsage(GPT_VERTEX_PROGRAM, this);
            }
            mShadowCasterVertexProgramUsage->setProgramName(name);
        }
        // Needs recompilation
        mParent->_notifyNeedsRecompile();
    }
    //-----------------------------------------------------------------------
    void Pass::setShadowCasterVertexProgramParameters(GpuProgramParametersSharedPtr params)
    {
        if (!mShadowCasterVertexProgramUsage)
        {
            OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
                "This pass does not have a shadow caster vertex program assigned!",
                "Pass::setShadowCasterVertexProgramParameters");
        }
        mShadowCasterVertexProgramUsage->setParameters(params);
    }
    //-----------------------------------------------------------------------
    const String& Pass::getShadowCasterVertexProgramName(void) const
    {
        if (!mShadowCasterVertexProgramUsage)
            return StringUtil::BLANK;
        else
            return mShadowCasterVertexProgramUsage->getProgramName();
    }
    //-----------------------------------------------------------------------
    GpuProgramParametersSharedPtr Pass::getShadowCasterVertexProgramParameters(void) const
    {
        if (!mShadowCasterVertexProgramUsage)
        {
            OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
                "This pass does not have a shadow caster vertex program assigned!",
                "Pass::getShadowCasterVertexProgramParameters");
        }
        return mShadowCasterVertexProgramUsage->getParameters();
    }
    //-----------------------------------------------------------------------
    const GpuProgramPtr& Pass::getShadowCasterVertexProgram(void) const
    {
        return mShadowCasterVertexProgramUsage->getProgram();
    }
    //-----------------------------------------------------------------------
    void Pass::setShadowCasterFragmentProgram(const String& name)
    {
        // Turn off fragment program if name blank
        if (name.empty())
        {
            OGRE_DELETE mShadowCasterFragmentProgramUsage;
            mShadowCasterFragmentProgramUsage = NULL;
        }
        else
        {
            if (!mShadowCasterFragmentProgramUsage)
            {
                mShadowCasterFragmentProgramUsage = OGRE_NEW GpuProgramUsage(GPT_FRAGMENT_PROGRAM, this);
            }
            mShadowCasterFragmentProgramUsage->setProgramName(name);
        }
        // Needs recompilation
        mParent->_notifyNeedsRecompile();
    }
    //-----------------------------------------------------------------------
    void Pass::setShadowCasterFragmentProgramParameters(GpuProgramParametersSharedPtr params)
    {
        if (Ogre::Root::getSingletonPtr()->getRenderSystem()->getName().find("OpenGL ES 2") != String::npos)
        {
            if (!mShadowCasterFragmentProgramUsage)
            {
                OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
                    "This pass does not have a shadow caster fragment program assigned!",
                    "Pass::setShadowCasterFragmentProgramParameters");
            }
            mShadowCasterFragmentProgramUsage->setParameters(params);
        }
    }
    //-----------------------------------------------------------------------
    const String& Pass::getShadowCasterFragmentProgramName(void) const
    {
        if (!mShadowCasterFragmentProgramUsage)
            return StringUtil::BLANK;
        else
            return mShadowCasterFragmentProgramUsage->getProgramName();
    }
    //-----------------------------------------------------------------------
    GpuProgramParametersSharedPtr Pass::getShadowCasterFragmentProgramParameters(void) const
    {
        if (Ogre::Root::getSingletonPtr()->getRenderSystem()->getName().find("OpenGL ES 2") != String::npos)
        {
            if (!mShadowCasterFragmentProgramUsage)
            {
                OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
                    "This pass does not have a shadow caster fragment program assigned!",
                    "Pass::getShadowCasterFragmentProgramParameters");
            }
        }
        return mShadowCasterFragmentProgramUsage->getParameters();
    }
    //-----------------------------------------------------------------------
    const GpuProgramPtr& Pass::getShadowCasterFragmentProgram(void) const
    {
        return mShadowCasterFragmentProgramUsage->getProgram();
    }
    //-----------------------------------------------------------------------
    void Pass::setShadowReceiverVertexProgram(const String& name)
    {
        // Turn off vertex program if name blank
        if (name.empty())
        {
            OGRE_DELETE mShadowReceiverVertexProgramUsage;
            mShadowReceiverVertexProgramUsage = NULL;
        }
        else
        {
            if (!mShadowReceiverVertexProgramUsage)
            {
                mShadowReceiverVertexProgramUsage = OGRE_NEW GpuProgramUsage(GPT_VERTEX_PROGRAM, this);
            }
            mShadowReceiverVertexProgramUsage->setProgramName(name);
        }
        // Needs recompilation
        mParent->_notifyNeedsRecompile();
    }
    //-----------------------------------------------------------------------
    void Pass::setShadowReceiverVertexProgramParameters(GpuProgramParametersSharedPtr params)
    {
        if (!mShadowReceiverVertexProgramUsage)
        {
            OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
                "This pass does not have a shadow receiver vertex program assigned!",
                "Pass::setShadowReceiverVertexProgramParameters");
        }
        mShadowReceiverVertexProgramUsage->setParameters(params);
    }
    //-----------------------------------------------------------------------
    const String& Pass::getShadowReceiverVertexProgramName(void) const
    {
        if (!mShadowReceiverVertexProgramUsage)
            return StringUtil::BLANK;
        else
            return mShadowReceiverVertexProgramUsage->getProgramName();
    }
    //-----------------------------------------------------------------------
    GpuProgramParametersSharedPtr Pass::getShadowReceiverVertexProgramParameters(void) const
    {
        if (!mShadowReceiverVertexProgramUsage)
        {
            OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
                "This pass does not have a shadow receiver vertex program assigned!",
                "Pass::getShadowReceiverVertexProgramParameters");
        }
        return mShadowReceiverVertexProgramUsage->getParameters();
    }
    //-----------------------------------------------------------------------
    const GpuProgramPtr& Pass::getShadowReceiverVertexProgram(void) const
    {
        return mShadowReceiverVertexProgramUsage->getProgram();
    }
	//-----------------------------------------------------------------------
	void Pass::setShadowReceiverFragmentProgram(const String& name)
	{
		// Turn off Fragment program if name blank
		if (name.empty())
		{
			OGRE_DELETE mShadowReceiverFragmentProgramUsage;
			mShadowReceiverFragmentProgramUsage = NULL;
		}
		else
		{
			if (!mShadowReceiverFragmentProgramUsage)
			{
				mShadowReceiverFragmentProgramUsage = OGRE_NEW GpuProgramUsage(GPT_FRAGMENT_PROGRAM, this);
			}
			mShadowReceiverFragmentProgramUsage->setProgramName(name);
		}
		// Needs recompilation
		mParent->_notifyNeedsRecompile();
	}
	//-----------------------------------------------------------------------
	void Pass::setShadowReceiverFragmentProgramParameters(GpuProgramParametersSharedPtr params)
	{
		if (!mShadowReceiverFragmentProgramUsage)
		{
			OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
				"This pass does not have a shadow receiver fragment program assigned!",
				"Pass::setShadowReceiverFragmentProgramParameters");
		}
		mShadowReceiverFragmentProgramUsage->setParameters(params);
	}
	//-----------------------------------------------------------------------
	const String& Pass::getShadowReceiverFragmentProgramName(void) const
	{
		if (!mShadowReceiverFragmentProgramUsage)
			return StringUtil::BLANK;
		else
			return mShadowReceiverFragmentProgramUsage->getProgramName();
	}
	//-----------------------------------------------------------------------
	GpuProgramParametersSharedPtr Pass::getShadowReceiverFragmentProgramParameters(void) const
	{
		if (!mShadowReceiverFragmentProgramUsage)
		{
			OGRE_EXCEPT (Exception::ERR_INVALIDPARAMS,
				"This pass does not have a shadow receiver fragment program assigned!",
				"Pass::getShadowReceiverFragmentProgramParameters");
		}
		return mShadowReceiverFragmentProgramUsage->getParameters();
	}
	//-----------------------------------------------------------------------
	const GpuProgramPtr& Pass::getShadowReceiverFragmentProgram(void) const
	{
		return mShadowReceiverFragmentProgramUsage->getProgram();
	}
    //-----------------------------------------------------------------------
	const String& Pass::getResourceGroup(void) const
	{
		return mParent->getResourceGroup();
	}

    //-----------------------------------------------------------------------
    bool Pass::applyTextureAliases(const AliasTextureNamePairList& aliasList, const bool apply) const
    {
        // iterate through each texture unit state and apply the texture alias if it applies
        TextureUnitStates::const_iterator i, iend;
        iend = mTextureUnitStates.end();
        bool testResult = false;

        for (i = mTextureUnitStates.begin(); i != iend; ++i)
        {
            if ((*i)->applyTextureAliases(aliasList, apply))
                testResult = true;
        }

        return testResult;

    }
	//-----------------------------------------------------------------------
	unsigned short Pass::_getTextureUnitWithContentTypeIndex(
		TextureUnitState::ContentType contentType, unsigned short index) const
	{
		if (!mContentTypeLookupBuilt)
		{
			mShadowContentTypeLookup.clear();
			for (unsigned short i = 0; i < mTextureUnitStates.size(); ++i)
			{
				if (mTextureUnitStates[i]->getContentType() == TextureUnitState::CONTENT_SHADOW)
				{
					mShadowContentTypeLookup.push_back(i);
				}
			}
			mContentTypeLookupBuilt = true;
		}

		switch(contentType)
		{
		case TextureUnitState::CONTENT_SHADOW:
			if (index < mShadowContentTypeLookup.size())
			{
				return mShadowContentTypeLookup[index];
			}
			break;
		default:
			// Simple iteration
			for (unsigned short i = 0; i < mTextureUnitStates.size(); ++i)
			{
				if (mTextureUnitStates[i]->getContentType() == TextureUnitState::CONTENT_SHADOW)
				{
					if (index == 0)
					{
						return i;
					}
					else
					{
						--index;
					}
				}
			}
			break;
		}

		// not found - return out of range
		return static_cast<unsigned short>(mTextureUnitStates.size() + 1);

	}
}
