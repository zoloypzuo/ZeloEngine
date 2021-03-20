# coding=utf-8
# render_item.py
# created on 2020/10/21
# author @zoloypzuo
# usage: render_item
from OpenGL.GL import *
from OpenGL.GLUT import *

from components.transform import Transform
from texture import TEXTURE_MAP


class IRenderable(object):
    def render(self):
        pass


class Polygon2DRenderer(object):
    """
    多边形
    指定顶点列表和顶点颜色
    """

    def __init__(self):
        super(Polygon2DRenderer, self).__init__()

    def render(self):
        glBegin(GL_POLYGON)
        glVertex2f(-.5, -.5)
        glVertex2f(-.5, +.5)
        glVertex2f(+.5, +.5)
        glVertex2f(+.5, -.5)
        glEnd()


class Polygon3DRenderer(object):
    def __init__(self):
        super(Polygon3DRenderer, self).__init__()

    def render(self):
        glBegin(GL_POLYGON)
        glColor4ub(255, 0, 0, 255)
        glVertex3f(-0.5, -0.25, -2.5)
        glColor4ub(0, 0, 255, 255)
        glVertex3f(0.5, -0.25, -2.5)
        glColor4ub(0, 255, 0, 255)
        glVertex3f(1.0, 0.5, -2.5)
        glColor4ub(255, 0, 0, 255)
        glVertex3f(0.5, 0.5, -2.5)
        glColor4ub(0, 255, 0, 255)
        glVertex3f(0.0, 0.25, -2.5)
        glEnd()


class LineRenderer(object):
    def __init__(self):
        pass

    def render(self):
        glBegin(GL_LINES)
        glVertex2i(1, 1)
        glVertex2i(639, 319)
        glEnd()


def zero_updater():
    return 0, 0, 0


class SolidSphereRenderer(object):
    def __init__(self, position_updater=None, color_updater=None):
        super(SolidSphereRenderer, self).__init__()
        self.position = position_updater or zero_updater
        self.color = color_updater or zero_updater

    def render(self):
        glColor3f(*self.color())
        glPushMatrix()
        glTranslatef(*self.position())
        glutSolidSphere(.3, 5, 4)
        glutSolidTeapot(1)
        glPopMatrix()


# ---------------------------------------------------
# glut primitive
# ---------------------------------------------------
"""

# /usr/include/GL/freeglut_std.h 514
glutSolidCone = platform.createBaseFunction( 
    'glutSolidCone', dll=platform.PLATFORM.GLUT, resultType=None, 
    argTypes=[GLdouble,GLdouble,GLint,GLint],
    doc='glutSolidCone( GLdouble(base), GLdouble(height), GLint(slices), GLint(stacks) ) -> None', 
    argNames=('base', 'height', 'slices', 'stacks'),
)


# /usr/include/GL/freeglut_std.h 510
glutSolidCube = platform.createBaseFunction( 
    'glutSolidCube', dll=platform.PLATFORM.GLUT, resultType=None, 
    argTypes=[GLdouble],
    doc='glutSolidCube( GLdouble(size) ) -> None', 
    argNames=('size',),
)


# /usr/include/GL/freeglut_std.h 519
glutSolidDodecahedron = platform.createBaseFunction( 
    'glutSolidDodecahedron', dll=platform.PLATFORM.GLUT, resultType=None, 
    argTypes=[],
    doc='glutSolidDodecahedron(  ) -> None', 
    argNames=(),
)


# /usr/include/GL/freeglut_std.h 525
glutSolidIcosahedron = platform.createBaseFunction( 
    'glutSolidIcosahedron', dll=platform.PLATFORM.GLUT, resultType=None, 
    argTypes=[],
    doc='glutSolidIcosahedron(  ) -> None', 
    argNames=(),
)


# /usr/include/GL/freeglut_std.h 521
glutSolidOctahedron = platform.createBaseFunction( 
    'glutSolidOctahedron', dll=platform.PLATFORM.GLUT, resultType=None, 
    argTypes=[],
    doc='glutSolidOctahedron(  ) -> None', 
    argNames=(),
)


# /usr/include/GL/freeglut_std.h 512
glutSolidSphere = platform.createBaseFunction( 
    'glutSolidSphere', dll=platform.PLATFORM.GLUT, resultType=None, 
    argTypes=[GLdouble,GLint,GLint],
    doc='glutSolidSphere( GLdouble(radius), GLint(slices), GLint(stacks) ) -> None', 
    argNames=('radius', 'slices', 'stacks'),
)


# /usr/include/GL/freeglut_std.h 531
glutSolidTeapot = platform.createBaseFunction( 
    'glutSolidTeapot', dll=platform.PLATFORM.GLUT, resultType=None, 
    argTypes=[GLdouble],
    doc='glutSolidTeapot( GLdouble(size) ) -> None', 
    argNames=('size',),
)


# /usr/include/GL/freeglut_std.h 523
glutSolidTetrahedron = platform.createBaseFunction( 
    'glutSolidTetrahedron', dll=platform.PLATFORM.GLUT, resultType=None, 
    argTypes=[],
    doc='glutSolidTetrahedron(  ) -> None', 
    argNames=(),
)


# /usr/include/GL/freeglut_std.h 517
glutSolidTorus = platform.createBaseFunction( 
    'glutSolidTorus', dll=platform.PLATFORM.GLUT, resultType=None, 
    argTypes=[GLdouble,GLdouble,GLint,GLint],
    doc='glutSolidTorus( GLdouble(innerRadius), GLdouble(outerRadius), GLint(sides), GLint(rings) ) -> None', 
    argNames=('innerRadius', 'outerRadius', 'sides', 'rings'),
)
"""


