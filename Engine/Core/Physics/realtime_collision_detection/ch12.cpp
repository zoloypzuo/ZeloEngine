
=== Section 12.1: ==============================================================

#define MAX_VERTICES 100000 // max number of vertices that can be welded at once
#define NUM_BUCKETS 128     // number of hash buckets to map grid cells into
#define CELL_SIZE 10.0f     // grid cell size; must be at least 2*WELD_EPSILON
#define WELD_EPSILON 0.5f   // radius around vertex defining welding neighborhood

// Maps unbounded grid cell coordinates (x, y) into an index
// into a fixed-size array of hash buckets
unsigned int GetGridCellBucket(int x, int y)
{
    const unsigned int magic1 = 0x8da6b343; // Large multiplicative constants;
    const unsigned int magic2 = 0xd8163841; // here arbitrarily chosen primes
    unsigned int index = magic1 * x + magic2 * y;
    // Bring index into [0, NUM_BUCKETS) range
    return index % NUM_BUCKETS;
}

--------------------------------------------------------------------------------

int first[NUM_BUCKETS];     // start of linked list for each bucket
int next[MAX_VERTICES];     // links each vertex to next in linked list
Point vertex[MAX_VERTICES]; // unique vertices within tolerance
int numVertices;            // number of unique vertices currently stored

--------------------------------------------------------------------------------

int LocateVertexInBucket(Point v, unsigned int bucket, Point **weldVertex) {
    // Scan through linked list of vertices at this bucket
    for (int index = first[bucket]; index >= 0; index = next[index]) {
        // Weld this vertex to existing vertex if within given distance tolerance
        if (SqDistPointPoint(vertex[index], v) < WELD_EPSILON * WELD_EPSILON) {
            *weldVertex = &vertex[index];
            return 1;
        }
    }

    // No vertex found to weld to. Return v itself
    *weldVertex = &v;
    return 0;
} 

--------------------------------------------------------------------------------

void AddVertexToBucket(Point v, unsigned int bucket)
{
    // Fill next available vertex buffer entry and link it into vertex list
    vertex[numVertices] = v;
    next[numVertices] = first[bucket];
    first[bucket] = numVertices++;
} 

--------------------------------------------------------------------------------

Point *WeldVertex(Point *v)
{
    // Make sure epsilon is not too small for the coordinates used!
    assert(v->x - WELD_EPSILON != v->x && v->x + WELD_EPSILON != v->x);
    assert(v->y - WELD_EPSILON != v->y && v->y + WELD_EPSILON != v->y);

    // Compute cell coordinates of bounding box of vertex epsilon neighborhood
    int top = int((v->y - WELD_EPSILON) / CELL_SIZE);
    int left = int((v->x - WELD_EPSILON) / CELL_SIZE);
    int right = int((v->x + WELD_EPSILON) / CELL_SIZE);
    int bottom = int((v->y + WELD_EPSILON) / CELL_SIZE);

    // To lessen effects of worst-case behavior, track previously tested buckets
    unsigned int prevBucket[4]; // 4 in 2D, 8 in 3D
    int numPrevBuckets = 0;
    
    // Loop over all overlapped cells and test against their buckets
    for (int i = left; i <= right; i++) {
        for (int j = top; j <= bottom; j++) {
            unsigned int bucket = GetGridCellBucket(i, j);
            // If this bucket already tested, don't test it again
            for (int k = 0; k < numPrevBuckets; k++)
                if (bucket == prevBucket[k]) goto skipcell;
            // Add this bucket to visited list, then test against its contents
            prevBucket[numPrevBuckets++] = bucket;
            Point *weldVertex;
            // Call function to step through linked list of bucket, testing
            // if v is within the epsilon of one of the vertices in the bucket
            if (LocateVertexInBucket(*v, bucket, &weldVertex)) return weldVertex;
skipcell: ;
        }
    }
   
    // Couldn't locate vertex, so add it to grid, then return vertex itself
    int x = int(v->x / CELL_SIZE);
    int y = int(v->y / CELL_SIZE);
    AddVertexToBucket(*v, GetGridCellBucket(x, y));
    return v;
}

--------------------------------------------------------------------------------

