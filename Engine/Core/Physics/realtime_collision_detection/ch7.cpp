
=== Section 7.1.3: =============================================================

// Cell position
struct Cell {
    Cell(int32 px, int32 py, int32 pz) { x = px; y = py; z = pz; }
    int32 x, y, z;
};

#define NUM_BUCKETS 1024

// Computes hash bucket index in range [0, NUM_BUCKETS-1]
int32 ComputeHashBucketIndex(Cell cellPos)
{
    const int32 h1 = 0x8da6b343; // Large multiplicative constants;
    const int32 h2 = 0xd8163841; // here arbitrarily chosen primes
    const int32 h3 = 0xcb1ab31f;
    int32 n = h1 * cellPos.x + h2 * cellPos.y + h3 * cellPos.z;
    n = n % NUM_BUCKETS;
    if (n < 0) n += NUM_BUCKETS;
    return n;
}

=== Section 7.1.5: =============================================================

b = (r[i] & c[j]) | (r[i] & c[j+1]) | (r[i+1] & c[j]) | (r[i+1] & c[j+1]);

--------------------------------------------------------------------------------

b = (r[i] | r[i+1]) & (c[j] | c[j+1]);

--------------------------------------------------------------------------------

// Define the two global bit arrays
const int NUM_OBJECTS_DIV_32 = (NUM_OBJECTS + 31) / 32; // Round up
int32 rowBitArray[GRID_HEIGHT][NUM_OBJECTS_DIV_32];
int32 columnBitArray[GRID_WIDTH][NUM_OBJECTS_DIV_32];

void TestObjectAgainstGrid(Object *pObject)
{
    // Allocate temporary bit arrays for all objects and clear them
    int32 mergedRowArray[NUM_OBJECTS_DIV_32];
    int32 mergedColumnArray[NUM_OBJECTS_DIV_32];
    memset(mergedRowArray, 0, NUM_OBJECTS_DIV_32 * sizeof(int32));
    memset(mergedColumnArray, 0, NUM_OBJECTS_DIV_32 * sizeof(int32));

    // Compute the extent of grid cells the bounding sphere of A overlaps.
    // Test assumes objects have been inserted in all rows/columns overlapped
    float ooCellWidth = 1.0f / CELL_WIDTH;
    int x1 = (int)floorf((pObject->x - pObject->radius) * ooCellWidth);
    int x2 = (int)floorf((pObject->x + pObject->radius) * ooCellWidth);
    int y1 = (int)floorf((pObject->y - pObject->radius) * ooCellWidth);
    int y2 = (int)floorf((pObject->y + pObject->radius) * ooCellWidth);
    assert(x1 >= 0 && y1 >= 0 && x2 < GRID_WIDTH && y2 < GRID_HEIGHT);

    // Compute the merged (bitwise-or'ed) bit array of all overlapped grid rows.
    // Ditto for all overlapped grid columns
    for (int y = y1; y <= y2; y++)
        for (int i = 0; i < NUM_OBJECTS_DIV_32; i++)
            mergedRowArray[i] |= rowBitArray[y][i];
    for (int x = x1; x <= x2; x++)
        for (int i = 0; i < NUM_OBJECTS_DIV_32; i++)
            mergedColumnArray[i] |= columnBitArray[x][i];

    // Now go through the intersection of the merged bit arrays and collision test
    // those objects having their corresponding bit set
    for (int i = 0; i < NUM_OBJECTS_DIV_32; i++) {
        int32 objectsMask = mergedRowArray[i] & mergedColumnArray[i];
        while (objectsMask ) {
            // Clears all but lowest bit set (eg. 01101010 -> 00000010)
            int32 objectMask = objectsMask & (objectsMask - 1);
            // Get index number of set bit, test against corresponding object
            // (GetBitIndex(v) returns log_2(v), i.e. n such that 2^n = v)
            int32 objectIndex = GetBitIndex(objectMask) + i * 32;
            TestCollisionAgainstObjectNumberN(objectIndex);
            // Mask out tested object, and continue with any remaining objects
            objectsMask ^= objectMask;
        }
    }
}

=== Section 7.1.6.1: ===========================================================

// Objects placed in single cell based on their bounding sphere center.
// Checking object's cell and all 8 neighboring grid cells:
check object's cell
check northwest neighbor cell
check north neighbor cell
check northeast neighbor cell
check west neighbor cell
check east neighbor cell
check southwest neighbor cell
check south neighbor cell
check southeast neighbor cell

--------------------------------------------------------------------------------

// Objects placed in single cell based on AABB minimum corner vertex.
// Checking object's "minimum corner" cell and up to all 8 neighboring grid cells:
check object's "minimum corner" cell
check north neighbor cell
check northwest neighbor cell
check west neighbor cell
if (object overlaps east cell border) {
    check northeast neighbor cell
    check east neighbor cell
}
if (object overlaps south cell border) {
    check southwest neighbor cell
    check south neighbor cell
    if (object overlaps east cell border)
        check southeast neighbor cell
}

