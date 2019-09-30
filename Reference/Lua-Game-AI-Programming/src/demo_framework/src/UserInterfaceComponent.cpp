/**
 * Copyright (c) 2013 David Young dayoung@goliathdesigns.com
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented; you must not
 *  claim that you wrote the original software. If you use this software
 *  in a product, an acknowledgment in the product documentation would be
 *  appreciated but is not required.
 *
 *  2. Altered source versions must be plainly marked as such, and must not be
 *  misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any source
 *  distribution.
 */

#include "PrecompiledHeaders.h"

#include "demo_framework/include/UserInterfaceComponent.h"

namespace
{
    static const int markupTextTopOffset = 1;
    static const int markupTextLeftOffset = 1;

    struct FontString
    {
        UserInterfaceComponent::Font font;
        char* fontString;
    };

    const FontString fontStrings[] =
    {
        { UserInterfaceComponent::SMALL,            "small" },
        { UserInterfaceComponent::SMALL_MONO,       "small_mono" },
        { UserInterfaceComponent::MEDIUM,           "medium" },
        { UserInterfaceComponent::MEDIUM_MONO,      "medium_mono" },
        { UserInterfaceComponent::LARGE,            "large" },
        { UserInterfaceComponent::LARGE_MONO,       "large_mono" }
    };

    struct GradientString
    {
        UserInterfaceComponent::GradientDirection gradient;
        char* gradientString;
    };

    const GradientString gradientStrings[] =
    {
        { UserInterfaceComponent::DIAGONAL,         "diagonal" },
        { UserInterfaceComponent::NORTH_SOUTH,      "north_south" },
        { UserInterfaceComponent::WEST_EAST,        "west_east" }
    };
}  // anonymous namespace

Ogre::String UserInterfaceComponent::FontToString(
    const UserInterfaceComponent::Font font)
{
    const size_t fontStringCount = sizeof(fontStrings) / sizeof(fontStrings[0]);

    for (size_t index = 0; index < fontStringCount; ++index)
    {
        if (fontStrings[index].font == font)
        {
            return fontStrings[index].fontString;
        }
    }

    return "unknown_string";
}

UserInterfaceComponent::Font UserInterfaceComponent::StringToFont(
    const Ogre::String& string)
{
    const size_t fontStringCount = sizeof(fontStrings) / sizeof(fontStrings[0]);

    for (size_t index = 0; index < fontStringCount; ++index)
    {
        if (fontStrings[index].fontString == string)
        {
            return fontStrings[index].font;
        }
    }

    return UserInterfaceComponent::UNKNOWN_FONT;
}

Ogre::String UserInterfaceComponent::GradientToString(
    const GradientDirection gradient)
{
    const size_t gradientStringCount =
        sizeof(gradientStrings) / sizeof(gradientStrings[0]);

    for (size_t index = 0; index < gradientStringCount; ++index)
    {
        if (gradientStrings[index].gradient == gradient)
        {
            return gradientStrings[index].gradientString;
        }
    }

    return "unknown_gradient";
}

UserInterfaceComponent::GradientDirection UserInterfaceComponent::StringToGradient(
    const Ogre::String& string)
{
    const size_t gradientStringCount =
        sizeof(gradientStrings) / sizeof(gradientStrings[0]);

    for (size_t index = 0; index < gradientStringCount; ++index)
    {
        if (gradientStrings[index].gradientString == string)
        {
            return gradientStrings[index].gradient;
        }
    }

    return UserInterfaceComponent::UNKNOWN_GRADIENT;
}

UserInterfaceComponent::UserInterfaceComponent(Gorilla::Layer* const layer)
    : parentLayer_(layer),
    topLeftPosition_(0, 0),
    topLeftOffset_(0, 0),
    textMargin_(0, 0),
    font_(SMALL),
    visible_(true),
    sceneNode_(NULL),
    screen_(NULL)
{
    Initialize();
}

