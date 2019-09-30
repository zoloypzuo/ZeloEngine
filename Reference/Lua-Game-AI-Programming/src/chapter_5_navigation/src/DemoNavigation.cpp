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

#include "chapter_5_navigation/include/DemoNavigation.h"

#include "demo_framework/include/Sandbox.h"
#include "ogre3d_gorilla/include/Gorilla.h"

#include "detour/include/DetourNavMeshQuery.h"
#include "recast/include/Recast.h"
#include "demo_framework/include/NavigationUtilities.h"
#include "ogre3d/include/OgreManualObject.h"
#include "demo_framework/include/DebugDrawer.h"
#include "demo_framework/include/UserInterface.h"
#include "demo_framework/include/UserInterfaceComponent.h"

DemoNavigation::DemoNavigation()
    : SandboxApplication(
        "Learning Game AI Programming with Lua - Chapter 5 Navigation")
{
}

DemoNavigation::~DemoNavigation()
{
}

void DemoNavigation::Cleanup()
{
    SandboxApplication::Cleanup();
}

void DemoNavigation::Draw()
{
    SandboxApplication::Draw();
}

void DemoNavigation::Initialize()
{
    SandboxApplication::Initialize();

    AddResourceLocation("../../../src/chapter_5_navigation/script");
    CreateSandbox("Sandbox.lua");

    Gorilla::Silverback* mSilverback = Gorilla::Silverback::getSingletonPtr();
    mSilverback->loadAtlas("fonts/dejavu/dejavu");
    Gorilla::Screen* mScreen = mSilverback->createScreen(
        GetCamera()->getViewport(), "fonts/dejavu/dejavu");
    // Ogre::Real vpW = mScreen->getWidth();
    // Ogre::Real vpH = mScreen->getHeight();

    Gorilla::Layer* mLayer = mScreen->createLayer(0);

    // DISABLES THE UI
    mLayer->hide();

    Gorilla::LineList* lines = mLayer->createLineList();
    lines->begin(1, Ogre::ColourValue(0, 0, 0, 0.5f));
    lines->position(650, 560);
    lines->position(650, 600);
    lines->position(550, 600);
    lines->position(550, 560);
    lines->end(true);

    Ogre::ColourValue highlight(0.0f, 0.2f, 0.4f, 0.7f);

    lines = mLayer->createLineList();
    // lines->begin(1, Ogre::ColourValue(0.2f, 0.2f, 0.4f, 0.5f));
    lines->begin(1, Ogre::ColourValue(0.2f, 0.4f, 0.8f, 0.5f));
    lines->position(649, 561);
    lines->position(649, 599);
    lines->position(552, 599);
    // lines->position(551, 561);
    lines->end(false);

    Gorilla::Rectangle* lRect = mLayer->createRectangle(551, 561, 99, 38);
    lRect->background_gradient(
        Gorilla::Gradient_NorthSouth,
        highlight,
        Ogre::ColourValue(0.1f, 0.1f, 0.1f, 0.8f));

    Gorilla::Rectangle* rectangle = mLayer->createRectangle(1, 1);
    rectangle->border(1, Ogre::ColourValue(0.1f, 0.1f, 0.2f));
    // rectangle->background_colour(Ogre::ColourValue(0, 0.1f, 0.2f, 0.6f));
    rectangle->background_gradient(
        Gorilla::Gradient_NorthSouth,
        highlight,
        Ogre::ColourValue(0.1f, 0.1f, 0.1f, 0.8f));

    Gorilla::MarkupText* text = mLayer->createMarkupText(
        9, 5, 30,
        "%@9%1234567890!@#$%^&*()-=_+abcdejghijklmnopqrstuvwxyz"
        "%@9%\n%@9%1234567890!@#$%^&*()-=_+ABCDEJGHIJKLMNOPQRSTUVWXYZ"
        "%@9%\n%@14%1234567890!@#$%^&*()-=_+abcdejghijklmnopqrstuvwxyz"
        "%@9%\n%@14%1234567890!@#$%^&*()-=_+ABCDEJGHIJKLMNOPQRSTUVWXYZ"
        "%@9%\n%@24%1234567890!@#$%^&*()-=_+abcdejghijklmnopqrstuvwxyz"
        "%@9%\n%@24%1234567890!@#$%^&*()-=_+ABCDEJGHIJKLMNOPQRSTUVWXYZ"
        "%@9%\n%@91%1234567890!@#$%^&*()-=_+abcdejghijklmnopqrstuvwxyz"
        "%@9%\n%@91%1234567890!@#$%^&*()-=_+ABCDEJGHIJKLMNOPQRSTUVWXYZ"
        "%@9%\n%@141%1234567890!@#$%^&*()-=_+abcdejghijklmnopqrstuvwxyz"
        "%@9%\n%@141%1234567890!@#$%^&*()-=_+ABCDEJGHIJKLMNOPQRSTUVWXYZ"
        "%@9%\n%@241%1234567890!@#$%^&*()-=_+abcdejghijklmnopqrstuvwxyz"
        "%@9%\n%@241%1234567890!@#$%^&*()-=_+ABCDEJGHIJKLMNOPQRSTUVWXYZ");

    rectangle->width(text->maxTextWidth() + text->left() + 15);
    rectangle->height(350.0f + text->top());

    Gorilla::Rectangle* title = mLayer->createRectangle(
        4, 4, text->maxTextWidth(), 23);
    title->background_gradient(
        Gorilla::Gradient_WestEast,
        Ogre::ColourValue(0.1f, 0.1f, 0.1f, 0.8f),
        Ogre::ColourValue(0.1f, 0.1f, 0.1f, 0.0f));

    Gorilla::Caption* titleCaption = mLayer->createCaption(
        9, 10, 8, "Output");
    (void)titleCaption;
}

void DemoNavigation::Update()
{
    SandboxApplication::Update();
}