--------------------------------------------------------------------------------

// Objects placed in all cells overlapped by their AABB.
// Checking object's "minimum corner" cell and up to 3 neighboring grid cells:
check object's "minimum corner" cell
if (object overlaps east cell border)
    check east neighbor cell
if (object overlaps south cell border) {
    check south neighbor cell
    if (object overlaps east cell border)
        check southeast neighbor cell
}

=== Section 7.1.6.2: ===========================================================

// Objects placed in single cell based on their bounding sphere center.
// All objects are checked for collisions at the same time, so collisions
// in the opposite direction will be handled when checking the objects
// existing in those cells.
check object's cell
check east neighbor cell
check southwest neighbor cell
check south neighbor cell
check southeast neighbor cell

--------------------------------------------------------------------------------

// Objects placed in single cell based on AABB minimum corner vertex.
// All objects are checked for collisions at the same time, so collisions
// in the opposite direction will be handled when checking the objects
// existing in those cells.
check object's "minimum corner" cell
check southwest neighbor cell
if (object overlaps east cell border)
    check east neighbor cell
if (object overlaps south cell border) {
    check south neighbor cell
    if (object overlaps east cell border)
        check southeast neighbor cell
}

=== Section 7.2.1: =============================================================

struct HGrid {
    uint32 occupiedLevelsMask;            // Initially zero (Implies max 32 hgrid levels)
    int objectsAtLevel[HGRID_MAX_LEVELS]; // Initially all zero
    Object *objectBucket[NUM_BUCKETS];    // Initially all NULL
    int timeStamp[NUM_BUCKETS];           // Initially all zero
    int tick;
};

--------------------------------------------------------------------------------

struct Object {
    Object *pNextObject; // Embedded link to next hgrid object
    Point pos;           // x, y (and z) position for sphere (or top left AABB corner)
    float radius;        // Radius for bounding sphere (or width of AABB)
    int bucket;          // Index of hash bucket object is in
    int level;           // Grid level for the object
    ...                  // Object data
};

--------------------------------------------------------------------------------

const float SPHERE_TO_CELL_RATIO = 1.0f/4.0f; // Largest sphere in cell is 1/4*cell size

--------------------------------------------------------------------------------

const float CELL_TO_CELL_RATIO = 2.0f; // Cells at next level are 2*side of current cell

--------------------------------------------------------------------------------

void AddObjectToHGrid(HGrid *grid, Object *obj)
{
    // Find lowest level where object fully fits inside cell, taking RATIO into account
    int level;
    float size = MIN_CELL_SIZE, diameter = 2.0f * obj->radius;
    for (level = 0; size * SPHERE_TO_CELL_RATIO < diameter; level++)
        size *= CELL_TO_CELL_RATIO;

    // Assert if object is larger than largest grid cell
    assert(level < HGRID_MAX_LEVELS);

    // Add object to grid square, and remember cell and level numbers,
    // treating level as a third dimension coordinate
    Cell cellPos((int)(obj->pos.x / size), (int)(obj->pos.y / size), level);
    int bucket = ComputeHashBucketIndex(cellPos);
    obj->bucket= bucket;
    obj->level = level;
    obj->pNextObject = grid->objectBucket[bucket];
    grid->objectBucket[bucket] = obj;

    // Mark this level as having one more object. Also indicate level is in use
    grid->objectsAtLevel[level]++;
    grid->occupiedLevelsMask |= (1 << level);
}

--------------------------------------------------------------------------------

void RemoveObjectFromHGrid(HGrid *grid, Object *obj)
{
    // One less object on this grid level. Mark level as unused if no objects left
    if (--grid->objectsAtLevel[obj->level] == 0)
        grid->occupiedLevelsMask &= ~(1 << obj->level);

    // Now scan through list and unlink object 'obj'
    int bucket= obj->bucket;
    Object *p = grid->objectBucket[bucket];
    // Special-case updating list header when object is first in list
    if (p == obj) {
        grid->objectBucket[bucket] = obj->pNextObject;
        return;
    }
    // Traverse rest of list, unlinking 'obj' when found
    while (p) {
        // Keep q as trailing pointer to previous element
        Object *q = p;
        p = p->pNextObject;
        if (p == obj) {
            q->pNextObject = p->pNextObject; // unlink by bypassing
            return;
        }
    }
    assert(0); // No such object in hgrid
}

--------------------------------------------------------------------------------

