
=== Section 13.2: ==============================================================

for (i = 0; i < N; i++) {
    ...A...;
    ...B...;
    ...C...; 
}

--------------------------------------------------------------------------------

for (i = 0; i < N; i++)
    ...A...;
for (i = 0; i < N; i++)
    ...B...;
for (i = 0; i < N; i++)
    ...C...;

--------------------------------------------------------------------------------

if (m > n) {
    for (int i = a; i < b; i++)
        c[i] = (big expression involving i) * d[i] + (second big expression involving i);
} else {
    for (int i = e; i < f; i++)
        g[i] = (big expression involving i) * h[i] + (second big expression involving i);
}

--------------------------------------------------------------------------------

if (m > n) {
    lo = a; hi = b; out = c; in = d;
} else {
    lo = e; hi = f; out = g; in = h;
}
for (int i = lo; i < hi; i++)
    out[i] = (big expression involving i) * in[i] + (second big expression involving i);

=== Section 13.3.1: ============================================================

struct X {                  struct Y {                       struct Z {
    int8 a;                     int8 a, pad_a[7];                int64 b;
    int64 b;                    int64 b;                         int64 e;
    int8 c;                     int8 c, pad_c[1];                float f;
    int16 d;                    int16 d, pad_d[2];               int16 d;
    int64 e;                    int64 e;                         int8 a;
    float f;                    float f, pad_f[1];               int8 c;
};                          };                               };

--------------------------------------------------------------------------------

struct S {
    int32 value;
    int32 count;
    ...
} elem[1000];

// Find the index of the element with largest value
int index = 0;
for (int i = 0; i < 1000; i++)
    if (elem[i].value > elem[index].value) index = i;
// Increment the count field of that element
elem[index].count++;

--------------------------------------------------------------------------------

// Hot fields of S
struct S1 {
    int32 value;
} elem1[1000];

// Cold fields of S
struct S2 {
    int32 count;
    ...
} elem2[1000];

// Find the index of the element with largest value
int index = 0;
for (int i = 0; i < 1000; i++)
    if (elem1[i].value > elem1[index].value) index = i;
// Increment the count field of that element
elem2[index].count++;

=== Section 13.3.3: ============================================================

// Loop through and process all 4n elements
for (int i = 0; i < 4 * n; i++)
    Process(elem[i]);

--------------------------------------------------------------------------------

const int kLookAhead = 4;            // Experiment to find which fixed distance works best
Prefetch(&elem[0]);                  // Prefetch first four elements
for (int i = 0; i < 4 * n; i += 4) { // Unrolled. Process and step 4 elements at a time
    Prefetch(&elem[i + kLookAhead]); // Prefetch cache line a few elements ahead
    Process(elem[i + 0]);            // Process the elements that have already
    Process(elem[i + 1]);            // been fetched into memory on the
    Process(elem[i + 2]);            // previous iteration
    Process(elem[i + 3]);
}

--------------------------------------------------------------------------------

void PreorderTraversal(Node *pNode)
{
    Prefetch(pNode->left);           // Greedily prefetch left traversal path
    Process(pNode);                  // Process the current node
    Prefetch(pNode->right);          // Greedily prefetch right traversal path
    PreorderTraversal(pNode->left);  // Recursively visit left subtree
    PreorderTraversal(pNode->right); // then recursively visit right subtree
}

--------------------------------------------------------------------------------

Elem a = elem[0];          // Load the cache line of the first four array elements
for (int i = 0; i < 4 * n; i += 4) {
    Elem e = elem[i + 4];  // Cache miss. Fetches next cache line using nonblocking load
    Elem b = elem[i + 1];  // These following three values are in cache and...
    Elem c = elem[i + 2];  // ...are loaded as hit-under-miss; no stalls
    Elem d = elem[i + 3];
    Process(a);            // Process the data from the cache line that...
    Process(b);            // ...was fetched in the previous iteration
    Process(c);
    Process(d);
    a = e;                 // e now in cache, and so is b, c, and d of next iteration
}

