# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# camera_modern.py
# created on 2020/12/21
# usage: camera_modern

from __future__ import division
import glm
from OpenGL.GLUT import GLUT_DOWN, GLUT_LEFT_BUTTON, GLUT_UP
from OpenGL.GL import glViewport

# CameraType

ORTHO = 0
FREE = 1

# CameraDirection
UP = 0
DOWN = 1
LEFT = 2
RIGHT = 3
FORWARD = 4
BACK = 5


class Camera:
	def __init__(self):
		self.camera_mode = FREE

		self.viewport_x = 0
		self.viewport_y = 0

		self.window_width = 0
		self.window_height = 0

		self.aspect = 0
		self.field_of_view = 45
		self.near_clip = 0
		self.far_clip = 0

		self.camera_scale = 0.5
		self.camera_heading = 0
		self.camera_pitch = 0

		self.max_pitch_rate = 5
		self.max_heading_rate = 5
		self.move_camera = False

		self.camera_position = glm.vec3()
		self.camera_position_delta = glm.vec3()
		self.camera_look_at = glm.vec3()
		self.camera_direction = glm.vec3()

		self.camera_up = glm.vec3(0, 1, 0)
		self.mouse_position = glm.vec3()

		self.projection = glm.mat4()
		self.view = glm.mat4()
		self.model = glm.mat4()
		self.MVP = glm.mat4()

	def Reset(self):
		self.camera_up = glm.vec3(0, 1, 0)

	def Update(self):
		# This function updates the camera
		# Depending on the current camera mode, the projection and viewport matricies are computed
		# Then the position and location of the camera is updated
		self.camera_direction = glm.normalize(self.camera_look_at - self.camera_position)
		glViewport(self.viewport_x, self.viewport_y, self.window_width, self.window_height)

		if self.camera_mode == ORTHO:
			self.projection = glm.ortho(-1.5 * self.aspect, 1.5 * self.aspect, -1.5, 1.5, -10., 10.)

		elif self.camera_mode == FREE:
			self.projection = glm.perspective(self.field_of_view, self.aspect, self.near_clip, self.far_clip)
			# detmine axis for pitch rotation
			axis = glm.cross(self.camera_direction, self.camera_up)
			# compute quaternion for pitch based on the camera pitch angle
			pitch_quat = glm.angleAxis(self.camera_pitch, axis)
			# determine heading quaternion from the camera up vector and the heading angle
			heading_quat = glm.angleAxis(self.camera_heading, self.camera_up)
			# add the two quaternions
			temp = glm.cross(pitch_quat, heading_quat)
			temp = glm.normalize(temp)
			# update the direction from the quaternion
			# camera_direction = glm.rotate(temp, self.camera_direction, axis)
			self.camera_direction = temp * self.camera_direction
			# add the camera delta
			self.camera_position += self.camera_position_delta
			# set the look at to be infront of the camera
			self.camera_look_at = self.camera_position + self.camera_direction * 1.0
			# damping for smooth camera
			self.camera_heading *= .5
			self.camera_pitch *= .5
			self.camera_position_delta = self.camera_position_delta * .8

		# compute the MVP
		self.view = glm.lookAt(self.camera_position, self.camera_look_at, self.camera_up)
		self.model = glm.mat4(1.)
		self.MVP = glm.mat4(self.projection * self.view * self.model)

	def Move(self, dir):
		# Given a specific moving direction, the camera will be moved in the appropriate direction
		# For a spherical camera this will be around the look_at point
		# For a free camera a delta will be computed for the direction of movement.
		if not self.camera_mode == FREE:
			return
		dir_map = {
			UP: +self.camera_up * self.camera_scale,
			DOWN: -self.camera_up * self.camera_scale,
			LEFT: -glm.cross(self.camera_direction, self.camera_up) * self.camera_scale,
			RIGHT: +glm.cross(self.camera_direction, self.camera_up) * self.camera_scale,
			FORWARD: +self.camera_direction * self.camera_scale,
			BACK: -self.camera_direction * self.camera_scale
		}
		self.camera_position_delta += dir_map[dir]

	def Move2D(self, x, y):
		# Change the heading and pitch of the camera based on the 2d movement of the mouse
		pass

	def ChangePitch(self, degrees):
		# Change the pitch (up, down) for the free camera
		pass

	def ChangeHeading(self, degrees):
		# Change heading (left, right) for the free camera
		pass

	# ---------------------------------------------------
	# setter
	# 	Changes the camera mode, only three valid modes, Ortho, Free, and Spherical
	# ---------------------------------------------------
	def SetMode(self, mode):
		pass

	def SetPosition(self, pos):
		# Set the position of the camera
		self.camera_position = pos

	def SetLookAt(self, pos):
		# Set's the look at point for the camera
		self.camera_look_at = pos

	def SetFOV(self, fov):
		# Changes the Field of View (FOV) for the camera
		self.field_of_view = fov

	def SetViewport(self, loc_x, loc_y, width, height):
		# Change the viewport location and size
		self.viewport_x = loc_x
		self.viewport_y = loc_y
		self.window_width = width
		self.window_height = height
		self.aspect = width / height

	def SetClipping(self, near_clip_distance, far_clip_distance):
		# Change the clipping distance for the camera
		self.near_clip = near_clip_distance
		self.far_clip = far_clip_distance

	def SetDistance(self, cam_dist):
		pass

	def SetPos(self, button, state, x, y):
		if button == 3 and state == GLUT_DOWN:
			self.camera_position_delta += self.camera_up * 0.05
		elif button == 4 and state == GLUT_DOWN:
			self.camera_position_delta -= self.camera_up * 0.05
		elif button == GLUT_LEFT_BUTTON and state == GLUT_DOWN:
			self.move_camera = True
		elif button == GLUT_LEFT_BUTTON and state == GLUT_UP:
			self.move_camera = False
		self.mouse_position = glm.vec3(x, y, 0)