// Test collisions between object and all objects in hgrid
void CheckObjAgainstGrid(HGrid *grid, Object *obj,
                         void (*pCallbackFunc)(Object *pA, Object *pB))
{
    float size = MIN_CELL_SIZE;
    int startLevel = 0;
    uint32 occupiedLevelsMask = grid->occupiedLevelsMask;
    Point pos = obj->pos;

    // If all objects are tested at the same time, the appropriate starting
    // grid level can be computed as:
    // float diameter = 2.0f * obj->radius;
    // for ( ; size * SPHERE_TO_CELL_RATIO < diameter; startLevel++) {
    //     size *= CELL_TO_CELL_RATIO;
    //     occupiedLevelsMask >>= 1;
    // }

    // For each new query, increase time stamp counter
    grid->tick++;

    for (int level = startLevel; level < HGRID_MAX_LEVELS;
                     size *= CELL_TO_CELL_RATIO, occupiedLevelsMask >>= 1, level++) {
        // If no objects in rest of grid, stop now
        if (occupiedLevelsMask == 0) break;
        // If no objects at this level, go on to the next level
        if ((occupiedLevelsMask & 1) == 0) continue;

        // Compute ranges [x1..x2, y1..y2] of cells overlapped on this level. To
        // make sure objects in neighboring cells are tested, by increasing range by
        // the maximum object overlap: size * SPHERE_TO_CELL_RATIO
        float delta = obj->radius + size * SPHERE_TO_CELL_RATIO + EPSILON;
        float ooSize = 1.0f / size;
        int x1 = (int)floorf((pos.x - delta) * ooSize);
        int y1 = (int)floorf((pos.y - delta) * ooSize);
        int x2 = (int) ceilf((pos.x + delta) * ooSize);
        int y2 = (int) ceilf((pos.y + delta) * ooSize);

        // Check all the grid cells overlapped on current level
        for (int x = x1; x <= x2; x++) {
            for (int y = y1; y <= y2; y++) {
                // Treat level as a third dimension coordinate
                Cell cellPos(x, y, level);
                int bucket = ComputeHashBucketIndex(cellPos);

                // Has this hash bucket already been checked for this object?
                if (grid->timeStamp[bucket] == grid->tick) continue;
                grid->timeStamp[bucket] = grid->tick;
                    
                // Loop through all objects in the bucket to find nearby objects
                Object *p = grid->objectBucket[bucket];
                while (p) {
                    if (p != obj) {
                        float dist2 = Sqr(pos.x - p->pos.x) + Sqr(pos.y - p->pos.y);
                        if (dist2 <= Sqr(obj->radius + p->radius + EPSILON))
                            pCallbackFunc(obj, p); // Close, call callback function
                    }
                    p = p->pNextObject;
                }
            }
        }
    } // end for level
}

=== Section 7.3.1: =============================================================

// Octree node data structure
struct Node {
    Point center;     // Center point of octree node (not strictly needed)
    float halfWidth;  // Half the width of the node volume (not strictly needed)
    Node *pChild[8];  // Pointers to the eight children nodes
    Object *pObjList; // Linked list of objects contained at this node
};

=== Section 7.3.2: =============================================================

// Preallocates an octree down to a specific depth
Node *BuildOctree(Point center, float halfWidth, int stopDepth)
{
    if (stopDepth < 0) return NULL;
    else {
        // Construct and fill in 'root' of this subtree
        Node *pNode = new Node;
        pNode->center = center;
        pNode->halfWidth = halfWidth;
        pNode->pObjList = NULL;

        // Recursively construct the eight children of the subtree
        Point offset;
        float step = halfWidth * 0.5f;
        for (int i = 0; i < 8; i++) {
            offset.x = ((i & 1) ? step : -step);
            offset.y = ((i & 2) ? step : -step);
            offset.z = ((i & 4) ? step : -step);
            pNode->pChild[i] = BuildOctree(center + offset, step, stopDepth - 1);
        }
        return pNode;
    }
}

--------------------------------------------------------------------------------

struct Object {
    Point center;        // Center point for object
    float radius;        // Radius of object bounding sphere
    ...
    Object *pNextObject; // Pointer to next object when linked into list
};

--------------------------------------------------------------------------------

void InsertObject(Node *pTree, Object *pObject)
{
    int index = 0, straddle = 0;
    // Compute the octant number [0..7] the object sphere center is in
    // If straddling any of the dividing x, y, or z planes, exit directly
    for (int i = 0; i < 3; i++) {
        float delta = pObject->center[i] - pTree->center[i];
        if (Abs(delta) <= pObject->radius) {
            straddle = 1;
            break;
        }
        if (delta > 0.0f) index |= (1 << i); // ZYX
    }
    if (!straddle && pTree->pChild[index]) {
        // Fully contained in existing child node; insert in that subtree
        InsertObject(pTree->pChild[index], pObject);
    } else {
        // Straddling, or no child node to descend into, so
        // link object into linked list at this node
        pObject->pNextObject = pTree->pObjList;
        pTree->pObjList = pObject;
    }
}

--------------------------------------------------------------------------------

if (!straddle) {
    if (pTree->pChild[index] == NULL) {
        pTree->pChild[index] = new Node;
        ...initialize node contents here...
    }
    InsertObject(pTree->pChild[index], pObject);
} else {
    ...same as before...
}

