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

#ifndef GORILLA_H
#define GORILLA_H

#include <iterator>

#include "ogre3d/include/OgreCamera.h"
#include "ogre3d/include/OgreColourValue.h"
#include "ogre3d/include/OgreConfigFile.h"
#include "ogre3d/include/OgreFrameListener.h"
#include "ogre3d/include/OgreFrustum.h"
#include "ogre3d/include/OgreHardwareBufferManager.h"
#include "ogre3d/include/OgreHardwareVertexBuffer.h"
#include "ogre3d/include/OgreMaterial.h"
#include "ogre3d/include/OgrePrerequisites.h"
#include "ogre3d/include/OgreRenderQueueListener.h"
#include "ogre3d/include/OgreRenderSystem.h"
#include "ogre3d/include/OgreResourceManager.h"
#include "ogre3d/include/OgreRoot.h"
#include "ogre3d/include/OgreSimpleRenderable.h"
#include "ogre3d/include/OgreSingleton.h"
#include "ogre3d/include/OgreTechnique.h"
#include "ogre3d/include/OgreTexture.h"
#include "ogre3d/include/OgreVector2.h"
#include "ogre3d/include/OgreVector3.h"

#ifndef GORILLA_USES_EXCEPTIONS
#  define GORILLA_USES_EXCEPTIONS 0
#endif

#if OGRE_COMP == OGRE_COMPILER_GNUC
#   define __FUNC__ __PRETTY_FUNCTION__
#elif OGRE_COMP != OGRE_COMPILER_BORL
#   define __FUNC__ "No function name info"
#endif

namespace Gorilla
{
 class Silverback;
 class TextureAtlas;
 class LayerContainer;
 class Screen;
 class ScreenRenderable;
 class Layer;
 class Rectangle;
 class Polygon;
 class LineList;
 class QuadList;
 class Caption;
 class MarkupText;

 template<typename T> struct VectorType
 {
#if OGRE_VERSION <= 67077 // If the version is less than or equal to 1.6.5
  typedef std::vector<T> type;
#else
  typedef typename Ogre::vector<T>::type type;
#endif
 };

 namespace Colours
 {
  enum Colour
  {
   None = 0, // No Colour.
   AliceBlue=0xf0f8ff,      Gainsboro=0xdcdcdc,            MistyRose=0xffe4e1,
   AntiqueWhite=0xfaebd7,   GhostWhite=0xf8f8ff,           Moccasin=0xffe4b5,
   Aqua=0x00ffff,           Gold=0xffd700,                 NavajoWhite=0xffdead,
   Aquamarine=0x7fffd4,     Goldenrod=0xdaa520,            Navy=0x000080,
   Azure=0xf0ffff,          Gray=0x808080,                 OldLace=0xfdf5e6,
   Beige=0xf5f5dc,          Green=0x008000,                Olive=0x808000,
   Bisque=0xffe4c4,         GreenYellow=0xadff2f,          OliveDrab=0x6b8e23,
   Black=0x000000,          Grey=0x808080,                 Orange=0xffa500,
   BlanchedAlmond=0xffebcd, Honeydew=0xf0fff0,             OrangeRed=0xff4500,
   Blue=0x0000ff,           HotPink=0xff69b4,              Orchid=0xda70d6,
   BlueViolet=0x8a2be2,     IndianRed=0xcd5c5c,            PaleGoldenrod=0xeee8aa,
   Brown=0xa52a2a,          Indigo=0x4b0082,               PaleGreen=0x98fb98,
   Burlywood=0xdeb887,      Ivory=0xfffff0,                PaleTurquoise=0xafeeee,
   CadetBlue=0x5f9ea0,      Khaki=0xf0e68c,                PaleVioletRed=0xdb7093,
   Chartreuse=0x7fff00,     Lavender=0xe6e6fa,             PapayaWhip=0xffefd5,
   Chocolate=0xd2691e,      LavenderBlush=0xfff0f5,        PeachPuff=0xffdab9,
   Coral=0xff7f50,          LawnGreen=0x7cfc00,            Peru=0xcd853f,
   CornflowerBlue=0x6495ed, LemonChiffon=0xfffacd,         Pink=0xffc0cb,
   Cornsilk=0xfff8dc,       LightBlue=0xadd8e6,            Plum=0xdda0dd,
   Crimson=0xdc143c,        LightCoral=0xf08080,           PowderBlue=0xb0e0e6,
   Cyan=0x00ffff,           LightCyan=0xe0ffff,            Purple=0x800080,
   DarkBlue=0x00008b,       LightGoldenrodyellow=0xfafad2, Red=0xff0000,
   DarkCyan=0x008b8b,       LightGray=0xd3d3d3,            RosyBrown=0xbc8f8f,
   DarkGoldenrod=0xb8860b,  LightGreen=0x90ee90,           RoyalBlue=0x4169e1,
   DarkGray=0xa9a9a9,       LightGrey=0xd3d3d3,            SaddleBrown=0x8b4513,
   DarkGreen=0x006400,      LightPink=0xffb6c1,            Salmon=0xfa8072,
   DarkGrey=0xa9a9a9,       LightSalmon=0xffa07a,          SandyBrown=0xf4a460,
   DarkKhaki=0xbdb76b,      LightSeagreen=0x20b2aa,        SeaGreen=0x2e8b57,
   DarkMagenta=0x8b008b,    LightSkyblue=0x87cefa,         SeaShell=0xfff5ee,
   DarkOlivegreen=0x556b2f, LightSlategray=0x778899,       Sienna=0xa0522d,
   DarkOrange=0xff8c00,     LightSlategrey=0x778899,       Silver=0xc0c0c0,
   DarkOrchid=0x9932cc,     LightSteelblue=0xb0c4de,       SkyBlue=0x87ceeb,
   DarkRed=0x8b0000,        LightYellow=0xffffe0,          SlateBlue=0x6a5acd,
   DarkSalmon=0xe9967a,     Lime=0x00ff00,                 SlateGray=0x708090,
   DarkSeagreen=0x8fbc8f,   LimeGreen=0x32cd32,            SlateGrey=0x708090,
   DarkSlateblue=0x483d8b,  Linen=0xfaf0e6,                Snow=0xfffafa,
   DarkSlategray=0x2f4f4f,  Magenta=0xff00ff,              SpringGreen=0x00ff7f,
   DarkSlategrey=0x2f4f4f,  Maroon=0x800000,               SteelBlue=0x4682b4,
   DarkTurquoise=0x00ced1,  MediumAquamarine=0x66cdaa,     Tan=0xd2b48c,
   DarkViolet=0x9400d3,     MediumBlue=0x0000cd,           Teal=0x008080,
   DeepPink=0xff1493,       MediumOrchid=0xba55d3,         Thistle=0xd8bfd8,
   DeepSkyblue=0x00bfff,    MediumPurple=0x9370db,         Tomato=0xff6347,
   DimGray=0x696969,        MediumSeaGreen=0x3cb371,       Turquoise=0x40e0d0,
   DimGrey=0x696969,        MediumSlateBlue=0x7b68ee,      Violet=0xee82ee,
   DodgerBlue=0x1e90ff,     MediumSpringGreen=0x00fa9a,    Wheat=0xf5deb3,
   FireBrick=0xb22222,      MediumTurquoise=0x48d1cc,      White=0xffffff,
   FloralWhite=0xfffaf0,    MediumBioletRed=0xc71585,      WhiteSmoke=0xf5f5f5,
   ForestGreen=0x228b22,    MidnightBlue=0x191970,         Yellow=0xffff00,
   Fuchsia=0xff00ff,        MintCream=0xf5fffa,            YellowGreen=0x9acd32
  }; // Colour
 } // namespace Colours

 /*! function. rgb
     desc.
         Convert three/four RGBA values into an Ogre::ColourValue
 */
 Ogre::ColourValue rgb(Ogre::uchar r, Ogre::uchar g, Ogre::uchar b, Ogre::uchar a = 255);

 /*! function. webcolour
     desc.
         Turn a webcolour from the Gorilla::Colours::Colour enum into an Ogre::ColourValue
 */
 Ogre::ColourValue webcolour(Colours::Colour, Ogre::Real alpha = 1.0);

 /*! enum. Gradient
     desc.
         Directions for background gradients
 */
 enum Gradient
 {
  Gradient_NorthSouth,
  Gradient_WestEast,
  Gradient_Diagonal
 };

 /*! enum. Border
     desc.
         Border Directions

         +---------------------+
         |\       NORTH       /|
         | \                 / |
         |  +---------------+  |
         |  |               |  |
         | W|               |E |
         | E|               |A |
         | S|               |S |
         | T|               |T |
         |  |               |  |
         |  +---------------+  |
         | /      SOUTH      \ |
         |/                   \|
         +---------------------+
 */
 enum Border
 {
  Border_North = 0,
  Border_South = 1,
  Border_East  = 2,
  Border_West  = 3
 };

 /*! enum. QuadCorner
     desc.
         Names of each corner/vertex of a Quad
 */
 enum QuadCorner
 {
  TopLeft     = 0,
  TopRight    = 1,
  BottomRight = 2,
  BottomLeft  = 3
 };

 /*! enum. TextAlignment
     desc.
         Horizontal text alignment for captions.
 */
 enum TextAlignment
 {
  TextAlign_Left,   // Place the text to where left is (X = left)
  TextAlign_Right,  // Place the text to the right of left (X = left - text_width)
  TextAlign_Centre, // Place the text centered at left (X = left - (text_width / 2 ) )
 };

 /*! enum. VerticalAlignment
     desc.
         Vertical text alignment for captions.
 */
 enum VerticalAlignment
 {
  VerticalAlign_Top,
  VerticalAlign_Middle,
  VerticalAlign_Bottom
 };