void WeldVertices(Point v[], int n) {
    // Initialize the hash table of linked vertex lists
    for (int k = 0; k < NUM_BUCKETS; k++)
        first[k] = -1;
    numVertices = 0;

    // Loop over all vertices, doing something with the welded vertex
    for (int i = 0; i < n; i++) {
        Point *pVert = WeldVertex(&v[i]);
        if (pVert != &v[i])
            ...report v[i] was welded to pVert...
    }
}

--------------------------------------------------------------------------------

fwrite(&numVertices, sizeof(numVertices), 1, stream);   // Output number of verts
fwrite(&vertex[0], sizeof(Point), numVertices, stream); // Output verts themselves

=== Section 12.2: ==============================================================

// Basic representation of an edge in the winged-edge representation
struct WingedEdge {
    Vertex *v1, *v2;             // The two vertices of the represented edge (E)
    Face *f1, *f2;               // The two faces connected to the edge
    Edge *e11, *e12, *e21, *e22; // The next edges CW and CCW for each face
};

// Basic representation of a half-edge in the half-edge representation
struct HalfEdge {
    HalfEdge *ht;   // The matching “twin” half-edge of the opposing face
    HalfEdge *hn;   // The next half-edge counter clockwise
    Face *f;        // The face connected to this half-edge
    Vertex *v;      // The vertex constituting the origin of this half-edge
};

// Basic representation of a triangle in the winged-triangle representation
struct WingedTriangle {
    Vertex *v1, *v2, *v3;          // The 3 vertices defining this triangle
    WingedTriangle *t1, *t2, *t3;  // The 3 triangles this triangle connects to

    // Fields specifying to which edge (0-2) of these triangles the connection
    // is made are not strictly required, but they improve performance and can
    // be stored “for free” inside the triangle pointers
    int edge1:2, edge2:2, edge3:2;
};

=== Section 12.2.1: ============================================================

int numTris;      // The number of triangles
Triangle *tri;    // Pointer to face table array containing all the triangles

--------------------------------------------------------------------------------

struct Triangle {
    int vertexIndex[3]; // Indices into vertex table array
};

--------------------------------------------------------------------------------

// Linked-list element to keep track of all triangles a vertex is part of 
struct TriList {
    int triIndex;    // Index to some triangle the vertex is part of
    TriList *pNext;  // Pointer to the next triangle in the linked list
};

--------------------------------------------------------------------------------

// If all vertices are unique, there are at most 3 * MAX_TRIANGLES vertices
const int MAX_VERTICES = 3 * MAX_TRIANGLES;

TriList *triListHead[MAX_VERTICES]; // The head of the list maintained for each vertex
TriList triListEntry[MAX_VERTICES]; // Entries of the linked list

--------------------------------------------------------------------------------

// Reset the list of triangles associated with each vertex
for (int i = 0; i < MAX_VERTICES; i++) triListHead[i] = NULL;
// Reset the triangle list entry counter
int cnt = 0;
// Loop over all triangles and all three of their vertices
for (int i = 0; i < numTris; i++) {
    for (int j = 0; j < 3; j++) {
        // Get the vertex index number
        int vi = tri[i].vertexIndex[j];
        // Fill in a new triangle entry for this vertex
        triListEntry[cnt].triIndex = i;
        // Link new entry first in list and bump triangle entry counter
        triListEntry[cnt].pNext = triListHead[vi];
        triListHead[vi] = &triListEntry[cnt++];
    }
}

--------------------------------------------------------------------------------

for (TriList *pEntry = triListHead[i]; pEntry; pEntry = pEntry->pNext) {
    /* do something with triangle tri[pEntry->triIndex] here */
}

=== Section 12.2.2: ============================================================

// Compare vertices lexicographically and return index (0 or 1) corresponding
// to which vertex is smaller. If equal, consider v0 as the smaller vertex
int SmallerVertex(Vertex v0, Vertex v1)
{
    if (v0.x != v1.x) return v1.x > v0.x;
    if (v0.y != v1.y) return v1.y > v0.y;
    return v1.z > v0.z;
}

--------------------------------------------------------------------------------

struct EdgeEntry {
    int vertexIndex[2];   // The two vertices this edge connects to
    int triangleIndex[2]; // The two triangles this edge connects to
    int edgeNumber[2];    // Which edge of that triangle this triangle connects to
    EdgeEntry *pNext;     // Pointer to the next edge in the current hash bucket
};

--------------------------------------------------------------------------------

