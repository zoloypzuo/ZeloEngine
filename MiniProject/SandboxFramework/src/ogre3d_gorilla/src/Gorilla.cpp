/*
    Gorilla
    -------

    Copyright (c) 2010 Robin Southern

    Additional contributions by:

    - Murat Sari
    - Nigel Atkinson

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

*/

#include "Gorilla.h"

#pragma warning ( disable : 4244 )

#if OGRE_VERSION < 67584 // 1.8.0
template<> Gorilla::Silverback* Ogre::Singleton<Gorilla::Silverback>::ms_Singleton = 0;
#else
template<> Gorilla::Silverback* Ogre::Singleton<Gorilla::Silverback>::msSingleton = 0;
#endif

#define PUSH_VERTEX(VERTICES, VERTEX, X, Y, UV, COLOUR)   \
  VERTEX.position.x = X;                                           \
  VERTEX.position.y = Y;                                           \
  VERTEX.position.z = 0;                                           \
  VERTEX.uv.x = UV.x;                                              \
  VERTEX.uv.y = UV.y;                                              \
  VERTEX.colour = COLOUR;                                          \
  VERTICES.push_back(VERTEX);

#define PUSH_TRIANGLE(VERTICES, VERTEX, A, B, C, UV, COLOUR)       \
  PUSH_VERTEX(VERTICES, VERTEX, A.x, A.y, UV, COLOUR) \
  PUSH_VERTEX(VERTICES, VERTEX, B.x, B.y, UV, COLOUR) \
  PUSH_VERTEX(VERTICES, VERTEX, C.x, C.y, UV, COLOUR)

#define PUSH_QUAD(VERTICES, VERTEX, POSITIONS, COLOURS, UV)   \
  PUSH_VERTEX(VERTICES, VERTEX, POSITIONS[3].x, POSITIONS[3].y, UV[3], COLOURS[3]) \
  PUSH_VERTEX(VERTICES, VERTEX, POSITIONS[1].x, POSITIONS[1].y, UV[1], COLOURS[1]) \
  PUSH_VERTEX(VERTICES, VERTEX, POSITIONS[0].x, POSITIONS[0].y, UV[0], COLOURS[0]) \
     \
  PUSH_VERTEX(VERTICES, VERTEX, POSITIONS[3].x, POSITIONS[3].y, UV[3], COLOURS[3]) \
  PUSH_VERTEX(VERTICES, VERTEX, POSITIONS[2].x, POSITIONS[2].y, UV[2], COLOURS[2]) \
  PUSH_VERTEX(VERTICES, VERTEX, POSITIONS[1].x, POSITIONS[1].y, UV[1], COLOURS[1])

#define PUSH_QUAD2(VERTICES, VERTEX, POSITIONS, COLOUR, UV)   \
  PUSH_VERTEX(VERTICES, VERTEX, POSITIONS[3].x, POSITIONS[3].y, UV[3], COLOUR) \
  PUSH_VERTEX(VERTICES, VERTEX, POSITIONS[1].x, POSITIONS[1].y, UV[1], COLOUR) \
  PUSH_VERTEX(VERTICES, VERTEX, POSITIONS[0].x, POSITIONS[0].y, UV[0], COLOUR) \
     \
  PUSH_VERTEX(VERTICES, VERTEX, POSITIONS[3].x, POSITIONS[3].y, UV[3], COLOUR) \
  PUSH_VERTEX(VERTICES, VERTEX, POSITIONS[2].x, POSITIONS[2].y, UV[2], COLOUR) \
  PUSH_VERTEX(VERTICES, VERTEX, POSITIONS[1].x, POSITIONS[1].y, UV[1], COLOUR)

namespace Gorilla
{
 enum
 {
  SCREEN_RENDERQUEUE = Ogre::RENDER_QUEUE_OVERLAY
 };

 Ogre::ColourValue rgb(Ogre::uchar r, Ogre::uchar g, Ogre::uchar b, Ogre::uchar a )
 {
  static const Ogre::Real inv255 = Ogre::Real(0.00392156863);
  return Ogre::ColourValue(Ogre::Real(r) * inv255, Ogre::Real(g) * inv255, Ogre::Real(b) * inv255, Ogre::Real(a) * inv255);
 }

 Ogre::ColourValue webcolour(Colours::Colour web_colour, Ogre::Real alpha)
 {
  static const Ogre::Real inv255 = Ogre::Real(0.00392156863);
  Ogre::ColourValue ret;
  ret.b = Ogre::Real(web_colour & 0xFF) * inv255;
  ret.g = Ogre::Real((web_colour >> 8) & 0xFF) * inv255;
  ret.r = Ogre::Real((web_colour >> 16) & 0xFF) * inv255;
  ret.a = alpha;
  return ret;
 }

 TextureAtlas::TextureAtlas(const Ogre::String& gorillaFile, const Ogre::String& groupName)
 {
  _reset();
  _load(gorillaFile, groupName);
  _calculateCoordinates();
  _create2DMaterial();
  _create3DMaterial();
 }

 TextureAtlas::~TextureAtlas()
 {
  for (std::map<Ogre::uint, GlyphData*>::iterator it = mGlyphData.begin(); it != mGlyphData.end(); it++)
  {
   OGRE_DELETE (*it).second;
  }

  for (std::map<Ogre::String, Sprite*>::iterator it = mSprites.begin(); it != mSprites.end(); it++)
  {
   OGRE_DELETE (*it).second;
  }
 }

 void  TextureAtlas::_reset()
 {
  refreshMarkupColours();
 }

 void  TextureAtlas::_load(const Ogre::String& gorillaFile, const Ogre::String& groupName)
 {
  Ogre::ConfigFile f;
  f.loadFromResourceSystem(gorillaFile, groupName, " ", true);
  Ogre::ConfigFile::SectionIterator seci = f.getSectionIterator();

  Ogre::String secName;
  while (seci.hasMoreElements())
  {
   secName = seci.peekNextKey();
   Ogre::ConfigFile::SettingsMultiMap *settings = seci.getNext();

   Ogre::StringUtil::toLowerCase(secName);

   if (secName == "texture")
   {
    settings->find("file")->second.append("~" + groupName);
    _loadTexture(settings);
   }
   else if (Ogre::StringUtil::startsWith(secName, "font.", false))
   {
    Ogre::uint index = Ogre::StringConverter::parseUnsignedInt(secName.substr(5));
    GlyphData* glyphData = OGRE_NEW GlyphData();
    mGlyphData[index] = glyphData;

    _loadGlyphs(settings, glyphData);
    _loadKerning(settings, glyphData);
    _loadVerticalOffsets(settings, glyphData);
   }
   else if (secName == "sprites")
    _loadSprites(settings);
  }
 }

 void  TextureAtlas::_loadTexture(Ogre::ConfigFile::SettingsMultiMap* settings)
 {
  Ogre::String name, data;
  Ogre::ConfigFile::SettingsMultiMap::iterator i;
  for (i = settings->begin(); i != settings->end(); ++i)
  {
   name = i->first;
   data = i->second;

   size_t comment = data.find_first_of('#');
   if (comment != std::string::npos)
    data = data.substr(0, comment);

   Ogre::StringUtil::toLowerCase(name);

   // file texturename ~groupname
   // >  file myatlas.png
   // >  file myatlas.png ~loadinggroup
   if (name == "file")
   {
    Ogre::String textureName = data;
    Ogre::String groupName = Ogre::ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME;
    size_t groupSplit = data.find_first_of('~');
    if (groupSplit != std::string::npos)
    {
     textureName = data.substr(0, groupSplit);
     groupName = data.substr(groupSplit+1);
     Ogre::StringUtil::trim(textureName);
     Ogre::StringUtil::trim(groupName);
    }
#if OGRE_VERSION <= 67077 // If the version is less than or equal to 1.6.5
    mTexture = Ogre::TextureManager::getSingletonPtr()->getByName(data);
#else
    mTexture = Ogre::TextureManager::getSingletonPtr()->getByName(data, groupName);
#endif
    if (mTexture.isNull())
     mTexture = Ogre::TextureManager::getSingletonPtr()->load(textureName, groupName);

    mInverseTextureSize.x = 1.0f / mTexture->getWidth();
    mInverseTextureSize.y = 1.0f / mTexture->getHeight();

    continue;
   }
   // layer x y
   // >  layer 100 105
   else if (name == "whitepixel")
   {
    mWhitePixel = Ogre::StringConverter::parseVector2(data);
    mWhitePixel.x *= mInverseTextureSize.x;
    mWhitePixel.y *= mInverseTextureSize.y;
   }
  }
 }

 void  TextureAtlas::_loadGlyphs(Ogre::ConfigFile::SettingsMultiMap* settings, GlyphData* glyphData)
 {
  Ogre::String name, data;
  Ogre::ConfigFile::SettingsMultiMap::iterator i;

  Ogre::StringVector str_values;
  Ogre::Vector2  offset(0,0);
  for (i = settings->begin(); i != settings->end(); ++i)
  {
   name = i->first;
   data = i->second;

   size_t comment = data.find_first_of('#');
   if (comment != std::string::npos)
    data = data.substr(0, comment);

   Ogre::StringUtil::toLowerCase(name);

   // lineheight x y
   // >  offset 0 80
   if (name == "offset")
   {
    offset = Ogre::StringConverter::parseVector2(data);
    continue;
   }
   // lineheight lineheight
   // >  lineheight 15
   else if (name == "lineheight")
   {
    glyphData->mLineHeight = Ogre::StringConverter::parseReal(data);
    continue;
   }
   // spacelength spacelength
   // >  spacelength 3
   else if (name == "spacelength")
   {
    glyphData->mSpaceLength = Ogre::StringConverter::parseReal(data);
    continue;
   }
   // baseline baseline
   // >  baseline 3
   else if (name == "baseline")
   {
    glyphData->mBaseline = Ogre::StringConverter::parseReal(data);
    continue;
   }
   // linespacing linespacing
   // >  linespacing 2
   else if (name == "linespacing")
   {
    glyphData->mLineSpacing = Ogre::StringConverter::parseReal(data);
    continue;
   }
   // monowidth width
   // >  monowidth 3
   else if (name == "monowidth")
   {
    glyphData->mMonoWidth = Ogre::StringConverter::parseReal(data);
    continue;
   }
   // range lower upper
   // >  range 33 126
   else if (name == "range")
   {
    Ogre::Vector2 t = Ogre::StringConverter::parseVector2(data);
    glyphData->mRangeBegin = t.x;
    glyphData->mRangeEnd = t.y;
   }
   // kerning kerning
   // >  kerning -1
   else if (name == "letterspacing")
   {
    glyphData->mLetterSpacing = Ogre::StringConverter::parseReal(data);
   }
  }

  for (Ogre::uint index = glyphData->mRangeBegin; index <= glyphData->mRangeEnd; index++)
  {
   Glyph* glyph = OGRE_NEW Glyph();
   glyphData->mGlyphs.push_back(glyph);

   std::stringstream s;
   s << "glyph_" << index;

   i = settings->find(s.str());
   if (i == settings->end())
    continue;

   str_values = Ogre::StringUtil::split((*i).second, " ", 5);

   if (str_values.size() < 4)
   {
    //std::cout << "[Gorilla] Glyph #" << (*i).second << " does not have enough properties.\n";
    continue;
   }

   glyph->uvLeft    = offset.x + Ogre::StringConverter::parseReal(  str_values[0]  );
   glyph->uvTop     = offset.y + Ogre::StringConverter::parseReal(  str_values[1]  );
   glyph->uvWidth   = Ogre::StringConverter::parseReal(  str_values[2]  );
   glyph->uvHeight  = Ogre::StringConverter::parseReal(  str_values[3]  );
   glyph->uvRight   = glyph->uvLeft + glyph->uvWidth;
   glyph->uvBottom  = glyph->uvTop + glyph->uvHeight;

   if (str_values.size() == 5)
     glyph->glyphAdvance = Ogre::StringConverter::parseInt(  str_values[4]  );
   else
    glyph->glyphAdvance = glyph->uvWidth;
  }
 }

