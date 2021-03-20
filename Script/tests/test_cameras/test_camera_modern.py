# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# test_camera_modern.py
# created on 2020/12/21
# usage: test_camera_modern
from sys import argv

import glm
from OpenGL.GL import *
from OpenGL.GLU import *
from OpenGL.GLUT import *

from cameras.camera_modern import *


class Window:
	def __init__(self):
		self.interval = int(1000 / 60.)
		self.window_handle = -1
		self.size = (0, 0)
		self.window_aspect = 1.


window = Window()


def ReshapeFunc(w, h):
	if (h > 0):
		window.size = (w, h)
		window.window_aspect = float(w) / float(h)
	camera.SetViewport(0, 0, window.size[0], window.size[1])


# Draw a wire cube! (nothing fancy here)
def DisplayFunc():
	glEnable(GL_CULL_FACE)
	glClearColor(0.1, 0.1, 0.1, 1.0)
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
	glViewport(0, 0, window.size[0], window.size[1])

	camera.Update()

	# Compute the mvp matrix
	# glm.value_ptr(camera.MVP)
	import numpy as np
	# mvp = np.array(camera.MVP, dtype=np.float32)
	mvp = [camera.MVP[i][j] for i in range(4) for j in range(4)]
	glLoadMatrixf(mvp)

	glutWireCube(1)
	glutSwapBuffers()


def KeyboardFunc(c, x, y):
	c_map = {
		"w": FORWARD,
		"a": LEFT,
		"s": BACK,
		"d": RIGHT,
		"q": DOWN,
		"e": UP,
	}
	if c in c_map:
		camera.Move(c_map[c])
	elif ord(c) == 27:  # TODO exit
		exit(0)


def SpecialFunc(args):
	pass


# Used when person clicks mouse
def CallBackMouseFunc(button, state, x, y):
	camera.SetPos(button, state, x, y)


# Used when person drags mouse around
def CallBackMotionFunc(x, y):
	camera.Move2D(x, y)


# Redraw based on fps set for window
def TimerFunc(value):
	if window.window_handle != -1:
		glutTimerFunc(window.interval, TimerFunc, value)
		glutPostRedisplay()


if __name__ == '__main__':
	# glut boilerplate
	glutInit(argv)
	glutInitWindowSize(1024, 512)
	glutInitWindowPosition(0, 0)
	glutInitDisplayMode(GLUT_RGBA | GLUT_DEPTH)
	# Setup window and callbacks
	window.window_handle = glutCreateWindow("MODERN_GL_CAMERA")
	glutReshapeFunc(ReshapeFunc)
	glutDisplayFunc(DisplayFunc)
	glutKeyboardFunc(KeyboardFunc)
	glutMouseFunc(CallBackMouseFunc)
	glutMotionFunc(CallBackMotionFunc)
	glutTimerFunc(window.interval, TimerFunc, 0)

	glewExperimental = GL_TRUE

	# if (glewInit() != GLEW_OK) {
	# cerr << "GLEW failed to initialize." << endl;
	# return 0;
	# }
	# Setup camera
	camera = Camera()
	camera.SetMode(FREE)
	camera.SetPosition(glm.vec3(0, 0, -1))
	camera.SetLookAt(glm.vec3(0, 0, 0))
	camera.SetClipping(.1, 1000)
	camera.SetFOV(45)
	# Start the glut loop!
	glutMainLoop()