// If all edges are unique, there are at most 3 * MAX_TRIANGLES edges
const int MAX_EDGES = 3 * MAX_TRIANGLES;

// Hash table over edges, with a linked list for each hash bucket
EdgeEntry *edgeListHead[MAX_EDGES];
EdgeEntry edgeListEntry[MAX_EDGES]; // Entries of the linked list

--------------------------------------------------------------------------------

// Reset the hash table
for (int i = 0; i < MAX_EDGES; i++) {
    edgeListHead[i] = NULL;
}
// Reset the edge list entry counter
int cnt = 0;
// Loop over all triangles and their three edges
for (int i = 0; i < numTris; i++) {
    for (int j = 2, k = 0; k < 2; j = k, k++) {
        // Get the vertex indices
        int vj = tri[i].vertexIndex[j];
        int vk = tri[i].vertexIndex[k];
        // Treat edges (vj, vk) and (vk, vj) as equal by
        // flipping the indices so vj <= vk (if necessary)
        if (vj > vk) Swap(vj, vk);
        // Form a hash key from the pair (vj, vk) in range 0 <= x < MAX_EDGES
        int hashKey = ComputeHashKey(vj, vk);
        // Check linked list to see if edge already present
        for (EdgeEntry *pEdge = edgeListHead[hashKey]; ; pEdge = pEdge->pNext) {
            // Edge is not in the list of this hash bucket; create new edge entry
            if (pEdge == NULL) {
                // Create new edge entry for this bucket
                edgeListEntry[cnt].vertexIndex[0] = vj;
                edgeListEntry[cnt].vertexIndex[1] = vk;
                edgeListEntry[cnt].triangleIndex[0] = i;
                edgeListEntry[cnt].edgeNumber[0] = j;
                // Link new entry first in list and bump edge entry counter
                edgeListEntry[cnt].pNext = edgeListHead[hashKey];
                edgeListHead[hashKey] = &edgeListEntry[cnt++];
                break;
            }
            // Edge is in this bucket, fill in the second edge
            if (pEdge->vertexIndex[0] == vj && pEdge->vertexIndex[1] == vk) {
                pEdge->triangleIndex[1] = i;
                pEdge->edgeNumber[1] = j;
                break;
            }
        }
    }
}

=== Section 12.2.3: ============================================================

// Unlabel all triangles
for (i = 0; i < numTris; i++)
    tri[i].label = 0;
// Loop over all triangles, identifying and marking all components
int componentNumber = 0;
for (i = 0; i < numTris; i++) {
    // Skip triangles already labeled
    if (tri[i].label != 0) continue;
    // Mark this triangle with the current component number
    tri[i].label = ++componentNumber;
    printf("Component %d starts at triangle %d\n", componentNumber, i);
    // Recursively visit all neighboring triangles and mark them with the same number
    MarkAllNeighbors(i, componentNumber);
}

--------------------------------------------------------------------------------

void MarkAllNeighbors(int triIndex, int componentNumber)
{
    int neighborIndex;
    // Visit neighboring triangles of all three edges (if present)
    for (int i = 0; i < 3; i++) {
        neighborIndex = GetTriangleNeighbor(triIndex, i);
        // If there is a neighboring triangle not already marked...
        if (neighborIndex >= 0 && tri[neighborIndex].label != componentNumber) {
            // ...mark it, and visit it recursively
            tri[neighborIndex].label = componentNumber;
            MarkAllNeighbors(neighborIndex, componentNumber);
        }
    }
}

--------------------------------------------------------------------------------

int GetTriangleNeighbor(int triIndex, int edgeNum)
{
    // Get vertex indices for the edge and compute corresponding hash key
    int vi = tri[triIndex].vertexIndex[edgeNum];
    int vj = tri[triIndex].vertexIndex[(edgeNum + 1) % 3];
    if (vi > vj) Swap(vi, vj);
    int hashKey = ComputeHashKey(vi, vj);
    // Search hash bucket list for a matching edge
    for (EdgeEntry *pEdge = edgeListHead[hashKey]; pEdge != NULL; pEdge = pEdge->pNext) {
        // ...
        if (pEdge->vertexIndex[0] == vi && pEdge->vertexIndex[1] == vj) {
            // Get index of the OTHER triangle of this edge
            int whichEdgeTri = (pEdge->triangleIndex[0] == triIndex);
            return pEdge->triangleIndex[whichEdgeTri];
        }
    }
    // The input edge was a boundary edge, not connected to any other triangle
    return -1;
}