def SolidPrimitiveRenderer(type_, *args):
    primitive_map = {
        "teapot": glutSolidTeapot,
        "sphere": glutSolidSphere,
        "cube": glutSolidCube,
        "cone": glutSolidCone
    }
    primitive_fn = primitive_map[type_]

    class Renderer(object):
        def __init__(self, position_updater=None, color_updater=None):
            super(Renderer, self).__init__()
            self.position = position_updater or zero_updater
            self.color = color_updater or zero_updater

        def render(self):
            glColor3f(*self.color())
            # ---------------------------------------------------
            # 设置材质
            # ---------------------------------------------------
            mat_specular = [1., 0., 1., 1.]
            mat_shininess = [50.]
            glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular)
            glMaterialfv(GL_FRONT, GL_SHININESS, mat_shininess)

            glPushMatrix()
            glTranslatef(*self.position())
            primitive_fn(*args)
            glPopMatrix()

    return Renderer


class RenderItem(object):
    def __init__(self):
        super(RenderItem, self).__init__()
        self.transform = None
        self.mesh_render = None
        self.mesh_filter = None
        self.material = None
        self.mesh = None

    @property
    def position(self):
        return self.transform.position

    def render(self):
        pass


class RenderItemTransform(object):
    def __init__(self, transform, renderfn):
        super(RenderItemTransform, self).__init__()
        self.transform = transform  # type: Transform
        self.renderfn = renderfn

    def render(self):
        glPushMatrix()
        glMultMatrixf(self.transform.local_to_world_matrix)
        self.renderfn()
        glPopMatrix()


class SphereRenderer(object):
    def __init__(self):
        super(SphereRenderer, self).__init__()
        self.position = (0, 0, 0)

    def render(self):
        glColor3f(0, 0, 0)
        glPushMatrix()
        glTranslatef(*self.position)
        glutSolidSphere(0.3, 5, 4)
        glPopMatrix()

        glColor3f(0.75, 0.75, 0.75)
        glPushMatrix()
        glTranslatef(self.position[0], 0, self.position[2])
        glScalef(1.0, 0.1, 1.0)
        glutSolidSphere(0.6, 5, 4)
        glPopMatrix()


'''
fail
class TextRenderer(object):
    def __init__(self):
        super(TextRenderer, self).__init__()
        self.x = 0
        self.y = 0
        self.text = "hello world"
        self.font = None
        self.width = 500
        self.height = 300

    def render(self):
        glColor3f(0.0, 0.0, 0.0)
        glDisable(GL_DEPTH_TEST)

        # 暂时在正交投影中建立view matrix
        glMatrixMode(GL_PROJECTION)
        glPushMatrix()
        glLoadIdentity()
        glOrtho(0., self.width, 0., self.height, -1., 1.)

        # move to model view mode
        glMatrixMode(GL_MODELVIEW)
        glPushMatrix()
        glLoadIdentity()

        # get font
        if not self.font:
            self.font = GLUT_BITMAP_HELVETICA_10
        print self.font
        glRasterPos2f(self.x, self.y)

        for letter in self.text:
            if letter == "\n":
                self.y -= 12.
                glRasterPos2f(self.x, self.y)
            glutBitmapCharacter(self.font, letter)

        # cleanup
        glPopMatrix()
        glMatrixMode(GL_PROJECTION)
        glPopMatrix()
        glMatrixMode(GL_MODELVIEW)
        glEnable(GL_DEPTH_TEST)
'''