--------------------------------------------------------------------------------

// Tests all objects that could possibly overlap due to cell ancestry and coexistence
// in the same cell. Assumes objects exist in a single cell only, and fully inside it
void TestAllCollisions(Node *pTree)
{
    // Keep track of all ancestor object lists in a stack
    const int MAX_DEPTH = 40;
    static Node *ancestorStack[MAX_DEPTH];
    static int depth = 0; // 'Depth == 0' is invariant over calls

    // Check collision between all objects on this level and all
    // ancestor objects. The current level is included as its own
    // ancestor so all necessary pairwise tests are done
    ancestorStack[depth++] = pTree;
    for (int n = 0; n < depth; n++) {
        Object *pA, *pB;
        for (pA = ancestorStack[n]->pObjList; pA; pA = pA->pNextObject) {
            for (pB = pTree->pObjList; pB; pB = pB->pNextObject) {
                // Avoid testing both A->B and B->A
                if (pA == pB) break;
                // Now perform the collision test between pA and pB in some manner
                TestCollision(pA, pB);
            }
        }
    }

    // Recursively visit all existing children
    for (int i = 0; i < 8; i++)
        if (pTree->pChild[i])
            TestAllCollisions(pTree->pChild[i]);

    // Remove current node from ancestor stack before returning
    depth--;
}

=== Section 7.3.4: =============================================================

// Octree node data structure (hashed)
struct Node {
    Point center;     // Center point of octree node (not strictly needed)
    int key;          // The location (Morton) code for this node
    int8 hasChildK;   // Bitmask indicating which eight children exist (optional)
    Object *pObjList; // Linked list of objects contained at this node
};

--------------------------------------------------------------------------------

int NodeDepth(unsigned int key)
{
    // Keep shifting off three bits at a time, increasing depth counter
    for (int d = 0; key; d++) {
        // If only sentinel bit remains, exit with node depth
        if (key == 1) return d;
        key >>= 3;
    }
    assert(0); // Bad key
}

--------------------------------------------------------------------------------

void VisitLinearOctree(Node *pTree)
{
    // For all eight possible children
    for (int i = 0; i < 8; i++) {
        // See if the ith child exist
        if (pTree->hasChildK & (1 << i)) {
            // Compute new Morton key for the child
            int key = (pTree->key << 3) + i;
            // Using key, look child up in hash table and recursively visit subtree
            Node *pChild = HashTableLookup(gHashTable, key);
            VisitLinearOctree(pChild);
        }
    }
}

=== Section 7.3.5: =============================================================

// Takes three 10-bit numbers and bit-interleaves them into one number
uint32 Morton3(uint32 x, uint32 y, uint32 z)
{
    // z--z--z--z--z--z--z--z--z--z-- : Part1By2(z) << 2
    // -y--y--y--y--y--y--y--y--y--y- : Part1By2(y) << 1
    // --x--x--x--x--x--x--x--x--x--x : Part1By2(x)
    // zyxzyxzyxzyxzyxzyxzyxzyxzyxzyx : Final result
    return (Part1By2(z) << 2) + (Part1By2(y) << 1) + Part1By2(x);
}

--------------------------------------------------------------------------------

// Separates low 10 bits of input by two bits
uint32 Part1By2(uint32 n)
{
    // n = ----------------------9876543210 : Bits initially
    // n = ------98----------------76543210 : After (1)
    // n = ------98--------7654--------3210 : After (2)
    // n = ------98----76----54----32----10 : After (3)
    // n = ----9--8--7--6--5--4--3--2--1--0 : After (4)
    n = (n ^ (n << 16)) & 0xff0000ff; // (1)
    n = (n ^ (n <<  8)) & 0x0300f00f; // (2)
    n = (n ^ (n <<  4)) & 0x030c30c3; // (3)
    n = (n ^ (n <<  2)) & 0x09249249; // (4)
    return n;
}

--------------------------------------------------------------------------------

// Takes two 16-bit numbers and bit-interleaves them into one number
uint32 Morton2(uint32 x, uint32 y)
{
    return (Part1By1(y) << 1) + Part1By1(x);
}

// Separates low 16 bits of input by one bit
uint32 Part1By1(uint32 n)
{
    // n = ----------------fedcba9876543210 : Bits initially
    // n = --------fedcba98--------76543210 : After (1)
    // n = ----fedc----ba98----7654----3210 : After (2)
    // n = --fe--dc--ba--98--76--54--32--10 : After (3)
    // n = -f-e-d-c-b-a-9-8-7-6-5-4-3-2-1-0 : After (4)
    n = (n ^ (n <<  8)) & 0x00ff00ff; // (1)
    n = (n ^ (n <<  4)) & 0x0f0f0f0f; // (2)
    n = (n ^ (n <<  2)) & 0x33333333; // (3)
    n = (n ^ (n <<  1)) & 0x55555555; // (4)
    return n;
}