 void  TextureAtlas::_loadKerning(Ogre::ConfigFile::SettingsMultiMap* settings, GlyphData* glyphData)
 {
  Ogre::String left_name, data;
  Ogre::ConfigFile::SettingsMultiMap::iterator i;
  Ogre::uint left_glyph_id;
  Ogre::uint right_glyph_id;
  int kerning;
  Ogre::StringVector str_values;

  for (i = settings->begin(); i != settings->end(); ++i)
  {
   left_name = i->first;
   data = i->second;
   Ogre::StringUtil::toLowerCase(left_name);

   if (left_name.substr(0,6) != "kerning_")
    continue;

   size_t comment = data.find_first_of('#');
   if (comment != std::string::npos)
    data = data.substr(0, comment);

   left_name = left_name.substr(8); // chop of kerning_
   left_glyph_id = Ogre::StringConverter::parseUnsignedInt(left_name);

   str_values = Ogre::StringUtil::split(data, " ", 2);

   if (str_values.size() != 2)
   {
    //std::cout << "[Gorilla] Kerning Glyph #" << left_name << " does not have enough properties\n";
    continue;
   }

   right_glyph_id = Ogre::StringConverter::parseUnsignedInt(str_values[0]);
   kerning = Ogre::StringConverter::parseInt(str_values[1]);

   glyphData->mGlyphs[right_glyph_id - glyphData->mRangeBegin]->kerning.push_back(Kerning(left_glyph_id, kerning));
  }
 }

 void  TextureAtlas::_loadVerticalOffsets(Ogre::ConfigFile::SettingsMultiMap* settings, GlyphData* glyphData)
 {
  Ogre::String left_name, data;
  Ogre::ConfigFile::SettingsMultiMap::iterator i;
  Ogre::uint glyph_id;
  int verticalOffset;

  for (i = settings->begin(); i != settings->end(); ++i)
  {
   left_name = i->first;
   data = i->second;
   Ogre::StringUtil::toLowerCase(left_name);

   if (left_name.substr(0,15) != "verticaloffset_")
    continue;

   size_t comment = data.find_first_of('#');
   if (comment != std::string::npos)
    data = data.substr(0, comment);

   left_name = left_name.substr(15); // chop of verticalOffset_
   glyph_id = Ogre::StringConverter::parseUnsignedInt(left_name);

   verticalOffset = Ogre::StringConverter::parseInt(data);

   glyphData->getGlyph(glyph_id)->verticalOffset = verticalOffset;
  }
 }

 void  TextureAtlas::_loadSprites(Ogre::ConfigFile::SettingsMultiMap* settings)
 {
  Ogre::String sprite_name, data;
  Ogre::ConfigFile::SettingsMultiMap::iterator i;

  Ogre::StringVector str_values;
  for (i = settings->begin(); i != settings->end(); ++i)
  {
   sprite_name = i->first;
   data = i->second;

   size_t comment = data.find_first_of('#');
   if (comment != std::string::npos)
    data = data.substr(0, comment);

   str_values = Ogre::StringUtil::split(data, " ", 4);

   if (str_values.size() != 4)
   {
    //std::cout << "[Gorilla] Sprite #" << sprite_name << " does not have enough properties\n" << data << "\n";
    continue;
   }

   Sprite* sprite = OGRE_NEW Sprite();

   sprite->uvLeft = Ogre::StringConverter::parseUnsignedInt(str_values[0]);
   sprite->uvTop = Ogre::StringConverter::parseUnsignedInt(str_values[1]);
   sprite->spriteWidth = Ogre::StringConverter::parseUnsignedInt(str_values[2]);
   sprite->spriteHeight = Ogre::StringConverter::parseUnsignedInt(str_values[3]);

   mSprites[sprite_name] = sprite;
  }
 }

 Ogre::MaterialPtr TextureAtlas::createOrGet2DMasterMaterial()
 {
  Ogre::MaterialPtr d2Material = Ogre::MaterialManager::getSingletonPtr()->getByName("Gorilla2D");
  if (d2Material.isNull() == false)
  {
    Ogre::Pass* pass = d2Material->getTechnique(0)->getPass(0);

    if(pass->hasVertexProgram())
    {
      Ogre::GpuProgramPtr gpuPtr = pass->getVertexProgram();
      gpuPtr->load();
    }

    if(pass->hasFragmentProgram())
    {
      Ogre::GpuProgramPtr gpuPtr = pass->getFragmentProgram();
      gpuPtr->load();
    }

    return d2Material;
  }

  d2Material = Ogre::MaterialManager::getSingletonPtr()->create("Gorilla2D", Ogre::ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME);
  Ogre::Pass* pass = d2Material->getTechnique(0)->getPass(0);
  pass->setCullingMode(Ogre::CULL_NONE);
  pass->setDepthCheckEnabled(false);
  pass->setDepthWriteEnabled(false);
  pass->setLightingEnabled(false);
  pass->setSceneBlending(Ogre::SBT_TRANSPARENT_ALPHA);

  Ogre::TextureUnitState* texUnit = pass->createTextureUnitState();
  texUnit->setTextureAddressingMode(Ogre::TextureUnitState::TAM_CLAMP);
  texUnit->setTextureFiltering(Ogre::FO_NONE, Ogre::FO_NONE, Ogre::FO_NONE);

  return d2Material;
 }

 Ogre::MaterialPtr TextureAtlas::createOrGet3DMasterMaterial()
 {
  Ogre::MaterialPtr d3Material = Ogre::MaterialManager::getSingletonPtr()->getByName("Gorilla3D");
  if (d3Material.isNull() == false)
  {
    Ogre::Pass* pass = d3Material->getTechnique(0)->getPass(0);

    if(pass->hasVertexProgram())
    {
      Ogre::GpuProgramPtr gpuPtr = pass->getVertexProgram();
      gpuPtr->load();
    }

    if(pass->hasFragmentProgram())
    {
      Ogre::GpuProgramPtr gpuPtr = pass->getFragmentProgram();
      gpuPtr->load();
    }

    return d3Material;
  }

  d3Material = Ogre::MaterialManager::getSingletonPtr()->create("Gorilla3D", Ogre::ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME);
  Ogre::Pass* pass = d3Material->getTechnique(0)->getPass(0);
  pass->setCullingMode(Ogre::CULL_NONE);
  pass->setDepthCheckEnabled(false);
  pass->setDepthWriteEnabled(false);
  pass->setLightingEnabled(false);
  pass->setSceneBlending(Ogre::SBT_TRANSPARENT_ALPHA);

  Ogre::TextureUnitState* texUnit = pass->createTextureUnitState();
  texUnit->setTextureAddressingMode(Ogre::TextureUnitState::TAM_CLAMP);
  texUnit->setTextureFiltering(Ogre::FO_ANISOTROPIC, Ogre::FO_ANISOTROPIC, Ogre::FO_ANISOTROPIC);

  return d3Material;
 }

 void  TextureAtlas::_create2DMaterial()
 {
  std::string matName = "Gorilla2D." + mTexture->getName();
  m2DMaterial = Ogre::MaterialManager::getSingletonPtr()->getByName(matName);

  if (m2DMaterial.isNull())
   m2DMaterial = createOrGet2DMasterMaterial()->clone(matName);

  m2DPass = m2DMaterial->getTechnique(0)->getPass(0);
  m2DPass->getTextureUnitState(0)->setTextureName(mTexture->getName());
 }

 void  TextureAtlas::_create3DMaterial()
 {
  std::string matName = "Gorilla3D." + mTexture->getName();
  m3DMaterial = Ogre::MaterialManager::getSingletonPtr()->getByName(matName);

  if (m3DMaterial.isNull())
   m3DMaterial = createOrGet3DMasterMaterial()->clone(matName);

  m3DPass = m3DMaterial->getTechnique(0)->getPass(0);
  m3DPass->getTextureUnitState(0)->setTextureName(mTexture->getName());
 }

 void  TextureAtlas::_calculateCoordinates()
 {
  Ogre::RenderSystem* rs = Ogre::Root::getSingletonPtr()->getRenderSystem();

  Ogre::Real texelX =  rs->getHorizontalTexelOffset(),
             texelY =  rs->getVerticalTexelOffset();

  for (std::map<Ogre::uint, GlyphData*>::iterator gd_it = mGlyphData.begin(); gd_it != mGlyphData.end(); gd_it++)
  {
    for(std::vector<Glyph*>::iterator it = (*gd_it).second->mGlyphs.begin(); it != (*gd_it).second->mGlyphs.end(); it++)
    {
     (*it)->uvLeft        -= texelX;
     (*it)->uvTop         -= texelY;
     (*it)->uvRight       += texelX;
     (*it)->uvBottom      += texelY;

     (*it)->uvLeft        *= mInverseTextureSize.x;
     (*it)->uvTop         *= mInverseTextureSize.y;
     (*it)->uvRight       *= mInverseTextureSize.x;
     (*it)->uvBottom      *= mInverseTextureSize.y;

     (*it)->texCoords[TopLeft].x = (*it)->uvLeft;
     (*it)->texCoords[TopLeft].y = (*it)->uvTop;
     (*it)->texCoords[TopRight].x = (*it)->uvRight;
     (*it)->texCoords[TopRight].y = (*it)->uvTop;
     (*it)->texCoords[BottomRight].x = (*it)->uvRight;
     (*it)->texCoords[BottomRight].y = (*it)->uvBottom;
     (*it)->texCoords[BottomLeft].x = (*it)->uvLeft;
     (*it)->texCoords[BottomLeft].y = (*it)->uvBottom;

     (*it)->glyphWidth     = (*it)->uvWidth;
     (*it)->glyphHeight    = (*it)->uvHeight;
    }
  }

  for (std::map<Ogre::String, Sprite*>::iterator it = mSprites.begin(); it != mSprites.end(); it++)
  {
   (*it).second->uvRight    = (*it).second->uvLeft + (*it).second->spriteWidth;
   (*it).second->uvBottom   = (*it).second->uvTop  + (*it).second->spriteHeight;

   (*it).second->uvLeft    *= mInverseTextureSize.x;
   (*it).second->uvTop     *= mInverseTextureSize.y;
   (*it).second->uvRight   *= mInverseTextureSize.x;
   (*it).second->uvBottom  *= mInverseTextureSize.y;

   (*it).second->texCoords[TopLeft].x = (*it).second->uvLeft;
   (*it).second->texCoords[TopLeft].y = (*it).second->uvTop;
   (*it).second->texCoords[TopRight].x = (*it).second->uvRight;
   (*it).second->texCoords[TopRight].y = (*it).second->uvTop;
   (*it).second->texCoords[BottomRight].x = (*it).second->uvRight;
   (*it).second->texCoords[BottomRight].y = (*it).second->uvBottom;
   (*it).second->texCoords[BottomLeft].x = (*it).second->uvLeft;
   (*it).second->texCoords[BottomLeft].y = (*it).second->uvBottom;
  }
 }