=== Section 13.4.1: ============================================================

union KDNode {
    float splitVal_type;  // nonleaf, type 00 = x, 01 = y, 10 = z-split
    int32 leafIndex_type; // leaf, type 11
};

--------------------------------------------------------------------------------

// Align tree root to start of cache line (64-byte aligned)
void ComputeChildPointers(KDNode *pRoot, KDNode *pNode, KDNode **pLeft, KDNode **pRight)
{
    int32 nodeAddress = (int32)pNode;
    int32 nodeIndex = (nodeAddress & 0x3f) >> 2; // node index within cache line (0-14)
    int32 leftAddress, rightAddress;
    if (nodeIndex < 7) {
        // Three out of four, children are at 2n+1 and 2n+2 within current cache line
        leftAddress = nodeAddress + (nodeAddress & 0x3f) + 4;
        rightAddress = leftAddress + 4;
    } else {
        // The children are roots of subtrees at some other cache lines
        int32 rootAddress = (int32)pRoot;
        int32 cacheLineFromStart = (nodeAddress - rootAddress) >> 6;
        int32 leftCacheLine = 16 * cacheLineFromStart + 1;
        int32 bitIndex = nodeIndex - 7; // (0-7)
        leftAddress = rootAddress + leftCacheLine * 64 + bitIndex * 2 * 64;
        rightAddress = leftAddress + 64; // at next consecutive cache line
    }
    *pLeft = (KDNode *)leftAddress;
    *pRight = (KDNode *)rightAddress;
}

--------------------------------------------------------------------------------

// Align tree root to start of cache line (64-byte aligned)
void ComputeChildPointers(KDNode *pRoot, KDNode *pNode, KDNode **pLeft, KDNode **pRight)
{
    int32 nodeAddress = (int32)pNode;
    int32 nodeIndex = (nodeAddress & 0x3f) >> 2; // node index within cache line (0-14)
    int32 leftAddress, rightAddress;
    if (nodeIndex < 7) {
        // Three out of four children are at 2n+1 and 2n+2 within current cache line
        leftAddress = nodeAddress + (nodeAddress & 0x3f) + 4;
        rightAddress = leftAddress + 4;
    } else {
        // The children are roots of subtrees at some other cache lines
        int32 rootAddress = (int32)pRoot;
        int32 bitIndex = nodeIndex - 7; // (0-7)
        // Last word on cache line specifies linking of subtrees
        int32 linkWord = *((int32 *)(nodeAddress | 0x3c));
        assert(linkWord & (1 << bitIndex)); // must be set
        int32 offset = PopCount8(linkWord & ((1 << bitIndex) - 1));
        leftAddress = rootAddress + ((linkWord >> 8) + offset * 2) * 64;
        rightAddress = leftAddress + 64; // at next consecutive cache line
    }
    *pLeft = (KDNode *)leftAddress;
    *pRight = (KDNode *)rightAddress;
}

--------------------------------------------------------------------------------

inline int32 PopCount8(int32 n)
{
    n = n - ((n & 0xaa) >> 1);          // Form partial sums of two bits each
    n = (n & 0x33) + ((n >> 2) & 0x33); // Form partial sums of four bits each
    return (n + (n >> 4)) & 0x0f;       // Add four-bit sums together and mask result
}

=== Section 13.4.2: ============================================================

// Uncompressed AABB
struct AABB {
    float & operator [](int n) { return ((float *)this)[n]; }
    Point min;          // The minimum point defining the AABB
    Point max;          // The maximum point defining the AABB
};

// Compressed AABB node
struct PackedAABBNode {
    uint8 flags;        // Bits determining if new extent belong to left or right child
    uint8 newExtent[6]; // New extents, quantized within the parent volume
    ...                 // Potential links to children nodes
};

