#pragma once

struct MeshFileHeader {
    /* Unique 64-bit value to check integrity of the file */
    uint32_t magicValue;

    /* Number of mesh descriptors following this header */
    uint32_t meshCount;

    /* The offset to combined mesh data (this is the base from which the offsets in individual meshes start) */
    uint32_t dataBlockStartOffset;

    /* How much space index data takes */
    uint32_t indexDataSize;

    /* How much space vertex data takes */
    uint32_t vertexDataSize;

    /* According to your needs, you may add additional metadata fields */
};