--------------------------------------------------------------------------------

uint32 Morton2(uint32 x, uint32 y)
{
    // Merge the two 16-bit inputs into one 32-bit value
    uint32 xy = (y << 16) + x;
    // Separate bits of 32-bit value by one, giving 64-bit value
    uint64 t = Part1By1_64BitOutput(xy);
    // Interleave the top bits (y) with the bottom bits (x)
    return (uint32)((t >> 31) + (t & 0x0ffffffff));
}

=== Section 7.3.7: =============================================================

struct KDNode {
    KDNode *child[2]; // 0 = near, 1 = far
    int splitType;    // Which axis split is along (0, 1, 2, ...)
    float splitValue; // Position of split along axis
    ...
};

// Visit k-d tree nodes overlapped by sphere. Call with volNearPt = s->c
void VisitOverlappedNodes(KDNode *pNode, Sphere *s, Point &volNearPt)
{
    if (pNode == NULL) return;

    // Visiting current node, perform work here
    ...

    // Figure out which child to recurse into first (0 = near, 1 = far)
    int first = s->c[pNode->splitType] > pNode->splitValue;

    // Always recurse into the subtree the sphere center is in
    VisitOverlappedNodes(pNode->child[first], s, volNearPt);

    // Update (by clamping) nearest point on volume when traversing far side.
    // Keep old value on the local stack so it can be restored later
    float oldValue = volNearPt[pNode->splitType];
    volNearPt[pNode->splitType] = pNode->splitValue;

    // If sphere overlaps the volume of the far node, recurse that subtree too
    if (SqDistPointPoint(volNearPt, s->c) < s->r * s->r)
        VisitOverlappedNodes(pNode->child[first ^ 1], s, volNearPt);

    // Restore component of nearest pt on volume when returning
    volNearPt[pNode->splitType] = oldValue;
}

=== Section 7.4.1: =============================================================

// Visit all k-d tree nodes intersected by segment S = a + t * d, 0 <= t < tmax
void VisitNodes(KDNode *pNode, Point a, Vector d, float tmax)
{
    if (pNode == NULL) return;

    // Visiting current node, perform actual work here
    ...

    // Figure out which child to recurse into first (0 = near, 1 = far)
    int dim = pNode->splitType;
    int first = a[dim] > pNode->splitValue;

    if (d[dim] == 0.0f) {
        // Segment parallel to splitting plane, visit near side only
        VisitNodes(pNode->child[first], a, d, tmax);
    } else {
        // Find t value for intersection between segment and split plane
        float t = (pNode->splitValue - a[dim]) / d[dim];

        // Test if line segment straddles splitting plane
        if (0.0f <= t && t < tmax) {
            // Yes, traverse near side first, then far side
            VisitNodes(pNode->child[first], a, d, t);
            VisitNodes(pNode->child[first ^ 1], a + t * d, d, tmax - t);
        } else {
            // No, so just traverse near side
            VisitNodes(pNode->child[first], a, d, tmax);
        }
    }
}

=== Section 7.4.2: =============================================================

void VisitCellsOverlapped(float x1, float y1, float x2, float y2)
{
    // Side dimensions of the square cell
    const float CELL_SIDE = 30.0f;

    // Determine start grid cell coordinates (i, j)
    int i = (int)floorf(x1 / CELL_SIDE);
    int j = (int)floorf(y1 / CELL_SIDE);

    // Determine end grid cell coordinates (iend, jend)
    int iend = (int)floorf(x2 / CELL_SIDE);
    int jend = (int)floorf(y2 / CELL_SIDE);

    // Determine in which primary direction to step
    int di = ((x1 < x2) ? 1 : ((x1 > x2) ? -1 : 0));
    int dj = ((y1 < y2) ? 1 : ((y1 > y2) ? -1 : 0));

    // Determine tx and ty, the values of t at which the directed segment
    // (x1,y1)-(x2,y2) crosses the first horizontal and vertical cell
    // boundaries, respectively. Min(tx, ty) indicates how far one can
    // travel along the segment and still remain in the current cell
    float minx = CELL_SIDE * floorf(x1/CELL_SIDE), maxx = minx + CELL_SIDE;
    float tx = ((x1 > x2) ? (x1 - minx) : (maxx - x1)) / Abs(x2 - x1);
    float miny = CELL_SIDE * floorf(y1/CELL_SIDE), maxy = miny + CELL_SIDE;
    float ty = ((y1 > y2) ? (y1 - miny) : (maxy - y1)) / Abs(y2 - y1);

    // Determine deltax/deltay, how far (in units of t) one must step
    // along the directed line segment for the horizontal/vertical
    // movement (respectively) to equal the width/height of a cell
    float deltatx = CELL_SIDE / Abs(x2 - x1);
    float deltaty = CELL_SIDE / Abs(y2 - y1);

    // Main loop. Visits cells until last cell reached
    for (;;) {
        VisitCell(i, j);
        if (tx <= ty) { // tx smallest, step in x
            if (i == iend) break;
            tx += deltatx;
            i += di;
        } else {        // ty smallest, step in y
            if (j == jend) break;
            ty += deltaty;
            j += dj;
        }
    }
}