void ComputeChildAABBs(AABB &parent, PackedAABBNode &node, AABB *left, AABB *right)
{
    for (int i = 0; i < 6; i++) {
        int xyz = i & 3;
        // Compute the actual side value from the quantized newExtent[] value
        float min = parent.min[xyz], max = parent.max[xyz];
        float val = min + (max - min) * (float)node.newExtent[i] / 255.0f;
        // Test bits to see which child gets parent side value and which get new value
        if (node.flags & (1 << i)) {
            (*left)[i] = parent[i];  // Left child gets parent's bound
            (*right)[i] = val;       // ...right child gets computed bound
        } else {
            (*left)[i] = val;        // Left child gets computed bound
            (*right)[i] = parent[i]; // ...right child gets parent's bound
        } 
    }
}

=== Section 13.5.1: ============================================================

// Array of all vertices, to avoid repeating vertices between triangles
Point vertex[NUM_VERTICES];

// Array of all triangles, to avoid repeating triangles between leaves
struct IndexedTriangle {
    int16 i0, i1, i2;
} triangle[NUM_TRIANGLES];

// Variable-size leaf node structure, containing indices into triangle array
struct Leaf {
    int16 numTris; // number of triangles in leaf node
    int16 tri[1];  // first element of variable-size array, with one or more triangles
};

--------------------------------------------------------------------------------

// Explicitly declared triangle, no indirection
struct Triangle {
    Point p0, p1, p2;
};

#define NUM_LEAFCACHE_ENTRIES (128-1)          // 2^N-1 for fast hash key masking w/ '&'

// Cached leaf node, no indirection
struct CachedLeaf {
    Leaf *pLeaf;                               // hash key corresponding to leaf id
    int16 numTris;                             // number of triangles in leaf node
    Triangle triangle[MAX_TRIANGLES_PER_LEAF]; // the cached triangles
} leafCache[NUM_LEAFCACHE_ENTRIES];

--------------------------------------------------------------------------------

// Compute direct-mapped hash table index from pLeaf pointer (given as input)
int32 hashIndex = ((int32)pLeaf >> 2) & NUM_LEAFCACHE_ENTRIES;

// If leaf not in cache at this address, cache it
CachedLeaf *pCachedLeaf = &leafCache[hashIndex];
if (pCachedLeaf->pLeaf != pLeaf) {
    // Set cache key to be pLeaf pointer
    pCachedLeaf->pLeaf = pLeaf;
    // Fetch all triangles and store in cached leaf (linearized)
    int numTris = pLeaf->numTris;
    pCachedLeaf->numTris = numTris;
    for (int i = 0; i < numTris; i++) {
        Triangle *pCachedTri = &pCachedLeaf->triangle[i];
        IndexedTriangle *pTri = &triangle[pLeaf->tri[i]];
        pCachedTri->p0 = vertex[pTri->i0];
        pCachedTri->p1 = vertex[pTri->i1];
        pCachedTri->p2 = vertex[pTri->i2];
    }
}

// Leaf now in cache so use cached leaf node data for processing leaf node
int numTris = pCachedLeaf->numTris;
for (int i = 0; i < numTris; i++) {
    Triangle *pCachedTri = &pCachedLeaf->triangle[i];
    DoSomethingWithTriangle(pCachedTri->p0, pCachedTri->p1, pCachedTri->p2);
}
...

=== Section 13.6: ==============================================================

int n;
int *p1 = &n; // *p1 references the location of n
int *p2 = &n; // *p2 also references the location of n

--------------------------------------------------------------------------------

void TransformPoint(Point *pOut, Matrix &m, Point &in)
{
    pOut->x = m[0][0] * in.x + m[0][1] * in.y + m[0][2] * in.z;
    pOut->y = m[1][0] * in.x + m[1][1] * in.y + m[1][2] * in.z;
    pOut->z = m[2][0] * in.x + m[2][1] * in.y + m[2][2] * in.z;
}

--------------------------------------------------------------------------------