 void   TextureAtlas::refreshMarkupColours()
 {
  mMarkupColour[0] = rgb(255, 255, 255);
  mMarkupColour[1] = rgb(0, 0, 0);
  mMarkupColour[2] = rgb(204, 204, 204);
  mMarkupColour[3] = rgb(254, 220, 129);
  mMarkupColour[4] = rgb(254, 138, 129);
  mMarkupColour[5] = rgb(123, 236, 110);
  mMarkupColour[6] = rgb(44,  192, 171);
  mMarkupColour[7] = rgb(199, 93,  142);
  mMarkupColour[8] = rgb(254, 254, 254);
  mMarkupColour[9] = rgb(13,  13,  13);
 }

 void   TextureAtlas::setMarkupColour(Ogre::uint index, const Ogre::ColourValue& colour)
 {
  if (index > 9)
   return;

  mMarkupColour[index] = colour;
 }

 Ogre::ColourValue  TextureAtlas::getMarkupColour(Ogre::uint index)
 {
  if (index > 9)
   return Ogre::ColourValue::White;

  return mMarkupColour[index];
 }

 GlyphData::GlyphData()
 : mRangeBegin(0),
   mRangeEnd(0),
   mSpaceLength(0),
   mLineHeight(0),
   mBaseline(0),
   mLineSpacing(0),
   mLetterSpacing(0),
   mMonoWidth(0)
 {
 }

 GlyphData::~GlyphData()
 {
  for (std::vector<Glyph*>::iterator it = mGlyphs.begin(); it != mGlyphs.end(); it++)
  {
   OGRE_DELETE (*it);
  }
 }

 Silverback::Silverback()
 {
  Ogre::Root::getSingletonPtr()->addFrameListener(this);
 }

 Silverback::~Silverback()
 {
  Ogre::Root::getSingletonPtr()->removeFrameListener(this);

  // Delete Screens.
  for (std::vector<Screen*>::iterator it = mScreens.begin(); it != mScreens.end(); it++)
   OGRE_DELETE (*it);

  mScreens.clear();

  // Delete Screens.
  for (std::vector<ScreenRenderable*>::iterator it = mScreenRenderables.begin(); it != mScreenRenderables.end(); it++)
   OGRE_DELETE (*it);

  mScreenRenderables.clear();

  // Delete Atlases.
  for (std::map<Ogre::String, TextureAtlas*>::iterator it = mAtlases.begin(); it != mAtlases.end(); it++)
   OGRE_DELETE (*it).second;
  mAtlases.clear();
 }

 void Silverback::loadAtlas(const Ogre::String &name, const Ogre::String &group)
 {
  TextureAtlas* atlas = OGRE_NEW TextureAtlas(name + ".gorilla", group);
  mAtlases[name] = atlas;
 }

 Screen* Silverback::createScreen(Ogre::Viewport* viewport, const Ogre::String& atlas_name)
 {
  TextureAtlas* atlas = (*mAtlases.find(atlas_name)).second;
  Screen* screen = OGRE_NEW Screen(viewport, atlas);
  mScreens.push_back(screen);
  return screen;
 }

 ScreenRenderable* Silverback::createScreenRenderable(const Ogre::Vector2& maxSize, const Ogre::String& atlas_name)
 {
  TextureAtlas* atlas = (*mAtlases.find(atlas_name)).second;
  ScreenRenderable* screen = OGRE_NEW ScreenRenderable(maxSize, atlas);
  mScreenRenderables.push_back(screen);
  return screen;
 }

 void Silverback::destroyScreen(Screen* screen)
 {
  if (screen == 0)
   return;

  mScreens.erase(std::find(mScreens.begin(), mScreens.end(), screen));
  OGRE_DELETE screen;
 }

 void Silverback::destroyScreenRenderable(ScreenRenderable* screen_renderables)
 {
  mScreenRenderables.erase(std::find(mScreenRenderables.begin(), mScreenRenderables.end(), screen_renderables));
  OGRE_DELETE screen_renderables;
 }

 bool Silverback::frameStarted(const Ogre::FrameEvent& evt)
 {
    (void)evt;
  for (std::vector<ScreenRenderable*>::iterator it = mScreenRenderables.begin(); it != mScreenRenderables.end(); it++)
   (*it)->frameStarted();

  return true;
 }

 LayerContainer::LayerContainer(TextureAtlas* atlas)
 : mIndexRedrawAll(false), mAtlas(atlas)
 {
 }

 LayerContainer::~LayerContainer()
 {
  for (std::vector<Layer*>::iterator it = mLayers.begin(); it != mLayers.end(); it++)
   OGRE_DELETE (*it);

  _destroyVertexBuffer();
 }

 Layer* LayerContainer::createLayer(Ogre::uint index)
 {
  Layer* layer = OGRE_NEW Layer(index, this);
  mLayers.push_back(layer);

  std::map<Ogre::uint, IndexData*>::iterator index_data = mIndexData.find( layer->getIndex() );
  if (index_data == mIndexData.end())
  {
   mIndexData[layer->getIndex()] = OGRE_NEW IndexData();
   index_data = mIndexData.find( layer->getIndex() );
  }

  (*index_data).second->mLayers.push_back( layer );
  (*index_data).second->mRedrawNeeded = true;

  mIndexRedrawNeeded = true;

  return layer;
 }

 /*! function. destroyLayer
     desc.
         Destroy a layer and it's contents.
 */
 void LayerContainer::destroy(Layer* layer)
 {
  if (layer == 0)
   return;

  std::map<Ogre::uint, IndexData*>::iterator index_data = mIndexData.find( layer->getIndex() );

  // Remove layer from index, and delete index if index is empty.
  if (index_data != mIndexData.end())
  {
   IndexData* indexData = (*index_data).second;
   indexData->mLayers.erase(std::find(indexData->mLayers.begin(), indexData->mLayers.end(), layer));
   indexData->mRedrawNeeded = true;
   mIndexRedrawNeeded = true;
   if (indexData->mLayers.size() == 0)
   {
    mIndexData.erase(index_data);
    OGRE_DELETE indexData;
   }
  }

  mLayers.erase(std::find(mLayers.begin(), mLayers.end(), layer));
  OGRE_DELETE layer;
 }

 void LayerContainer::_createVertexBuffer(size_t initialSize = 32)
 {
  mVertexBufferSize = initialSize * 6;
  mRenderOpPtr->vertexData = OGRE_NEW Ogre::VertexData;
  mRenderOpPtr->vertexData->vertexStart = 0;

  Ogre::VertexDeclaration* vertexDecl = mRenderOpPtr->vertexData->vertexDeclaration;
  size_t offset = 0;

  // Position.
  vertexDecl->addElement(0,0, Ogre::VET_FLOAT3, Ogre::VES_POSITION);
  offset += Ogre::VertexElement::getTypeSize(Ogre::VET_FLOAT3);

  // Colour
  vertexDecl->addElement(0, offset, Ogre::VET_FLOAT4, Ogre::VES_DIFFUSE);
  offset += Ogre::VertexElement::getTypeSize(Ogre::VET_FLOAT4);

  // Texture Coordinates
  vertexDecl->addElement(0, offset, Ogre::VET_FLOAT2, Ogre::VES_TEXTURE_COORDINATES);

  mVertexBuffer = Ogre::HardwareBufferManager::getSingletonPtr()
     ->createVertexBuffer(
         vertexDecl->getVertexSize(0),
         mVertexBufferSize,
         Ogre::HardwareBuffer::HBU_DYNAMIC_WRITE_ONLY_DISCARDABLE,
         false
     );

  mRenderOpPtr->vertexData->vertexBufferBinding->setBinding(0, mVertexBuffer);
  mRenderOpPtr->operationType = Ogre::RenderOperation::OT_TRIANGLE_LIST;
  mRenderOpPtr->useIndexes = false;
 }

 void LayerContainer::_destroyVertexBuffer()
 {
  OGRE_DELETE mRenderOpPtr->vertexData;
  mRenderOpPtr->vertexData = 0;
  mVertexBuffer.setNull();
  mVertexBufferSize = 0;
 }

 void LayerContainer::_resizeVertexBuffer(size_t requestedSize)
 {
  if (mVertexBufferSize == 0)
   _createVertexBuffer();

  if (requestedSize > mVertexBufferSize)
  {
   size_t newVertexBufferSize = 1;

   while(newVertexBufferSize < requestedSize)
    newVertexBufferSize <<= 1;

   mVertexBuffer = Ogre::HardwareBufferManager::getSingletonPtr()->createVertexBuffer(
     mRenderOpPtr->vertexData->vertexDeclaration->getVertexSize(0),
     newVertexBufferSize,
     Ogre::HardwareBuffer::HBU_DYNAMIC_WRITE_ONLY_DISCARDABLE,
     false
   );
   mVertexBufferSize = newVertexBufferSize;
   mRenderOpPtr->vertexData->vertexStart = 0;
   mRenderOpPtr->vertexData->vertexBufferBinding->setBinding(0, mVertexBuffer);
  }
 }

 void LayerContainer::_recalculateIndexes()
 {
  std::map<Ogre::uint, IndexData*>::iterator index_data;

  // Clear all index data.
  for(std::map< Ogre::uint, IndexData* >::iterator index_data = mIndexData.begin(); index_data != mIndexData.end(); index_data++)
  {
   (*index_data).second->mVertices.remove_all();
   (*index_data).second->mLayers.clear();
   (*index_data).second->mRedrawNeeded = false;
  }

  // Loop through layers, and add them to IndexData
  for(std::vector<Layer*>::iterator layer = mLayers.begin(); layer != mLayers.end(); layer++)
  {
   index_data = mIndexData.find( (*layer)->getIndex() );
   if (index_data == mIndexData.end())
   {
    mIndexData[(*layer)->getIndex()] = OGRE_NEW IndexData();
    index_data = mIndexData.find( (*layer)->getIndex() );
   }

   (*index_data).second->mLayers.push_back( (*layer) );
  }

  // Prune any index data that is not.
  bool deleted = false;

  while(!deleted)
  {
   deleted = false;
   for(std::map< Ogre::uint, IndexData* >::iterator index_data = mIndexData.begin(); index_data != mIndexData.end(); index_data++)
   {
    if (  (*index_data).second->mLayers.size() == 0)
    {
     OGRE_DELETE (*index_data).second;
     mIndexData.erase(index_data);
     deleted = true;
     break;
    }
   }

   if (!deleted)
    break;
  }

  mIndexRedrawAll = true;
 }