--------------------------------------------------------------------------------

for (;;) {
    VisitCell(i, j, k);
    if (tx <= ty && tx <= tz) {        // tx smallest, step in x
        if (i == iend) break;
        tx += deltatx;
        i += di;
    } else if (ty <= tx && ty <= tz) { // ty smallest, step in y
        if (j == jend) break;
        ty += deltaty;
        j += dj;
    } else {                           // tz smallest, step in z
        if (k == kend) break;
        tz += deltatz;
        k += dk;
    }
}

=== Section 7.5.1: =============================================================

struct AABB {
    Elem *pMin[3];  // Pointers to the three minimum interval values (one for each axis)
    Elem *pMax[3];  // Pointers to the three maximum interval values (one for each axis)
    Object *pObj;   // Pointer to the actual object contained in the AABB
};
                    
struct Elem {
    AABB *pAABB;    // Back pointer to AABB object (to find matching max/min element)
    Elem *pLeft;    // Pointer to the previous linked list element
    Elem *pRight;   // Pointer to the next linked list element
    float value;    // The actual min or max coordinate value
    int   minmax:1; // A min value or a max value?
};

--------------------------------------------------------------------------------

Elem *gListHead[3];

--------------------------------------------------------------------------------

struct AABB {
    Elem *pMin;      // Pointer to element containing the three minimum interval values
    Elem *pMax;      // Pointer to element containing the three minimum interval values
    Object *pObj;    // Pointer to the actual object contained in the AABB
};

struct Elem {
    AABB *pAABB;     // Back pointer to AABB object (to find matching max/min element)
    Elem *pLeft[3];  // Pointers to the previous linked list element (one for each axis)
    Elem *pRight[3]; // Pointers to the next linked list element (one for each axis)
    float value[3];  // All min or all max coordinate values (one for each axis)
    int   minmax:1;  // All min values or all max values?
};

--------------------------------------------------------------------------------

struct AABB {
    Elem min;        // Element containing the three minimum interval values
    Elem max;        // Element containing the three maximum interval values
    Object *pObj;    // Pointer to the actual object contained in the AABB
};

struct Elem {
    Elem *pLeft[3];  // Pointers to the previous linked list element (one for each axis)
    Elem *pRight[3]; // Pointers to the next linked list element (one for each axis)
    float value[3];  // All min or all max coordinate values (one for each axis)
    int   minmax:1;  // All min values or all max values?
};

--------------------------------------------------------------------------------

AABB *GetAABB(Elem *pElem)
{
    return (AABB *)(pElem->minmax ? (pElem - 1) : pElem);
}

--------------------------------------------------------------------------------

enum {
    MIN_ELEM = 0, // Indicates AABB minx, miny, or minz element
    MAX_ELEM = 1  // Indicates AABB maxx, maxy, or maxz element
};

// Initialize the lists, with start and end sentinels
AABB *pSentinel = new AABB;
for (int i = 0; i < 3; i++) {
    pSentinel->min.pLeft[i] = NULL; // not strictly needed
    pSentinel->min.pRight[i] = &pSentinel->max;
    pSentinel->max.pLeft[i] = &pSentinel->min;
    pSentinel->max.pRight[i] = NULL; // not strictly needed
    pSentinel->min.value[i] = -FLT_MAX;
    pSentinel->max.value[i] = FLT_MAX;
    gListHead[i] = &pSentinel->min;
}
// Note backwardness of initializing these two
pSentinel->min.minmax = MAX_ELEM;
pSentinel->max.minmax = MIN_ELEM;

--------------------------------------------------------------------------------

void InsertAABBIntoList(AABB *pAABB)
{
    // For all three axes
    for (int i = 0; i < 3; i++) {
        // Search from start of list
        Elem *pElem = gListHead[i];

        // Insert min cell at position where pElem points to first larger element.
        // Assumes large sentinel value guards from falling off end of list
        while (pElem->value[i] < pAABB->min.value[i])
            pElem = pElem->pRight[i];
        pAABB->min.pLeft[i] = pElem->pLeft[i];
        pAABB->min.pRight[i] = pElem;
        pElem->pLeft[i]->pRight[i] = &pAABB->min;
        pElem->pLeft[i] = &pAABB->min;

        // Insert max cell in the same way. Can continue searching from last
        // position as list is sorted. Also assumes sentinel value present
        while (pElem->value[i] < pAABB->max.value[i])
            pElem = pElem->pRight[i];
        pAABB->max.pLeft[i] = pElem->pLeft[i];
        pAABB->max.pRight[i] = pElem;
        pElem->pLeft[i]->pRight[i] = &pAABB->max;
        pElem->pLeft[i] = &pAABB->max;
    }

    // Now scan through list and add overlap pairs for all objects that
    // this AABB intersects. This pair tracking could be incorporated into
    // the loops above, but is not done here to simplify the code
    for (Elem *pElem = gListHead[0]; ; ) {
        if (pElem->minmax == MIN_ELEM) {
            if (pElem->value[0] > pAABB->max.value[0])
                break;
            if (AABBOverlap(pAABB, GetAABB(pElem)))
                AddCollisionPair(pAABB, GetAABB(pElem));
        } else if (pElem->value[0] < pAABB->min.value[0])
            break;
    }
}

