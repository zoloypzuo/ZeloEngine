#pragma once

#include "GRCookbook/Texture/Bitmap.h"

Bitmap convertEquirectangularMapToVerticalCross(const Bitmap& b);
Bitmap convertVerticalCrossToCubeMapFaces(const Bitmap& b);