 /*! enum. buffer<T>
     desc.
         Internal container class that is similar to std::vector
 */
 template<typename T> class buffer
 {
  public:

   inline buffer() : mBuffer(0), mUsed(0), mCapacity(0)
   { // no code.
   }

   inline ~buffer()
   {
    if (mBuffer && mCapacity)
     OGRE_FREE(mBuffer, Ogre::MEMCATEGORY_GEOMETRY);
   }

   inline size_t size() const
   {
    return mUsed;
   }

   inline size_t capacity() const
   {
    return mCapacity;
   }

   inline T& operator[](size_t index)
   {
    return *(mBuffer + index);
   }

   inline const T& operator[](size_t index) const
   {
    return *(mBuffer + index);
   }

   inline T& at(size_t index)
   {
    return *(mBuffer + index);
   }

   inline const T& at(size_t index) const
   {
    return *(mBuffer + index);
   }

   inline void remove_all()
   {
    mUsed = 0;
   }

   inline void resize(size_t new_capacity)
   {
    T* new_buffer = (T*) OGRE_MALLOC(sizeof(T) * new_capacity, Ogre::MEMCATEGORY_GEOMETRY);

    if (mUsed != 0)
    {
     if (mUsed < new_capacity)  // Copy all
      std::copy(mBuffer, mBuffer + mUsed, stdext::checked_array_iterator<T*>(new_buffer, mUsed));
     else if (mUsed >= new_capacity) // Copy some
      std::copy(mBuffer, mBuffer + new_capacity, stdext::checked_array_iterator<T*>(new_buffer, new_capacity));
    }

    OGRE_FREE(mBuffer, Ogre::MEMCATEGORY_GEOMETRY);
    mCapacity = new_capacity;
    mBuffer = new_buffer;
   }

   inline void push_back(const T& value)
   {
    if (mUsed == mCapacity)
     resize(mUsed == 0 ? 1 : mUsed * 2);
    *(mBuffer + mUsed) = value;
    mUsed++;
   }

   inline void pop_back()
   {
    if (mUsed != 0)
     mUsed--;
   }

   inline void erase(size_t index)
   {
    *(mBuffer + index) = *(mBuffer + mUsed - 1);
    mUsed--;
   }

   inline  T* first()
   {
    return mBuffer;
   }

   inline T* last()
   {
    return mBuffer + mUsed;
   }

  protected:

   T*     mBuffer;
   size_t mUsed, mCapacity;
 };

 /*! struct. Vertex
     desc.
         Structure for a single vertex.
 */
 struct Vertex
 {
  Ogre::Vector3 position;
  Ogre::ColourValue colour;
  Ogre::Vector2 uv;
 };

 /*! struct. Kerning
     desc.
         Distances between two characters next to each other.
 */
 struct Kerning
 {
  Kerning(Ogre::uint c, Ogre::Real k) : character(c), kerning(k) {}
  Ogre::uint character;
  Ogre::Real kerning;
 };

 /*! struct. Glyph
     desc.
         Texture and size information about a single character loaded from a TextureAtlas.
 */
 class Glyph : public Ogre::GeneralAllocatedObject
 {
  public:

   Glyph() : uvTop(0), uvBottom(0), uvWidth(0), uvHeight(0), uvLeft(0), uvRight(0), glyphWidth(0), glyphHeight(0), glyphAdvance(0), verticalOffset(0) {}

  ~Glyph() {}

   Ogre::Vector2    texCoords[4];
   Ogre::Real uvTop, uvBottom, uvWidth, uvHeight, uvLeft, uvRight,
                       glyphWidth, glyphHeight, glyphAdvance, verticalOffset;
   buffer<Kerning> kerning;

   // Get kerning value of a character to the right of another.
   // Ab -- get the kerning value of b, pass on A.
   inline const Ogre::Real getKerning(unsigned char left_of) const
   {
    if (kerning.size() == 0)
     return 0;
    for (size_t i=0;i < kerning.size();i++)
    {
     if (kerning[i].character == left_of)
      return kerning[i].kerning;
    }
    return 0;
   }
 };

 /*! class. Sprite
     desc.
         Portions of a texture from a TextureAtlas.
 */
 class Sprite : public Ogre::GeneralAllocatedObject
 {
  public:

   Sprite() {}

  ~Sprite() {}

   Ogre::Real uvTop, uvLeft, uvRight, uvBottom, spriteWidth, spriteHeight;
   Ogre::Vector2    texCoords[4];
 };

 /* class. Silverback
    desc.
        Main singleton class for Gorilla
 */
 class Silverback : public Ogre::Singleton<Silverback>, public Ogre::GeneralAllocatedObject, public Ogre::FrameListener
 {
  public:

   /*! constructor. Silverback
       desc.
           Silverback constructor.
   */
   Silverback();

   /*! destructor. Silverback
       desc.
           Silverback destructor.
   */
  ~Silverback();

   /*! function. loadAtlas
       desc.
           Create a TextureAtlas from a ".gorilla" file.

           Name is the name of the TextureAtlas, as well as the first part of the filename
           of the gorilla file; i.e. name.gorilla, the gorilla file can be loaded from a different
           resource group if you give that name as the second argument, otherwise it will assume
           to be "General".
   */
   void loadAtlas(const Ogre::String& name, const Ogre::String& group = Ogre::ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME);

   /*! function. createScreen
       desc.
           Create a Screen using a Viewport and a name of a previously loaded TextureAtlas.
           Both must exist. The screen will register itself as a RenderQueueListener to the
           SceneManager that has the Camera which is tied to the Viewport.
       note.
           Each screen is considered a new batch. To reduce your batch count in Gorilla,
           reduce the number of screens you use.
   */
   Screen* createScreen(Ogre::Viewport*, const Ogre::String& atlas);

   /*! function. destroyScreen
       desc.
           Destroy an existing screen, its layers and the contents of those layers.
   */
   void destroyScreen(Screen*);

   /*! function. createScreenRenderable
   */
   ScreenRenderable* createScreenRenderable(const Ogre::Vector2& maxSize, const Ogre::String& atlas);

   /*! function. destroyScreen
       desc.
           Destroy an existing screen, its layers and the contents of those layers.
   */
   void destroyScreenRenderable(ScreenRenderable*);

   /*! function. frameStarted
       desc.
           Call ScreenRenderable draw
   */
   bool frameStarted(const Ogre::FrameEvent& evt);

  protected:

   std::map<Ogre::String, TextureAtlas*>  mAtlases;
   std::vector<Screen*>                   mScreens;
   std::vector<ScreenRenderable*>         mScreenRenderables;
 };

 /*! class. GlyphData
     desc.
         Collection of glyphs of the same size.
 */
 class GlyphData : public Ogre::GeneralAllocatedObject
 {
  friend class TextureAtlas;

   public:

    GlyphData();

   ~GlyphData();

    /*! function. getGlyph
        desc.
            Get a glyph (character information) from a specific character.
        note.
            If the character doesn't exist then a null pointer is returned.
            Do not delete the Glyph pointer.
    */
    inline Glyph* getGlyph(Ogre::uint character) const
    {
     Ogre::uint safe_character = character - mRangeBegin;
     if (safe_character >= 0 && safe_character <= mGlyphs.size())
      return mGlyphs[safe_character];
     return 0;
    }

    std::vector<Glyph*>  mGlyphs;
    Ogre::uint           mRangeBegin, mRangeEnd;
    Ogre::Real           mSpaceLength,
                         mLineHeight,
                         mBaseline,
                         mLineSpacing,
                         mLetterSpacing,
                         mMonoWidth;
 };

 /*! class. TextureAtlas
     desc.
          The TextureAtlas file represents a .gorilla file which contains all the needed information that
          describes the portions of a single texture. Such as Glyph and Sprite information, text kerning,
          line heights and so on. It isn't typically used by the end-user.
 */
 class TextureAtlas : public Ogre::GeneralAllocatedObject
 {
   friend class Silverback;

   public:

    Ogre::MaterialPtr createOrGet2DMasterMaterial();

    Ogre::MaterialPtr createOrGet3DMasterMaterial();

    /*! function. getTexture
        desc.
            Get the texture assigned to this TextureAtlas
    */
    inline Ogre::TexturePtr getTexture() const
    {
     return mTexture;
    }

    /*! function. getMaterial
        desc.
            Get the material assigned to this TextureAtlas
    */
    inline Ogre::MaterialPtr get2DMaterial() const
    {
     return m2DMaterial;
    }

    /*! function. getMaterial
        desc.
            Get the material assigned to this TextureAtlas
    */
    inline Ogre::MaterialPtr get3DMaterial() const
    {
     return m3DMaterial;
    }
    /*! function. getMaterialName
        desc.
            Get the name of the material assigned to this TextureAtlas
    */
    inline Ogre::String get2DMaterialName() const
    {
     return m2DMaterial->getName();
    }
    /*! function. getMaterialName
        desc.
            Get the name of the material assigned to this TextureAtlas
    */
    inline Ogre::String get3DMaterialName() const
    {
     return m3DMaterial->getName();
    }

    inline GlyphData* getGlyphData(Ogre::uint index) const
    {
     std::map<Ogre::uint, GlyphData*>::const_iterator it = mGlyphData.find(index);
     if (it == mGlyphData.end())
      return 0;
     return (*it).second;
    }

    /*! function. getSprite
        desc.
            Get a sprite (portion of a texture) from a name.
        note.
            If the sprite doesn't exist then a null pointer is returned.
            Do not delete the Sprite pointer.
    */
    inline Sprite* getSprite(const Ogre::String& name) const
    {
     std::map<Ogre::String, Sprite*>::const_iterator it = mSprites.find(name);
     if (it == mSprites.end())
      return 0;
     return (*it).second;
    }

    /*! function. getGlyphKerning
        desc.
            Get the UV information for a designated white pixel in the texture.
        note.
            Units are in relative coordinates (0..1)
    */
    inline Ogre::Vector2 getWhitePixel() const
    {
     return mWhitePixel;
    }

    /*! function. getGlyphKerning
        desc.
            Get the X coordinate for a designated white pixel in the texture.
        note.
            Units are in relative coordinates (0..1)

    */
    inline Ogre::Real getWhitePixelX() const
    {
     return mWhitePixel.x;
    }