void TransformPoint(Point *pOut, Matrix &m, Point &in)
{
    float tmpx, tmpy, tmpz;
    tmpx = m[0][0] * in.x + m[0][1] * in.y + m[0][2] * in.z;
    tmpy = m[1][0] * in.x + m[1][1] * in.y + m[1][2] * in.z;
    tmpz = m[2][0] * in.x + m[2][1] * in.y + m[2][2] * in.z;
    pOut->x = tmpx; pOut->y = tmpy; pOut->z = tmpz;
}

=== Section 13.6.1: ============================================================

void Foo(float *v, int *n)
{
    for (int i = 0; i < *n; i++)
        v[i] += 1.0f;
}

--------------------------------------------------------------------------------

void Foo(float *v, int *n)
{
    int t = *n;
    for (int i = 0; i < t; i++)
        v[i] += 1.0f;
}

--------------------------------------------------------------------------------

uint32 i;
float f;
i = *((int32 *)&f); // Illegal way of getting the integer representation of the float f

--------------------------------------------------------------------------------

union {
    uint32 i;
    float f;
} u;
u.f = f;
uint32 i = u.i;

=== Section 13.6.2: ============================================================

void TransformPoint(Point * restrict pOut, Matrix & restrict m, Point & restrict in)
{
    pOut->x = m[0][0] * in.x + m[0][1] * in.y + m[0][2] * in.z;
    pOut->y = m[1][0] * in.x + m[1][1] * in.y + m[1][2] * in.z;
    pOut->z = m[2][0] * in.x + m[2][1] * in.y + m[2][2] * in.z;
}

--------------------------------------------------------------------------------

void ComplexMult(float *a, float *b, float *c)
{
    a[0] = b[0]*c[0] - b[1]*c[1]; // real part in a[0] (b[0] and c[0])
    a[1] = b[0]*c[1] + b[1]*c[0]; // imaginary part in a[1] (b[1] and c[1])
}

--------------------------------------------------------------------------------

float f[3];
ComplexMult(&f[0], &f[0], &f[0]); // a[0] aliases b[0], c[0]; a[1] aliases b[1], c[1]
ComplexMult(&f[1], &f[0], &f[0]); // a[0] aliases b[1], c[1]
ComplexMult(&f[0], &f[1], &f[1]); // a[1] aliases b[0], c[0]

--------------------------------------------------------------------------------

ComplexMult(float *, float *, float *)
lwc1    f3,0x0000(a2)  ; f3 = c[0]
lwc1    f2,0x0004(a2)  ; f2 = c[1]
lwc1    f1,0x0000(a1)  ; f1 = b[0]
lwc1    f0,0x0004(a1)  ; f0 = b[1]
mul.s   f1,f1,f3       ; f1 = f1 * f3
mul.s   f0,f0,f2       ; f0 = f0 * f2
sub.s   f1,f1,f0       ; f1 = f1 – f0
swc1    f1,0x0000(a0)  ; a[0] = f1
lwc1    f2,0x0004(a1)  ; f2 = b[1] (reloaded)
lwc1    f3,0x0000(a2)  ; f3 = c[0] (reloaded)
lwc1    f0,0x0000(a1)  ; f0 = b[0] (reloaded)
lwc1    f1,0x0004(a2)  ; f1 = c[1] (reloaded)
mul.s   f2,f2,f3       ; f2 = f2 * f3
mul.s   f0,f0,f1       ; f0 = f0 * f1
add.s   f0,f0,f2       ; f0 = f0 + f2
jr      ra
swc1    f0,0x0004(a0)  ; a[1] = f0

--------------------------------------------------------------------------------

void ComplexMult(float * restrict a, float * restrict b, float * restrict c)
{
    a[0] = b[0]*c[0] - b[1]*c[1]; // real part
    a[1] = b[0]*c[1] + b[1]*c[0]; // imaginary part
}

--------------------------------------------------------------------------------