 void LayerContainer::_redrawIndex(Ogre::uint index, bool force)
 {
  std::map<Ogre::uint, IndexData*>::iterator it = mIndexData.find( index );
  if (it == mIndexData.end())
   return;

  IndexData* indexData = (*it).second;

  indexData->mVertices.remove_all();
  indexData->mRedrawNeeded = false;

  for (size_t i=0;i < indexData->mLayers.size();i++)
  {
   if (indexData->mLayers[i]->mVisible)
    indexData->mLayers[i]->_render( indexData->mVertices, force );
  }
 }

 void LayerContainer::_requestIndexRedraw(Ogre::uint index)
 {
  std::map<Ogre::uint, IndexData*>::iterator it = mIndexData.find( index );
  if (it == mIndexData.end())
   return;

  (*it).second->mRedrawNeeded = true;
  mIndexRedrawNeeded = true;
 }

 void LayerContainer::_redrawAllIndexes(bool force)
 {
  mIndexRedrawNeeded = false;
  for(std::map<Ogre::uint, IndexData*>::iterator it = mIndexData.begin(); it != mIndexData.end();it++)
  {
   IndexData* indexData = (*it).second;
   if (indexData->mRedrawNeeded || force)
   {
    //std::cout << "+++ Drawing Index: " << (*it).first;
    indexData->mVertices.remove_all();
    indexData->mRedrawNeeded = false;

    for (size_t i=0;i < indexData->mLayers.size();i++)
    {
     if (indexData->mLayers[i]->mVisible)
      indexData->mLayers[i]->_render( indexData->mVertices, force );
    }
   }
  }
 }

 void LayerContainer::_renderVertices(bool force)
 {
  if (mIndexRedrawNeeded == false)
   if (!force)
    return;

  _redrawAllIndexes(force);

  size_t knownVertexCount = 0;

  for(std::map<Ogre::uint, IndexData*>::iterator it = mIndexData.begin(); it != mIndexData.end();it++)
   knownVertexCount += (*it).second->mVertices.size();

  _resizeVertexBuffer(knownVertexCount);
  //std::cout << "+++ Known Vertex Count is: " << knownVertexCount << "\n";
  Vertex* writeIterator = (Vertex*) mVertexBuffer->lock(Ogre::HardwareBuffer::HBL_DISCARD);

  size_t i = 0;
  IndexData* indexData = 0;
  for(std::map<Ogre::uint, IndexData*>::iterator it = mIndexData.begin(); it != mIndexData.end();it++)
  {
   indexData = (*it).second;
   for (i=0;i < indexData->mVertices.size();i++)
   {
    *writeIterator++ = indexData->mVertices[i];
   }
  }

  mVertexBuffer->unlock();
  mRenderOpPtr->vertexData->vertexCount = knownVertexCount;
 }

 Screen::Screen(Ogre::Viewport* viewport, TextureAtlas* atlas)
 : LayerContainer(atlas), mViewport(viewport), mScale(1,1,1), mIsVisible(true), mCanRender(false)
 {
  mRenderOpPtr = &mRenderOp;
  mSceneMgr = mViewport->getCamera()->getSceneManager();

  mRenderSystem = Ogre::Root::getSingletonPtr()->getRenderSystem();

  mWidth = mViewport->getActualWidth();
  mHeight = mViewport->getActualHeight();
#if OGRE_NO_VIEWPORT_ORIENTATIONMODE == 0
  mOrientation = mViewport->getOrientationMode();
#else
  mOrientation = Ogre::OR_DEGREE_0;
  mOrientationChanged = false;
#endif

  mInvWidth = 1.0f / mWidth;
  mInvHeight = 1.0f / mHeight;

  mVertexTransform.makeTransform(Ogre::Vector3::ZERO, mScale, Ogre::Quaternion(1,0,0,0));

  mSceneMgr->addRenderQueueListener(this);
  _createVertexBuffer();
 }

 Screen::~Screen()
 {
  mSceneMgr->removeRenderQueueListener(this);
 }

 void Screen::renderQueueEnded(Ogre::uint8 queueGroupId, const Ogre::String& invocation, bool& repeatThisInvocation)
 {
    (void)invocation;
    (void)repeatThisInvocation;

  if (mRenderSystem->_getViewport() != mViewport || queueGroupId != SCREEN_RENDERQUEUE)
   return;
  if (mIsVisible && mLayers.size())
   renderOnce();
 }

 void Screen::_prepareRenderSystem()
 {
  mRenderSystem->_setWorldMatrix( Ogre::Matrix4::IDENTITY );
  mRenderSystem->_setProjectionMatrix( Ogre::Matrix4::IDENTITY );
  mRenderSystem->_setViewMatrix( Ogre::Matrix4::IDENTITY );
  mSceneMgr->_setPass(mAtlas->get2DPass());
 }

 void Screen::renderOnce()
 {
  bool force = false;
  // force == true if viewport size changed.
  if (mWidth != mViewport->getActualWidth() || mHeight != mViewport->getActualHeight()
#if OGRE_NO_VIEWPORT_ORIENTATIONMODE == 0
    || mOrientation != mViewport->getOrientationMode()
#else
    || mOrientationChanged
#endif
    )
  {
   mWidth = mViewport->getActualWidth();
   mHeight = mViewport->getActualHeight();

   mInvWidth = 1.0f / mWidth;
   mInvHeight = 1.0f / mHeight;

#if OGRE_NO_VIEWPORT_ORIENTATIONMODE == 0
   mOrientation = mViewport->getOrientationMode();
#else
   if (mOrientation == Ogre::OR_DEGREE_90 || mOrientation == Ogre::OR_DEGREE_270)
   {
    std::swap(mWidth, mHeight);
    std::swap(mInvWidth, mInvHeight);
   }
   mOrientationChanged = false;
#endif

   if (mOrientation == Ogre::OR_DEGREE_90)
    mVertexTransform.makeTransform(Ogre::Vector3::ZERO, mScale, Ogre::Quaternion(Ogre::Degree(90), Ogre::Vector3::UNIT_Z));
   else if (mOrientation == Ogre::OR_DEGREE_180)
     mVertexTransform.makeTransform(Ogre::Vector3::ZERO, mScale, Ogre::Quaternion(Ogre::Degree(180), Ogre::Vector3::UNIT_Z));
   else if (mOrientation == Ogre::OR_DEGREE_270)
     mVertexTransform.makeTransform(Ogre::Vector3::ZERO, mScale, Ogre::Quaternion(Ogre::Degree(270), Ogre::Vector3::UNIT_Z));
   else
     mVertexTransform.makeTransform(Ogre::Vector3::ZERO, mScale, Ogre::Quaternion(1,0,0,0));

   force = true;
  }

  _renderVertices(force);
  if (mRenderOp.vertexData->vertexCount)
  {
   _prepareRenderSystem();
   mRenderSystem->_render(mRenderOp);
  }
 }

 void  Screen::_transform(buffer<Vertex>& vertices, size_t begin, size_t end)
 {
  for (size_t i = begin; i < end; i++)
  {
   vertices[i].position.x = ((vertices[i].position.x) * mInvWidth) * 2 - 1;
   vertices[i].position.y = ((vertices[i].position.y) * mInvHeight) * -2 + 1;
  }

  if (mVertexTransform != Ogre::Matrix4::IDENTITY)
  {
   for (size_t i = begin; i < end; i++)
     vertices[i].position = mVertexTransform * vertices[i].position;
  }
 }

 ScreenRenderable::ScreenRenderable(const Ogre::Vector2& maxSize, TextureAtlas* atlas)
 : LayerContainer(atlas), mMaxSize(maxSize)
 {
  mRenderOpPtr = &mRenderOp;

  mBox.setInfinite();
  setMaterial(mAtlas->get3DMaterialName());

  _createVertexBuffer();
 }

 ScreenRenderable::~ScreenRenderable()
 {
 }

 void ScreenRenderable::frameStarted()
 {
  renderOnce();
 }

 void ScreenRenderable::renderOnce()
 {
  if (mIndexRedrawNeeded)
  {
   _renderVertices(false);
   calculateBoundingBox();
  }
 }

 void ScreenRenderable::calculateBoundingBox()
 {
  IndexData* indexData = 0;
  mBox.setExtents(0,0,0,0,0,0);
  size_t i = 0;
  for(std::map<Ogre::uint, IndexData*>::iterator it = mIndexData.begin(); it != mIndexData.end();it++)
  {
   indexData = (*it).second;
   for (i=0;i < indexData->mVertices.size();i++)
   {
    mBox.merge( indexData->mVertices[i].position );
   }
  }
  if (mBox.isNull() == false)
  {
   mBox.merge(Ogre::Vector3(0,0,-0.25f));
   mBox.merge(Ogre::Vector3(0,0, 0.25f));
  }

  Ogre::SceneNode* node = getParentSceneNode();
  if (node)
   node->_updateBounds();
 }

 void ScreenRenderable::_transform(buffer<Vertex>& vertices, size_t begin, size_t end)
 {
  Ogre::Vector2 halfSize = mMaxSize * 0.5;
  for (size_t i = begin; i < end; i++)
  {
   vertices[i].position.x = (vertices[i].position.x * 0.005f) - halfSize.x;
   vertices[i].position.y = (vertices[i].position.y * -0.005f) + halfSize.y;
  }
 }

 Layer::Layer(Ogre::uint index, LayerContainer* parent)
 : mIndex(index), mParent(parent), mVisible(true), mAlphaModifier(1.0f)
 {
 }

 Layer::~Layer()
 {
  destroyAllRectangles();
  destroyAllPolygons();
  destroyAllLineLists();
  destroyAllQuadLists();
  destroyAllCaptions();
  destroyAllMarkupTexts();
 }

 void Layer::_markDirty()
 {
  mParent->_requestIndexRedraw(mIndex);
 }

 Rectangle* Layer::createRectangle(Ogre::Real left, Ogre::Real top, Ogre::Real width, Ogre::Real height)
 {
  Rectangle* rectangle = OGRE_NEW Rectangle(left, top, width, height, this);
  mRectangles.push_back(rectangle);
  return rectangle;
 }

 void Layer::destroyRectangle(Rectangle* rectangle)
 {
  if (rectangle == 0)
   return;

  mRectangles.erase(std::find(mRectangles.begin(), mRectangles.end(), rectangle));
  OGRE_DELETE rectangle;
  _markDirty();
 }

 void Layer::destroyAllRectangles()
 {
  for (Rectangles::iterator it = mRectangles.begin(); it != mRectangles.end(); it++)
  {
   OGRE_DELETE (*it);
  }

  mRectangles.clear();
 }