    /*! function. getGlyphKerning
        desc.
            Get the Y coordinate for a designated white pixel in the texture.
        note.
            Units are in relative coordinates (0..1)
    */
    inline Ogre::Real getWhitePixelY() const
    {
     return mWhitePixel.y;
    }

    /*! function. getTextureSize
        desc.
            Get the size of the texture.
    */
    inline Ogre::Vector2 getTextureSize() const
    {
     return Ogre::Vector2(Ogre::Real(mTexture->getWidth()), Ogre::Real(mTexture->getHeight()));
    }

    /*! function. getTextureSize
        desc.
            Get the reciprocal of the width of the texture.
    */
    inline Ogre::Real getInvTextureCoordsX() const
    {
     return 1.0f / Ogre::Real(mTexture->getWidth());
    }

    /*! function. getTextureSize
        desc.
            Get the reciprocal of the height of the texture.
    */
    inline Ogre::Real getInvTextureCoordsY() const
    {
     return 1.0f / Ogre::Real(mTexture->getHeight());
    }

    /*! function. getPass
        desc.
            Get the first pass of the material used by this TextureAtlas
    */
    inline Ogre::Pass* get2DPass() const
    {
     return m2DPass;
    }

    /*! function. getGlyphMonoWidth
        desc.
            Reset the ten markup colours used in the MarkupText, by default these are:

             0 = 255, 255, 255
             1 = 0, 0, 0
             2 = 204, 204, 204
             3 = 254, 220, 129
             4 = 254, 138, 129
             5 = 123, 236, 110
             6 = 44,  192, 171
             7 = 199, 93,  142
             8 = 254, 254, 254
             9 = 13,  13,  13
    */
    void refreshMarkupColours();

    /*! function. setMarkupColour
        desc.
            Change one of the ten markup colours.
        note.
            colour_palette_index must be between or equal to 0 and 9.
    */
    void setMarkupColour(Ogre::uint colour_palette_index, const Ogre::ColourValue&);

    /*! function. getMarkupColour
        desc.
            Get one of the ten markup colours.
        note.
            colour_palette_index must be between or equal to 0 and 9.
    */
    Ogre::ColourValue getMarkupColour(Ogre::uint colour_palette_index);

   protected:

    TextureAtlas(const Ogre::String& gorillaFile, const Ogre::String& group);

   ~TextureAtlas();

    void  _reset();
    void  _load(const Ogre::String& gorillaFile, const Ogre::String& groupName);
    void  _loadTexture(Ogre::ConfigFile::SettingsMultiMap*);
    void  _loadGlyphs(Ogre::ConfigFile::SettingsMultiMap*, GlyphData*);
    void  _loadKerning(Ogre::ConfigFile::SettingsMultiMap*, GlyphData*);
    void  _loadVerticalOffsets(Ogre::ConfigFile::SettingsMultiMap*, GlyphData*);
    void  _loadSprites(Ogre::ConfigFile::SettingsMultiMap*);
    void  _create2DMaterial();
    void  _create3DMaterial();
    void  _calculateCoordinates();

    Ogre::TexturePtr                  mTexture;
    Ogre::MaterialPtr                 m2DMaterial, m3DMaterial;
    Ogre::Pass*                       m2DPass, *m3DPass;
    std::map<Ogre::uint, GlyphData*>  mGlyphData;
    std::map<Ogre::String, Sprite*>   mSprites;
    Ogre::Vector2                     mWhitePixel;
    Ogre::Vector2                     mInverseTextureSize;
    Ogre::ColourValue                 mMarkupColour[10];
  };

  class LayerContainer
  {
   public:

    LayerContainer(TextureAtlas*);

    virtual ~LayerContainer();

    /*! function. createLayer
        desc.
            Create a layer for drawing on to.

            Index represents the z-order, 0 being the layer drawn first and 15
            the layer drawn last. Layers drawn after another layer will appear
            to be top than the other.

        note.
            Index must be between or equal to 0 and 15. Any other value will cause
            a very nasty crash.
    */
    Layer*  createLayer(Ogre::uint index = 0);

    /*! function. destroyLayer
        desc.
            Destroy a layer and it's contents.
    */
    void   destroy(Layer* layer);

    /*! function. getAtlas
        desc.
            Get atlas assigned to this LayerContainer
    */
    TextureAtlas* getAtlas() const { return mAtlas; }

    virtual Ogre::Real getTexelOffsetX() const { return 0.0f; }

    virtual Ogre::Real getTexelOffsetY() const { return 0.0f; }

    /*! function. _createVertexBuffer
        desc.
            Create the vertex buffer
    */
    void _createVertexBuffer(size_t initialSize);

    /*! function. _destroyVertexBuffer
        desc.
            Destroy the vertex buffer
    */
    void _destroyVertexBuffer();

    /*! function. _resizeVertexBuffer
        desc.
            Resize the vertex buffer to the greatest nearest power
            of 2 of requestedSize.
    */
    void _resizeVertexBuffer(size_t requestedSize);

    /* function. _recalculateIndexes
       desc.
           Clear mIndexes, mIndexVertices and mIndexRedraw,
           and from mLayers fill them out again. A full redraw
           is required.
    */
    void _recalculateIndexes();

    /*! function. _redrawIndex
        desc.
            Redraw all layers of an index.
            If force is true, then all elements of that layer
            will be redrawn regardless of anything has changed
            or not.
    */
    void _redrawIndex(Ogre::uint id, bool force);

    /*! function. _redrawAllIndexes
        desc.
            Redraw all layers of all indexes
            If force is true, then all elements of all layers
            will be redrawn regardless of anything has changed
            or not.
    */
    void _redrawAllIndexes(bool force = false);

    /*! function. _redrawAllIndexes
        desc.
            Redraw a redraw of an index on the next call of _renderVertices
    */
    void _requestIndexRedraw(Ogre::uint index);

    /*! function. _renderVertices
        desc.
            Bundle up mIndexData (redraw any if needed) then copy them
            into mVertexBuffer, and update mRenderOpPtr with the new
            vertex count.
    */
    void _renderVertices(bool force = false);

    /*! function. renderOnce
        desc.
            Draw the vertices from mVertexBuffer into Ogre.
    */
    virtual void renderOnce() = 0;

    virtual void _transform(buffer<Vertex>& vertices, size_t begin, size_t end)
    {
        (void)vertices;
        (void)begin;
        (void)end;
    }

   protected:

    /// mLayers -- Master copy of all layers of this Target.
    std::vector<Layer*>     mLayers;

    struct IndexData : public Ogre::GeneralAllocatedObject
    {
     std::vector<Layer*>    mLayers;
     buffer<Vertex>         mVertices;
     bool                   mRedrawNeeded;
    };

    /// mIndexes -- Copies pointers to Layers arranged their index.
    std::map< Ogre::uint, IndexData* >  mIndexData;

    /// mIndexRedrawNeeded -- An index (not sure what) needs to be redrawn.
    bool  mIndexRedrawNeeded;

    /// mRedrawAll -- All indexes need to be redrawn regardless of state.
    bool  mIndexRedrawAll;

    /// mVertexBuffer -- Compiled layers of all indexes go into here for rendering directly to the screen or scene.
    Ogre::HardwareVertexBufferSharedPtr   mVertexBuffer;

    /// mVertexBufferSize -- How much the VertexBuffer can hold.
    size_t  mVertexBufferSize;

    /// mRenderOpPtr -- Pointer to the RenderOperation (Not owned by LayerContainer)
    Ogre::RenderOperation*  mRenderOpPtr;

    /// Atlas assigned to this LayerContainer
    TextureAtlas*  mAtlas;
  };

  class Screen : public LayerContainer, public Ogre::RenderQueueListener, public Ogre::GeneralAllocatedObject
  {
   public:

    friend class Silverback;
    friend class Layer;

    /*! desc. getTexelOffsetX
            Helper function to get horizontal texel offset.
    */
    inline Ogre::Real getTexelOffsetX() const { return mRenderSystem->getHorizontalTexelOffset(); }

    /*! desc. getTexelOffsetY
            Helper function to get vertical texel offset.
    */
    inline Ogre::Real getTexelOffsetY() const { return mRenderSystem->getVerticalTexelOffset(); }

    /*! desc. getWidth
            Get screen height in pixels.
    */
    inline Ogre::Real getWidth() const { return mWidth; }

    /*! desc. getHeight
            Get screen height in pixels.
    */
    inline Ogre::Real getHeight() const { return mHeight; }

    /*! desc. isVisible
            Is the screen and it's contents visible or not?
        note.
            If the screen is hidden, then it is not rendered which decrease the batch count by one.
    */
    inline bool isVisible() const { return mIsVisible; }

    /*! desc. setVisible
            Show or hide the screen.
    */
    inline void setVisible(bool value) { mIsVisible = value;}

    /*! desc. hide
            Hide the screen and the all of layers within it.
    */
    inline void hide() { mIsVisible = false;}

    /*! desc. show
            Show the screen and the visible layers within it.
    */
    inline void show() { mIsVisible = true;}

#if OGRE_NO_VIEWPORT_ORIENTATIONMODE == 1
    inline void setOrientation(Ogre::OrientationMode o)
    {
      mOrientation = o; mOrientationChanged = true;

      if (mOrientation == Ogre::OR_DEGREE_90 || mOrientation == Ogre::OR_DEGREE_270)
      {
       std::swap(mWidth, mHeight);
       std::swap(mInvWidth, mInvHeight);
      }
    }
#endif
   protected:

    /*! constructor. Screen
        desc.
            Use Silverback::createScreen
    */
    Screen(Ogre::Viewport*, TextureAtlas*);

    /*! destructor. Screen
        desc.
            Use Silverback::destroyScreen
    */
   ~Screen();

    // Internal -- Not used, but required by renderQueueListener
    void renderQueueStarted(Ogre::uint8, const Ogre::String&, bool&) {}

