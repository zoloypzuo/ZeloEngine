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

#ifndef CHAPTER_2_MOVEMENT_DEMO_MOVEMENT_H
#define CHAPTER_2_MOVEMENT_DEMO_MOVEMENT_H

#include "demo_framework/include/SandboxApplication.h"

class DemoMovement : public SandboxApplication
{
public:
    DemoMovement(void);

    virtual ~DemoMovement(void);

    virtual void Cleanup();

    virtual void Draw();

    virtual void Initialize();

    virtual void Update();

private:
    DemoMovement(const DemoMovement&);
    DemoMovement& operator=(const DemoMovement&);
};

#endif  // CHAPTER_2_MOVEMENT_DEMO_MOVEMENT_H