 Polygon* Layer::createPolygon(Ogre::Real left, Ogre::Real top, Ogre::Real radius, Ogre::uint sides)
 {
  if (sides < 3)
   sides = 3;

  Polygon* polygon = OGRE_NEW Polygon(left, top, radius, sides, this);
  mPolygons.push_back(polygon);
  return polygon;
 }

 void Layer::destroyPolygon(Polygon* polygon)
 {
  if (polygon == 0)
   return;

  mPolygons.erase(std::find(mPolygons.begin(), mPolygons.end(), polygon));
  OGRE_DELETE polygon;
  _markDirty();
 }

 void Layer::destroyAllPolygons()
 {
  for (Polygons::iterator it = mPolygons.begin(); it != mPolygons.end(); it++)
  {
   OGRE_DELETE (*it);
  }

  mPolygons.clear();
 }

 LineList* Layer::createLineList()
 {
  LineList* linelist = OGRE_NEW LineList(this);
  mLineLists.push_back(linelist);
  return linelist;
 }

 void Layer::destroyLineList(LineList* linelist)
 {
  if (linelist == 0)
   return;

  mLineLists.erase(std::find(mLineLists.begin(), mLineLists.end(), linelist));
  OGRE_DELETE linelist;
  _markDirty();
 }

 void Layer::destroyAllLineLists()
 {
  for (LineLists::iterator it = mLineLists.begin(); it != mLineLists.end(); it++)
  {
   OGRE_DELETE (*it);
  }

  mLineLists.clear();
 }

 QuadList* Layer::createQuadList()
 {
  QuadList* quadlist = OGRE_NEW QuadList(this);
  mQuadLists.push_back(quadlist);
  return quadlist;
 }

 void Layer::destroyQuadList(QuadList* quadlist)
 {
  if (quadlist == 0)
   return;

  mQuadLists.erase(std::find(mQuadLists.begin(), mQuadLists.end(), quadlist));
  OGRE_DELETE quadlist;
  _markDirty();
 }

 void Layer::destroyAllQuadLists()
 {
  for (QuadLists::iterator it = mQuadLists.begin(); it != mQuadLists.end(); it++)
  {
   OGRE_DELETE (*it);
  }

  mQuadLists.clear();
 }

 Caption* Layer::createCaption(Ogre::uint glyphDataIndex, Ogre::Real x, Ogre::Real y, const Ogre::String& text)
 {
  Caption* caption = OGRE_NEW Caption(glyphDataIndex,x, y, text, this);
  mCaptions.push_back(caption);
  return caption;
 }

 void Layer::destroyCaption(Caption* caption)
 {
  if (caption == 0)
   return;

  mCaptions.erase(std::find(mCaptions.begin(), mCaptions.end(), caption));
  OGRE_DELETE caption;
  _markDirty();
 }

 void Layer::destroyAllCaptions()
 {
  for (Captions::iterator it = mCaptions.begin(); it != mCaptions.end(); it++)
  {
   OGRE_DELETE (*it);
  }

  mCaptions.clear();
 }

 MarkupText* Layer::createMarkupText(Ogre::uint defaultGlyphIndex, Ogre::Real x, Ogre::Real y, const Ogre::String& text)
 {
  MarkupText* markuptext = OGRE_NEW MarkupText(defaultGlyphIndex, x, y, text, this);
  mMarkupTexts.push_back(markuptext);
  return markuptext;
 }

 void Layer::destroyMarkupText(MarkupText* markuptext)
 {
  if (markuptext == 0)
   return;

  mMarkupTexts.erase(std::find(mMarkupTexts.begin(), mMarkupTexts.end(), markuptext));
  OGRE_DELETE markuptext;
  _markDirty();
 }

 void Layer::destroyAllMarkupTexts()
 {
  for (MarkupTexts::iterator it = mMarkupTexts.begin(); it != mMarkupTexts.end(); it++)
  {
   OGRE_DELETE (*it);
  }

  mMarkupTexts.clear();
 }

 void Layer::_render(buffer<Vertex>& vertices, bool force)
 {
  if (mAlphaModifier == 0.0f)
   return;

  size_t begin = vertices.size();
  size_t i = 0;

  // Render/redraw rectangles
  for (Rectangles::iterator it = mRectangles.begin(); it != mRectangles.end(); it++)
  {
   if ((*it)->mDirty || force)
    (*it)->_redraw();

   for (i=0; i < (*it)->mVertices.size(); i++)
    vertices.push_back((*it)->mVertices[i]);
  }

  // Render/redraw polygons
  for (Polygons::iterator it = mPolygons.begin(); it != mPolygons.end(); it++)
  {
   if ((*it)->mDirty || force)
    (*it)->_redraw();

   for (i=0; i < (*it)->mVertices.size(); i++)
    vertices.push_back((*it)->mVertices[i]);
  }

  // Render/redraw line lists
  for (LineLists::iterator it = mLineLists.begin(); it != mLineLists.end(); it++)
  {
   if ((*it)->mDirty || force)
    (*it)->_redraw();

   for (i=0; i < (*it)->mVertices.size(); i++)
    vertices.push_back((*it)->mVertices[i]);
  }

  // Render/redraw quad lists
  for (QuadLists::iterator it = mQuadLists.begin(); it != mQuadLists.end(); it++)
  {
   if ((*it)->mDirty || force)
    (*it)->_redraw();

   for (i=0; i < (*it)->mVertices.size(); i++)
    vertices.push_back((*it)->mVertices[i]);
  }

  // Render/redraw caption
  for (Captions::iterator it = mCaptions.begin(); it != mCaptions.end(); it++)
  {
   if ((*it)->mDirty || force)
    (*it)->_redraw();

   for (i=0; i < (*it)->mVertices.size(); i++)
    vertices.push_back((*it)->mVertices[i]);
  }

  // Render/redraw caption
  for (MarkupTexts::iterator it = mMarkupTexts.begin(); it != mMarkupTexts.end(); it++)
  {
   if ((*it)->mTextDirty || force)
    (*it)->_calculateCharacters();

   if ((*it)->mDirty || force)
    (*it)->_redraw();

   for (i=0; i < (*it)->mVertices.size(); i++)
    vertices.push_back((*it)->mVertices[i]);
  }

  if (mAlphaModifier != 1.0f)
  {
   for (i=begin;i < vertices.size();i++)
    vertices[i].colour.a *= mAlphaModifier;
  }

  mParent->_transform(vertices, begin, vertices.size());
 }

 Rectangle::Rectangle(Ogre::Real left, Ogre::Real top, Ogre::Real width, Ogre::Real height, Layer* layer) : mLayer(layer)
 {
  mDirty       = true;
  mLeft        = left;
  mTop         = top;
  mRight       = left + width;
  mBottom      = top + height;
  mBorderWidth = 0.0f;
  mBackgroundColour[0] = mBackgroundColour[1] =  mBackgroundColour[2] = mBackgroundColour[3] = Ogre::ColourValue::White;
  mUV[0] = mUV[1] = mUV[2] = mUV[3] = mLayer->_getSolidUV();
  mVisible     = true;
 }

 void  Rectangle::_redraw()
 {
  if (mDirty == false)
   return;

  mVertices.remove_all();

  if (!mVisible)
   return;

  Ogre::Real texelOffsetX = mLayer->_getTexelX(), texelOffsetY = mLayer->_getTexelY();
  Ogre::Vector2 a, b, c, d;
  a.x = mLeft  + texelOffsetX; a.y = mTop    + texelOffsetY;
  b.x = mRight + texelOffsetX; b.y = mTop    + texelOffsetY;
  c.x = mLeft  + texelOffsetX; c.y = mBottom + texelOffsetY;
  d.x = mRight + texelOffsetX; d.y = mBottom + texelOffsetY;

  // Border
  if (mBorderWidth != 0)
  {
    Ogre::Vector2 i = a, j = b, k = c, l = d;
    i.x -= mBorderWidth;    i.y -= mBorderWidth;
    j.x += mBorderWidth;    j.y -= mBorderWidth;
    k.x -= mBorderWidth;    k.y += mBorderWidth;
    l.x += mBorderWidth;    l.y += mBorderWidth;

    Vertex temp;
    Ogre::Vector2 uv = mLayer->_getSolidUV();

    // North
    PUSH_TRIANGLE(mVertices, temp, a, j, i, uv, mBorderColour[Border_North])
    PUSH_TRIANGLE(mVertices, temp, a, b, j, uv, mBorderColour[Border_North])

    // East
    PUSH_TRIANGLE(mVertices, temp, d, j, b, uv, mBorderColour[Border_East])
    PUSH_TRIANGLE(mVertices, temp, d, l, j, uv, mBorderColour[Border_East])

    // South
    PUSH_TRIANGLE(mVertices, temp, k, d, c, uv, mBorderColour[Border_South])
    PUSH_TRIANGLE(mVertices, temp, k, l, d, uv, mBorderColour[Border_South])

    // West
    PUSH_TRIANGLE(mVertices, temp, k, a, i, uv, mBorderColour[Border_West])
    PUSH_TRIANGLE(mVertices, temp, k, c, a, uv, mBorderColour[Border_West])
  }

  // Fill
  if (mBackgroundColour[0].a != 0)
  {
   Vertex temp;
   // Triangle A
   PUSH_VERTEX(mVertices, temp, c.x, c.y, mUV[3], mBackgroundColour[3]);    // Left/Bottom  3
   PUSH_VERTEX(mVertices, temp, b.x, b.y, mUV[1], mBackgroundColour[1]);    // Right/Top    1
   PUSH_VERTEX(mVertices, temp, a.x, a.y, mUV[0], mBackgroundColour[0]);    // Left/Top     0

   // Triangle B
   PUSH_VERTEX(mVertices, temp, c.x, c.y, mUV[3], mBackgroundColour[3]);    // Left/Bottom   3
   PUSH_VERTEX(mVertices, temp, d.x, d.y, mUV[2], mBackgroundColour[2]);    // Right/Bottom  2
   PUSH_VERTEX(mVertices, temp, b.x, b.y, mUV[1], mBackgroundColour[1]);    // Right/Top     1
  }

  mDirty = false;
 }

Polygon::Polygon(Ogre::Real left, Ogre::Real top, Ogre::Real radius, size_t sides, Layer* layer)
 : mLayer(layer), mSprite(0)
 {
  mDirty        = true;
  mLayer->_markDirty();
  mLeft           = left;
  mTop            = top;
  mRadius         = radius;
  mSides          = sides;
  mBackgroundColour         = Ogre::ColourValue::White;
  mBorderColour.a = 0;
  mBorderWidth    = 0;
 }