    // Internal -- Called by Ogre to render the screen.
    void renderQueueEnded(Ogre::uint8 queueGroupId, const Ogre::String& invocation, bool& repeatThisInvocation);

    // Internal -- Prepares RenderSystem for rendering.
    void _prepareRenderSystem();

    // Internal -- Renders mVertexData to screen.
    void renderOnce();

    // Internal -- Used to transform vertices using units of pixels into screen coordinates.
    void _transform(buffer<Vertex>& vertices, size_t begin, size_t end);

    Ogre::RenderOperation mRenderOp;
    Ogre::SceneManager*   mSceneMgr;
    Ogre::RenderSystem*   mRenderSystem;
    Ogre::Viewport*       mViewport;
    Ogre::Real            mWidth, mHeight, mInvWidth, mInvHeight;
    Ogre::OrientationMode mOrientation;
#if OGRE_NO_VIEWPORT_ORIENTATIONMODE == 1
    bool                  mOrientationChanged;
#endif
    Ogre::Vector3         mScale;
    bool                  mIsVisible;
    bool                  mCanRender;
    Ogre::Matrix4         mVertexTransform;
  };

  class ScreenRenderable : public LayerContainer, public Ogre::SimpleRenderable
  {
   public:

    ScreenRenderable(const Ogre::Vector2& maxSize, TextureAtlas*);

   ~ScreenRenderable();

    void frameStarted();
    void renderOnce();
    void _transform(buffer<Vertex>& vertices, size_t begin, size_t end);
    void calculateBoundingBox();

    Ogre::Real getBoundingRadius(void) const { return mBox.getMaximum().squaredLength(); }

    Ogre::Real getSquaredViewDepth(const Ogre::Camera* cam) const
    {
     Ogre::Vector3 min, max, mid, dist;
     min = mBox.getMinimum();
     max = mBox.getMaximum();
     mid = ((max - min) * 0.5) + min;
     dist = cam->getDerivedPosition() - mid;
     return dist.squaredLength();
    }

   protected:

    Ogre::SceneManager*   mSceneMgr;
    Ogre::RenderSystem*   mRenderSystem;
    Ogre::Viewport*       mViewport;
    Ogre::Vector2         mMaxSize;
  };

  /*! class. Layer
      desc.
          Text
  */
  class Layer : public Ogre::GeneralAllocatedObject
  {
   friend class LayerContainer;

   public:

    typedef Gorilla::VectorType<Rectangle*>::type            Rectangles;
    typedef Ogre::VectorIterator<Rectangles>                 RectangleIterator;
    typedef Gorilla::VectorType<Polygon*>::type              Polygons;
    typedef Ogre::VectorIterator<Polygons>                   PolygonIterator;
    typedef Gorilla::VectorType<LineList*>::type             LineLists;
    typedef Ogre::VectorIterator<LineLists>                  LineListIterator;
    typedef Gorilla::VectorType<QuadList*>::type             QuadLists;
    typedef Ogre::VectorIterator<QuadLists>                  QuadListIterator;
    typedef Gorilla::VectorType<Caption*>::type              Captions;
    typedef Ogre::VectorIterator<Captions>                   CaptionIterator;
    typedef Gorilla::VectorType<MarkupText*>::type           MarkupTexts;
    typedef Ogre::VectorIterator<MarkupTexts>                MarkupTextIterator;

    /*! function. isVisible
        desc.
            Is the layer being drawn on screen or not?
    */
    inline  bool isVisible() const
    {
     return mVisible;
    }

    /*! function. setVisible
        desc.
            Show or hide the layer
    */
    inline void setVisible(bool isVisible)
    {
     if (mVisible == isVisible)
      return;
     mVisible = isVisible;
     _markDirty();
    }

    /*! function. show
        desc.
            Show the layer
    */
    inline void show()
    {
     if (mVisible)
      return;
     mVisible = true;
     _markDirty();
    }

    /*! function. hide
        desc.
            hide the layer
    */
    inline void hide()
    {
     if (!mVisible)
      return;
     mVisible = false;
     _markDirty();
    }

    /*! function. setAlphaModifier
        desc.
            Set's a modifier to the alpha component of all colours of the vertices that make up this layer
        note.
            Final alpha value of all vertices in this layer is the following:

             final_alpha = vertex_alpha * alphaModifier;

            Alpha modifier should be between 0.0 and 1.0
    */
    void setAlphaModifier(const Ogre::Real& alphaModifier)
    {
     mAlphaModifier = alphaModifier;
     _markDirty();
    }

    /*! function. getAlphaModifier
        desc.
            Set's a modifier to the alpha component of all colours of the vertices that make up this layer
    */
    Ogre::Real getAlphaModifier() const
    {
     return mAlphaModifier;
    }

    /*! function. createRectangle
        desc.
            Creates a rectangle.
    */
    Rectangle*         createRectangle(Ogre::Real left, Ogre::Real top, Ogre::Real width = 100, Ogre::Real height = 100);

    /*! function. createRectangle
        desc.
            Creates a rectangle.
    */
    Rectangle*         createRectangle(const Ogre::Vector2& position, const Ogre::Vector2& size = Ogre::Vector2(100,100))
    {
     return createRectangle(position.x, position.y, size.x, size.y);
    }

    /*! function. destroyRectangle
        desc.
            Removes a rectangle from the layer and *deletes* it.
    */
    void               destroyRectangle(Rectangle*);

    /*! function. destroyAllRectangles
        desc.
            Removes all rectangles from the layer and *deletes* them.
    */
    void               destroyAllRectangles();

    /*! function. getRectangles
        desc.
            Get an iterator to all the rectangles in this layer.
    */
    RectangleIterator  getRectangles()
    {
     return RectangleIterator(mRectangles.begin(), mRectangles.end());
    }

    /*! function. createPolygon
        desc.
            Creates a regular polygon.
    */
    Polygon*         createPolygon(Ogre::Real left, Ogre::Real top, Ogre::Real radius = 100, Ogre::uint sides = 6);

    /*! function. destroyPolygon
        desc.
            Removes a polygon from the layer and *deletes* it.
    */
    void               destroyPolygon(Polygon*);

    /*! function. destroyAllPolygons
        desc.
            Removes all polygons from the layer and *deletes* them.
    */
    void               destroyAllPolygons();

    /*! function. getPolygons
        desc.
            Get an iterator to all the polygons in this layer.
    */
    PolygonIterator  getPolygons()
    {
     return PolygonIterator(mPolygons.begin(), mPolygons.end());
    }

    /*! function. createLineList
        desc.
            Creates a line list.
    */
    LineList*         createLineList();

    /*! function. destroyLineList
        desc.
            Removes a line list from the layer and *deletes* it.
    */
    void               destroyLineList(LineList*);

    /*! function. destroyAllLineLists
        desc.
            Removes all line lists from the layer and *deletes* them.
    */
    void               destroyAllLineLists();

    /*! function. getLineLists
        desc.
            Get an iterator to all the line lists in this layer.
    */
    LineListIterator  getLineLists()
    {
     return LineListIterator(mLineLists.begin(), mLineLists.end());
    }

    /*! function. createQuadList
        desc.
            Creates a quad list.
    */
    QuadList*         createQuadList();

    /*! function. destroyQuadList
        desc.
            Removes a quad list from the layer and *deletes* it.
    */
    void               destroyQuadList(QuadList*);

    /*! function. destroyAllQuadLists
        desc.
            Removes all quad lists from the layer and *deletes* them.
    */
    void               destroyAllQuadLists();

    /*! function. getQuadLists
        desc.
            Get an iterator to all the quad lists in this layer.
    */
    QuadListIterator  getQuadLists()
    {
     return QuadListIterator(mQuadLists.begin(), mQuadLists.end());
    }

    /*! function. createCaption
        desc.
            Creates a caption
    */
    Caption*         createCaption(Ogre::uint glyphDataIndex, Ogre::Real x, Ogre::Real y, const Ogre::String& text);

    /*! function. destroyCaption
        desc.
            Removes a caption from the layer and *deletes* it.
    */
    void               destroyCaption(Caption*);

    /*! function. destroyAllCaptions
        desc.
            Removes all caption from the layer and *deletes* them.
    */
    void               destroyAllCaptions();

    /*! function. getCaptions
        desc.
            Get an iterator to all the quad lists in this layer.
    */
    CaptionIterator  getCaptions()
    {
     return CaptionIterator(mCaptions.begin(), mCaptions.end());
    }

    /*! function. createMarkupText
        desc.
            Creates a markup text
            %0 Select the markup color, %0 up to %9.
            %@9% Select the font size, %@9% %@14% or %@24% for dejavu atlas.
            %R Reset the markup color to 0, %R or %r.
            %:spriteName% Insert a sprite.
            %M Monospace the font. %M of %m.
    */
    MarkupText*         createMarkupText(Ogre::uint defaultGlyphIndex, Ogre::Real x, Ogre::Real y, const Ogre::String& text);

    /*! function. destroyMarkupText
        desc.
            Removes a markup text from the layer and *deletes* it.
    */
    void               destroyMarkupText(MarkupText*);

    /*! function. destroyAllMarkupTexts
        desc.
            Removes all markup text from the layer and *deletes* them.
    */
    void               destroyAllMarkupTexts();

    /*! function. getMarkupTexts
        desc.
            Get an iterator to all the quad lists in this layer.
    */
    MarkupTextIterator  getMarkupTexts()
    {
     return MarkupTextIterator(mMarkupTexts.begin(), mMarkupTexts.end());
    }

    /*! function. getIndex
        desc.
            Get render index
    */
    Ogre::uint getIndex() const
    {
     return mIndex;
    }

    /*! function. _getSolidUV
        desc.
            Helper function to get a white pixel in the TextureAtlas.
    */
    inline Ogre::Vector2      _getSolidUV() const
    {
     return mParent->getAtlas()->getWhitePixel();
    }

