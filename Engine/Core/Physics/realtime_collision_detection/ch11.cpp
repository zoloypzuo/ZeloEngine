
=== Section 11.2.2: ============================================================

float a = 1.0e20; float b = 1.0e-20;
float c = a / b; // gives c = +INF
float d = -a / b; // gives d = -INF 

--------------------------------------------------------------------------------

float a = 0.0f; float b = a / a; // gives b = NaN (and _not_ 1.0f) 

--------------------------------------------------------------------------------

if (a > b) x; else y;

--------------------------------------------------------------------------------

if (a <= b) y; else x;

--------------------------------------------------------------------------------

// Test if val is in the range [min..max]  int NumberInRange(float val, float min, float max)
{
    if (val < min || val > max) return 0;
    // Here val assumed to be in [min..max] range, but could actually be NaN
    ...
    return 1;
} 

--------------------------------------------------------------------------------

// Test if val is in the range [min..max] int NumberInRange(float val, float min, float max)
{
    if (val >= min && val <= max) {
        // Here val guaranteed to be in [min..max] range (and not be NaN)
        ...
        return 1;
    } else return 0;
} 

--------------------------------------------------------------------------------

// Test if segment AB intersects plane p. If so, return 1, along with 
// the intersection t value and the intersection point Q. If not, return 0
int IntersectSegmentPlane(Point a, Point b, Plane p, float &t, Point &q)
{
    // Compute t value at which the directed line ab intersects the plane
    Vector ab = b - a;
    t = (p.d - Dot(p.n, a)) / Dot(p.n, ab);

    // If t in [0..1] compute and return intersection point
    if (t >= 0.0f && t <= 1.0f) {
        q = a + t * ab;
        return 1;
    }
    // Else t is +INF, -INF, NaN, or not in [0..1], so no intersection
    return 0;
}

=== Section 11.2.3: ============================================================

float tenth = 0.1f; if (tenth * 10.0f > 1.0f)
    printf("Greater than\n");
else if (tenth * 10.0f < 1.0f)
    printf("Less than\n");
else if (tenth * 10.0f == 1.0f)
    printf("Equal\n");
else
    printf("Huh?\n"); 

--------------------------------------------------------------------------------

float a = 9876543.0f; float b = -9876547.0f;
float c = 3.45f;

--------------------------------------------------------------------------------

(a + b) + c = (9876543.0f + -9876547.0f) + 3.45f = -4.0f + 3.45f = -0.55f
a + (b + c) = 9876543.0f + (-9876547.0f + 3.45f) = 9876543.0f + -9876544.0f = -1.0f 

=== Section 11.3.1: ============================================================

if (x == 0.0f) ...

--------------------------------------------------------------------------------

if (Abs(x) <= epsilon) ...

--------------------------------------------------------------------------------

if (Abs(x - y) <= epsilon) ... // Absolute tolerance comparison

--------------------------------------------------------------------------------

if (Abs(x / y - 1.0f) <= epsilon) ...

--------------------------------------------------------------------------------

if (Abs((x - y) / y) <= epsilon) ...

--------------------------------------------------------------------------------

if (Abs(x - y) <= epsilon * Abs(y)) ...

--------------------------------------------------------------------------------

if (Abs(x - y) <= epsilon * Max(Abs(x), Abs(y))) ... // Relative tolerance comparison 

--------------------------------------------------------------------------------

if (Abs(x - y) <= epsilon * Max(Abs(x), Abs(y), 1.0f)) ... // Combined comparison 

--------------------------------------------------------------------------------

if (Abs(x - y) <= epsilon * (Abs(x) + Abs(y) + 1.0f)) ... // Combined comparison

=== Section 11.5.1: ============================================================

bool overflow = (a > ~b);
unsigned int c = a + b;

--------------------------------------------------------------------------------

unsigned int c = a + b;
bool overflow = (c < a);

--------------------------------------------------------------------------------

bool overflow = (a > 0 ? (b > INT_MAX - a) : (b < INT_MIN - a));
signed int c = a + b;

