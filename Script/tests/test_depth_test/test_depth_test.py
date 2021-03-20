# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# test_depth_test.py
# created on 2020/12/22
# usage: test_depth_test

# coding=utf-8
# 4-light.py
# created on 2020/10/20
# author @zoloypzuo
# usage: 4-light

from OpenGL.GL import *
from OpenGL.GLU import *
from OpenGL.GLUT import *


    # (角度,x,y,z)
def init():
    """
    Initialize material property, light source, lighting model, and depth buffer.
    :return:
    """
    mat_specular = [1., 0., 1., 1.]
    mat_shininess = [50.]
    light_position = [1., 1., 1., 0.]

    light_ambient = [0., 0., 1., 1.]
    light_diffuse = [0., 0., 1., 1.]
    light_specular = [0., 0., 1., 1.]

    light_model_ambient = [.2, .2, .2, 1.]
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, light_model_ambient)

    # glClearColor(0., 0., 0., 0.)

    glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular)
    glMaterialfv(GL_FRONT, GL_SHININESS, mat_shininess)
    glLightfv(GL_LIGHT0, GL_AMBIENT, light_ambient)
    glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse)
    glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular)
    glLightfv(GL_LIGHT0, GL_POSITION, light_position)

    glEnable(GL_LIGHTING)
    glEnable(GL_LIGHT0)
    glDepthFunc(GL_LESS)
    glEnable(GL_DEPTH_TEST)


def display():
    # 清除之前画面
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    # glClear(GL_COLOR_BUFFER_BIT)
    # glRotatef(.05, .05, .05, .05)
    # (角度,x,y,z)
    # glutSolidTeapot(0.5)

    glColor3f(0, 0, 0)
    glPushMatrix()
    glTranslatef(0,0,0)
    glutSolidSphere(0.3, 5, 4)
    glPopMatrix()

    # glColor3f(0.75, 0.75, 0.75)
    # glPushMatrix()
    # glTranslatef(0,0,0)
    # glScalef(1.0, 0.1, 1.0)
    # glutSolidSphere(0.6, 5, 4)
    # glPopMatrix()

    # 刷新显示
    glFlush()


# 使用glut初始化OpenGL
glutInit()
# 显示模式:GLUT_SINGLE无缓冲直接显示|GLUT_RGBA采用RGB(A非alpha)
glutInitDisplayMode(GLUT_SINGLE | GLUT_RGBA | GLUT_DEPTH)
# 窗口位置及大小-生成
glutInitWindowPosition(0, 0)
glutInitWindowSize(400, 400)
glutCreateWindow(sys.argv[0])

init()

# 调用函数绘制图像
glutDisplayFunc(display)
glutIdleFunc(display)
# 主循环
glutMainLoop()
