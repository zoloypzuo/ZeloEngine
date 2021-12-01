#pragma once

#include <glad/glad.h>
#include <memory>
#include "GLTexture.h"

class GLFramebuffer
{
public:
	GLFramebuffer(int width, int height, GLenum formatColor, GLenum formatDepth);
	~GLFramebuffer();
	GLFramebuffer(const GLFramebuffer&) = delete;
	GLFramebuffer(GLFramebuffer&&) = default;
	GLuint getHandle() const { return handle_; }
	const GLTexture& getTextureColor() const { return *texColor_.get(); }
	const GLTexture& getTextureDepth() const { return *texDepth_.get(); }
	void bind();
	void unbind();

private:
	int width_;
	int height_;
	GLuint handle_ = 0;

	std::unique_ptr<GLTexture> texColor_;
	std::unique_ptr<GLTexture> texDepth_;
};