UserInterfaceComponent::UserInterfaceComponent(
    Ogre::SceneNode& sceneNode,
    Gorilla::ScreenRenderable* const screenRenderable)
    : parentLayer_(screenRenderable->createLayer(0)),
    topLeftPosition_(0, 0),
    topLeftOffset_(0, 0),
    textMargin_(0, 0),
    font_(SMALL),
    visible_(true),
    sceneNode_(&sceneNode),
    screen_(screenRenderable)
{
    sceneNode_->attachObject(screen_);
    Initialize();
}

UserInterfaceComponent::~UserInterfaceComponent()
{
    parentLayer_->destroyCaption(text_);
    parentLayer_->destroyRectangle(rectangle_);
    parentLayer_->destroyMarkupText(markupText_);

    for (std::vector<UserInterfaceComponent*>::iterator it = children_.begin();
        it != children_.end(); ++it)
    {
        delete *it;
    }

    children_.clear();
}

void UserInterfaceComponent::AddChild(UserInterfaceComponent* const child)
{
    children_.push_back(child);

    child->SetOffsetPosition(topLeftPosition_ + topLeftOffset_);
}

UserInterfaceComponent* UserInterfaceComponent::CreateChildComponent()
{
    UserInterfaceComponent* const child =
        new UserInterfaceComponent(parentLayer_);

    AddChild(child);

    return child;
}

void UserInterfaceComponent::CreateLine(
    std::vector<Ogre::Vector2> points,
    const Ogre::ColourValue& color,
    const Ogre::Real thickness,
    const bool cyclical)
{
}

bool UserInterfaceComponent::DestroyChild(UserInterfaceComponent* const child)
{
    std::vector<UserInterfaceComponent*>::iterator it =
        std::find(children_.begin(), children_.end(), child);

    if (it != children_.end())
    {
        children_.erase(it);
        return true;
    }
    return false;
}

Ogre::Vector2 UserInterfaceComponent::GetDimensions() const
{
    return dimensions_;
}

UserInterfaceComponent::Font UserInterfaceComponent::GetFont() const
{
    return font_;
}

Ogre::String UserInterfaceComponent::GetMarkupText() const
{
    return markupText_->text();
}

Ogre::Vector2 UserInterfaceComponent::GetOffsetPosition() const
{
    return topLeftOffset_;
}

Ogre::Vector2 UserInterfaceComponent::GetPosition() const
{
    return topLeftPosition_;
}

Ogre::Vector2 UserInterfaceComponent::GetScreenPosition() const
{
    return GetOffsetPosition() + GetPosition();
}

Ogre::String UserInterfaceComponent::GetText() const
{
    return text_->text();
}

Ogre::Vector2 UserInterfaceComponent::GetTextMargin() const
{
    return textMargin_;
}

void UserInterfaceComponent::Initialize()
{
    text_ = parentLayer_->createCaption(
        font_,
        textMargin_.x + topLeftOffset_.x,
        textMargin_.y + topLeftOffset_.y,
        "");

    rectangle_ = parentLayer_->createRectangle(
        topLeftPosition_ + topLeftOffset_, dimensions_);

    markupText_ = parentLayer_->createMarkupText(
        UserInterfaceComponent::SMALL,
        textMargin_.x + topLeftOffset_.x + markupTextLeftOffset,
        textMargin_.y + topLeftOffset_.y + markupTextTopOffset,
        "");

    SetBackgroundColor(Ogre::ColourValue(0, 0, 0, 0));
    SetDimension(Ogre::Vector2(100, 100));
}

bool UserInterfaceComponent::IsVisible() const
{
    return visible_;
}

void UserInterfaceComponent::SetBackgroundColor(const Ogre::ColourValue& color)
{
    rectangle_->background_colour(color);
}

void UserInterfaceComponent::SetBackgroundImage(const Ogre::String& sprite)
{
    rectangle_->background_image(sprite);
}

void UserInterfaceComponent::SetDimension(const Ogre::Vector2& dimension)
{
    dimensions_ = dimension;

    rectangle_->width(dimension.x);
    rectangle_->height(dimension.y);

    text_->size(
        dimension.x - textMargin_.x * 2,
        dimension.y - textMargin_.y * 2);

    markupText_->size(
        dimension.x - textMargin_.x * 2,
        dimension.y - textMargin_.y * 2);
}