--------------------------------------------------------------------------------

signed int c = a + b;
bool overflow = ((a ^ b) >= 0 && (b ^ c) < 0);

--------------------------------------------------------------------------------

typedef uint32 uint64[2];

void Uadd64(uint64 x, uint64 y, uint64 res)
{
    uint32 a = x[1] + y[1]; // Compute sum of higher 32 bits
    uint32 b = x[0] + y[0]; // Compute sum of lower 32 bits
    if (b < x[0]) a++;      // Carry if low sum overflowed
    res[0] = b; 
    res[1] = a;
}

--------------------------------------------------------------------------------

void Umult32to64(uint32 x, uint32 y, uint64 res)
{
    uint16 xh = x >> 16, xl = x & 0xffff;
    uint16 yh = y >> 16, yl = y & 0xffff;
    uint32 a = xh * yh;
    uint32 b = xh * yl;
    uint32 c = xl * yh;
    uint32 d = xl * yl;
    d = d + (b << 16);
    if (d < (b << 16)) a++;
    d = d + (c << 16);
    if (d < (c << 16)) a++;
    a = a + (b >> 16) + (c >> 16);
    res[0] = d;
    res[1] = a;
}

=== Section 11.5.2: ============================================================

// Compare rational numbers a/b and c/d
int Order(int a, int b, int c, int d)
{
    // Make c and d be nonnegative
    if (c < 0) b = -b, c = -c;
    if (d < 0) a = -a, d = -d;

    // Handle a and/or b being negative
    if (a < 0 && b < 0) {
        int olda = a, oldb = b;
        a = c; b = d; c = -olda; d = -oldb;
    }
    if (a < 0) return LESS_THAN;
    if (b < 0) return GREATER_THAN;

    // Make a <= b, exit if order becomes known
    if (a > b) {
        if (c < d) return GREATER_THAN;
        int olda = a, oldb = b;
        a = d; b = c; c = oldb; d = olda;
    }
    if (c > d) return LESS_THAN;

    // Do continued fraction expansion (given that 0<=a<=b, 0<=c<=d)
    while (a != 0 && c != 0) {
        int m = d / c;
        int n = b / a;
        if (m != n) {
            if (m < n) return LESS_THAN;
            if (m > n) return GREATER_THAN;
        }
        int olda = a, oldb = b;
        a = d % c; b = c; c = oldb % olda; d = olda;
    }
    if (a == 0) return c == 0 ? EQUAL : LESS_THAN;
    return GREATER_THAN;
}

=== Section 11.5.3: ============================================================

// Test if segment ab intersects plane p. If so, return 1, along with
// an adjusted intersection point q. If not, return 0
int TestSegmentPlane(Point a, Point b, Plane p, Point &q)
{
    // Compute t value, t=tnom/tdenom, for directed segment ab intersecting plane p
    Vector ab = b - a;
    int64 tnom = p.d - Dot(p.n, a);
    int64 tdenom = Dot(p.n, ab);

    // Exit if segment is parallel to plane
    if (tdenom == 0) return 0;

    // Ensure denominator is positive so it can be multiplied through throughout
    if (tdenom < 0) {
        tnom = -tnom;
        tdenom = -tdenom;
    }

    // If t not in [0..1], no intersection
    if (tnom < 0 || tnom > tdenom) return 0;

    // Line segment is definitely intersecting plane. Compute vector d to adjust
    // the computation of q, biasing the result to lie on the side of point a
    Vector d(0,0,0);
    int64 k = tdenom – 1;
    // If a lies behind plane p, round division other way
    if (tdenom > 0) k = -k;
    if (p.n.x > 0) d.x = k; else if (p.n.x < 0) d.x = -k;
    if (p.n.y > 0) d.y = k; else if (p.n.y < 0) d.y = -k;
    if (p.n.z > 0) d.z = k; else if (p.n.z < 0) d.z = -k;

    // Compute and return adjusted intersection point
    q = a + (tnom * ab + d) / tdenom;
    return 1;
}
