#pragma once

#include "Renderer/OpenGL/Drawable/MeshScene/Texture/Bitmap.h"

Bitmap convertEquirectangularMapToVerticalCross(const Bitmap &b);

Bitmap convertVerticalCrossToCubeMapFaces(const Bitmap &b);