 void  Polygon::_redraw()
 {
  if (mDirty == false)
   return;

  mVertices.remove_all();
  Vertex temp;

  Ogre::Real theta = mAngle.valueRadians();
  Ogre::Real inc = (2 * Ogre::Math::PI) / Ogre::Real(mSides);

  Ogre::Vector2 lastVertex;
  lastVertex.x = mLeft + (mRadius * cos(theta));
  lastVertex.y = mTop + (mRadius * sin(theta));
  Ogre::Vector2 thisVertex;

  if (mBorderWidth != 0)
  {
   Ogre::Vector2 lastOuterVertex, outerVertex, thisVertex, uv;
   uv = mLayer->_getSolidUV();

   lastOuterVertex.x = mLeft + ((mRadius + mBorderWidth) * cos(theta));
   lastOuterVertex.y = mTop + ((mRadius + mBorderWidth) * sin(theta));

   for (size_t i=0;i < mSides;i++)
   {
    theta += inc;
    thisVertex.x = mLeft + (mRadius * Ogre::Math::Cos(theta));
    thisVertex.y = mTop + (mRadius * Ogre::Math::Sin(theta));
    outerVertex.x = mLeft + ((mRadius + mBorderWidth) * Ogre::Math::Cos(theta));
    outerVertex.y = mTop + ((mRadius + mBorderWidth) * Ogre::Math::Sin(theta));

    PUSH_TRIANGLE(mVertices, temp, lastVertex, outerVertex, lastOuterVertex, uv, mBorderColour);
    PUSH_TRIANGLE(mVertices, temp, lastVertex, thisVertex, outerVertex, uv, mBorderColour);

    lastVertex = thisVertex;
    lastOuterVertex = outerVertex;
   }
  }

  if (mBackgroundColour.a != 0)
  {
     if (mSprite)
     {
      Ogre::Real xRadius = mSprite->spriteWidth * 0.5f;
      Ogre::Real yRadius = mSprite->spriteHeight * 0.5f;

      Ogre::Vector2 centerUV, lastUV, thisUV, baseUV, texSize = mLayer->_getTextureSize();
      baseUV.x = mSprite->uvLeft * texSize.x;
      baseUV.y = mSprite->uvTop * texSize.y;
      baseUV.x += xRadius;
      baseUV.y += yRadius;

      centerUV = baseUV / texSize;
      lastUV = baseUV;
      lastUV.x = baseUV.x + (xRadius * Ogre::Math::Cos(theta));
      lastUV.y = baseUV.y + (yRadius * Ogre::Math::Sin(theta));
      lastUV /= texSize;

      for (size_t i=0;i < mSides;i++)
      {
       PUSH_VERTEX(mVertices, temp, mLeft, mTop, centerUV, mBackgroundColour);
       theta += inc;
       thisVertex.x = mLeft + (mRadius * Ogre::Math::Cos(theta));
       thisVertex.y = mTop + (mRadius * Ogre::Math::Sin(theta));
       thisUV.x = baseUV.x + (xRadius * Ogre::Math::Cos(theta));
       thisUV.y = baseUV.y + (yRadius * Ogre::Math::Sin(theta));
       thisUV /= texSize;
       PUSH_VERTEX(mVertices, temp, thisVertex.x, thisVertex.y, thisUV, mBackgroundColour);
       PUSH_VERTEX(mVertices, temp, lastVertex.x, lastVertex.y, lastUV, mBackgroundColour);
       lastVertex = thisVertex;
       lastUV = thisUV;
      }
     }
     else
     {
      Ogre::Vector2 uv = uv = mLayer->_getSolidUV();

      for (size_t i=0;i < mSides;i++)
      {
       PUSH_VERTEX(mVertices, temp, mLeft, mTop, uv, mBackgroundColour);
       theta += inc;
       thisVertex.x = mLeft + (mRadius * Ogre::Math::Cos(theta));
       thisVertex.y = mTop + (mRadius * Ogre::Math::Sin(theta));
       PUSH_VERTEX(mVertices, temp, thisVertex.x, thisVertex.y, uv, mBackgroundColour);
       PUSH_VERTEX(mVertices, temp, lastVertex.x, lastVertex.y, uv, mBackgroundColour);
       lastVertex = thisVertex;
      }
     }
  }

  mDirty = false;
 }

 LineList::LineList(Layer* layer) : mLayer(layer)
 {
  mDirty = false;
 }

 void  LineList::begin(Ogre::Real lineThickness, const Ogre::ColourValue& colour)
 {
  mDirty = false;
  mPositions.remove_all();
  mThickness = lineThickness;
  mColour = colour;
 }

 void  LineList::position(Ogre::Real x, Ogre::Real y)
 {
  mPositions.push_back(Ogre::Vector2(x,y));
 }

 void  LineList::position(const Ogre::Vector2& position)
 {
  mPositions.push_back(position);
 }

 void  LineList::end(bool closed)
 {
  mIsClosed = closed;
  mDirty = true;
 }

 void  LineList::_redraw()
 {
  if (mDirty == false)
   return;

  mVertices.remove_all();

  if (mPositions.size() < 2)
   return;

  Vertex temp;

  Ogre::Real halfThickness = mThickness * 0.5f;

  Ogre::Vector2 perp, lastLeft, lastRight, thisLeft, thisRight, uv = mLayer->_getSolidUV();

  size_t i = 1;

  for (;i < mPositions.size();i++)
  {
   perp      = (mPositions[i] - mPositions[i-1]).perpendicular().normalisedCopy();
   lastLeft  = mPositions[i-1] - perp * halfThickness;
   lastRight = mPositions[i-1] + perp * halfThickness;
   thisLeft  = mPositions[i] - perp * halfThickness;
   thisRight = mPositions[i] + perp * halfThickness;

   // Triangle A
   PUSH_VERTEX(mVertices, temp, lastRight.x, lastRight.y, uv, mColour);       // Left/Bottom
   PUSH_VERTEX(mVertices, temp, thisLeft.x, thisLeft.y, uv, mColour);         // Right/Top
   PUSH_VERTEX(mVertices, temp, lastLeft.x, lastLeft.y, uv, mColour);          // Left/Top
   // Triangle B
   PUSH_VERTEX(mVertices, temp, lastRight.x, lastRight.y, uv, mColour);       // Left/Bottom
   PUSH_VERTEX(mVertices, temp, thisRight.x, thisRight.y, uv, mColour);      // Right/Bottom
   PUSH_VERTEX(mVertices, temp, thisLeft.x, thisLeft.y, uv, mColour);         // Right/Top
  }

  if (mIsClosed)
  {
   i = mPositions.size() - 1;
   perp      = (mPositions[0] - mPositions[i]).perpendicular().normalisedCopy();
   lastLeft  = mPositions[i] - perp * halfThickness;
   lastRight = mPositions[i] + perp * halfThickness;
   thisLeft  = mPositions[0] - perp * halfThickness;
   thisRight = mPositions[0] + perp * halfThickness;

   // Triangle A
   PUSH_VERTEX(mVertices, temp, lastRight.x, lastRight.y, uv, mColour);       // Left/Bottom
   PUSH_VERTEX(mVertices, temp, thisLeft.x, thisLeft.y, uv, mColour);         // Right/Top
   PUSH_VERTEX(mVertices, temp, lastLeft.x, lastLeft.y, uv, mColour);          // Left/Top
   // Triangle B
   PUSH_VERTEX(mVertices, temp, lastRight.x, lastRight.y, uv, mColour);       // Left/Bottom
   PUSH_VERTEX(mVertices, temp, thisRight.x, thisRight.y, uv, mColour);      // Right/Bottom
   PUSH_VERTEX(mVertices, temp, thisLeft.x, thisLeft.y, uv, mColour);         // Right/Top
  }
 }

 QuadList::QuadList(Layer* layer)
 : mLayer(layer)
 {
  mWhiteUV = mLayer->_getSolidUV();
 }

 void  QuadList::begin()
 {
  mQuads.remove_all();
  mDirty = false;
 }

 void  QuadList::rectangle(Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, const Ogre::ColourValue colour)
 {
  Quad q;
  q.mPosition[TopLeft].x = x; q.mPosition[TopLeft].y = y;
  q.mPosition[TopRight].x = x + w; q.mPosition[TopRight].y = y;
  q.mPosition[BottomRight].x = x + w; q.mPosition[BottomRight].y = y + h;
  q.mPosition[BottomLeft].x = x; q.mPosition[BottomLeft].y = y + h;

  q.mColour[0] = q.mColour[1] = q.mColour[2] = q.mColour[3] = colour;
  q.mUV[0] = q.mUV[1] = q.mUV[2] = q.mUV[3] = mWhiteUV;
  mQuads.push_back(q);
 }

 void  QuadList::gradient(Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, Gradient gradient, const Ogre::ColourValue& colourA, const Ogre::ColourValue& colourB)
 {
  Quad q;
  if (gradient == Gradient_NorthSouth)
  {
   q.mColour[0] = q.mColour[1] = colourA;
   q.mColour[2] = q.mColour[3] = colourB;
  }
  else if (gradient == Gradient_WestEast)
  {
   q.mColour[0] = q.mColour[3] = colourA;
   q.mColour[1] = q.mColour[2] = colourB;
  }
  else if (gradient == Gradient_Diagonal)
  {
   Ogre::ColourValue avg;
   avg.r = (colourA.r + colourB.r) * 0.5f;
   avg.g = (colourA.g + colourB.g) * 0.5f;
   avg.b = (colourA.b + colourB.b) * 0.5f;
   avg.a = (colourA.a + colourB.a) * 0.5f;
   q.mColour[0] = colourA;
   q.mColour[1] = avg = q.mColour[3] = avg;
   q.mColour[2] = colourB;
  }

  q.mPosition[TopLeft].x = x; q.mPosition[TopLeft].y = y;
  q.mPosition[TopRight].x = x + w; q.mPosition[TopRight].y = y;
  q.mPosition[BottomRight].x = x + w; q.mPosition[BottomRight].y = y + h;
  q.mPosition[BottomLeft].x = x; q.mPosition[BottomLeft].y = y + h;

  q.mUV[0] = q.mUV[1] = q.mUV[2] = q.mUV[3] = mWhiteUV;
  mQuads.push_back(q);
 }

 void  QuadList::sprite(Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, Sprite* sprite)
 {
  Quad q;
  q.mPosition[TopLeft].x     = q.mPosition[BottomLeft].x    = x;
  q.mPosition[TopLeft].y     = q.mPosition[TopRight].y      = y;
  q.mPosition[TopRight].x    = q.mPosition[BottomRight].x   = x + w;
  q.mPosition[BottomRight].y = q.mPosition[BottomLeft].y    = y + h;
  q.mColour[0] = q.mColour[1] = q.mColour[2] = q.mColour[3] = Ogre::ColourValue::White;

  q.mUV[TopLeft].x = sprite->uvLeft;
  q.mUV[TopLeft].y = sprite->uvTop;

  q.mUV[TopRight].x = sprite->uvRight;
  q.mUV[TopRight].y = sprite->uvTop;

  q.mUV[BottomLeft].x = sprite->uvLeft;
  q.mUV[BottomLeft].y = sprite->uvBottom;

  q.mUV[BottomRight].x = sprite->uvRight;
  q.mUV[BottomRight].y = sprite->uvBottom;
  mQuads.push_back(q);
 }