void UserInterfaceComponent::SetFont(const Font font)
{
    text_->font(font);
}

void UserInterfaceComponent::SetFontColor(const Ogre::ColourValue& color)
{
    text_->colour(color);
}

void UserInterfaceComponent::SetGradientColor(
    const GradientDirection direction,
    const Ogre::ColourValue startColor,
    const Ogre::ColourValue endColor)
{
    rectangle_->background_gradient(
        (Gorilla::Gradient)direction, startColor, endColor);
}

void UserInterfaceComponent::SetHeight(const Ogre::Real height)
{
    SetDimension(Ogre::Vector2(dimensions_.x, height));
}

void UserInterfaceComponent::SetMarkupText(const Ogre::String& text)
{
    markupText_->text(text);
}

void UserInterfaceComponent::SetOffsetPosition(const Ogre::Vector2& offset)
{
    topLeftOffset_ = offset;

    rectangle_->position(topLeftOffset_ + topLeftPosition_);

    text_->top(topLeftOffset_.y + topLeftPosition_.y + textMargin_.y);
    text_->left(topLeftOffset_.x + topLeftPosition_.x + textMargin_.x);

    markupText_->top(
        topLeftOffset_.y + topLeftPosition_.y + textMargin_.y + markupTextTopOffset);
    markupText_->left(
        topLeftOffset_.x + topLeftPosition_.x + textMargin_.x + markupTextLeftOffset);

    for (std::vector<UserInterfaceComponent*>::iterator it = children_.begin();
        it != children_.end(); ++it)
    {
        (*it)->SetOffsetPosition(topLeftOffset_ + topLeftPosition_);
    }
}

void UserInterfaceComponent::SetPosition(const Ogre::Vector2& position)
{
    topLeftPosition_ = position;

    rectangle_->position(topLeftOffset_ + topLeftPosition_);

    text_->top(topLeftOffset_.y + topLeftPosition_.y + textMargin_.y);
    text_->left(topLeftOffset_.x + topLeftPosition_.x + textMargin_.x);

    markupText_->top(
        topLeftOffset_.y + topLeftPosition_.y + textMargin_.y + markupTextTopOffset);
    markupText_->left(
        topLeftOffset_.x + topLeftPosition_.x + textMargin_.x + markupTextLeftOffset);

    for (std::vector<UserInterfaceComponent*>::iterator it = children_.begin();
        it != children_.end(); ++it)
    {
        (*it)->SetOffsetPosition(topLeftOffset_ + topLeftPosition_);
    }
}

void UserInterfaceComponent::SetText(const Ogre::String& string)
{
    text_->text(string);
}

void UserInterfaceComponent::SetTextMargin(
    const Ogre::Real top, const Ogre::Real left)
{
    textMargin_.x = left;
    textMargin_.y = top;

    text_->left(topLeftOffset_.x + topLeftPosition_.x + textMargin_.x);
    text_->top(topLeftOffset_.y + topLeftPosition_.y + textMargin_.y);

    markupText_->left(topLeftOffset_.x + topLeftPosition_.x + textMargin_.x);
    markupText_->top(topLeftOffset_.y + topLeftPosition_.y + textMargin_.y);

    text_->size(
        dimensions_.x - textMargin_.x * 2,
        dimensions_.y - textMargin_.y * 2);

    markupText_->size(
        dimensions_.x - textMargin_.x * 2,
        dimensions_.y - textMargin_.y * 2);
}

void UserInterfaceComponent::SetWidth(const Ogre::Real width)
{
    SetDimension(Ogre::Vector2(width, dimensions_.y));
}

void UserInterfaceComponent::SetWorldPosition(const Ogre::Vector3& position)
{
    if (sceneNode_)
    {
        sceneNode_->_setDerivedPosition(position);
    }
}

void UserInterfaceComponent::SetWorldRotation(const Ogre::Quaternion& rotation)
{
    if (sceneNode_)
    {
        sceneNode_->_setDerivedOrientation(rotation);
    }
}

void UserInterfaceComponent::SetVisible(const bool visible)
{
    visible_ = visible;

    rectangle_->visible(visible);
    text_->visible(visible);
    markupText_->visible(visible);
}