--------------------------------------------------------------------------------

// This updating code assumes all other elements of list are sorted
void UpdateAABBPosition(AABB *pAABB)
{
    // For all three axes
    for (int i = 0; i < 3; i++) {
        Elem *pMin = &pAABB->min, *pMax = &pAABB->max, *t;

        // Try to move min element to the left. Move the roaming pointer t left
        // for as long as it points to elem with value larger than pMin's. While
        // doing so, keep track of the update status of any AABBs passed over
        for (t = pMin->pLeft[i]; pMin->value[i] < t->value[i]; t = t->pLeft[i])
            if (t->minmax == MAX_ELEM)
                if (AABBOverlap(pAABB, GetAABB(t)))
                    if (!HasCollisionPair(pAABB, GetAABB(t)))
                        AddCollisionPair(pAABB, GetAABB(t));
        // If t moves from its original position, move pMin into new place
        if (t != pMin->pLeft[i])
            MoveElement(i, pMin, t);

        // Similarly to above, try to move max element to the right
        for (t = pMax->pRight[i]; pMax->value[i] > t->value[i]; t = t->pRight[i])
            if (t->minmax == MIN_ELEM)
                if (AABBOverlap(pAABB, GetAABB(t)))
                    if (!HasCollisionPair(pAABB, GetAABB(t)))
                        AddCollisionPair(pAABB, GetAABB(t));
        if (t != pMax->pRight[i])
            MoveElement(i, pMax, t->pLeft[i]);

        // Similarly to above, try to move min element to the right
        for (t = pMin->pRight[i]; pMin->value[i] > t->value[i]; t = t->pRight[i])
            if (t->minmax == MAX_ELEM)
                if (HasCollisionPair(pAABB, GetAABB(t)))
                    DeleteCollisionPair(pAABB, GetAABB(t));
        if (t != pMin->pRight[i])
            MoveElement(i, pMin, t->pLeft[i]);

        // Similarly to above, try to move max element to the left
        for (t = pMax->pLeft[i]; pMax->value[i] < t->value[i]; t = t->pLeft[i])
            if (t->minmax == MIN_ELEM)
                if (HasCollisionPair(pAABB, GetAABB(t)))
                    DeleteCollisionPair(pAABB, GetAABB(t));
        if (t != pMax->pLeft[i])
            MoveElement(i, pMax, t);

    }
}

--------------------------------------------------------------------------------

void MoveElement(int i, Elem *pElem, Elem *pDest)
{
    // Unlink element...
    pElem->pLeft[i]->pRight[i] = pElem->pRight[i];
    pElem->pRight[i]->pLeft[i] = pElem->pLeft[i];
    // ...and relink it _after_ the destination element
    pElem->pLeft[i] = pDest;
    pElem->pRight[i] = pDest->pRight[i];
    pDest->pRight[i]->pLeft[i] = pElem;
    pDest->pRight[i] = pElem;
}

=== Section 7.5.2: =============================================================

struct AABB {
    Point min;
    Point max;
    ...
};

AABB *gAABBArray[MAX_OBJECTS];

--------------------------------------------------------------------------------

int gSortAxis = 0; // Specifies axis (0/1/2) to sort on (here arbitrarily initialized)

--------------------------------------------------------------------------------

// Comparison function for qsort. Given two arguments A and B must return a
// value of less than zero if A < B, zero if A = B, and greater than zero if A > B
int cmpAABBs(const void *a, const void *b)
{
    // Sort on minimum value along either x, y or z (specified in gSortAxis)
    float minA = (*(AABB **)a)->min[gSortAxis];
    float minB = (*(AABB **)b)->min[gSortAxis];
    if (minA < minB) return -1;
    if (minA > minB) return 1;
    return 0;
}

--------------------------------------------------------------------------------

