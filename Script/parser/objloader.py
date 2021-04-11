# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# objloader.py
# created on 2020/12/21
# usage: objloader

'''
    Load and pack *.obj files
'''

import logging
import re
import struct

import numpy as np

__all__ = ['Obj', 'default_packer']

__version__ = '0.2.0'

log = logging.getLogger(__file__)

RE_COMMENT = re.compile(r'#[^\n]*\n', flags=re.M)
RE_VERT = re.compile(
	r'^v\s+(-?\d+(?:\.\d+)?(?:[Ee]-?\d+)?)\s+(-?\d+(?:\.\d+)?(?:[Ee]-?\d+)?)\s+(-?\d+(?:\.\d+)?(?:[Ee]-?\d+)?)$')
RE_TEXT = re.compile(
	r'^vt\s+(-?\d+(?:\.\d+)?(?:[Ee]-?\d+)?)\s+(-?\d+(?:\.\d+)?(?:[Ee]-?\d+)?)(?:\s+(-?\d+(?:\.\d+)?(?:[Ee]-?\d+)?))?$')
RE_NORM = re.compile(
	r'^vn\s+(-?\d+(?:\.\d+)?(?:[Ee]-?\d+)?)\s+(-?\d+(?:\.\d+)?(?:[Ee]-?\d+)?)\s+(-?\d+(?:\.\d+)?(?:[Ee]-?\d+)?)$')
RE_TRIANGLE_FACE = re.compile(r'^f\s+(\d+)(/(\d+)?(/(\d+))?)?\s+(\d+)(/(\d+)?(/(\d+))?)?\s+(\d+)(/(\d+)?(/(\d+))?)?$')
RE_QUAD_FACE = re.compile(
	r'^f\s+(\d+)(/(\d+)?(/(\d+))?)?\s+(\d+)(/(\d+)?(/(\d+))?)?\s+(\d+)(/(\d+)?(/(\d+))?)?\s+(\d+)(/(\d+)?(/(\d+))?)?$')

PACKER = 'lambda vx, vy, vz, tx, ty, tz, nx, ny, nz: struct.pack("%df", %s)'


def default_packer(vx, vy, vz, tx, ty, tz, nx, ny, nz):
	return struct.pack('9f', vx, vy, vz, tx, ty, tz, nx, ny, nz)


def int_or_none(x):
	return None if x is None else int(x)


def safe_float(x):
	return 0.0 if x is None else float(x)


class Obj:
	@staticmethod
	def open(filename):
		'''
			Args:
				filename (str): The filename.

			Returns:
				Obj: The object.

			Examples:

				.. code-block:: python

					import ModernGL
					from ModernGL.ext import obj

					model = obj.Obj.open('box.obj')
		'''

		return Obj.fromstring(open(filename).read())

	@staticmethod
	def frombytes(data):
		'''
			Args:
				data (bytes): The obj file content.

			Returns:
				Obj: The object.

			Examples:

				.. code-block:: python

					import ModernGL
					from ModernGL.ext import obj

					content = open('box.obj', 'rb').read()
					model = obj.Obj.frombytes(content)
		'''

		return Obj.fromstring(data.decode())

	@staticmethod
	def fromstring(data):
		'''
			Args:
				data (str): The obj file content.

			Returns:
				Obj: The object.

			Examples:

				.. code-block:: python

					import ModernGL
					from ModernGL.ext import obj

					content = open('box.obj').read()
					model = obj.Obj.fromstring(content)
		'''

		vert = []
		text = []
		norm = []
		face = []

		data = RE_COMMENT.sub('\n', data)

		for line in data.splitlines():
			line = line.strip()

			if not line:
				continue

			match = RE_VERT.match(line)

			if match:
				vert.append(tuple(map(safe_float, match.groups())))
				continue

			match = RE_TEXT.match(line)
			if match:
				text.append(tuple(map(safe_float, match.groups())))
				continue

			match = RE_NORM.match(line)

			if match:
				norm.append(tuple(map(safe_float, match.groups())))
				continue

			match = RE_TRIANGLE_FACE.match(line)

			if match:
				v, t, n = match.group(1, 3, 5)
				face.append((int(v), int_or_none(t), int_or_none(n)))
				v, t, n = match.group(6, 8, 10)
				face.append((int(v), int_or_none(t), int_or_none(n)))
				v, t, n = match.group(11, 13, 15)
				face.append((int(v), int_or_none(t), int_or_none(n)))
				continue

			match = RE_QUAD_FACE.match(line)
			if match:
				# we convert the face in two triangles
				v, t, n = match.group(1, 3, 5)
				face.append((int(v), int_or_none(t), int_or_none(n)))
				v, t, n = match.group(6, 8, 10)
				face.append((int(v), int_or_none(t), int_or_none(n)))
				v, t, n = match.group(11, 13, 15)
				face.append((int(v), int_or_none(t), int_or_none(n)))
				v, t, n = match.group(1, 3, 5)
				face.append((int(v), int_or_none(t), int_or_none(n)))
				v, t, n = match.group(11, 13, 15)
				face.append((int(v), int_or_none(t), int_or_none(n)))
				v, t, n = match.group(16, 18, 20)
				face.append((int(v), int_or_none(t), int_or_none(n)))
				continue

			log.debug('unknown line "%s"', line)

		if not face:
			raise Exception('empty')

		t0, n0 = face[0][1:3]

		for v, t, n in face:
			if (t0 is None) ^ (t is None):
				raise Exception('inconsinstent')

			if (n0 is None) ^ (n is None):
				raise Exception('inconsinstent')

		return Obj(vert, text, norm, face)

	def __init__(self, vert, text, norm, face):
		self.vert = vert
		self.text = text
		self.norm = norm
		self.face = face

	def pack(self, packer=default_packer):
		'''
			Args:
				packer (str or lambda): The vertex attributes to pack.

			Returns:
				bytes: The packed vertex data.

			Examples:

				.. code-block:: python

					import ModernGL
					from ModernGL.ext import obj

					model = obj.Obj.open('box.obj')

					# default packer
					data = model.pack()

					# same as the default packer
					data = model.pack('vx vy vz tx ty tz nx ny nz')

					# pack vertices
					data = model.pack('vx vy vz')

					# pack vertices and texture coordinates (xy)
					data = model.pack('vx vy vz tx ty')

					# pack vertices and normals
					data = model.pack('vx vy vz nx ny nz')

					# pack vertices with padding
					data = model.pack('vx vy vz 0.0')
		'''

		if isinstance(packer, str):
			nodes = packer.split()
			packer = eval(PACKER % (len(nodes), ', '.join(nodes)))

		result = bytearray()

		for v, t, n in self.face:
			vx, vy, vz = self.vert[v - 1]
			tx, ty, tz = self.text[t - 1] if t is not None else (0.0, 0.0, 0.0)
			nx, ny, nz = self.norm[n - 1] if n is not None else (0.0, 0.0, 0.0)
			result += packer(vx, vy, vz, tx, ty, tz, nx, ny, nz)

		return bytes(result)

	def to_array(self):
		return np.array([
			# [
			# 	*(self.vert[v - 1]),
			# 	*(self.norm[n - 1] if n is not None else (0.0, 0.0, 0.0)),
			# 	*(self.text[t - 1] if t is not None else (0.0, 0.0, 0.0)),
			# ]
			(self.vert[v - 1]) +
			(self.norm[n - 1] if n is not None else (0.0, 0.0, 0.0)) +
			(self.text[t - 1] if t is not None else (0.0, 0.0, 0.0))
			for v, t, n in self.face
		], dtype='f4')
