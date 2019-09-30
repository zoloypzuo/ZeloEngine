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

#ifndef DEMO_FRAMEWORK_EVENT_H
#define DEMO_FRAMEWORK_EVENT_H

#include <map>

#include "ogre3d/include/OgrePrerequisites.h"
#include "ogre3d/include/OgreString.h"

class Object;

class Event
{
public:
    enum AttributeType
    {
        ATTRIBUTE_BOOLEAN,
        ATTRIBUTE_INT,
        ATTRIBUTE_FLOAT,
        ATTRIBUTE_OBJECT,
        ATTRIBUTE_STRING,
        ATTRIBUTE_VECTOR3,

        ATTRIBUTE_UNKNOWN
    };

    Event(const Ogre::String& eventType);

    Event(const Event& event);

    Event& operator=(const Event& event);

    void AddAttribute(const Ogre::String& attributeName, const bool value);

    void AddAttribute(const Ogre::String& attributeName, const int value);

    void AddAttribute(const Ogre::String& attributeName, const float value);

    void AddAttribute(
        const Ogre::String& attributeName, const Ogre::String& value);

    void AddAttribute(
        const Ogre::String& attributeName, Object* const object);

    void AddAttribute(
        const Ogre::String& attributeName, const Ogre::Vector3& value);

    unsigned int GetAttributeCount() const;

    void GetAttributeNames(std::vector<Ogre::String>& attributeNames) const;

    AttributeType GetAttributeType(const Ogre::String& attributeName) const;

    bool GetBoolAttribute(const Ogre::String& attributeName) const;

    float GetFloatAttribute(const Ogre::String& attributeName) const;

    int GetIntAttribute(const Ogre::String& attributeName) const;

    Object* GetObjectAttribute(const Ogre::String& attributeName) const;

    Ogre::String GetStringAttribute(const Ogre::String& attributeName) const;

    const Ogre::Vector3& GetVector3Attribute(
        const Ogre::String& attributeName) const;

    Ogre::String GetEventType() const;

private:
    struct EventAttribute
    {
        Ogre::String string_;
        Ogre::Vector3 vector_;

        union
        {
            bool boolean_;
            float float_;
            int int_;
            Object* object_;
        };

        AttributeType type_;
    };

    Ogre::String eventType_;
    std::map<Ogre::String, EventAttribute> attributes_;

    void InitializeAttribute(EventAttribute& attribute);
};

#endif  // DEMO_FRAMEWORK_EVENT_H