void SortAndSweepAABBArray(void)
{
    // Sort the array on currently selected sorting axis (gSortAxis)
    qsort(gAABBArray, MAX_OBJECTS, sizeof(AABB *), cmpAABBs);

    // Sweep the array for collisions
    float s[3] = { 0.0f, 0.0f, 0.0f }, s2[3] = { 0.0f, 0.0f, 0.0f }, v[3];
    for (int i = 0; i < MAX_OBJECTS; i++) {
        // Determine AABB center point
        Point p = 0.5f * (gAABBArray[i]->min + gAABBArray[i]->max);
        // Update sum and sum2 for computing variance of AABB centers
        for (int c = 0; c < 3; c++) {
            s[c] += p[c];
            s2[c] += p[c] * p[c];
        }
        // Test collisions against all possible overlapping AABBs following current one
        for (int j = i + 1; j < MAX_OBJECTS; j++) {
            // Stop when tested AABBs are beyond the end of current AABB
            if (gAABBArray[j]->min[gSortAxis] > gAABBArray[i]->max[gSortAxis])
                break;
            if (AABBOverlap(gAABBArray[i], gAABBArray[j]))
                TestCollision(gAABBArray[i], gAABBArray[j]);
        }
    }

    // Compute variance (less a, for comparison unnecessary, constant factor)
    for (int c = 0; c < 3; c++)
        v[c] = s2[c] - s[c] * s[c] / MAX_OBJECTS;

    // Update axis sorted to be the one with greatest AABB variance
    gSortAxis = 0;
    if (v[1] > v[0]) gSortAxis = 1;
    if (v[2] > v[gSortAxis]) gSortAxis = 2;
}

=== Section 7.6: ===============================================================

RenderCell(ClipRegion r, Cell *c)
{
    // If the cell has not already been visited this frame...
    if (c->lastFrameVisited != currentFrameNumber) {
        // ...timestamp it to make sure it is not visited several
        // times due to multiple traversal paths through the cells
        c->lastFrameVisited = currentFrameNumber;
        // Recursively visit all connected cells with visible portals
        for (Portal *pl = c->pPortalList; pl != NULL; pl = pl->pNextPortal) {
            // Clip the portal region against the current clipping region
            ClipRegion visiblePart = ProjectAndIntersectRegion(r, pl->boundary);
            // If portal is not completely clipped its contents must be partially
            // visible, so recursively render other side through the reduced portal
            if (!EmptyRegion(visiblePart))
                RenderCell(visiblePart, pl->pAdjoiningCell);
        }
        // Now render all polygons (done last, for back-to-front rendering)
        for (Polygon *p = c.pPolygonList; p != NULL; p = p->pNextPolygon)
            RenderPolygon(p);
    }
}

=== Section 7.7.1: =============================================================

// Allocate enough words to hold a bit flag for each object pair
const int32 MAX_OBJECTS = 1000;
const int32 MAX_OBJECT_PAIRS = MAX_OBJECTS * (MAX_OBJECTS – 1) / 2;
int32 bitflags[(MAX_OBJECT_PAIRS + 31) / 32];
...
void TestObjectPair(int32 index0, int32 index1)
{
    assert(index0 != index1);
    // Find which object index is smaller and which is larger
    int32 min = index0, max = index1;
    if (index1 < index0) {
        min = index1;
        max = index0;
    }
    // Compute index of bit representing the object pair in the array
    int32 bitindex = min * (2 * MAX_OBJECTS - min - 3) / 2 + max - 1;
    // Look up the corresponding bit in the appropriate word
    int32 mask = 1L << (bitindex & 31);
    if ((bitflags[bitindex >> 5] & mask) == 0) {
        // Bit not set, so pair has not already been processed;
        // process object pair for intersection now
        ...
        // Finally mark object pair as processed
        bitflags[bitindex >> 5] |= mask;
    }
}

=== Section 7.7.3: =============================================================

// Use 8 bits for the time stamp counter [0..255]
#define MAX_COUNTER_VALUE 255

// Divide up all time-stamped objects into as many blocks
#define NUM_BLOCKS MAX_COUNTER_VALUE

--------------------------------------------------------------------------------

blockToClear = 0;
tickCounter = 0;
for (i = 0; i < MAX_OBJECTS; i++)
    object[i].timeStamp = tickCounter;

--------------------------------------------------------------------------------

// Increment the global time stamp counter
tickCounter++;
// Do any and all object testing required for the frame
for (i = 0; i < MAX_OBJECTS; i++) {
    if (object[i].timeStamp == tickCounter) {
        // Already processed this object this frame, do nothing
        continue;
    } else {
        // Process object for intersection here
        ...
        // Mark object as processed
        object[i].timeStamp = tickCounter;
    }
}

--------------------------------------------------------------------------------

// Reset the time stamp for all objects in the current block to be cleared
from = blockToClear * MAX_OBJECTS / MAX_COUNTER_VALUE;
to = (blockToClear + 1) * MAX_OBJECTS / MAX_COUNTER_VALUE;
for (i = from; i < to; i++)
    object[i].timeStamp = tickCounter;
// Indicate that the next block should be cleared the next frame
if (++blockToClear >= NUM_BLOCKS)
    blockToClear = 0;
// Wrap the global time stamp counter when it exceeds its maximum value
if (tickCounter >= MAX_COUNTER_VALUE - 1)
    tickCounter = 0;
