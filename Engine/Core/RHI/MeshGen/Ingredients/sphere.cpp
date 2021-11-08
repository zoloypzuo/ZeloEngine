#include "sphere.h"
#include <cmath>

Sphere::Sphere(float rad, uint32_t sl, uint32_t st) {
    int nVerts = (sl + 1) * (st + 1);
    int elements = (sl * 2 * (st - 1)) * 3;

    // Verts
    std::vector<GLfloat> p(3 * nVerts);
    // Normals
    std::vector<GLfloat> n(3 * nVerts);
    // Tex coords
    std::vector<GLfloat> tex(2 * nVerts);
    // Elements
    std::vector<GLuint> el(elements);

    // Generate positions and normals
    GLfloat theta, phi;
    GLfloat thetaFac = glm::two_pi<float>() / sl;
    GLfloat phiFac = glm::pi<float>() / st;
    GLfloat nx, ny, nz, s, t;
    GLuint idx = 0, tIdx = 0;
    for (GLuint i = 0; i <= sl; i++) {
        theta = i * thetaFac;
        s = (GLfloat) i / sl;
        for (GLuint j = 0; j <= st; j++) {
            phi = j * phiFac;
            t = (GLfloat) j / st;
            nx = sinf(phi) * cosf(theta);
            ny = sinf(phi) * sinf(theta);
            nz = cosf(phi);
            p[idx] = rad * nx;
            p[idx + 1] = rad * ny;
            p[idx + 2] = rad * nz;
            n[idx] = nx;
            n[idx + 1] = ny;
            n[idx + 2] = nz;
            idx += 3;

            tex[tIdx] = s;
            tex[tIdx + 1] = t;
            tIdx += 2;
        }
    }

    // Generate the element list
    idx = 0;
    for (GLuint i = 0; i < sl; i++) {
        GLuint stackStart = i * (st + 1);
        GLuint nextStackStart = (i + 1) * (st + 1);
        for (GLuint j = 0; j < st; j++) {
            if (j == 0) {
                el[idx] = stackStart;
                el[idx + 1] = stackStart + 1;
                el[idx + 2] = nextStackStart + 1;
                idx += 3;
            } else if (j == st - 1) {
                el[idx] = stackStart + j;
                el[idx + 1] = stackStart + j + 1;
                el[idx + 2] = nextStackStart + j;
                idx += 3;
            } else {
                el[idx] = stackStart + j;
                el[idx + 1] = stackStart + j + 1;
                el[idx + 2] = nextStackStart + j + 1;
                el[idx + 3] = nextStackStart + j;
                el[idx + 4] = stackStart + j;
                el[idx + 5] = nextStackStart + j + 1;
                idx += 6;
            }
        }
    }

    initMeshData(&el, &p, &n, &tex);
}