ComplexMult(float *, float *, float *)
lwc1    f2,0x0004(a1)  ; f2 = b[1]
lwc1    f0,0x0004(a2)  ; f0 = c[1]
lwc1    f1,0x0000(a1)  ; f1 = b[0]
mul.s   f4,f2,f0       ; f4 = f2 * f0
lwc1    f3,0x0000(a2)  ; f3 = c[0]
mul.s   f0,f1,f0       ; f0 = f1 * f0
mul.s   f2,f2,f3       ; f2 = f2 * f3
mul.s   f1,f1,f3       ; f1 = f1 * f3
add.s   f0,f0,f2       ; f0 = f0 + f2
sub.s   f1,f1,f4       ; f1 = f1 – f4
swc1    f0,0x0004(a0)  ; a[1] = f0
jr      ra
swc1    f1,0x0000(a0)  ; a[0] = f1

=== Section 13.7.1: ============================================================

PX = x1 | x2 | x3 | x4          QX = x5 | x6 | x7 | x8
PY = y1 | y2 | y3 | y4          QY = y5 | y6 | y7 | y8
PZ = z1 | z2 | z3 | z4          QZ = z5 | z6 | z7 | z8
PR = r1 | r2 | r3 | r4          QR = r5 | r6 | r7 | r8

--------------------------------------------------------------------------------

SUB T1,PX,QX     ; T1 = PX - QX
SUB T2,PY,QY     ; T2 = PY - QY
SUB T3,PZ,QZ     ; T3 = PZ - QZ (T1-3 is difference between sphere centers)
ADD T4,PR,QR     ; T4 = PR + QR (T4 is sum of radii)
MUL T1,T1,T1     ; T1 = T1 * T1
MUL T2,T2,T2     ; T2 = T2 * T2
MUL T3,T3,T3     ; T3 = T3 * T3 (T1-3 is squared distance between sphere centers)
MUL R2,T4,T4     ; R2 = T4 * T4 (R2 is square of sum of radii)
ADD T1,T1,T2     ; T1 = T1 + T2
SUB T2,R2,T3     ; T2 = R2 - T3
LEQ Result,T1,T2 ; Result = T1 <= T2

=== Section 13.7.2: ============================================================

MINX = min1x | min2x | min3x | min4x          SX = x1 | x2 | x3 | x4
MINY = min1y | min2y | min3y | min4y          SY = y1 | y2 | y3 | y4
MINZ = min1z | min2z | min3z | min4z          SZ = z1 | z2 | z3 | z4
MAXX = max1x | max2x | max3x | max4x          SR = r1 | r2 | r3 | r4
MAXY = max1y | max2y | max3y | max4y          
MAXZ = max1z | max2z | max3z | max4z          

--------------------------------------------------------------------------------

MAX TX,SX,MINX   ; TX = Max(SX,MINX)  Find point T = (TX, TY, TZ) on/in AABB, closest
MAX TY,SY,MINY   ; TY = Max(SY,MINY)  to sphere center S. Computed by clamping sphere
MAX TZ,SZ,MINZ   ; TZ = Max(SZ,MINZ)  center to AABB extents.
MIN TX,TX,MAXX   ; TX = Min(TX,MAXX)
MIN TY,TY,MAXY   ; TY = Min(TY,MAXY)
MIN TZ,TZ,MAXZ   ; TZ = Min(TZ,MAXZ)
SUB DX,SX,TX     ; DX = SX - TX       D = S - T is vector between S and clamped center T
SUB DY,SY,TY     ; DY = SY - TY
SUB DZ,SZ,TZ     ; DZ = SZ - TZ
MUL R2,SR,SR     ; R2 = SR * SR       Finally compute Result = Dot(D, D) <= SR^2,
MUL DX,DX,DX     ; DX = DX * DX       where SR is sphere radius. (To reduce the latency
MUL DY,DY,DY     ; DY = DY * DY       of having two sequential additions in the dot
MUL DZ,DZ,DZ     ; DZ = DZ * DZ       product, move DZ^2 term over to right-hand side
ADD T1,DX,DY     ; T1 = DX + DY       of comparison and subtract it off SR^2 instead.)
SUB T2,R2,DZ     ; T2 = R2 - DZ       
LEQ Result,T1,T2 ; Result = T1 <= T2