# TODO translate it
# void Camera::ChangePitch(float degrees) {
# 	//Check bounds with the max pitch rate so that we aren't moving too fast
# 	if (degrees < -max_pitch_rate) {
# 		degrees = -max_pitch_rate;
# 	} else if (degrees > max_pitch_rate) {
# 		degrees = max_pitch_rate;
# 	}
# 	camera_pitch += degrees;
#
# 	//Check bounds for the camera pitch
# 	if (camera_pitch > 360.0f) {
# 		camera_pitch -= 360.0f;
# 	} else if (camera_pitch < -360.0f) {
# 		camera_pitch += 360.0f;
# 	}
# }
# void Camera::ChangeHeading(float degrees) {
# 	//Check bounds with the max heading rate so that we aren't moving too fast
# 	if (degrees < -max_heading_rate) {
# 		degrees = -max_heading_rate;
# 	} else if (degrees > max_heading_rate) {
# 		degrees = max_heading_rate;
# 	}
# 	//This controls how the heading is changed if the camera is pointed straight up or down
# 	//The heading delta direction changes
# 	if (camera_pitch > 90 && camera_pitch < 270 || (camera_pitch < -90 && camera_pitch > -270)) {
# 		camera_heading -= degrees;
# 	} else {
# 		camera_heading += degrees;
# 	}
# 	//Check bounds for the camera heading
# 	if (camera_heading > 360.0f) {
# 		camera_heading -= 360.0f;
# 	} else if (camera_heading < -360.0f) {
# 		camera_heading += 360.0f;
# 	}
# }
# void Camera::Move2D(int x, int y) {
# 	//compute the mouse delta from the previous mouse position
# 	glm::vec3 mouse_delta = mouse_position - glm::vec3(x, y, 0);
# 	//if the camera is moving, meaning that the mouse was clicked and dragged, change the pitch and heading
# 	if (move_camera) {
# 		ChangeHeading(.08f * mouse_delta.x);
# 		ChangePitch(.08f * mouse_delta.y);
# 	}
# 	mouse_position = glm::vec3(x, y, 0);
# }

if __name__ == '__main__':
	# print glm.rotate(glm.mat4(), glm.quat(), 1)
	print glm.quat() * glm.vec3()