=== Section 12.4.2: ============================================================

// Given n-gon specified by points v[], compute a good representative plane p
void NewellPlane(int n, Point v[], Plane *p)
{
    // Compute normal as being proportional to projected areas of polygon onto the yz,
    // xz, and xy planes. Also compute centroid as representative point on the plane
    Vector centroid(0.0f, 0.0f, 0.0f), normal(0.0f, 0.0f, 0.0f);
    for (int i = n - 1, j = 0; j < n; i = j, j++) {
        normal.x += (v[i].y - v[j].y) * (v[i].z + v[j].z); // projection on yz
        normal.y += (v[i].z - v[j].z) * (v[i].x + v[j].x); // projection on xz
        normal.z += (v[i].x - v[j].x) * (v[i].y + v[j].y); // projection on xy
        centroid += v[j];
    }
    // Normalize normal and fill in the plane equation fields
    p->n = Normalize(normal);
    p->d = Dot(centroid, p->n) / n; // “centroid / n” is the true centroid point
}

--------------------------------------------------------------------------------

// Test if n-gon specified by vertices v[] is planar
int IsPlanar(int n, Point v[])
{
    // Compute a representative plane for the polygon
    Plane p;
    NewellPlane(n, v, &p);
    // Test each vertex to see if it is farther from plane than allowed max distance
    for (int i = 0; i < n; i++) {
        float dist = Dot(p.n, v[i]) - p.d;
        if (Abs(dist) > PLANARITY_EPSILON) return 0;
    }
    // All points passed distance test, so polygon is considered planar
    return 1;
}

=== Section 12.5.1: ============================================================

// Triangulate the CCW n-gon specified by the vertices v[]
void Triangulate(Point v[], int n)
{
    // Set up previous and next links to effectively form a double-linked vertex list
    int prev[MAX_VERTICES], next[MAX_VERTICES];
    for (int i = 0; i < n; i++) {
        prev[i] = i – 1;
        next[i] = i + 1;
    }
    prev[0] = n – 1;
    next[n – 1] = 0;

    // Start at vertex 0
    int i = 0;
    // Keep removing vertices until just a triangle left
    while (n > 3) {
        // Test if current vertex, v[i], is an ear
        int isEar = 1;
        // An ear must be convex (here counterclockwise)
        if (TriangleIsCCW(v[prev[i]], v[i], v[next[i]])) {
            // Loop over all vertices not part of the tentative ear
            int k = next[next[i]];
            do {
                // If vertex k is inside the ear triangle, then this is not an ear
                if (TestPointTriangle(v[k], v[prev[i]], v[i], v[next[i]])) {
                    isEar = 0;
                    break;
                }
                k = next[k];
            } while (k != prev[i]);
        } else {
            // The ‘ear’ triangle is clockwise so v[i] is not an ear
            isEar = 0;
        }

        // If current vertex v[i] is an ear, delete it and visit the previous vertex
        if (isEar) {
            // Triangle (v[i], v[prev[i]], v[next[i]]) is an ear
            ...output triangle here...
            // ‘Delete’ vertex v[i] by redirecting next and previous links
            // of neighboring verts past it. Decrement vertex count
            next[prev[i]] = next[i];
            prev[next[i]] = prev[i];
            n--;
            // Visit the previous vertex next
            i = prev[i];
        } else {
            // Current vertex is not an ear; visit the next vertex
            i = next[i];
        }
    }
}

=== Section 12.5.2: ============================================================

Mesh HertelMehlhorn(Polygon p)
{
    // Produce a triangulated mesh from the original polygon
    Mesh m = TriangulatePolygon(p);
    // Loop over all diagonals of the triangulated polygon
    int numDiagonals = GetNumberOfDiagonals(m);
    for (int i = 0; i < numDiagonals; i++) {
        // Test if the i’th diagonal can be removed without creating
        // a concave vertex; if so, remove the diagonal from the mesh
        if (DiagonalCanBeRemoved(m, i))
            RemoveDiagonal(m, i);
    }
    // The mesh is now a convex decomposition of the polygon. Return it
    return m;
}

=== Section 12.5.4: ============================================================

bool collides = PartiallyInside(A,M) && PartiallyInside(B,M) && PartiallyOutside(C,M);
