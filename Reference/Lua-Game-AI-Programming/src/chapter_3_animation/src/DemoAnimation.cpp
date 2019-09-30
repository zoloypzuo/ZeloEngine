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

#include "chapter_3_animation/include/DemoAnimation.h"

DemoAnimation::DemoAnimation()
    : SandboxApplication(
        "Learning Game AI Programming with Lua - Chapter 3 Animation")
{
}

DemoAnimation::~DemoAnimation()
{
}

void DemoAnimation::Cleanup()
{
    SandboxApplication::Cleanup();
}

void DemoAnimation::Draw()
{
    SandboxApplication::Draw();
}

void DemoAnimation::Initialize()
{
    SandboxApplication::Initialize();

    AddResourceLocation("../../../src/chapter_3_animation/script");
    CreateSandbox("Sandbox.lua");
}

void DemoAnimation::Update()
{
    SandboxApplication::Update();
}