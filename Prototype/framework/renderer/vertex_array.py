# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# vertex_array.py
# created on 2020/12/25
# usage: VAO
from OpenGL import GL as gl


# TODO map self defined shader data types to gl types

class VertexArray(object):
    def __init__(self):
        self.handle = 0
        self.vertex_buffer_index = 0
        self.index_buffer = None  # type: IndexBuffer
        # self.vertex_buffers = []  # type: List[VertexBuffer]
        self.vertex_buffer = None
        self.initialize()

    def initialize(self):
        # self.handle = gl.glCreateVertexArrays(1)
        self.handle = gl.glGenVertexArrays(1)

    def finalize(self):
        gl.glDeleteVertexArrays(1, self.handle)

    def bind(self):
        gl.glBindVertexArray(self.handle)

    def unbind(self):
        gl.glBindVertexArray(0)

    def set_index_buffer(self, index_buffer):
        self.bind()
        self.index_buffer = index_buffer
        self.index_buffer.bind()

    def add_vertex_buffer(self, vertex_buffer, layout_fn):
        self.bind()
        vertex_buffer.bind()
        # TODO handle layout
        # 		const auto& layout = vertexBuffer->GetLayout();
        # 		for (const auto& element : layout)
        # 		{
        # 			switch (element.Type)
        # 			{
        # 				case ShaderDataType::Float:
        # 				case ShaderDataType::Float2:
        # 				case ShaderDataType::Float3:
        # 				case ShaderDataType::Float4:
        # 				case ShaderDataType::Int:
        # 				case ShaderDataType::Int2:
        # 				case ShaderDataType::Int3:
        # 				case ShaderDataType::Int4:
        # 				case ShaderDataType::Bool:
        # 				{
        # 					glEnableVertexAttribArray(m_VertexBufferIndex);
        # 					glVertexAttribPointer(m_VertexBufferIndex,
        # 						element.GetComponentCount(),
        # 						ShaderDataTypeToOpenGLBaseType(element.Type),
        # 						element.Normalized ? GL_TRUE : GL_FALSE,
        # 						layout.GetStride(),
        # 						(const void*)element.Offset);
        # 					m_VertexBufferIndex++;
        # 					break;
        # 				}
        # 				case ShaderDataType::Mat3:
        # 				case ShaderDataType::Mat4:
        # 				{
        # 					uint8_t count = element.GetComponentCount();
        # 					for (uint8_t i = 0; i < count; i++)
        # 					{
        # 						glEnableVertexAttribArray(m_VertexBufferIndex);
        # 						glVertexAttribPointer(m_VertexBufferIndex,
        # 							count,
        # 							ShaderDataTypeToOpenGLBaseType(element.Type),
        # 							element.Normalized ? GL_TRUE : GL_FALSE,
        # 							layout.GetStride(),
        # 							(const void*)(element.Offset + sizeof(float) * count * i));
        # 						glVertexAttribDivisor(m_VertexBufferIndex, 1);
        # 						m_VertexBufferIndex++;
        # 					}
        # 					break;
        # 				}
        # 				default:
        # 					HZ_CORE_ASSERT(false, "Unknown ShaderDataType!");
        # 			}
        # 		}
        layout_fn()
        pass # self.vertex_buffers.append(vertex_buffer) 暂时不用list

    def __len__(self):
        return len(self.vertex_buffer)