# rotation
X_AXIS = 0.0
Y_AXIS = 0.0
Z_AXIS = 0.0


class TexturedCubeRenderer(object):
    def __init__(self, tex_name, position_updater=None):
        self.tex_name = tex_name
        self.position_updater = position_updater or zero_updater

    @property
    def texture(self):
        return TEXTURE_MAP[self.tex_name]

    def render(self):
        global X_AXIS, Y_AXIS, Z_AXIS

        glTranslatef(*self.position_updater())

        glRotatef(X_AXIS, 1.0, 0.0, 0.0)
        glRotatef(Y_AXIS, 0.0, 1.0, 0.0)
        glRotatef(Z_AXIS, 0.0, 0.0, 1.0)

        self.texture.bind()
        # Draw Cube (multiple quads)
        glBegin(GL_QUADS)
        # @formatter:off
        glTexCoord2f(0.0, 0.0)
        glVertex3f(-1.0, -1.0, 1.0)
        glTexCoord2f(1.0, 0.0)
        glVertex3f(1.0, -1.0, 1.0)
        glTexCoord2f(1.0, 1.0)
        glVertex3f(1.0, 1.0, 1.0)
        glTexCoord2f(0.0, 1.0)
        glVertex3f(-1.0, 1.0, 1.0)
        glTexCoord2f(1.0, 0.0)
        glVertex3f(-1.0, -1.0, -1.0)
        glTexCoord2f(1.0, 1.0)
        glVertex3f(-1.0, 1.0, -1.0)
        glTexCoord2f(0.0, 1.0)
        glVertex3f(1.0, 1.0, -1.0)
        glTexCoord2f(0.0, 0.0)
        glVertex3f(1.0, -1.0, -1.0)
        glTexCoord2f(0.0, 1.0)
        glVertex3f(-1.0, 1.0, -1.0)
        glTexCoord2f(0.0, 0.0)
        glVertex3f(-1.0, 1.0, 1.0)
        glTexCoord2f(1.0, 0.0)
        glVertex3f(1.0, 1.0, 1.0)
        glTexCoord2f(1.0, 1.0)
        glVertex3f(1.0, 1.0, -1.0)
        glTexCoord2f(1.0, 1.0)
        glVertex3f(-1.0, -1.0, -1.0)
        glTexCoord2f(0.0, 1.0)
        glVertex3f(1.0, -1.0, -1.0)
        glTexCoord2f(0.0, 0.0)
        glVertex3f(1.0, -1.0, 1.0)
        glTexCoord2f(1.0, 0.0)
        glVertex3f(-1.0, -1.0, 1.0)
        glTexCoord2f(1.0, 0.0)
        glVertex3f(1.0, -1.0, -1.0)
        glTexCoord2f(1.0, 1.0)
        glVertex3f(1.0, 1.0, -1.0)
        glTexCoord2f(0.0, 1.0)
        glVertex3f(1.0, 1.0, 1.0)
        glTexCoord2f(0.0, 0.0)
        glVertex3f(1.0, -1.0, 1.0)
        glTexCoord2f(0.0, 0.0)
        glVertex3f(-1.0, -1.0, -1.0)
        glTexCoord2f(1.0, 0.0)
        glVertex3f(-1.0, -1.0, 1.0)
        glTexCoord2f(1.0, 1.0)
        glVertex3f(-1.0, 1.0, 1.0)
        glTexCoord2f(0.0, 1.0)
        glVertex3f(-1.0, 1.0, -1.0)
        # @formatter:on
        glEnd()

        # X_AXIS = X_AXIS - 0.30
        # Z_AXIS = Z_AXIS - 0.30


class DebugPlaneRenderer:
    def render(self):
        glColor3f(1.0, 1.0, 1.0)
        glBegin(GL_LINES)
        i = -2.5
        while i <= 2.5:
            glVertex3f(i, 0, 2.5)
            glVertex3f(i, 0, -2.5)
            glVertex3f(2.5, 0, i)
            glVertex3f(-2.5, 0, i)
            i += 0.25
        glEnd()