 void  QuadList::border(Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, Ogre::Real thickness, const Ogre::ColourValue& colour)
 {
  border(x,y,w,h,thickness,colour,colour,colour,colour);
 }

void  QuadList::border(Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, Ogre::Real thickness, const Ogre::ColourValue& northColour, const Ogre::ColourValue& eastColour, const Ogre::ColourValue& southColour, const Ogre::ColourValue& westColour)
 {
  Ogre::Vector2 a(x,y), b(x+w,y), c(x,y+h), d(x+w,y+h),
                       i = a, j = b, k = c, l = d;
  i.x -= thickness;    i.y -= thickness;
  j.x += thickness;    j.y -= thickness;
  k.x -= thickness;    k.y += thickness;
  l.x += thickness;    l.y += thickness;

  Vertex temp;

  // North
  Quad q;
  q.mUV[0] = q.mUV[1] = q.mUV[2] = q.mUV[3] = mWhiteUV;

  // North
  q.mPosition[TopLeft] = i;
  q.mPosition[TopRight] = j;
  q.mPosition[BottomLeft] = a;
  q.mPosition[BottomRight] = b;
  q.mColour[0] = q.mColour[1] = q.mColour[2] = q.mColour[3] = northColour;
  mQuads.push_back(q);

  // East
  q.mPosition[TopLeft] = b;
  q.mPosition[TopRight] = j;
  q.mPosition[BottomLeft] = d;
  q.mPosition[BottomRight] = l;
  q.mColour[0] = q.mColour[1] = q.mColour[2] = q.mColour[3] = eastColour;
  mQuads.push_back(q);

  // South
  q.mPosition[TopLeft] = c;
  q.mPosition[TopRight] = d;
  q.mPosition[BottomLeft] = k;
  q.mPosition[BottomRight] = l;
  q.mColour[0] = q.mColour[1] = q.mColour[2] = q.mColour[3] = southColour;
  mQuads.push_back(q);

  // West
  q.mPosition[TopLeft] = i;
  q.mPosition[TopRight] = a;
  q.mPosition[BottomLeft] = k;
  q.mPosition[BottomRight] = c;
  q.mColour[0] = q.mColour[1] = q.mColour[2] = q.mColour[3] = westColour;
  mQuads.push_back(q);
 }

 void  QuadList::glyph(Ogre::uint glyphDataIndex, Ogre::Real x, Ogre::Real y, unsigned char character, const Ogre::ColourValue& colour)
 {
  GlyphData* glyphData = mLayer->_getGlyphData(glyphDataIndex);
  if (glyphData == 0)
  {
#if GORILLA_USES_EXCEPTIONS == 1
    OGRE_EXCEPT( Ogre::Exception::ERR_ITEM_NOT_FOUND, "Glyph data not found", __FUNC__ );
#else
    return;
#endif
  }

  Glyph* glyph = glyphData->getGlyph(character);
  if (glyph == 0)
   return;

  y += glyph->verticalOffset;

  Quad q;
  q.mPosition[TopLeft].x = x;
  q.mPosition[TopLeft].y = y;
  q.mPosition[TopRight].x = x + glyph->glyphWidth;
  q.mPosition[TopRight].y = y;
  q.mPosition[BottomRight].x = x + glyph->glyphWidth;
  q.mPosition[BottomRight].y = y + glyph->glyphHeight;
  q.mPosition[BottomLeft].x = x;
  q.mPosition[BottomLeft].y = y + glyph->glyphHeight;

  q.mColour[0] = q.mColour[1] = q.mColour[2] = q.mColour[3] = colour;

  q.mUV[TopLeft].x = glyph->uvLeft;
  q.mUV[TopLeft].y = glyph->uvTop;

  q.mUV[TopRight].x = glyph->uvRight;
  q.mUV[TopRight].y = glyph->uvTop;

  q.mUV[BottomRight].x = glyph->uvRight;
  q.mUV[BottomRight].y = glyph->uvBottom;

  q.mUV[BottomLeft].x = glyph->uvLeft;
  q.mUV[BottomLeft].y = glyph->uvBottom;

  mQuads.push_back(q);
 }

 void  QuadList::glyph(Ogre::uint glyphDataIndex, Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, unsigned char character, const Ogre::ColourValue& colour)
 {
  GlyphData* glyphData = mLayer->_getGlyphData(glyphDataIndex);
  if (glyphData == 0)
  {
#if GORILLA_USES_EXCEPTIONS == 1
    OGRE_EXCEPT( Ogre::Exception::ERR_ITEM_NOT_FOUND, "Glyph data not found", __FUNC__ );
#else
    return;
#endif
  }

  Glyph* glyph = glyphData->getGlyph(character);
  if (glyph == 0)
   return;

  y += glyph->verticalOffset;

  Quad q;
  q.mPosition[TopLeft].x = x;
  q.mPosition[TopLeft].y = y;
  q.mPosition[TopRight].x = x + w;
  q.mPosition[TopRight].y = y;
  q.mPosition[BottomRight].x = x + w;
  q.mPosition[BottomRight].y = y + h;
  q.mPosition[BottomLeft].x = x;
  q.mPosition[BottomLeft].y = y + h;

  q.mColour[0] = q.mColour[1] = q.mColour[2] = q.mColour[3] = colour;

  q.mUV[TopLeft].x = glyph->uvLeft;
  q.mUV[TopLeft].y = glyph->uvTop;

  q.mUV[TopRight].x = glyph->uvRight;
  q.mUV[TopRight].y = glyph->uvTop;

  q.mUV[BottomRight].x = glyph->uvRight;
  q.mUV[BottomRight].y = glyph->uvBottom;

  q.mUV[BottomLeft].x = glyph->uvLeft;
  q.mUV[BottomLeft].y = glyph->uvBottom;

  mQuads.push_back(q);
 }

 void  QuadList::end()
 {
  mDirty = true;
  mLayer->_markDirty();
 }

 void  QuadList::_redraw()
 {
  if (mDirty == false)
   return;

  mVertices.remove_all();
  Vertex temp;

  for (size_t i=0;i < mQuads.size();i++)
  {
   PUSH_QUAD(mVertices, temp, mQuads[i].mPosition, mQuads[i].mColour, mQuads[i].mUV)
  }

  mDirty = false;
 }

 Caption::Caption(Ogre::uint glyphDataIndex, Ogre::Real left, Ogre::Real top, const Ogre::String& caption, Layer* layer)
 : mLayer(layer)
 {
  mGlyphData      = mLayer->_getGlyphData(glyphDataIndex);
  if (mGlyphData == 0)
  {
    mDirty        = false;
#if GORILLA_USES_EXCEPTIONS == 1
    OGRE_EXCEPT( Ogre::Exception::ERR_ITEM_NOT_FOUND, "Glyph data not found", __FUNC__ );
#else
    return;
#endif
  }
  mDirty        = true;
  mLayer->_markDirty();
  mLeft           = left;
  mTop            = top;
  mWidth          = 0.0f;
  mHeight         = 0.0f;
  mText           = caption;
  mColour         = Ogre::ColourValue::White;
  mBackground.a   = 0.0f;
  mAlignment      = TextAlign_Left;
  mVerticalAlign  = VerticalAlign_Top;
  mFixedWidth     = false;
  mVisible        = true;
 }

 void Caption::_calculateDrawSize(Ogre::Vector2& retSize)
 {
  Ogre::Real cursor = 0,
             kerning = 0;

  unsigned char thisChar = 0, lastChar = 0;
  Glyph* glyph = 0;
  retSize.x = 0;
  retSize.y = mGlyphData->mLineHeight;

  for (size_t i=0;i < mText.length();i++)
  {
   thisChar = mText[i];

   if (thisChar == ' ')
   {
    lastChar = thisChar;
    cursor += mGlyphData->mSpaceLength;
    continue;
   }

   if (  thisChar < mGlyphData->mRangeBegin || thisChar > mGlyphData->mRangeEnd  )
   {
    lastChar = 0;
    continue;
   }

   glyph = mGlyphData->getGlyph(thisChar);
   if (glyph == 0)
    continue;
   kerning = glyph->getKerning(lastChar);
   if (kerning == 0)
    kerning = mGlyphData->mLetterSpacing;

   cursor  += _getAdvance(glyph, kerning);
   lastChar = thisChar;
  } // for

  retSize.x = cursor - kerning;
 }

 void Caption::_redraw()
 {
  if (mDirty == false)
   return;

  mVertices.remove_all();

  if (!mVisible)
   return;

  Ogre::Vector2 uv = mLayer->_getSolidUV();

  if (mBackground.a > 0)
  {
   Ogre::Vector2  a, b, c, d;
   a.x = mLeft;  a.y = mTop;
   b.x = mLeft + mWidth; b.y = mTop;
   c.x = mLeft;  c.y = mTop + mHeight;
   d.x = mLeft + mWidth; d.y = c.y = mTop + mHeight;
   Vertex temp;
   PUSH_TRIANGLE(mVertices, temp, c, b, a, uv, mBackground);
   PUSH_TRIANGLE(mVertices, temp, c, d, b, uv, mBackground);
  }

  Ogre::Real left = 0, top = 0, right = 0, bottom = 0, cursorX = 0, cursorY = 0, kerning = 0, texelOffsetX = mLayer->_getTexelX(), texelOffsetY = mLayer->_getTexelY();
  Ogre::Vector2 knownSize;
  Glyph* glyph = 0;

  bool clipLeft = false, clipRight = false;
  Ogre::Real clipLeftPos = 0, clipRightPos = 0;

  if (mAlignment == TextAlign_Left)
  {
   cursorX = mLeft;

   if (mWidth)
   {
    clipRight = true;
    clipRightPos = mLeft + mWidth;
   }
  }
  else if (mAlignment == TextAlign_Centre)
  {
   _calculateDrawSize(knownSize);
   cursorX = mLeft + (mWidth * 0.5f) - (knownSize.x * 0.5f);

   if (mWidth)
   {
    clipLeft = true;
    clipLeftPos = mLeft;
    clipRight = true;
    clipRightPos = mLeft + mWidth;
   }
  }
  else if (mAlignment == TextAlign_Right)
  {
   _calculateDrawSize(knownSize);
   cursorX = mLeft + mWidth - knownSize.x;
   if (mWidth)
   {
    clipLeft = true;
    clipLeftPos = mLeft;
   }
  }

  if (mVerticalAlign == VerticalAlign_Top)
   cursorY = mTop;
  else if (mVerticalAlign == VerticalAlign_Middle)
   cursorY = mTop + (mHeight * 0.5) - (mGlyphData->mLineHeight * 0.5);
  else if (mVerticalAlign == VerticalAlign_Bottom)
   cursorY = mTop +  mHeight - mGlyphData->mLineHeight;

  unsigned char thisChar = 0, lastChar = 0;
  Vertex temp;
  mClippedLeftIndex = std::string::npos;
  mClippedRightIndex = std::string::npos;

  cursorX = Ogre::Math::Floor( cursorX );
  cursorY = Ogre::Math::Floor( cursorY );

  for (size_t i=0;i < mText.size();i++)
  {
   thisChar = mText[i];

   if (thisChar == ' ')
   {
    lastChar = thisChar;
    cursorX += mGlyphData->mSpaceLength;
    continue;
   }

   if (  thisChar < mGlyphData->mRangeBegin || thisChar > mGlyphData->mRangeEnd  )
   {
    lastChar = 0;
    continue;
   }

   glyph = mGlyphData->getGlyph(thisChar);
   if (glyph == 0)
    continue;
   kerning = glyph->getKerning(lastChar);
   if (kerning == 0)
    kerning = mGlyphData->mLetterSpacing;

   left = cursorX - texelOffsetX;
   top = cursorY - texelOffsetY + glyph->verticalOffset;
   right = left + glyph->glyphWidth + texelOffsetX;
   bottom = top + glyph->glyphHeight + texelOffsetY;

   if (clipLeft)
   {
    if (left < clipLeftPos)
    {
     if (mClippedLeftIndex == std::string::npos)
       mClippedLeftIndex = i;
     cursorX  += _getAdvance(glyph, kerning);
     lastChar = thisChar;
     continue;
    }
   }

   if (clipRight)
   {
    if (right > clipRightPos)
    {
     if (mClippedRightIndex == std::string::npos)
       mClippedRightIndex = i;
     cursorX  += _getAdvance(glyph, kerning);
     lastChar = thisChar;
     continue;
    }
   }

   if(fixedWidth())
   {
     Ogre::Real offset = std::floor((mGlyphData->mMonoWidth - glyph->glyphWidth) / 2.0f);
     left += offset;
     right += offset;
   }

   // Triangle A
   PUSH_VERTEX(mVertices, temp, left, bottom, glyph->texCoords[BottomLeft], mColour);  // Left/Bottom  3
   PUSH_VERTEX(mVertices, temp, right, top, glyph->texCoords[TopRight], mColour);    // Right/Top    1
   PUSH_VERTEX(mVertices, temp, left, top, glyph->texCoords[TopLeft], mColour);     // Left/Top     0

   // Triangle B
   PUSH_VERTEX(mVertices, temp, left, bottom, glyph->texCoords[BottomLeft], mColour);  // Left/Bottom  3
   PUSH_VERTEX(mVertices, temp, right, bottom, glyph->texCoords[BottomRight], mColour); // Right/Bottom 2
   PUSH_VERTEX(mVertices, temp, right, top, glyph->texCoords[TopRight], mColour);    // Right/Top    1

   cursorX  += _getAdvance(glyph, kerning);
   lastChar = thisChar;
  } // for

  mDirty = false;
 }

