#pragma once

#include "Renderer/OpenGL/Drawable/MeshSceneFinal/Texture/Bitmap.h"

Bitmap convertEquirectangularMapToVerticalCross(const Bitmap &b);

Bitmap convertVerticalCrossToCubeMapFaces(const Bitmap &b);