=== Section 13.7.3: ============================================================

MIN1X = min1x | min2x | min3x | min4x          MIN2X = min5x | min6x | min7x | min8x
MIN1Y = min1y | min2y | min3y | min4y          MIN2Y = min5y | min6y | min7y | min8y
MIN1Z = min1z | min2z | min3z | min4z          MIN2Z = min5z | min6z | min7z | min8z
MAX1X = max1x | max2x | max3x | max4x          MAX2X = max5x | max6x | max7x | max8x
MAX1Y = max1y | max2y | max3y | max4y          MAX2Y = max5y | max6y | max7y | max8y
MAX1Z = max1z | max2z | max3z | max4z          MAX2Z = max5z | max6z | max7z | max8z

--------------------------------------------------------------------------------

MAX AX,MIN1X,MIN2X ; AX = Max(MIN1X,MIN2X)  Compute the intersection volume of the
MIN BX,MAX1X,MAX2X ; BX = Min(MAX1X,MAX2X)  two bounding boxes by taking the maximum
MAX AY,MIN1Y,MIN2Y ; AY = Max(MIN1Y,MIN2Y)  value of the minimum extents and the
MIN BY,MAX1Y,MAX2Y ; BY = Min(MAX1Y,MAX2Y)  minimum value of the maximum extents.
MAX AZ,MIN1Z,MIN2Z ; AZ = Max(MIN1Z,MIN2Z)
MIN BZ,MAX1Z,MAX2Z ; BZ = Min(MAX1Z,MAX2Z)
LEQ T1,AX,BX       ; T1 = AX <= BX          If the intersection volume is valid (if
LEQ T2,AY,BY       ; T2 = AY <= BY          the two AABBs are overlapping) the
LEQ T3,AZ,BZ       ; T3 = AZ <= BZ          resulting minimum extents must be smaller
AND T4,T1,T2       ; T4 = T1 && T2          than the resulting maximum extents.
AND Result,T3,T4   ; Result = T3 && T4

=== Section 13.8: ==============================================================

uint32 SmallPrime(uint32 x)
{
    if ((x == 2) || (x == 3) || (x == 5) || (x == 7) || (x == 11))
        return 1;
    return 0;
}

--------------------------------------------------------------------------------

00401150   mov         eax,dword ptr [esp+4]   ; fetch x
00401154   cmp         eax,2                   ; if (x == 2) goto RETURN_1
00401157   je          00401170
00401159   cmp         eax,3                   ; if (x == 3) goto RETURN_1
0040115C   je          00401170
0040115E   cmp         eax,5                   ; if (x == 5) goto RETURN_1
00401161   je          00401170
00401163   cmp         eax,7                   ; if (x == 7) goto RETURN_1
00401166   je          00401170
00401168   cmp         eax,11                  ; if (x == 11) goto RETURN_1
0040116B   je          00401170
0040116D   xor         eax,eax                 ; return 0
0040116F   ret
00401170   mov         eax,1                   ; RETURN_1: return 1
00401175   ret

--------------------------------------------------------------------------------

uint32 SmallPrime(uint32 x)
{
    const uint32 PRIME_BITS = (1 << 2) | (1 << 3) | (1 << 5) | (1 << 7) | (1 << 11);
    uint32 mask = (x < 32);
    return (PRIME_BITS >> x) & mask;
}

--------------------------------------------------------------------------------

00401180   mov         ecx,dword ptr [esp+4]   ; fetch x
00401184   mov         edx,8Ach                ; PRIME_BITS = ...
00401189   cmp         ecx,32                  ; x < 32
0040118C   sbb         eax,eax
0040118E   shr         edx,cl                  ; edx = PRIME_BITS >> “x”
00401190   neg         eax                     ; eax = mask
00401192   and         eax,edx
00401194   ret                                 ; return (PRIME_BITS >> x) & mask