    /*! function. _getSprite
        desc.
            Helper function to get a Sprite from the assigned texture atlas.
    */
    inline Sprite*            _getSprite(const Ogre::String& sprite_name) const
    {
     return mParent->getAtlas()->getSprite(sprite_name);
    }

    /*! function. _getGlyph
        desc.
            Helper function to get a Glyph from the assigned texture atlas.
    */
    inline GlyphData*         _getGlyphData(Ogre::uint id) const
    {
     return mParent->getAtlas()->getGlyphData(id);
    }

    /*! function. _getGlyph
        desc.
            Helper function to get the used texture size.
    */
    inline Ogre::Vector2      _getTextureSize() const
    {
     return mParent->getAtlas()->getTextureSize();
    }

    /*! function. _getAtlas
        desc.
            Helper function to get the used TextureAtlas.
    */
    inline TextureAtlas*      _getAtlas() const
    {
     return mParent->getAtlas();
    }

    /*! function. _getTexelX
        desc.
            Helper function to get the offset X texel coordinate.
    */
    inline Ogre::Real         _getTexelX() const
    {
     return mParent->getTexelOffsetX();
    }

    /*! function. _getTexelX
        desc.
            Helper function to get the offset Y texel coordinate.
    */
    inline Ogre::Real         _getTexelY() const
    {
     return mParent->getTexelOffsetY();
    }

    /*! function. _getMarkupColour
        desc.
            Helper function to get the markup colourvalue.
    */
    inline Ogre::ColourValue  _getMarkupColour(Ogre::uint index) const
    {
     return mParent->getAtlas()->getMarkupColour(index);
    }

    /*! function. _markDirty
        desc.
            Make this layer redraw itself on the next time that
            Gorilla updates to the screen.
        note.
            This shouldn't be needed to be called by the user.
    */
    void _markDirty();

   protected:

    void _render(buffer<Vertex>&, bool force = false);

    Layer(Ogre::uint index, LayerContainer*);

   ~Layer();

    Ogre::uint               mIndex;
    Rectangles               mRectangles;
    Polygons                 mPolygons;
    LineLists                mLineLists;
    QuadLists                mQuadLists;
    Captions                 mCaptions;
    MarkupTexts              mMarkupTexts;
    LayerContainer*          mParent;
    bool                     mVisible;
    Ogre::Real               mAlphaModifier;
  };

  /*! class. Rectangle
      desc.
          Single rectangle with an optional border.
  */
  class Rectangle : public Ogre::GeneralAllocatedObject
  {
   friend class Layer;

   public:

    /*! function. intersects
        desc.
            Does a set of coordinates lie within this rectangle?
    */
    inline bool intersects(const Ogre::Vector2& coordinates) const
    {
     return ((coordinates.x >= mLeft && coordinates.x <= mRight) && (coordinates.y >= mTop && coordinates.y <= mBottom));
    }

    /*! function. position
        desc.
            Get the position
    */
    inline Ogre::Vector2 position() const
    {
     return Ogre::Vector2(mLeft, mTop);
    }

    /*! function. position
        desc.
            Set the position
    */
    inline void position(const Ogre::Real& l, const Ogre::Real& t)
    {
     left(l);
     top(t);
    }
    /*! function. position
        desc.
            Set the position
    */
    inline void position(const Ogre::Vector2& position)
    {
     left(position.x);
     top(position.y);
    }

    /*! function. left
        desc.
            Get left position
    */
    inline Ogre::Real  left() const
    {
     return mLeft;
    }

