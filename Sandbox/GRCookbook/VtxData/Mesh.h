#pragma once

#include <stdint.h>
#include <glm/glm.hpp>
#include "GRCookbook/Util/Utils.h"
#include "GRCookbook/Util/UtilsMath.h"

constexpr const uint32_t kMaxLODs = 8;
constexpr const uint32_t kMaxStreams = 8;

// All offsets are relative to the beginning of the data block (excluding headers with Mesh list)
struct Mesh final {
    /* Number of LODs in this mesh. Strictly less than MAX_LODS, last LOD offset is used as a marker only */
    uint32_t lodCount = 1;

    /* Number of vertex data streams */
    uint32_t streamCount = 0;

    /* The total count of all previous vertices in this mesh file */
    uint32_t indexOffset = 0;

    uint32_t vertexOffset = 0;

    /* Vertex count (for all LODs) */
    uint32_t vertexCount = 0;

    /* Offsets to LOD data. Last offset is used as a marker to calculate the size */
    uint32_t lodOffset[kMaxLODs] = {0};

    inline uint32_t getLODIndicesCount(uint32_t lod) const { return lodOffset[lod + 1] - lodOffset[lod]; }

    /* All the data "pointers" for all the streams */
    uint32_t streamOffset[kMaxStreams] = {0};

    /* Information about stream element (size pretty much defines everything else, the "semantics" is defined by the shader) */
    uint32_t streamElementSize[kMaxStreams] = {0};

    /* We could have included the streamStride[] array here to allow interleaved storage of attributes.
        For this book we assume tightly-packed (non-interleaved) vertex attribute streams */

    /* Additional information, like mesh name, can be added here */
};