 Ogre::Real Caption::_getAdvance(Glyph* glyph, Ogre::Real kerning)
 {
   if(mFixedWidth)
     return mGlyphData->mMonoWidth;
   else
     return glyph->glyphAdvance + kerning;
 }

 MarkupText::MarkupText(Ogre::uint defaultGlyphIndex, Ogre::Real left, Ogre::Real top, const Ogre::String& text, Layer* parent)
 : mLayer(parent)
 {
  mDefaultGlyphData = mLayer->_getGlyphData(defaultGlyphIndex);

  if (mDefaultGlyphData == 0)
  {
   mDirty          = false;
   mTextDirty      = false;
#if GORILLA_USES_EXCEPTIONS == 1
    OGRE_EXCEPT( Ogre::Exception::ERR_ITEM_NOT_FOUND, "Glyph data not found", __FUNC__ );
#else
    return;
#endif
  }

  mDirty          = true;
  mTextDirty      = true;
  mLayer->_markDirty();
  mLeft           = left;
  mTop            = top;
  mWidth          = 0.0f;
  mHeight         = 0.0f;
  mText           = text;
  mBackground.a   = 0.0f;
  mVisible        = true;
 }

 void MarkupText::_calculateCharacters()
 {
  if (mTextDirty == false)
   return;

  Ogre::Real cursorX = mLeft, cursorY = mTop, kerning = 0, texelOffsetX = mLayer->_getTexelX(), texelOffsetY = mLayer->_getTexelY(), right = 0, bottom = 0, left = 0, top = 0;
  unsigned int thisChar = 0, lastChar = 0;

  bool clipRight = false, clipBottom = false;
  Ogre::Real clipRightPos = 0, clipBottomPos = 0;

  if (mWidth)
  {
   clipRight = true;
   clipRightPos = mLeft + mWidth;
  }

  if (mHeight)
  {
   clipBottom = true;
   clipBottomPos = mTop + mHeight;
  }

  Glyph* glyph = 0;

  mMaxTextWidth = 0;

  mCharacters.remove_all();

  bool markupMode = false;
  Ogre::ColourValue colour = mLayer->_getMarkupColour(0);
  bool fixedWidth = false;

  GlyphData* glyphData = mDefaultGlyphData;
  Ogre::Real lineHeight = glyphData->mLineHeight;

  for(size_t i=0;i < mText.length();i++)
  {
   thisChar = mText[i];

   if (thisChar == ' ')
   {
    lastChar = thisChar;
    cursorX += glyphData->mSpaceLength;
    continue;
   }

   if (thisChar == '\n')
   {
    lastChar = thisChar;
    cursorX = mLeft;
    cursorY += lineHeight;
    lineHeight = glyphData->mLineHeight;
    continue;
   }

   if (  thisChar < glyphData->mRangeBegin || thisChar > glyphData->mRangeEnd  )
   {
    lastChar = 0;
    continue;
   }

   if (thisChar == '%' && markupMode == false)
   {
    markupMode = true;
    continue;
   }

   if (markupMode == true)
   {
    if (thisChar == '%')
    {
     // Escape Character.
    }
    else
    {
     markupMode = false;

     if (thisChar >= '0' && thisChar <= '9')
     {
      colour = mLayer->_getMarkupColour(thisChar - 48);
     }
     else if (thisChar == 'R' || thisChar == 'r')
     {
      colour = mLayer->_getMarkupColour(0);
     }
     else if (thisChar == 'M' || thisChar == 'm')
     {
      fixedWidth = !fixedWidth;
     }
     else if (thisChar == '@')
     {
      markupMode = false;
      bool foundIt = false;
      size_t begin = i;
      while(i < mText.size())
      {
       if (mText[i] == '%')
       {
        foundIt = true;
        break;
       }
       i++;
      }

      if (foundIt == false)
       return;

      Ogre::uint index = Ogre::StringConverter::parseUnsignedInt(mText.substr(begin+1, i - begin - 1));
      glyphData = mLayer->_getGlyphData(index);
      if (glyphData == 0)
       return;
      lineHeight = std::max(lineHeight, glyphData->mLineHeight);
      continue;
     }
     else if (thisChar == ':')
     {
      markupMode = false;
      bool foundIt = false;
      size_t begin = i;
      while(i < mText.size())
      {
       if (mText[i] == '%')
       {
        foundIt = true;
        break;
       }
       i++;
      }

      if (foundIt == false)
       return;

      Ogre::String sprite_name = mText.substr(begin+1, i - begin - 1);

      Sprite* sprite = mLayer->_getSprite(sprite_name);
      if (sprite == 0)
       continue;

      left = cursorX - texelOffsetX;
      top = cursorY - texelOffsetY + glyph->verticalOffset;
      right = left + sprite->spriteWidth + texelOffsetX;
      bottom = top + sprite->spriteHeight + texelOffsetY;

      bool shouldClip = false;

      if (clipRight)
      {
        shouldClip |= cursorX + sprite->spriteWidth > clipRightPos;
      }

      if (clipBottom)
      {
        shouldClip |= cursorY + sprite->spriteHeight > clipBottomPos;
      }

      if (!shouldClip)
      {
       Character c;
       c.mIndex = i;
       c.mPosition[TopLeft].x = left;
       c.mPosition[TopLeft].y = top;
       c.mPosition[TopRight].x = right;
       c.mPosition[TopRight].y = top;
       c.mPosition[BottomLeft].x = left;
       c.mPosition[BottomLeft].y = bottom;
       c.mPosition[BottomRight].x = right;
       c.mPosition[BottomRight].y = bottom;
       c.mUV[0] = sprite->texCoords[0];
       c.mUV[1] = sprite->texCoords[1];
       c.mUV[2] = sprite->texCoords[2];
       c.mUV[3] = sprite->texCoords[3];
       c.mColour = colour;

       mCharacters.push_back(c);
      }

      cursorX  += sprite->spriteWidth;

      lineHeight = std::max(lineHeight, sprite->spriteHeight);

      continue;
     }

     continue;
    }
    markupMode = false;
   }

   glyph = glyphData->getGlyph(thisChar);

   if (!fixedWidth)
   {
    kerning = glyph->getKerning(lastChar);
    if (kerning == 0)
     kerning = glyphData->mLetterSpacing;
   }

   left = cursorX;
   top = cursorY + glyph->verticalOffset;
   right = cursorX + glyph->glyphWidth + texelOffsetX;
   bottom = top + glyph->glyphHeight + texelOffsetY;

   if (fixedWidth)
   {
     Ogre::Real offset = std::floor((glyphData->mMonoWidth - glyph->glyphWidth) / 2.0f);
     left += offset;
     right += offset;
   }

   bool shouldClip = false;

   if (clipRight)
   {
     if (fixedWidth)
      shouldClip |= cursorX + glyphData->mMonoWidth > clipRightPos;
     else
      shouldClip |= cursorX + glyph->glyphAdvance + kerning > clipRightPos;
   }

   if (clipBottom)
   {
    shouldClip |= cursorY + lineHeight > clipBottomPos;
   }

   if (!shouldClip)
   {
     Character c;
     c.mIndex = i;
     c.mPosition[TopLeft].x = left;
     c.mPosition[TopLeft].y = top;
     c.mPosition[TopRight].x = right;
     c.mPosition[TopRight].y = top;
     c.mPosition[BottomLeft].x = left;
     c.mPosition[BottomLeft].y = bottom;
     c.mPosition[BottomRight].x = right;
     c.mPosition[BottomRight].y = bottom;
     c.mUV[0] = glyph->texCoords[0];
     c.mUV[1] = glyph->texCoords[1];
     c.mUV[2] = glyph->texCoords[2];
     c.mUV[3] = glyph->texCoords[3];
     c.mColour = colour;

     mCharacters.push_back(c);
   }

   if (fixedWidth)
     cursorX  += glyphData->mMonoWidth;
   else
     cursorX  += glyph->glyphAdvance + kerning;

   if( cursorX > mMaxTextWidth )
       mMaxTextWidth = cursorX;

   lastChar = thisChar;
  }

  mMaxTextWidth -= mLeft;

  mTextDirty = false;
 }

 void  MarkupText::_redraw()
 {
  if (mDirty == false)
   return;

  mVertices.remove_all();

  if (!mVisible)
   return;

  Vertex temp;
  for (size_t i=0; i < mCharacters.size();i++)
  {
   PUSH_QUAD2(mVertices, temp, mCharacters[i].mPosition, mCharacters[i].mColour, mCharacters[i].mUV);
  }

  mDirty = false;
 }
} // namespace Gorilla