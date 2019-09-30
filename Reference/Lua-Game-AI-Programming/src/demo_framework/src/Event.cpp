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

#include "demo_framework/include/Event.h"

Event::Event(const Ogre::String& eventType)
    : eventType_(eventType) {
}

Event::Event(const Event& event)
{
    *this = event;
}

Event& Event::operator=(const Event& event)
{
    eventType_ = event.eventType_;
    attributes_ = event.attributes_;

    return *this;
}

void Event::AddAttribute(const Ogre::String& attributeName, const bool value)
{
    InitializeAttribute(attributes_[attributeName]);
    attributes_[attributeName].boolean_ = value;
    attributes_[attributeName].type_ = ATTRIBUTE_BOOLEAN;
}

void Event::AddAttribute(const Ogre::String& attributeName, const int value)
{
    InitializeAttribute(attributes_[attributeName]);
    attributes_[attributeName].int_ = value;
    attributes_[attributeName].type_ = ATTRIBUTE_INT;
}

void Event::AddAttribute(const Ogre::String& attributeName, const float value)
{
    InitializeAttribute(attributes_[attributeName]);
    attributes_[attributeName].float_ = value;
    attributes_[attributeName].type_ = ATTRIBUTE_FLOAT;
}

void Event::AddAttribute(
    const Ogre::String& attributeName, const Ogre::String& value)
{
    InitializeAttribute(attributes_[attributeName]);
    attributes_[attributeName].string_ = value;
    attributes_[attributeName].type_ = ATTRIBUTE_STRING;
}

void Event::AddAttribute(
    const Ogre::String& attributeName, Object* const object)
{
    InitializeAttribute(attributes_[attributeName]);
    attributes_[attributeName].object_ = object;
    attributes_[attributeName].type_ = ATTRIBUTE_OBJECT;
}

void Event::AddAttribute(
    const Ogre::String& attributeName, const Ogre::Vector3& value)
{
    InitializeAttribute(attributes_[attributeName]);
    attributes_[attributeName].vector_ = value;
    attributes_[attributeName].type_ = ATTRIBUTE_VECTOR3;
}

bool Event::GetBoolAttribute(const Ogre::String& attributeName) const
{
	std::map<Ogre::String, EventAttribute>::const_iterator it =
		attributes_.find(attributeName);

	if (it != attributes_.end())
	{
		return it->second.boolean_;
	}

	return false;
}

unsigned int Event::GetAttributeCount() const
{
    return static_cast<unsigned int>(attributes_.size());
}

void Event::GetAttributeNames(std::vector<Ogre::String>& attributeNames) const
{
    attributeNames.clear();

    if (attributes_.size())
    {
        attributeNames.reserve(attributes_.size());

        std::map<Ogre::String, EventAttribute>::const_iterator it;

        for (it = attributes_.begin(); it != attributes_.end(); ++it)
        {
            attributeNames.push_back(it->first);
        }
    }
}

Event::AttributeType Event::GetAttributeType(
    const Ogre::String& attributeName) const
{
    std::map<Ogre::String, EventAttribute>::const_iterator it =
        attributes_.find(attributeName);

    if (it != attributes_.end())
    {
        return it->second.type_;
    }

    return ATTRIBUTE_UNKNOWN;
}

float Event::GetFloatAttribute(const Ogre::String& attributeName) const
{
    std::map<Ogre::String, EventAttribute>::const_iterator it =
        attributes_.find(attributeName);

    if (it != attributes_.end())
    {
        return it->second.float_;
    }

    return 0;
}

int Event::GetIntAttribute(const Ogre::String& attributeName) const
{
    std::map<Ogre::String, EventAttribute>::const_iterator it =
        attributes_.find(attributeName);

    if (it != attributes_.end())
    {
        return it->second.int_;
    }

    return 0;
}

Object* Event::GetObjectAttribute(const Ogre::String& attributeName) const
{
    std::map<Ogre::String, EventAttribute>::const_iterator it =
        attributes_.find(attributeName);

    if (it != attributes_.end())
    {
        return it->second.object_;
    }

    return NULL;
}

Ogre::String Event::GetStringAttribute(const Ogre::String& attributeName) const
{
    std::map<Ogre::String, EventAttribute>::const_iterator it =
        attributes_.find(attributeName);

    if (it != attributes_.end())
    {
        return it->second.string_;
    }

    return "";
}

const Ogre::Vector3& Event::GetVector3Attribute(
    const Ogre::String& attributeName) const
{
    std::map<Ogre::String, EventAttribute>::const_iterator it =
        attributes_.find(attributeName);

    if (it != attributes_.end())
    {
        return it->second.vector_;
    }

    return Ogre::Vector3::ZERO;
}

Ogre::String Event::GetEventType() const
{
    return eventType_;
}

void Event::InitializeAttribute(EventAttribute& attribute)
{
    attribute.string_ = "";
    attribute.vector_ = Ogre::Vector3::ZERO;
    attribute.int_ = 0;
    attribute.type_ = ATTRIBUTE_UNKNOWN;
}