    /*! function. left
        desc.
            Set left position
    */
    inline void  left(const Ogre::Real& left)
    {
     Ogre::Real w = width();
     mLeft = left;
     mRight = left + w;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. top
        desc.
            Get top position
    */
    inline Ogre::Real  top() const
    {
     return mTop;
    }

    /*! function. top
        desc.
            Set top position
    */
    inline void  top(const Ogre::Real& top)
    {
     Ogre::Real h = height();
     mTop = top;
     mBottom = top + h;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. width
        desc.
            Get the width
    */
    inline Ogre::Real  width() const
    {
     return mRight - mLeft;
    }

    /*! function. width
        desc.
            Set the width
    */
    inline void  width(const Ogre::Real& width)
    {
     mRight = mLeft + width;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. height
        desc.
            Get the height
    */
    Ogre::Real  height() const
    {
     return mBottom - mTop;
    }

    /*! function. height
        desc.
            Set the height
    */
    inline void  height(const Ogre::Real& height)
    {
     mBottom = mTop + height;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. no_background
        desc.
            Don't draw the background.
        note.
            This just sets the background colour alpha to zero. Which on the next
            draw tells Rectangle to skip over drawing the background.
    */
    void  no_background()
    {
     mBackgroundColour[0].a = 0;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. no_border
        desc.
            Don't draw the border.
        note.
            This just sets the border to zero. Which on the next
            draw tells Rectangle to skip over drawing the border.
    */
    void  no_border()
    {
     mBorderWidth = 0;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background_colour
        desc.
            Get a background colour of a specific corner.
    */
    Ogre::ColourValue  background_colour(QuadCorner index) const
    {
     return mBackgroundColour[index];
    }

    /*! function. background_colour
        desc.
            Set a background colour to all corners.
    */
    void  background_colour(const Ogre::ColourValue& colour)
    {
     mBackgroundColour[0] = colour;
     mBackgroundColour[1] = colour;
     mBackgroundColour[2] = colour;
     mBackgroundColour[3] = colour;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background_colour
        desc.
            Set a background colour to all corners.
    */
    void  background_colour(Gorilla::Colours::Colour colour)
    {
     mBackgroundColour[0] = webcolour(colour);
     mBackgroundColour[1] = mBackgroundColour[0];
     mBackgroundColour[2] = mBackgroundColour[0];
     mBackgroundColour[3] = mBackgroundColour[0];
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background_colour
        desc.
            Set a background colour to a specific corner.
    */
    void  background_colour(QuadCorner index, const Ogre::ColourValue& colour)
    {
     mBackgroundColour[index] = colour;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background_gradient
        desc.
            Set the background to a gradient.
    */
    void  background_gradient(Gradient gradient, const Ogre::ColourValue& colourA, const Ogre::ColourValue& colourB)
    {
     if (gradient == Gradient_NorthSouth)
     {
      mBackgroundColour[0] = mBackgroundColour[1] = colourA;
      mBackgroundColour[2] = mBackgroundColour[3] = colourB;
     }
     else if (gradient == Gradient_WestEast)
     {
      mBackgroundColour[0] = mBackgroundColour[3] = colourA;
      mBackgroundColour[1] = mBackgroundColour[2] = colourB;
     }
     else if (gradient == Gradient_Diagonal)
     {
      Ogre::ColourValue avg;
      avg.r = (colourA.r + colourB.r) * 0.5f;
      avg.g = (colourA.g + colourB.g) * 0.5f;
      avg.b = (colourA.b + colourB.b) * 0.5f;
      avg.a = (colourA.a + colourB.a) * 0.5f;
      mBackgroundColour[0] = colourA;
      mBackgroundColour[1] = avg = mBackgroundColour[3] = avg;
      mBackgroundColour[2] = colourB;
     }
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background_image
        desc.
            Set the background to a sprite from the texture atlas.
        note.
            To remove the image pass on a null pointer.
    */
    void  background_image(Sprite* sprite)
    {
     if (sprite == 0)
     {
      mUV[0] = mUV[1] = mUV[2] = mUV[3] = mLayer->_getSolidUV();
     }
     else
     {
      if (sprite == 0)
      {
#if GORILLA_USES_EXCEPTIONS == 1
       OGRE_EXCEPT( Ogre::Exception::ERR_ITEM_NOT_FOUND, "Sprite name not found", __FUNC__ );
#else
       return;
#endif
      }
      Ogre::Real texelOffsetX = mLayer->_getTexelX(), texelOffsetY = mLayer->_getTexelY();
      texelOffsetX /= mLayer->_getTextureSize().x;
      texelOffsetY /= mLayer->_getTextureSize().y;
      mUV[0].x = mUV[3].x = sprite->uvLeft - texelOffsetX;
      mUV[0].y = mUV[1].y = sprite->uvTop - texelOffsetY;
      mUV[1].x = mUV[2].x = sprite->uvRight + texelOffsetX;
      mUV[2].y = mUV[3].y = sprite->uvBottom + texelOffsetX;
     }
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background_image
        desc.
            Set the background to a sprite from the texture atlas, with clipping.
            Clipping is used for example with RPM meters on HUDs, where a portion
            of the sprite needs to be shown to indicate the RPM on the car.

            widthClip  is a decimal percentage of the width of the sprite (0.0 none, 1.0 full)
            heightClip is a decimal percentage of the height of the sprite (0.0 none, 1.0 full)

            You should use this with the width() and height() functions for a full effect.
        note.
            To remove the image pass on a null pointer.
    */
    void  background_image(Sprite* sprite, Ogre::Real widthClip, Ogre::Real heightClip)
    {
     if (sprite == 0)
     {
      mUV[0] = mUV[1] = mUV[2] = mUV[3] = mLayer->_getSolidUV();
     }
     else
     {
      if (sprite == 0)
      {
#if GORILLA_USES_EXCEPTIONS == 1
       OGRE_EXCEPT( Ogre::Exception::ERR_ITEM_NOT_FOUND, "Sprite name not found", __FUNC__ );
#else
       return;
#endif
      }
      Ogre::Real texelOffsetX = mLayer->_getTexelX(), texelOffsetY = mLayer->_getTexelY();
      texelOffsetX /= mLayer->_getTextureSize().x;
      texelOffsetY /= mLayer->_getTextureSize().y;
      mUV[0].x = mUV[3].x = sprite->uvLeft - texelOffsetX;
      mUV[0].y = mUV[1].y = sprite->uvTop - texelOffsetY;
      mUV[1].x = mUV[2].x = sprite->uvLeft + ( (sprite->uvRight - sprite->uvLeft) * widthClip ) + texelOffsetX;
      mUV[2].y = mUV[3].y = sprite->uvTop + ( (sprite->uvBottom - sprite->uvTop) * heightClip ) + texelOffsetY;
     }
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background_image
        desc.
            Set the background to a sprite from the texture atlas, with clipping.
            Clipping is used for example with RPM meters on HUDs, where a portion
            of the sprite needs to be shown to indicate the RPM on the car.

            widthClip  is a decimal percentage of the width of the sprite (0.0 none, 1.0 full)
            heightClip is a decimal percentage of the height of the sprite (0.0 none, 1.0 full)

            You should use this with the width() and height() functions for a full effect.
        note.
            To remove the image pass on a null pointer.
    */
    void  background_image(const Ogre::String& sprite_name_or_none, Ogre::Real widthClip, Ogre::Real heightClip)
    {
     if (sprite_name_or_none.length() == 0 || sprite_name_or_none == "none")
     {
      mUV[0] = mUV[1] = mUV[2] = mUV[3] = mLayer->_getSolidUV();
     }
     else
     {
      Sprite* sprite = mLayer->_getSprite(sprite_name_or_none);
      if (sprite == 0)
      {
#if GORILLA_USES_EXCEPTIONS == 1
       OGRE_EXCEPT( Ogre::Exception::ERR_ITEM_NOT_FOUND, "Sprite name not found", __FUNC__ );
#else
       return;
#endif
      }
      Ogre::Real texelOffsetX = mLayer->_getTexelX(), texelOffsetY = mLayer->_getTexelY();
      texelOffsetX /= mLayer->_getTextureSize().x;
      texelOffsetY /= mLayer->_getTextureSize().y;
      mUV[0].x = mUV[3].x = sprite->uvLeft - texelOffsetX;
      mUV[0].y = mUV[1].y = sprite->uvTop - texelOffsetY;
      mUV[1].x = mUV[2].x = sprite->uvLeft + ( (sprite->uvRight - sprite->uvLeft) * widthClip ) + texelOffsetX;
      mUV[2].y = mUV[3].y = sprite->uvTop + ( (sprite->uvBottom - sprite->uvTop) * heightClip ) + texelOffsetY;
     }
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background_image
        desc.
            Set the background to a sprite from the texture atlas.
        note.
            To remove the image pass on "none" or a empty string
    */
    void  background_image(const Ogre::String& sprite_name_or_none)
    {
     if (sprite_name_or_none.length() == 0 || sprite_name_or_none == "none")
     {
      mUV[0] = mUV[1] = mUV[2] = mUV[3] = mLayer->_getSolidUV();
     }
     else
     {
      Sprite* sprite = mLayer->_getSprite(sprite_name_or_none);
      if (sprite == 0)
      {
#if GORILLA_USES_EXCEPTIONS == 1
       OGRE_EXCEPT( Ogre::Exception::ERR_ITEM_NOT_FOUND, "Sprite name not found", __FUNC__ );
#else
       return;
#endif
      }

      Ogre::Real texelOffsetX = mLayer->_getTexelX(), texelOffsetY = mLayer->_getTexelY();
      texelOffsetX /= mLayer->_getTextureSize().x;
      texelOffsetY /= mLayer->_getTextureSize().y;
      mUV[0].x = mUV[3].x = sprite->uvLeft - texelOffsetX;
      mUV[0].y = mUV[1].y = sprite->uvTop - texelOffsetY;
      mUV[1].x = mUV[2].x = sprite->uvRight + texelOffsetX;
      mUV[2].y = mUV[3].y = sprite->uvBottom + texelOffsetY;
     }
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border_colour
        desc.
            Get the border colour.
    */
    Ogre::ColourValue  border_colour(Border index) const
    {
     return mBorderColour[index];
    }

    /*! function. border_colour
        desc.
            Set all of border to one colour
    */
    void  border_colour(const Ogre::ColourValue& bordercolour)
    {
     mBorderColour[0] = bordercolour;
     mBorderColour[1] = bordercolour;
     mBorderColour[2] = bordercolour;
     mBorderColour[3] = bordercolour;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border_colour
        desc.
            Set a border part to one colour.
    */
    void  border_colour(Border index, const Ogre::ColourValue& bordercolour)
    {
     mBorderColour[index] = bordercolour;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border_colour
        desc.
            Set all of border to one colour
    */
    void  border_colour(Gorilla::Colours::Colour bordercolour)
    {
     mBorderColour[0] = webcolour(bordercolour);
     mBorderColour[1] = mBorderColour[0];
     mBorderColour[2] = mBorderColour[0];
     mBorderColour[3] = mBorderColour[0];
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border_colour
        desc.
            Set a border part to one colour.
    */
    void  border_colour(Border index, Gorilla::Colours::Colour bordercolour)
    {
     mBorderColour[index] = webcolour(bordercolour);
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border_width
        desc.
            Get the border width
    */
    Ogre::Real  border_width() const
    {
     return mBorderWidth;
    }

    /*! function. border_width
        desc.
            Set the border width
    */
    void  border_width(Ogre::Real width)
    {
     mBorderWidth = width;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border
        desc.
            Set the border width and colour.
    */
    void  border(Ogre::Real width, const Ogre::ColourValue& colour)
    {
     mBorderColour[0] = colour;
     mBorderColour[1] = mBorderColour[0];
     mBorderColour[2] = mBorderColour[0];
     mBorderColour[3] = mBorderColour[0];
     mBorderWidth = width;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border
        desc.
            Set the border width and specific colours for each part.
    */
    void  border(Ogre::Real width, const Ogre::ColourValue& north, const Ogre::ColourValue& east, const Ogre::ColourValue& south, const Ogre::ColourValue& west)
    {
     mBorderColour[Border_North] = north;
     mBorderColour[Border_South] = south;
     mBorderColour[Border_East] = east;
     mBorderColour[Border_West] = west;
     mBorderWidth = width;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border
        desc.
            Set the border width and colour.
    */
    void  border(Ogre::Real width, Gorilla::Colours::Colour colour)
    {
     mBorderColour[0] = webcolour(colour);
     mBorderColour[1] = mBorderColour[0];
     mBorderColour[2] = mBorderColour[0];
     mBorderColour[3] = mBorderColour[0];
     mBorderWidth = width;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border
        desc.
            Set the border width and specific colours for each part.
    */
    void  border(Ogre::Real width, Gorilla::Colours::Colour north, Gorilla::Colours::Colour east, Gorilla::Colours::Colour south, Gorilla::Colours::Colour west)
    {
     mBorderColour[Border_North] = webcolour(north);
     mBorderColour[Border_South] = webcolour(south);
     mBorderColour[Border_East] = webcolour(east);
     mBorderColour[Border_West] = webcolour(west);
     mBorderWidth = width;
     mDirty = true;
     mLayer->_markDirty();
    }

    bool visible() const
    {
     return mVisible;
    }

    void visible(const bool visible)
    {
        if (mVisible != visible)
        {
            mVisible = visible;
            mDirty = true;
            mLayer->_markDirty();
        }
    }

    /*! function. _redraw
        desc.
            Redraw the rectangle
        note.
            This should not be needed to be called by the user.
    */
    void _redraw();

   protected:

    Rectangle(Ogre::Real left, Ogre::Real top, Ogre::Real width, Ogre::Real height, Layer* parent);

   ~Rectangle() {}

   protected:

    Layer*             mLayer;
    Ogre::Real         mLeft, mTop, mRight, mBottom, mBorderWidth;
    Ogre::ColourValue  mBackgroundColour[4];
    Ogre::ColourValue  mBorderColour[4];
    Ogre::Vector2      mUV[4];
    bool               mDirty;
    buffer<Vertex>     mVertices;
    bool               mVisible;
  };

  /*! class. Polygon
      desc.
          A regular n-sided polygon.
  */
  class Polygon : public Ogre::GeneralAllocatedObject
  {
   friend class Layer;

   public:

    /*! function. left
        desc.
            Get left position
    */
    Ogre::Real  left() const
    {
     return mLeft;
    }

    /*! function. left
        desc.
            Set left position
    */
    void  left(const Ogre::Real& left)
    {
     mLeft = left;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. left
        desc.
            Get left position
    */
    Ogre::Real  top() const
    {
     return mTop;
    }

    /*! function. left
        desc.
            Set left position
    */
    void  top(const Ogre::Real& top)
    {
     mTop = top;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. radius
        desc.
            Get the radius of the polygon
    */
    Ogre::Real  radius() const
    {
     return mRadius;
    }

    /*! function. radius
        desc.
            Set the radius of the polygon
    */
    void  radius(const Ogre::Real& radius)
    {
     mRadius = radius;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. sides
        desc.
            Get the number of sides the polygon has.
    */
    size_t  sides() const
    {
     return mSides;
    }

    /*! function. sides
        desc.
            Set the number of sides the polygon has.
        note.
            Number of sides must be at least 2.
    */
    void  sides(size_t sides)
    {
     if (sides < 3)
      sides = 3;
     mSides = sides;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. angle
        desc.
            Get the angle of the polygon
    */
    Ogre::Radian  angle() const
    {
     return mAngle;
    }

    /*! function. angle
        desc.
            Set the angle of the polygon.
    */
    void  angle(const Ogre::Radian& angle)
    {
     mAngle = angle;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background_image
        desc.
            Get the sprite used as a background image or null pointer
    */
    Sprite*  background_image() const
    {
     return mSprite;
    }

    /*! function. background_image
        desc.
            Set the sprite used as a background image or null pointer to clear.
    */
    void  background_image(Sprite* sprite)
    {
     mSprite = sprite;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background_image
        desc.
            Set the sprite used as a background image from a string.
        note.
            Use a empty string or "none" to clear.
    */
    void  background_image(const Ogre::String& name_or_none)
    {
     if (name_or_none.size() == 0 || name_or_none == "none")
      mSprite = 0;
     else
      mSprite = mLayer->_getSprite(name_or_none);

     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background_colour
        desc.
            Get the background colour.
    */
    Ogre::ColourValue  background_colour() const
    {
     return mBackgroundColour;
    }

    /*! function. background_colour
        desc.
            Set the background colour.
        note.
            If there is a background sprite then it will be tinted by this colour.
    */
    void  background_colour(const Ogre::ColourValue& colour)
    {
     mBackgroundColour = colour;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border
        desc.
            Set the border width and colour
    */
    void border(Ogre::Real width, const Ogre::ColourValue& colour)
    {
     mBorderColour = colour;
     mBorderWidth = width;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border
        desc.
            Set the border width and colour
    */
    void border(Ogre::Real width, Gorilla::Colours::Colour colour)
    {
     if (colour == Gorilla::Colours::None)
     {
      mBorderColour.a = 0;
      mBorderWidth = 0;
     }
     else
     {
      mBorderColour = webcolour(colour);
      mBorderWidth = width;
     }
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border_colour
        desc.
            Get the border colour
    */
    Ogre::ColourValue  border_colour() const
    {
     return mBorderColour;
    }

    /*! function. border_colour
        desc.
            Set the border colour
    */
    void  border_colour(const Ogre::ColourValue& bordercolour)
    {
     mBorderColour = bordercolour;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border_colour
        desc.
            Set the border colour
    */
    void  border_colour(Gorilla::Colours::Colour colour)
    {
     if (colour == Gorilla::Colours::None)
     {
      mBorderColour.a = 0;
     }
     else
     {
      mBorderColour = webcolour(colour);
     }
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. border_width
        desc.
            Get the border width
    */
    Ogre::Real  border_width() const
    {
     return mBorderWidth;
    }

    /*! function. border_width
        desc.
            Set the border width
    */
    void  border_width(Ogre::Real width)
    {
     mBorderWidth = width;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. no_background
        desc.
            Don't draw the background.
        note.
            This just sets the background colour alpha to zero. Which on the next
            draw tells Rectangle to skip over drawing the background.
    */
    void  no_background()
    {
     mBackgroundColour.a = 0;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. no_border
        desc.
            Don't draw the border.
        note.
            This just sets the border to zero. Which on the next
            draw tells Rectangle to skip over drawing the border.
    */
    void  no_border()
    {
     mBorderWidth = 0;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. _redraw
        desc.
            Redraw the polygon
        note.
            This should not be needed to be called by the user.
    */
    void  _redraw();

    protected:

    Polygon(Ogre::Real left, Ogre::Real top, Ogre::Real radius, size_t sides, Layer* parent);

   ~Polygon() {}

    Layer*             mLayer;
    Ogre::Real         mLeft, mTop, mRadius, mBorderWidth;
    Ogre::Radian       mAngle;
    size_t             mSides;
    Ogre::ColourValue  mBackgroundColour, mBorderColour;
    Sprite*            mSprite;
    bool               mDirty;
    buffer<Vertex>     mVertices;
  };

  class LineList : public Ogre::GeneralAllocatedObject
  {
   friend class Layer;

   public:

    /*! function. begin
        desc.
            Clear lines and start again
    */
    void  begin(Ogre::Real lineThickness = 1.0f, const Ogre::ColourValue& colour = Ogre::ColourValue::White);

    /*! function. begin
        desc.
            Clear lines and start again
    */
    void  begin(Ogre::Real lineThickness, Gorilla::Colours::Colour colour)
    {
     begin(lineThickness, webcolour(colour));
    }

    /*! function. position
        desc.
            Extent the list to x and y.
    */
    void  position(Ogre::Real x, Ogre::Real y);

    /*! function. position
        desc.
            Extent the list to given coordinates.
    */
    void  position(const Ogre::Vector2&);

    /*! function. end
        desc.
            Stop line drawing and calculate vertices.
        note.
            If "isClosed" is set to true, then the line list joins back to the first position.
    */
    void  end(bool isClosed = false);

    /*! function. _redraw
        desc.
            Redraw the line list
        note.
            This should not be needed to be called by the user.
    */
    void  _redraw();

   protected:

    LineList(Layer* parent);

   ~LineList() {}

   protected:

    Layer*                mLayer;
    Ogre::Real            mThickness;
    Ogre::ColourValue     mColour;
    bool                  mIsClosed;
    buffer<Ogre::Vector2> mPositions;
    bool                  mDirty;
    buffer<Vertex>        mVertices;
  };

  /*! class. QuadList
      desc.
          "ManualObject" like class to quickly draw rectangles, gradients, sprites and borders.
  */
  class QuadList : public Ogre::GeneralAllocatedObject
  {
   friend class Layer;

   public:

    /*! function. begin
        desc.
            Clear everything and start again
    */
    void  begin();

    /*! function. rectangle
        desc.
            Draw a rectangle sized w,h at x,y
    */
    void  rectangle(Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, const Ogre::ColourValue = Ogre::ColourValue::White);

    /*! function. gradient
        desc.
            Draw a gradient rectangle sized w,h at x,y
    */
    void  gradient(Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, Gradient gradient, const Ogre::ColourValue& colourA = Ogre::ColourValue::White, const Ogre::ColourValue& colourB = Ogre::ColourValue::White);

    /*! function. gradient
        desc.
            Draw a gradient rectangle sized w,h at x,y
    */
    void  gradient(Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, Gradient gradient, const Gorilla::Colours::Colour& colourA, const Gorilla::Colours::Colour& colourB)
    {
     this->gradient(x,y,w,h,gradient, webcolour(colourA), webcolour(colourB));
    }

    /*! function. sprite
        desc.
            Draw a sprite sized w,h at x,y
    */
    void  sprite(Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, Sprite*);

    /*! function. border
        desc.
            Draw a border sized w,h at x,y of a thickness
    */
    void  border(Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, Ogre::Real thickness, const Ogre::ColourValue& = Ogre::ColourValue::White);

    /*! function. border
        desc.
            Draw a border sized w,h at x,y of a thickness
    */
    void  border(Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, Ogre::Real thickness, const Gorilla::Colours::Colour& colour)
    {
     border(x,y,w,h,thickness, webcolour(colour));
    }

    /*! function. border
        desc.
            Draw a border sized w,h at x,y of a thickness
    */
    void  border(Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, Ogre::Real thickness, const Ogre::ColourValue& northColour, const Ogre::ColourValue& eastColour, const Ogre::ColourValue& southColour, const Ogre::ColourValue& westColour);

    /*! function. border
        desc.
            Draw a border sized w,h at x,y of a thickness
    */
    void  border(Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, Ogre::Real thickness, const Gorilla::Colours::Colour& northColour, const Gorilla::Colours::Colour& eastColour, const Gorilla::Colours::Colour& southColour, const Gorilla::Colours::Colour& westColour)
    {
     border(x,y,w,h,thickness, webcolour(northColour), webcolour(eastColour), webcolour(southColour), webcolour(westColour));
    }

    /*! function. glyph
        desc.
            Draw a glpyh
    */
    void  glyph(Ogre::uint glyphDataIndex, Ogre::Real x, Ogre::Real y, unsigned char character, const Ogre::ColourValue& colour);

    /*! function. glyph
        desc.
            Draw a glyph with a custom size.
    */
    void  glyph(Ogre::uint glyphDataIndex, Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, unsigned char character, const Ogre::ColourValue& colour);

    /*! function. glyph
        desc.
            Draw a glpyh
    */
    void  glyph(Ogre::uint glyphDataIndex, Ogre::Real x, Ogre::Real y, unsigned char character, const Gorilla::Colours::Colour& colour)
    {
     glyph(glyphDataIndex,x,y,character, webcolour(colour));
    }

    /*! function. glyph
        desc.
            Draw a glyph with a custom size.
    */
    void  glyph(Ogre::uint glyphDataIndex, Ogre::Real x, Ogre::Real y, Ogre::Real w, Ogre::Real h, unsigned char character, const Gorilla::Colours::Colour& colour)
    {
     glyph(glyphDataIndex, x,y,w,h, character, webcolour(colour));
    }

    /*! function. end
        desc.
            Stop drawing and calculate vertices.
    */
    void  end();

    void  _redraw();

   protected:

    QuadList(Layer*);

    ~QuadList() {}

    struct Quad
    {
     Ogre::Vector2        mPosition[4];
     Ogre::Vector2        mUV[4];
     Ogre::ColourValue    mColour[4];
    };

    Ogre::Vector2         mWhiteUV;
    Layer*                mLayer;
    buffer<Quad>          mQuads;
    buffer<Vertex>        mVertices;
    bool                  mDirty;
  };

  /* class. Caption
     desc.
         A single line piece of text
  */
  class Caption : public Ogre::GeneralAllocatedObject
  {
   friend class Layer;

   public:

    /*! function. font
        desc.
            Changes the font to a different Glyph index.
        note.
             If the font index does not exist, an exception may be thrown.
    */
    void font(size_t font_index)
    {
     mGlyphData      = mLayer->_getGlyphData(Ogre::uint(font_index));
     if (mGlyphData == 0)
     {
       mDirty        = false;
   #if GORILLA_USES_EXCEPTIONS == 1
       OGRE_EXCEPT( Ogre::Exception::ERR_ITEM_NOT_FOUND, "Glyph data not found", __FUNC__ );
   #else
       return;
   #endif
     }
     mDirty = true;
     mLayer->_markDirty();
    }
    /*! function. intersects
        desc.
            Does a set of coordinates lie within this caption?
    */
    inline bool intersects(const Ogre::Vector2& coordinates) const
    {
     return ((coordinates.x >= mLeft && coordinates.x <= mLeft + mWidth) && (coordinates.y >= mTop && coordinates.y <= mTop + mHeight));
    }

    /*! function. top
        desc.
            Get where the text should be drawn vertically.
    */
    Ogre::Real  left() const
    {
     return mLeft;
    }

    /*! function. top
        desc.
            Set where the text should be drawn vertically.
        note.
             If the TextAlignment is Right Aligned, then this will be the right-side of the last character drawn (with in width limits).
             If the TextAlignment is Centre Aligned, then this will be the center of the drawn text drawn (with in width limits).
    */
    void  left(const Ogre::Real& left)
    {
     mLeft = left;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. top
        desc.
            Get where the text should be drawn vertically.
    */
    Ogre::Real  top() const
    {
     return mTop;
    }

    /*! function. top
        desc.
            Set where the text should be drawn vertically.
    */
    void  top(const Ogre::Real& top)
    {
     mTop = top;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. size
        desc.
            Set the maximum width and height of the text can draw into.
    */
    void size(const Ogre::Real& width, const Ogre::Real& height)
    {
     mWidth = width;
     mHeight = height;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. width
        desc.
            Get the maximum width of the text can draw into.
    */
    Ogre::Real width() const
    {
     return mWidth;
    }

    /*! function. width
        desc.
            Set the maximum width of the text can draw into.
    */
    void  width(const Ogre::Real& width)
    {
     mWidth = width;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. height
        desc.
            Get the maximum height of the text can draw into.
    */
    Ogre::Real height() const
    {
     return mHeight;
    }

    /*! function. height
        desc.
            Set the maximum height of the text can draw into.
    */
    void  height(const Ogre::Real& height)
    {
     mHeight = height;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. caption
        desc.
            Get the text indented to show.
    */
    Ogre::String  text() const
    {
     return mText;
    }

    /*! function. alignment
        desc.
            Set the text to show.
    */
    void  text(const Ogre::String& text)
    {
     mText = text;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. alignment
        desc.
            Get the alignment of text.
    */
    TextAlignment align() const
    {
     return mAlignment;
    }

    /*! function. alignment
        desc.
            Set the alignment of text.
    */
    void  align(const TextAlignment& alignment)
    {
     mAlignment = alignment;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. alignment
        desc.
            Get the vertical alignment of text.
    */
    VerticalAlignment vertical_align() const
    {
     return mVerticalAlign;
    }

    /*! function. vertical_align
        desc.
            Set the vertical alignment of text.
    */
    void  vertical_align(const VerticalAlignment& alignment)
    {
     mVerticalAlign = alignment;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. clipped_left_index
        desc.
            Get the index (character position), of the first character that could not be drawn due to the limits
            of the width of the text, to the left.
        return.
            size_t -- The index if the first clipped character, or std::string::npos if there was no clipping and
                      the text was drawn fully within the given space.
    */
    size_t  clipped_left_index() const
    {
     return mClippedLeftIndex;
    }

    /*! function. clipped_right_index
        desc.
            Get the index (character position), of the first character that could not be drawn due to the limits
            of the width of the text, to the right.
        return.
            size_t -- The index if the first clipped character, or std::string::npos if there was no clipping and
                      the text was drawn fully within the given space.
    */
    size_t  clipped_right_index() const
    {
     return mClippedRightIndex;
    }

    /*! function. colour
        desc.
            Get the text colour.
    */
    Ogre::ColourValue  colour() const
    {
     return mColour;
    }

    /*! function. colour
        desc.
            Set the text colour.
    */
    void  colour(const Ogre::ColourValue& colour)
    {
     mColour = colour;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. colour
        desc.
            Set the text colour.
    */
    void  colour(Gorilla::Colours::Colour colour)
    {
     mColour = webcolour(colour);
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background
        desc.
            Get the background colour
    */
    Ogre::ColourValue  background() const
    {
     return mBackground;
    }

    /*! function. background
        desc.
            Set the background colour
    */
    void  background(const Ogre::ColourValue& background)
    {
     mBackground = background;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background
        desc.
            Set the background colour
    */
    void  background(Gorilla::Colours::Colour background)
    {
     if (background == Colours::None)
      mBackground.a = 0;
     else
      mBackground = webcolour(background);
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. no_background
        desc.
            Don't draw the background.
        note.
            This just sets the background colour alpha to zero. Which on the next
            draw tells Caption to skip over drawing the background.
    */
    void  no_background()
    {
     mBackground.a = 0;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. fixedWidth
        desc.
            Set, whether the font should be drawn with a fixed width.
    */
    void fixedWidth(bool fixedWidth)
    {
      mFixedWidth = fixedWidth;
      mDirty = true;
      mLayer->_markDirty();
    }

    bool fixedWidth() const
    {
      return mFixedWidth;
    }

    bool visible() const
    {
        return mVisible;
    }

    void visible(const bool visible)
    {
        if (mVisible != visible)
        {
            mVisible = visible;
            mDirty = true;
            mLayer->_markDirty();
        }
    }

    /*! function. _redraw
        desc.
            Redraw the text.
        note.
            This shouldn't be need to be called by the user.
    */
    void               _redraw();

   protected:

    void               _calculateDrawSize(Ogre::Vector2& size);

    Caption(Ogre::uint glyphDataIndex, Ogre::Real left, Ogre::Real top, const Ogre::String& caption, Layer* parent);

   ~Caption() {}

   protected:

    bool                  mFixedWidth;
    Layer*                mLayer;
    GlyphData*            mGlyphData;
    Ogre::Real            mLeft, mTop, mWidth, mHeight;
    TextAlignment         mAlignment;
    VerticalAlignment     mVerticalAlign;
    Ogre::String          mText;
    Ogre::ColourValue     mColour, mBackground;
    bool                  mDirty;
    buffer<Vertex>        mVertices;
    size_t                mClippedLeftIndex, mClippedRightIndex;
    bool                  mVisible;

  private:
    Ogre::Real _getAdvance(Glyph* glyph, Ogre::Real kerning);
  };

  /* class. Caption
     desc.
         A multi-line collection of text formatted by a light markup language, that can
         switch colours, change to monospace and insert sprites directly into the text.
  */
  class MarkupText : public Ogre::GeneralAllocatedObject
  {
   friend class Layer;

   public:

    /*! function. top
        desc.
            Get where the text should be drawn vertically.
    */
    Ogre::Real  left() const
    {
     return mLeft;
    }

    /*! function. top
        desc.
            Set where the text should be drawn vertically.
        note.
             If the TextAlignment is Right Aligned, then this will be the right-side of the last character drawn (with in width limits).
             If the TextAlignment is Centre Aligned, then this will be the center of the drawn text drawn (with in width limits).
    */
    void  left(const Ogre::Real& left)
    {
     mLeft = left;
     mDirty = true;
     mTextDirty = true;
     mLayer->_markDirty();
    }

    /*! function. top
        desc.
            Get where the text should be drawn vertically.
    */
    Ogre::Real  top() const
    {
     return mTop;
    }

    /*! function. top
        desc.
            Set where the text should be drawn vertically.
    */
    void  top(const Ogre::Real& top)
    {
     mTop = top;
     mDirty = true;
     mTextDirty = true;
     mLayer->_markDirty();
    }

    /*! function. size
        desc.
            Set the maximum width and height of the text can draw into.
    */
    void size(const Ogre::Real& width, const Ogre::Real& height)
    {
     mWidth = width;
     mHeight = height;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. width
        desc.
            Get the maximum width of the text can draw into.
    */
    Ogre::Real width() const
    {
     return mWidth;
    }

    /*! function. width
        desc.
            Set the maximum width of the text can draw into.
    */
    void  width(const Ogre::Real& width)
    {
     mWidth = width;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. height
        desc.
            Get the maximum height of the text can draw into.
    */
    Ogre::Real height() const
    {
     return mHeight;
    }

    /*! function. height
        desc.
            Set the maximum height of the text can draw into.
    */
    void  height(const Ogre::Real& height)
    {
     mHeight = height;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. maxTextWidth
        desc.
            Get the width of the text once drawn.
    */
    Ogre::Real maxTextWidth()
    {
     _calculateCharacters();
     return mMaxTextWidth;
    }

    /*! function. caption
        desc.
            Get the text indented to show.
    */
    Ogre::String  text() const
    {
     return mText;
    }

    /*! function. alignment
        desc.
            Set the text to show.
    */
    void  text(const Ogre::String& text)
    {
     mText = text;
     mTextDirty = true;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background
        desc.
            Get the background colour
    */
    Ogre::ColourValue  background() const
    {
     return mBackground;
    }

    /*! function. background
        desc.
            Set the background colour
    */
    void  background(const Ogre::ColourValue& background)
    {
     mBackground = background;
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. background
        desc.
            Set the background colour
    */
    void  background(Gorilla::Colours::Colour background)
    {
     if (background == Colours::None)
      mBackground.a = 0;
     else
      mBackground = webcolour(background);
     mDirty = true;
     mLayer->_markDirty();
    }

    /*! function. _redraw
        desc.
            Redraw the text.
        note.
            This shouldn't be need to be called by the user.
    */
    void               _redraw();

    void               _calculateCharacters();

    bool visible() const
    {
        return mVisible;
    }

    void visible(const bool visible)
    {
        if (mVisible != visible)
        {
            mVisible = visible;
            mDirty = true;
            mLayer->_markDirty();
        }
    }

   protected:

    MarkupText(Ogre::uint defaultGlyphIndex, Ogre::Real left, Ogre::Real top, const Ogre::String& text, Layer* parent);

   ~MarkupText() {}

   protected:

    struct Character
    {
     Ogre::Vector2        mPosition[4];
     Ogre::Vector2        mUV[4];
     Ogre::ColourValue    mColour;
     size_t               mIndex;
    };

    Layer*                mLayer;
    GlyphData*            mDefaultGlyphData;
    Ogre::Real            mLeft, mTop, mWidth, mHeight;
    Ogre::Real            mMaxTextWidth;
    Ogre::String          mText;
    Ogre::ColourValue     mBackground;
    bool                  mDirty, mTextDirty;
    buffer<Character>     mCharacters;
    buffer<Vertex>        mVertices;
    size_t                mClippedIndex;
    bool                  mVisible;
  };
}

#endif
