#ifndef SKYBOX_H
#define SKYBOX_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
//#include "drawable.h"

//class SkyBox : public Drawable
class SkyBox {
private:
    unsigned int vaoHandle{};

public:
    SkyBox();

    void render() const;
};

#endif // SKYBOX_H
