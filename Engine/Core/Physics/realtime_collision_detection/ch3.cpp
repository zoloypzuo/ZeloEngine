
=== Section 3.4: ===============================================================

// Compute barycentric coordinates (u, v, w) for 
// point p with respect to triangle (a, b, c)
void Barycentric(Point a, Point b, Point c, Point p, float &u, float &v, float &w)
{
    Vector v0 = b - a, v1 = c - a, v2 = p - a;
    float d00 = Dot(v0, v0);
    float d01 = Dot(v0, v1);
    float d11 = Dot(v1, v1);
    float d20 = Dot(v2, v0);
    float d21 = Dot(v2, v1);
    float denom = d00 * d11 - d01 * d01;
    v = (d11 * d20 - d01 * d21) / denom;
    w = (d00 * d21 - d01 * d20) / denom;
    u = 1.0f - v - w;
} 

--------------------------------------------------------------------------------

u = SignedArea(PBC)/SignedArea(ABC),
v = SignedArea(PCA)/SignedArea(ABC), and
w = SignedArea(PAB)/SignedArea(ABC) = 1 - u - v

--------------------------------------------------------------------------------

SignedArea(PBC) = Dot(Cross(B-P, C-P), Normalize(Cross(B-A, C-A))). 

--------------------------------------------------------------------------------

inline float TriArea2D(float x1, float y1, float x2, float y2, float x3, float y3)
{
    return (x1-x2)*(y2-y3) - (x2-x3)*(y1-y2);
}

// Compute barycentric coordinates (u, v, w) for 
// point p with respect to triangle (a, b, c)
void Barycentric(Point a, Point b, Point c, Point p, float &u, float &v, float &w)
{
    // Unnormalized triangle normal
    Vector m = Cross(b - a, c - a);
    // Nominators and one-over-denominator for u and v ratios
    float nu, nv, ood;
    // Absolute components for determining projection plane
    float x = Abs(m.x), y = Abs(m.y), z = Abs(m.z);

    // Compute areas in plane of largest projection
    if (x >= y && x >= z) {
        // x is largest, project to the yz plane
        nu = TriArea2D(p.y, p.z, b.y, b.z, c.y, c.z); // Area of PBC in yz plane
        nv = TriArea2D(p.y, p.z, c.y, c.z, a.y, a.z); // Area of PCA in yz plane
        ood = 1.0f / m.x;                             // 1/(2*area of ABC in yz plane)
    } else if (y >= x && y >= z) {
        // y is largest, project to the xz plane
        nu = TriArea2D(p.x, p.z, b.x, b.z, c.x, c.z);
        nv = TriArea2D(p.x, p.z, c.x, c.z, a.x, a.z);
        ood = 1.0f / -m.y;
    } else {
        // z is largest, project to the xy plane
        nu = TriArea2D(p.x, p.y, b.x, b.y, c.x, c.y);
        nv = TriArea2D(p.x, p.y, c.x, c.y, a.x, a.y);
        ood = 1.0f / m.z;
    }
    u = nu * ood;
    v = nv * ood;
    w = 1.0f - u - v;
}

--------------------------------------------------------------------------------

// Test if point p is contained in triangle (a, b, c)
int TestPointTriangle(Point p, Point a, Point b, Point c)
{
    float u, v, w;
    Barycentric(a, b, c, p, u, v, w);
    return v >= 0.0f && w >= 0.0f && (v + w) <= 1.0f;
}

=== Section 3.6: ===============================================================

struct Plane {
    Vector n;  // Plane normal. Points x on the plane satisfy Dot(n,x) = d
    float d;   // d = dot(n,p) for a given point p on the plane
};

// Given three noncollinear points (ordered ccw), compute the plane equation
Plane ComputePlane(Point a, Point b, Point c)
{
    Plane p;
    p.n = Normalize(Cross(b - a, c - a));
    p.d = Dot(p.n, a);
    return p;
}

=== Section 3.7.1: =============================================================

// Test if quadrilateral (a, b, c, d) is convex
int IsConvexQuad(Point a, Point b, Point c, Point d)
{
    // Quad is nonconvex if Dot(Cross(bd, ba), Cross(bd, bc)) >= 0
    Vector bda = Cross(d - b, a - b);
    Vector bdc = Cross(d - b, c - b);
    if (Dot(bda, bdc) >= 0.0f) return 0;
    // Quad is now convex iff Dot(Cross(ac, ad), Cross(ac, ab)) < 0
    Vector acd = Cross(c - a, d - a);
    Vector acb = Cross(c - a, b - a);
    return Dot(acd, acb) < 0.0f;
}

=== Section 3.9.2: =============================================================

// Return index i of point p[i] farthest from the edge ab, to the left of the edge
int PointFarthestFromEdge(Point2D a, Point2D b, Point2D p[], int n)
{
    // Create edge vector and vector (counterclockwise) perpendicular to it
    Vector2D e = b – a, eperp = Vector2D(-e.y, e.x);

    // Track index, ‘distance’ and ‘rightmostness’ of currently best point
    int bestIndex = -1;
    float maxVal = -FLT_MAX, rightMostVal = -FLT_MAX;

    // Test all points to find the one farthest from edge ab on the left side
    for (int i = 1; i < n; i++) {
        float d = Dot2D(p[i] – a, eperp); // d is proportional to distance along eperp
        float r = Dot2D(p[i] – a, e);     // r is proportional to distance along e
        if (d > maxVal || (d == maxVal && r > rightMostVal)) {
            bestIndex = i;
            maxVal = d;
            rightMostVal = r;
        }
    }
    return bestIndex;
}

