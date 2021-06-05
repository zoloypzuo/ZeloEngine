
=== Section 5.1.1: =============================================================

Point ClosestPtPointPlane(Point q, Plane p)
{
    float t = (Dot(p.n, q) – p.d) / Dot(p.n, p.n);
    return q – t * p.n;
}

--------------------------------------------------------------------------------

Point ClosestPtPointPlane(Point q, Plane p)
{
    float t = Dot(p.n, q) – p.d;
    return q – t * p.n;
}

--------------------------------------------------------------------------------

float DistPointPlane(Point q, Plane p)
{
    // return Dot(q, p.n) – p.d; if plane equation normalized (||p.n||==1)
    return (Dot(p.n, q) – p.d) / Dot(p.n, p.n);
}

=== Section 5.1.2: =============================================================

// Given segment ab and point c, computes closest point d on ab.
// Also returns t for the position of d, d(t) = a + t*(b - a)
void ClosestPtPointSegment(Point c, Point a, Point b, float &t, Point &d)
{
    Vector ab = b – a;
    // Project c onto ab, computing parameterized position d(t) = a + t*(b – a)
    t = Dot(c – a, ab) / Dot(ab, ab);
    // If outside segment, clamp t (and therefore d) to the closest endpoint
    if (t < 0.0f) t = 0.0f;
    if (t > 1.0f) t = 1.0f;
    // Compute projected position from the clamped t
    d = a + t * ab;
}

--------------------------------------------------------------------------------

// Given segment ab and point c, computes closest point d on ab.
// Also returns t for the parametric position of d, d(t) = a + t*(b - a)
void ClosestPtPointSegment(Point c, Point a, Point b, float &t, Point &d)
{
    Vector ab = b – a;
    // Project c onto ab, but deferring divide by Dot(ab, ab)
    t = Dot(c – a, ab);
    if (t <= 0.0f) {
        // c projects outside the [a,b] interval, on the a side; clamp to a
        t = 0.0f;
        d = a;
    } else {
        float denom = Dot(ab, ab); // Always nonnegative since denom = ||ab||^2
        if (t >= denom) {
            // c projects outside the [a,b] interval, on the b side; clamp to b
            t = 1.0f;
            d = b;
        } else {
            // c projects inside the [a,b] interval; must do deferred divide now
            t = t / denom;
            d = a + t * ab;
        }
    }
}

=== Section 5.1.2.1: ===========================================================

// Returns the squared distance between point c and segment ab
float SqDistPointSegment(Point a, Point b, Point c)
{
    Vector ab = b – a, ac = c – a, bc = c – b;
    float e = Dot(ac, ab);
    // Handle cases where c projects outside ab
    if (e <= 0.0f) return Dot(ac, ac);
    float f = Dot(ab, ab);
    if (e >= f) return Dot(bc, bc);
    // Handle case where c projects onto ab
    return Dot(ac, ac) – e * e / f;
}

=== Section 5.1.3: =============================================================

// Given point p, return the point q on or in AABB b, that is closest to p
void ClosestPtPointAABB(Point p, AABB b, Point &q)
{
    // For each coordinate axis, if the point coordinate value is
    // outside box, clamp it to the box, else keep it as is
    for (int i = 0; i < 3; i++) {
        float v = p[i];
        if (v < b.min[i]) v = b.min[i]; // v = max(v, b.min[i])
        if (v > b.max[i]) v = b.max[i]; // v = min(v, b.max[i])
        q[i] = v;
    }
}

=== Section 5.1.3.1: ===========================================================

// Computes the square distance between a point p and an AABB b
float SqDistPointAABB(Point p, AABB b)
{
    float sqDist = 0.0f;
    for (int i = 0; i < 3; i++) {
        // For each axis count any excess distance outside box extents
        float v = p[i];
        if (v < b.min[i]) sqDist += (b.min[i] – v) * (b.min[i] – v);
        if (v > b.max[i]) sqDist += (v – b.max[i]) * (v – b.max[i]);
    }
    return sqDist;
}

=== Section 5.1.4: =============================================================

// Given point p, return point q on (or in) OBB b, closest to p
void ClosestPtPointOBB(Point p, OBB b, Point &q)
{
    Vector d = p – b.c;
    // Start result at center of box; make steps from there
    q = b.c;
    // For each OBB axis...
    for (int i = 0; i < 3; i++) {
        // ...project d onto that axis to get the distance
        // along the axis of d from the box center
        float dist = Dot(d, b.u[i]);
        // If distance farther than the box extents, clamp to the box
        if (dist > b.e[i]) dist = b.e[i];
        if (dist < –b.e[i]) dist = –b.e[i];
        // Step that distance along the axis to get world coordinate
        q += dist * b.u[i];
    }
}

=== Section 5.1.4.1: ===========================================================

// Computes the square distance between point p and OBB b
float SqDistPointOBB(Point p, OBB b)
{
    Point closest;
    ClosestPtPointOBB(p, b, closest);
    float sqDist = Dot(closest – p, closest – p);
    return sqDist;
}

--------------------------------------------------------------------------------

// Computes the square distance between point p and OBB b
float SqDistPointOBB(Point p, OBB b)
{
    Vector v = p – b.c;
    float sqDist = 0.0f;
    for (int i = 0; i < 3; i++) {
        // Project vector from box center to p on each axis, getting the distance
        // of p along that axis, and count any excess distance outside box extents
        float d = Dot(v, b.u[i]), excess = 0.0f;
        if (d < –b.e[i])
            excess = d + b.e[i];
        else if (d > b.e[i])
            excess = d – b.e[i];
        sqDist += excess * excess;
    }
    return sqDist;
}

=== Section 5.1.4.2: ===========================================================

struct Rect {
    Point c;     // center point of rectangle
    Vector u[2]; // unit vectors determining local x and y axes for the rectangle
    float e[2];  // the halfwidth extents of the rectangle along the axes
};

--------------------------------------------------------------------------------

// Given point p, return point q on (or in) Rect r, closest to p
void ClosestPtPointRect(Point p, Rect r, Point &q)
{
    Vector d = p – r.c;
    // Start result at center of rect; make steps from there
    q = r.c;
    // For each rect axis...
    for (int i = 0; i < 2; i++) {
        // ...project d onto that axis to get the distance
        // along the axis of d from the rect center
        float dist = Dot(d, r.u[i]);
        // If distance farther than the rect extents, clamp to the rect
        if (dist > r.e[i]) dist = r.e[i];
        if (dist < –r.e[i]) dist = –r.e[i];
        // Step that distance along the axis to get world coordinate
        q += dist * r.u[i];
    }
}

--------------------------------------------------------------------------------

// Return point q on (or in) rect (specified by a, b, and c), closest to given point p
void ClosestPtPointRect(Point p, Point a, Point b, Point c, Point &q)
{
    Vector ab = b – a; // vector across rect
    Vector ac = c – a; // vector down rect
    Vector d = p – a;
    // Start result at top-left corner of rect; make steps from there
    q = a;
    // Clamp p’ (projection of p to plane of r) to rectangle in the across direction
    float dist = Dot(d, ab);
    float maxdist = Dot(ab, ab);
    if (dist >= maxdist)
        q += ab;
    else if (dist > 0.0f)
        q += (dist / maxdist) * ab;
    // Clamp p’ (projection of p to plane of r) to rectangle in the down direction
    dist = Dot(d, ac);
    maxdist = Dot(ac, ac);
    if (dist >= maxdist)
        q += ac;
    else if (dist > 0.0f)
        q += (dist / maxdist) * ac;
}

=== Section 5.1.5: =============================================================

Vector n = Cross(b – a, c – a);
float rab = Dot(n, Cross(a – r, b – r)); // proportional to signed area of RAB
float rbc = Dot(n, Cross(b – r, c – r)); // proportional to signed area of RBC
float rca = Dot(n, Cross(c – r, a – r)); // proportional to signed area of RCA
float abc = rab + rbc + rca;             // proportional to signed area of ABC

--------------------------------------------------------------------------------

Point ClosestPtPointTriangle(Point p, Point a, Point b, Point c)
{
    Vector ab = b - a;
    Vector ac = c - a;
    Vector bc = c - b;

    // Compute parametric position s for projection P' of P on AB,
    // P' = A + s*AB, s = snom/(snom+sdenom)
    float snom = Dot(p - a, ab), sdenom = Dot(p - b, a - b);

    // Compute parametric position t for projection P' of P on AC,
    // P' = A + t*AC, s = tnom/(tnom+tdenom)
    float tnom = Dot(p - a, ac), tdenom = Dot(p - c, a - c);

    if (snom <= 0.0f && tnom <= 0.0f) return a; // Vertex region early out

    // Compute parametric position u for projection P' of P on BC,
    // P' = B + u*BC, u = unom/(unom+udenom)
    float unom = Dot(p - b, bc), udenom = Dot(p - c, b - c);

    if (sdenom <= 0.0f && unom <= 0.0f) return b; // Vertex region early out
    if (tdenom <= 0.0f && udenom <= 0.0f) return c; // Vertex region early out


    // P is outside (or on) AB if the triple scalar product [N PA PB] <= 0
    Vector n = Cross(b - a, c - a);
    float vc = Dot(n, Cross(a - p, b - p));
    // If P outside AB and within feature region of AB,
    // return projection of P onto AB
    if (vc <= 0.0f && snom >= 0.0f && sdenom >= 0.0f)
        return a + snom / (snom + sdenom) * ab;

    // P is outside (or on) BC if the triple scalar product [N PB PC] <= 0
    float va = Dot(n, Cross(b - p, c - p));
    // If P outside BC and within feature region of BC,
    // return projection of P onto BC
    if (va <= 0.0f && unom >= 0.0f && udenom >= 0.0f)
        return b + unom / (unom + udenom) * bc;

    // P is outside (or on) CA if the triple scalar product [N PC PA] <= 0
    float vb = Dot(n, Cross(c - p, a - p));
    // If P outside CA and within feature region of CA,
    // return projection of P onto CA
    if (vb <= 0.0f && tnom >= 0.0f && tdenom >= 0.0f)
        return a + tnom / (tnom + tdenom) * ac;

    // P must project inside face region. Compute Q using barycentric coordinates
    float u = va / (va + vb + vc);
    float v = vb / (va + vb + vc);
    float w = 1.0f - u - v; // = vc / (va + vb + vc)
    return u * a + v * b + w * c;
}

--------------------------------------------------------------------------------

    Vector n = Cross(b - a, c - a);
    float va = Dot(n, Cross(b - p, c - p));
    float vb = Dot(n, Cross(c - p, a - p));
    float vc = Dot(n, Cross(a - p, b - p));

--------------------------------------------------------------------------------

    float d1 = Dot(b - a, p - a);
    float d2 = Dot(c - a, p - a);
    float d3 = Dot(b - a, p - b);
    float d4 = Dot(c - a, p - b);
    float d5 = Dot(b - a, p - c);
    float d6 = Dot(c - a, p - c);

--------------------------------------------------------------------------------

    float va = d3*d6 - d5*d4;
    float vb = d5*d2 - d1*d6;
    float vc = d1*d4 - d3*d2;

--------------------------------------------------------------------------------

    float snom = d1;
    float sdenom = -d3;
    float tnom = d2;
    float tdenom = -d6;
    float unom = d4 - d3;
    float udenom = d5 - d6;

--------------------------------------------------------------------------------

Point ClosestPtPointTriangle(Point p, Point a, Point b, Point c)
{
    // Check if P in vertex region outside A
    Vector ab = b - a;
    Vector ac = c - a;
    Vector ap = p - a;
    float d1 = Dot(ab, ap);
    float d2 = Dot(ac, ap);
    if (d1 <= 0.0f && d2 <= 0.0f) return a; // barycentric coordinates (1,0,0)

    // Check if P in vertex region outside B
    Vector bp = p - b;
    float d3 = Dot(ab, bp);
    float d4 = Dot(ac, bp);
    if (d3 >= 0.0f && d4 <= d3) return b; // barycentric coordinates (0,1,0)

    // Check if P in edge region of AB, if so return projection of P onto AB
    float vc = d1*d4 - d3*d2;
    if (vc <= 0.0f && d1 >= 0.0f && d3 <= 0.0f) {
        float v = d1 / (d1 - d3);
        return a + v * ab; // barycentric coordinates (1-v,v,0)
    }

    // Check if P in vertex region outside C
    Vector cp = p - c;
    float d5 = Dot(ab, cp);
    float d6 = Dot(ac, cp);
    if (d6 >= 0.0f && d5 <= d6) return c; // barycentric coordinates (0,0,1)

    // Check if P in edge region of AC, if so return projection of P onto AC
    float vb = d5*d2 - d1*d6;
    if (vb <= 0.0f && d2 >= 0.0f && d6 <= 0.0f) {
        float w = d2 / (d2 - d6);
        return a + w * ac; // barycentric coordinates (1-w,0,w)
    }

    // Check if P in edge region of BC, if so return projection of P onto BC
    float va = d3*d6 - d5*d4;
    if (va <= 0.0f && (d4 - d3) >= 0.0f && (d5 - d6) >= 0.0f) {
        float w = (d4 - d3) / ((d4 - d3) + (d5 - d6));
        return b + w * (c - b); // barycentric coordinates (0,1-w,w)
    }

    // P inside face region. Compute Q through its barycentric coordinates (u,v,w)
    float denom = 1.0f / (va + vb + vc);
    float v = vb * denom;
    float w = vc * denom;
    return a + ab * v + ac * w; // = u*a + v*b + w*c, u = va * denom = 1.0f - v - w
}

=== Section 5.1.6: =============================================================

Point ClosestPtPointTetrahedron(Point p, Point a, Point b, Point c, Point d)
{
    // Start out assuming point inside all halfspaces, so closest to itself
    Point closestPt = p;
    float bestSqDist = FLT_MAX;
    // If point outside face abc then compute closest point on abc
    if (PointOutsideOfPlane(p, a, b, c)) {
        Point q = ClosestPtPointTriangle(p, a, b, c);
        float sqDist = Dot(q – p, q – p);
        // Update best closest point if (squared) distance is less than current best
        if (sqDist < bestSqDist) bestSqDist = sqDist, closestPt = q;
    }
    // Repeat test for face acd
    if (PointOutsideOfPlane(p, a, c, d)) {
        Point q = ClosestPtPointTriangle(p, a, c, d);
        float sqDist = Dot(q – p, q – p);
        if (sqDist < bestSqDist) bestSqDist = sqDist, closestPt = q;
    }
    // Repeat test for face adb
    if (PointOutsideOfPlane(p, a, d, b)) {
        Point q = ClosestPtPointTriangle(p, a, d, b);
        float sqDist = Dot(q – p, q – p);
        if (sqDist < bestSqDist) bestSqDist = sqDist, closestPt = q;
    }
    // Repeat test for face bdc
    if (PointOutsideOfPlane(p, b, d, c)) {
        Point q = ClosestPtPointTriangle(p, b, d, c);
        float sqDist = Dot(q – p, q – p);
        if (sqDist < bestSqDist) bestSqDist = sqDist, closestPt = q;
    }
    return closestPt;
}

--------------------------------------------------------------------------------

// Test if point p lies outside plane through abc
int PointOutsideOfPlane(Point p, Point a, Point b, Point c)
{
    return Dot(p – a, Cross(b – a, c – a)) >= 0.0f; // [AP AB AC] >= 0
}

--------------------------------------------------------------------------------

// Test if point p and d lie on opposite sides of plane through abc
int PointOutsideOfPlane(Point p, Point a, Point b, Point c, Point d)
{
    float signp = Dot(p – a, Cross(b – a, c – a)); // [AP AB AC]
    float signd = Dot(d – a, Cross(b – a, c – a)); // [AD AB AC]
    // Points on opposite sides if expression signs are opposite
    return signp * signd < 0.0f;
}

=== Section 5.1.9: =============================================================

// Clamp n to lie within the range [min, max]
float Clamp(float n, float min, float max) {
    if (n < min) return min;
    if (n > max) return max;
    return n;
}

// Computes closest points C1 and C2 of S1(s)=P1+s*(Q1-P1) and
// S2(t)=P2+t*(Q2-P2), returning s and t. Function result is squared
// distance between between S1(s) and S2(t)
float ClosestPtSegmentSegment(Point p1, Point q1, Point p2, Point q2,
                              float &s, float &t, Point &c1, Point &c2)
{
    Vector d1 = q1 - p1; // Direction vector of segment S1
    Vector d2 = q2 - p2; // Direction vector of segment S2
    Vector r = p1 - p2;
    float a = Dot(d1, d1); // Squared length of segment S1, always nonnegative
    float e = Dot(d2, d2); // Squared length of segment S2, always nonnegative
    float f = Dot(d2, r);

    // Check if either or both segments degenerate into points
    if (a <= EPSILON && e <= EPSILON) {
        // Both segments degenerate into points
        s = t = 0.0f;
        c1 = p1;
        c2 = p2;
        return Dot(c1 - c2, c1 - c2);
    }
    if (a <= EPSILON) {
        // First segment degenerates into a point
        s = 0.0f;
        t = f / e; // s = 0 => t = (b*s + f) / e = f / e
        t = Clamp(t, 0.0f, 1.0f);
    } else {
        float c = Dot(d1, r);
        if (e <= EPSILON) {
            // Second segment degenerates into a point
            t = 0.0f;
            s = Clamp(-c / a, 0.0f, 1.0f); // t = 0 => s = (b*t - c) / a = -c / a
        } else {
            // The general nondegenerate case starts here
            float b = Dot(d1, d2);
            float denom = a*e-b*b; // Always nonnegative

            // If segments not parallel, compute closest point on L1 to L2, and
            // clamp to segment S1. Else pick arbitrary s (here 0)
            if (denom != 0.0f) {
                s = Clamp((b*f - c*e) / denom, 0.0f, 1.0f);
            } else s = 0.0f;

            // Compute point on L2 closest to S1(s) using
            // t = Dot((P1+D1*s)-P2,D2) / Dot(D2,D2) = (b*s + f) / e
            t = (b*s + f) / e;

            // If t in [0,1] done. Else clamp t, recompute s for the new value
            // of t using s = Dot((P2+D2*t)-P1,D1) / Dot(D1,D1)= (t*b - c) / a
            // and clamp s to [0, 1]
            if (t < 0.0f) {
                t = 0.0f;
                s = Clamp(-c / a, 0.0f, 1.0f);
            } else if (t > 1.0f) {
                t = 1.0f;
                s = Clamp((b - c) / a, 0.0f, 1.0f);
            }
        }
    }

    c1 = p1 + d1 * s;
    c2 = p2 + d2 * t;
    return Dot(c1 - c2, c1 - c2);
}

--------------------------------------------------------------------------------

...
float tnom = b*s + f;
if (tnom < 0.0f) {
    t = 0.0f;
    s = Clamp(-c / a, 0.0f, 1.0f);
} else if (tnom > e) {
    t = 1.0f;
    s = Clamp((b - c) / a, 0.0f, 1.0f);
} else {
    t = tnom / e;
}

=== Section 5.1.9.1: ===========================================================

// Returns 2 times the signed triangle area. The result is positive if
// abc is ccw, negative if abc is cw, zero if abc is degenerate.
float Signed2DTriArea(Point a, Point b, Point c)
{
    return (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);
}

--------------------------------------------------------------------------------

// Test if segments ab and cd overlap. If they do, compute and return
// intersection t value along ab and intersection position p
int Test2DSegmentSegment(Point a, Point b, Point c, Point d, float &t, Point &p)
{
    // Sign of areas correspond to which side of ab points c and d are
    float a1 = Signed2DTriArea(a, b, d); // Compute winding of abd (+ or -)
    float a2 = Signed2DTriArea(a, b, c); // To intersect, must have sign opposite of a1

    // If c and d are on different sides of ab, areas have different signs
    if (a1 * a2 < 0.0f) {
        // Compute signs for a and b with respect to segment cd
        float a3 = Signed2DTriArea(c, d, a); // Compute winding of cda (+ or -)
        // Since area is constant a1-a2 = a3-a4, or a4=a3+a2-a1
//      float a4 = Signed2DTriArea(c, d, b); // Must have opposite sign of a3
        float a4 = a3 + a2 - a1;
        // Points a and b on different sides of cd if areas have different signs
        if (a3 * a4 < 0.0f) {
            // Segments intersect. Find intersection point along L(t)=a+t*(b-a).
            // Given height h1 of a over cd and height h2 of b over cd,
            // t = h1 / (h1 - h2) = (b*h1/2) / (b*h1/2 - b*h2/2) = a3 / (a3 - a4),
            // where b (the base of the triangles cda and cdb, i.e., the length
            // of cd) cancels out.
            t = a3 / (a3 - a4);
            p = a + t * (b - a);
            return 1;
        }
    }

    // Segments not intersecting (or collinear)
    return 0;
}

--------------------------------------------------------------------------------

if (a1 != 0.0f && a2 != 0.0f && a1*a2 < 0.0f) ... // for floating-point variables
if ((a1 | a2) != 0 && a1 ^ a2 < 0) ... // for integer variables

=== Section 5.2.1.1: ===========================================================

// Compute a tentative separating axis for ab and cd
Vector m = Cross(ab, cd);
if (!IsZeroVector(m)) {
    // Edges ab and cd not parallel, continue with m as a potential separating axis
    ...
 } else {
    // Edges ab and cd must be (near) parallel, and therefore lie in some plane P.
    // Thus, as a separating axis try an axis perpendicular to ab and lying in P
    Vector n = Cross(ab, c - a);
    m = Cross(ab, n);
    if (!IsZeroVector(m)) {
        // Continue with m as a potential separating axis
        ...
    }
    // ab and ac are parallel too, so edges must be on a line. Ignore testing
    // the axis for this combination of edges as it won’t be a separating axis.
    // (Alternatively, test if edges overlap on this line, in which case the
    // objects are overlapping.)
    ...
}

=== Section 5.2.2: =============================================================

// Determine whether plane p intersects sphere s
int TestSpherePlane(Sphere s, Plane p)
{
    // For a normalized plane (|p.n| = 1), evaluating the plane equation
    // for a point gives the signed distance of the point to the plane
    float dist = Dot(s.c, p.n) - p.d;
    // If sphere center within +/-radius from plane, plane intersects sphere
    return Abs(dist) <= s.r;
}

--------------------------------------------------------------------------------

// Determine whether sphere s fully behind (inside negative halfspace of) plane p
int InsideSpherePlane(Sphere s, Plane p)
{
    float dist = Dot(s.c, p.n) - p.d;
    return dist < -s.r;
}

--------------------------------------------------------------------------------

// Determine whether sphere s intersects negative halfspace of plane p
int TestSphereHalfspace(Sphere s, Plane p)
{
    float dist = Dot(s.c, p.n) - p.d;
    return dist <= s.r;
}

=== Section 5.2.3: =============================================================

// Test if OBB b intersects plane p
int TestOBBPlane(OBB b, Plane p)
{
    // Compute the projection interval radius of b onto L(t) = b.c + t * p.n
    float r = b.e[0]*Abs(Dot(p.n, b.u[0])) +
              b.e[1]*Abs(Dot(p.n, b.u[1])) +
              b.e[2]*Abs(Dot(p.n, b.u[2]));
    // Compute distance of box center from plane
    float s = Dot(p.n, b.c) – p.d;
    // Intersection occurs when distance s falls within [-r,+r] interval
    return Abs(s) <= r;
}

--------------------------------------------------------------------------------

// Test if AABB b intersects plane p
int TestAABBPlane(AABB b, Plane p)
{
    // These two lines not necessary with a (center, extents) AABB representation
    Point c = (b.max + b.min) * 0.5f; // Compute AABB center
    Point e = b.max - c; // Compute positive extents

    // Compute the projection interval radius of b onto L(t) = b.c + t * p.n
    float r = e[0]*Abs(p.n[0]) + e[1]*Abs(p.n[1]) + e[2]*Abs(p.n[2]);
    // Compute distance of box center from plane
    float s = Dot(p.n, c) - p.d;
    // Intersection occurs when distance s falls within [-r,+r] interval
    return Abs(s) <= r;
}

=== Section 5.2.5: =============================================================

// Returns true if sphere s intersects AABB b, false otherwise
int TestSphereAABB(Sphere s, AABB b)
{
    // Compute squared distance between sphere center and AABB
    float sqDist = SqDistPointAABB(s.c, b);

    // Sphere and AABB intersect if the (squared) distance
    // between them is less than the (squared) sphere radius
    return sqDist <= s.r * s.r;
}

--------------------------------------------------------------------------------

// Returns true if sphere s intersects AABB b, false otherwise.
// The point p on the AABB closest to the sphere center is also returned
int TestSphereAABB(Sphere s, AABB b, Point &p)
{
    // Find point p on AABB closest to sphere center
    ClosestPtPointAABB(s.c, b, p);

    // Sphere and AABB intersect if the (squared) distance from sphere
    // center to point p is less than the (squared) sphere radius
    Vector v = p - s.c;
    return Dot(v, v) <= s.r * s.r;
}

=== Section 5.2.6: =============================================================

// Returns true if sphere s intersects OBB b, false otherwise.
// The point p on the OBB closest to the sphere center is also returned
int TestSphereOBB(Sphere s, OBB b, Point &p)
{
    // Find point p on OBB closest to sphere center
    ClosestPtPointOBB(s.c, b, p);

    // Sphere and OBB intersect if the (squared) distance from sphere
    // center to point p is less than the (squared) sphere radius
    Vector v = p - s.c;
    return Dot(v, v) <= s.r * s.r;
}

=== Section 5.2.7: =============================================================

// Returns true if sphere s intersects triangle ABC, false otherwise.
// The point p on abc closest to the sphere center is also returned
int TestSphereTriangle(Sphere s, Point a, Point b, Point c, Point &p)
{
    // Find point P on triangle ABC closest to sphere center
    p = ClosestPtPointTriangle(s.c, a, b, c);

    // Sphere and triangle intersect if the (squared) distance from sphere
    // center to point p is less than the (squared) sphere radius
    Vector v = p - s.c;
    return Dot(v, v) <= s.r * s.r;
}

=== Section 5.2.8: =============================================================

// Test whether sphere s intersects polygon p
int TestSpherePolygon(Sphere s, Polygon p)
{
    // Compute normal for the plane of the polygon
    Vector n = Normalize(Cross(p.v[1] – p.v[0], p.v[2] – p.v[0]));
    // Compute the plane equation for p
    Plane m; m.n = n; m.d = -Dot(n, p.v[0]);
    // No intersection if sphere not intersecting plane of polygon
    if (!TestSpherePlane(s, m)) return 0;
    // Test to see if any one of the polygon edges pierces the sphere   
    for (int k = p.numVerts, i = 0, j = k - 1; i < k; j = i, i++) {
        float t;
        Point q;
        // Test if edge (p.v[j], p.v[i]) intersects s
        if (IntersectRaySphere(p.v[j], p.v[i] – p.v[j], s, t, q) && t <= 1.0f)
            return 1;
    }
    // Test if the orthogonal projection q of the sphere center onto m is inside p
    Point q = ClosestPtPointPlane(s.c, m);
    return PointInPolygon(q, p);
}

=== Section 5.2.9: =============================================================

int TestTriangleAABB(Point v0, Point v1, Point v2, AABB b)
{
    float p0, p1, p2, r;

    // Compute box center and extents (if not already given in that format)
    Vector c = (b.min + b.max) * 0.5f;
    float e0 = (b.max.x – b.min.x) * 0.5f;
    float e1 = (b.max.y – b.min.y) * 0.5f;
    float e2 = (b.max.z – b.min.z) * 0.5f;

    // Translate triangle as conceptually moving AABB to origin
    v0 = v0 – c;
    v1 = v1 – c;
    v2 = v2 – c;

    // Compute edge vectors for triangle
    Vector f0 = v1 – v0,  f1 = v2 – v1, f2 = v0 – v2;

    // Test axes a00..a22 (category 3)
    // Test axis a00
    p0 = v0.z*v1.y – v0.y*v1.z;
    p2 = v2.z*(v1.y – v0.y) – v2.y*(v1.z – v0.z);
    r = e1 * Abs(f0.z) + e2 * Abs(f0.y);
    if (Max(-Max(p0, p2), Min(p0, p2)) > r) return 0; // Axis is a separating axis

    // Repeat similar tests for remaining axes a01..a22
    ...

    // Test the three axes corresponding to the face normals of AABB b (category 1).
    // Exit if...
    // ... [-e0, e0] and [min(v0.x,v1.x,v2.x), max(v0.x,v1.x,v2.x)] do not overlap
    if (Max(v0.x, v1.x, v2.x) < -e0 || Min(v0.x, v1.x, v2.x) > e0) return 0;
    // ... [-e1, e1] and [min(v0.y,v1.y,v2.y), max(v0.y,v1.y,v2.y)] do not overlap
    if (Max(v0.y, v1.y, v2.y) < -e1 || Min(v0.y, v1.y, v2.y) > e1) return 0;
    // ... [-e2, e2] and [min(v0.z,v1.z,v2.z), max(v0.z,v1.z,v2.z)] do not overlap
    if (Max(v0.z, v1.z, v2.z) < -e2 || Min(v0.z, v1.z, v2.z) > e2) return 0;

    // Test separating axis corresponding to triangle face normal (category 2)
    Plane p;
    p.n = Cross(f0, f1);
    p.d = Dot(p.n, v0);
    return TestAABBPlane(b, p);
}

=== Section 5.3.1: =============================================================

int IntersectSegmentPlane(Point a, Point b, Plane p, float &t, Point &q)
{
    // Compute the t value for the directed line ab intersecting the plane
    Vector ab = b - a;
    t = (p.d - Dot(p.n, a)) / Dot(p.n, ab);

    // If t in [0..1] compute and return intersection point
    if (t >= 0.0f && t <= 1.0f) {
        q = a + t * ab;
        return 1;
    }
    // Else no intersection
    return 0;
}

--------------------------------------------------------------------------------

// Intersect segment ab against plane of triangle def. If intersecting,
// return t value and position q of intersection
int IntersectSegmentPlane(Point a, Point b, Point d, Point e, Point f,
                          float &t, Point &q)
{
    Plane p;
    p.n = Cross(e – d, f – d);
    p.d = Dot(p.n, d);
    return IntersectSegmentPlane(a, b, p, t, q);
}

=== Section 5.3.2: =============================================================

// Intersects ray r = p + td, |d| = 1, with sphere s and, if intersecting,
// returns t value of intersection and intersection point q
int IntersectRaySphere(Point p, Vector d, Sphere s, float &t, Point &q)
{
    Vector m = p – s.c;
    float b = Dot(m, d);
    float c = Dot(m, m) – s.r * s.r;
    // Exit if r’s origin outside s (c > 0)and r pointing away from s (b > 0)
    if (c > 0.0f && b > 0.0f) return 0;
    float discr = b*b – c;
    // A negative discriminant corresponds to ray missing sphere
    if (discr < 0.0f) return 0;
    // Ray now found to intersect sphere, compute smallest t value of intersection
    t = -b – Sqrt(discr);
    // If t is negative, ray started inside sphere so clamp t to zero
    if (t < 0.0f) t = 0.0f;
    q = p + t * d;
    return 1;
}

--------------------------------------------------------------------------------

// Test if ray r = p + td intersects sphere s
int TestRaySphere(Point p, Vector d, Sphere s)
{
    Vector m = p – s.c;
    float c = Dot(m, m) – s.r * s.r;
    // If there is definitely at least one real root, there must be an intersection
    if (c <= 0.0f) return 1;
    float b = Dot(m, d);
    // Early exit if ray origin outside sphere and ray pointing away from sphere
    if (b > 0.0f) return 0;
    float disc = b*b – c;
    // A negative discriminant corresponds to ray missing sphere
    if (disc < 0.0f) return 0;
    // Now ray must hit sphere
    return 1;
}

=== Section 5.3.3: =============================================================

// Intersect ray R(t) = p + t*d against AABB a. When intersecting,
// return intersection distance tmin and point q of intersection
int IntersectRayAABB(Point p, Vector d, AABB a, float &tmin, Point &q)
{
    tmin = 0.0f;          // set to -FLT_MAX to get first hit on line
    float tmax = FLT_MAX; // set to max distance ray can travel (for segment)

    // For all three slabs
    for (int i = 0; i < 3; i++) {
        if (Abs(d[i]) < EPSILON) {
            // Ray is parallel to slab. No hit if origin not within slab
            if (p[i] < a.min[i] || p[i] > a.max[i]) return 0;
        } else {
            // Compute intersection t value of ray with near and far plane of slab
            float ood = 1.0f / d[i];
            float t1 = (a.min[i] - p[i]) * ood;
            float t2 = (a.max[i] - p[i]) * ood;
            // Make t1 be intersection with near plane, t2 with far plane
            if (t1 > t2) Swap(t1, t2);
            // Compute the intersection of slab intersections intervals
            tmin = Max(tmin, t1);
            tmax = Min(tmax, t2);
            // Exit with no collision as soon as slab intersection becomes empty
            if (tmin > tmax) return 0;
        }
    }
    // Ray intersects all 3 slabs. Return point (q) and intersection t value (tmin) 
    q = p + d * tmin;
    return 1;
}

--------------------------------------------------------------------------------

// Test if segment specified by points p0 and p1 intersects AABB b
int TestSegmentAABB(Point p0, Point p1, AABB b)
{
    Point c = (b.min + b.max) * 0.5f; // Box center-point
    Vector e = b.max - c;             // Box halflength extents
    Point m = (p0 + p1) * 0.5f;       // Segment midpoint
    Vector d = p1 - m;                // Segment halflength vector
    m = m - c;                        // Translate box and segment to origin

    // Try world coordinate axes as separating axes
    float adx = Abs(d.x);
    if (Abs(m.x) > e.x + adx) return 0;
    float ady = Abs(d.y);
    if (Abs(m.y) > e.y + ady) return 0;
    float adz = Abs(d.z);
    if (Abs(m.z) > e.z + adz) return 0;

    // Add in an epsilon term to counteract arithmetic errors when segment is
    // (near) parallel to a coordinate axis (see text for detail)
    adx += EPSILON; ady += EPSILON; adz += EPSILON;

    // Try cross products of segment direction vector with coordinate axes
    if (Abs(m.y * d.z - m.z * d.y) > e.y * adz + e.z * ady) return 0;
    if (Abs(m.z * d.x - m.x * d.z) > e.x * adz + e.z * adx) return 0;
    if (Abs(m.x * d.y - m.y * d.x) > e.x * ady + e.y * adx) return 0;

    // No separating axis found; segment must be overlapping AABB
    return 1;
}

--------------------------------------------------------------------------------

    Vector e = b.max – b.min;
    Vector d = p1 - p0;
    Point m = p0 + p1 - b.min - b.max;

=== Section 5.3.4: =============================================================

// Given line pq and ccw triangle abc, return whether line pierces triangle. If
// so, also return the barycentric coordinates (u,v,w) of the intersection point
int IntersectLineTriangle(Point p, Point q, Point a, Point b, Point c,
                          float &u, float &v, float &w)
{
    Vector pq = q - p;
    Vector pa = a - p;
    Vector pb = b - p;
    Vector pc = c - p;
    // Test if pq is inside the edges bc, ca and ab. Done by testing
    // that the signed tetrahedral volumes, computed using scalar triple
    // products, are all positive
    u = ScalarTriple(pq, pc, pb);
    if (u < 0.0f) return 0;
    v = ScalarTriple(pq, pa, pc);
    if (v < 0.0f) return 0;
    w = ScalarTriple(pq, pb, pa);
    if (w < 0.0f) return 0;

    // Compute the barycentric coordinates (u, v, w) determining the
    // intersection point r, r = u*a + v*b + w*c
    float denom = 1.0f / (u + v + w);
    u *= denom;
    v *= denom;
    w *= denom; // w = 1.0f - u - v;
    return 1;
}

--------------------------------------------------------------------------------

Vector m = Cross(pq, pc);
u = Dot(pb, m); // ScalarTriple(pq, pc, pb);
if (u < 0.0f) return 0;
v = -Dot(pa, m); // ScalarTriple(pq, pa, pc);
if (v < 0.0f) return 0;
w = ScalarTriple(pq, pb, pa);
if (w < 0.0f) return 0;

--------------------------------------------------------------------------------

Vector m = Cross(pq, pc);
u = Dot(pb, m); // ScalarTriple(pq, pc, pb);
v = -Dot(pa, m); // ScalarTriple(pq, pa, pc);
if (!SameSign(u, v)) return 0;
w = ScalarTriple(pq, pb, pa);
if (!SameSign(u, w)) return 0;

--------------------------------------------------------------------------------

Vector m = Cross(pq, p);
u = Dot(pq, Cross(c, b)) + Dot(m, c – b);
v = Dot(pq, Cross(a, c)) + Dot(m, a – c);
w = Dot(pq, Cross(b, a)) + Dot(m, b – a);

--------------------------------------------------------------------------------

Vector m = Cross(pq, p);
float s = Dot(m, c – b);
float t = Dot(m, a – c);
u = Dot(pq, Cross(c, b)) + s;
v = Dot(pq, Cross(a, c)) + t;
w = Dot(pq, Cross(b, a)) – s - t;

=== Section 5.3.5: =============================================================

// Given line pq and ccw quadrilateral abcd, return whether the line
// pierces the triangle. If so, also return the point r of intersection
int IntersectLineQuad(Point p, Point q, Point a, Point b, Point c, Point d, Point &r)
{
    Vector pq = q - p;
    Vector pa = a - p;
    Vector pb = b - p;
    Vector pc = c - p;
    // Determine which triangle to test against by testing against diagonal first
    Vector m = Cross(pc, pq);
    float v = Dot(pa, m); // ScalarTriple(pq, pa, pc);
    if (v >= 0.0f) {
        // Test intersection against triangle abc
        float u = -Dot(pb, m); // ScalarTriple(pq, pc, pb);
        if (u < 0.0f) return 0;
        float w = ScalarTriple(pq, pb, pa);
        if (w < 0.0f) return 0;
        // Compute r, r = u*a + v*b + w*c, from barycentric coordinates (u, v, w)
        float denom = 1.0f / (u + v + w);
        u *= denom;
        v *= denom;
        w *= denom; // w = 1.0f - u - v;
        r = u*a + v*b + w*c;
    } else {
        // Test intersection against triangle dac
        Vector pd = d - p;
        float u = Dot(pd, m); // ScalarTriple(pq, pd, pc);
        if (u < 0.0f) return 0;
        float w = ScalarTriple(pq, pa, pd);
        if (w < 0.0f) return 0;
        v = -v;
        // Compute r, r = u*a + v*d + w*c, from barycentric coordinates (u, v, w)
        float denom = 1.0f / (u + v + w);
        u *= denom;
        v *= denom;
        w *= denom; // w = 1.0f - u - v;
        r = u*a + v*d + w*c;
    }
    return 1;
}

=== Section 5.3.6: =============================================================

// Given segment pq and triangle abc, returns whether segment intersects
// triangle and if so, also returns the barycentric coordinates (u,v,w)
// of the intersection point
int IntersectSegmentTriangle(Point p, Point q, Point a, Point b, Point c,
                             float &u, float &v, float &w, float &t)
{
    Vector ab = b - a;
    Vector ac = c - a;
    Vector qp = p - q;

    // Compute triangle normal. Can be precalculated or cached if
    // intersecting multiple segments against the same triangle
    Vector n = Cross(ab, ac);

    // Compute denominator d. If d <= 0, segment is parallel to or points
    // away from triangle, so exit early
    float d = Dot(qp, n);
    if (d <= 0.0f) return 0;

    // Compute intersection t value of pq with plane of triangle. A ray
    // intersects iff 0 <= t. Segment intersects iff 0 <= t <= 1. Delay
    // dividing by d until intersection has been found to pierce triangle
    Vector ap = p - a;
    t = Dot(ap, n);
    if (t < 0.0f) return 0;
    if (t > d) return 0; // For segment; exclude this code line for a ray test

    // Compute barycentric coordinate components and test if within bounds
    Vector e = Cross(qp, ap);
    v = Dot(ac, e);
    if (v < 0.0f || v > d) return 0;
    w = -Dot(ab, e);
    if (w < 0.0f || v + w > d) return 0;

    // Segment/ray intersects triangle. Perform delayed division and
    // compute the last barycentric coordinate component
    float ood = 1.0f / d;
    t *= ood;
    v *= ood;
    w *= ood;
    u = 1.0f - v - w;
    return 1;
}

--------------------------------------------------------------------------------

struct Triangle {
    Plane p;           // Plane equation for triangle plane
    Plane edgePlaneBC; // When evaluated gives barycentric weight u (for vertex A)
    Plane edgePlaneCA; // When evaluated gives barycentric weight v (for vertex B)
};

// Given segment pq and precomputed triangle tri, returns whether segment intersects
// triangle. If so, also returns the barycentric coordinates (u,v,w) of the
// intersection point s, and the parameterized intersection t value
int IntersectSegmentTriangle(Point p, Point q, Triangle tri,
                             float &u, float &v, float &w, float &t, Point &s)
{
    // Compute distance of p to triangle plane. Exit if p lies behind plane
    float distp = Dot(p, tri.p.n) – tri.p.d;
    if (distp < 0.0f) return 0;

    // Compute distance of q to triangle plane. Exit if q lies in front of plane
    float distq = Dot(q, tri.p.n) – tri.p.d;
    if (distq >= 0.0f) return 0;

    // Compute t value and point s of intersection with triangle plane
    float denom = distp – distq;
    t = distp / denom;
    s = p + t * (q – p);

    // Compute the barycentric coordinate u; exit if outside 0..1 range
    u = Dot(s, tri.edgePlaneBC.n) – tri.edgePlaneBC.d;
    if (u < 0.0f || u > 1.0f) return 0;
    // Compute the barycentric coordinate v; exit if negative
    v = Dot(s, tri.edgePlaneCA.n) – tri.edgePlaneCA.d;
    if (v < 0.0f) return 0;
    // Compute the barycentric coordinate w; exit if negative
    w = 1.0f – u – v;
    if (w < 0.0f) return 0;

    // Segment intersects tri at distance t in position s (s = u*A + v*B + w*C)
    return 1;
}

--------------------------------------------------------------------------------

Triangle tri;
Vector n = Cross(b – a, c – a);
tri.p = Plane(n, a);
tri.edgePlaneBC = Plane(Cross(n, c – b), b);
tri.edgePlaneCA = Plane(Cross(n, a – c), c);

--------------------------------------------------------------------------------

tri.edgePlaneBC *= 1.0f / (Dot(a, tri.edgePlaneBC.n) – tri.edgePlaneBC.d);
tri.edgePlaneCA *= 1.0f / (Dot(b, tri.edgePlaneCA.n) – tri.edgePlaneCA.d);

=== Section 5.3.7: =============================================================

// Intersect segment S(t)=sa+t(sb-sa), 0<=t<=1 against cylinder specified by p, q and r
int IntersectSegmentCylinder(Point sa, Point sb, Point p, Point q, float r, float &t)
{
    Vector d = q – p, m = sa – p, n = sb – sa;
    float md = Dot(m, d);
    float nd = Dot(n, d);
    float dd = Dot(d, d);
    // Test if segment fully outside either endcap of cylinder
    if (md < 0.0f && md + nd < 0.0f) return 0; // Segment outside ‘p’ side of cylinder
    if (md > dd && md + nd > dd) return 0;     // Segment outside ‘q’ side of cylinder
    float nn = Dot(n, n);
    float mn = Dot(m, n);
    float a = dd * nn – nd * nd;
    float k = Dot(m, m) – r * r;
    float c = dd * k – md * md;
    if (Abs(a) < EPSILON) {
        // Segment runs parallel to cylinder axis
        if (c > 0.0f) return 0; // ‘a’ and thus the segment lie outside cylinder
        // Now known that segment intersects cylinder; figure out how it intersects
        if (md < 0.0f) t = -mn / nn; // Intersect segment against ‘p’ endcap
        else if (md > dd) t = (nd - mn) / nn; // Intersect segment against ‘q’ endcap
        else t = 0.0f; // ‘a’ lies inside cylinder
        return 1;
    }
    float b = dd * mn – nd * md;
    float discr = b * b – a * c;
    if (discr < 0.0f) return 0; // No real roots; no intersection
    t = (-b – Sqrt(discr)) / a;
    if (t < 0.0f || t > 1.0f) return 0; // Intersection lies outside segment
    if (md + t * nd < 0.0f) {
        // Intersection outside cylinder on ‘p’ side
        if (nd <= 0.0f) return 0; // Segment pointing away from endcap
        t = -md / nd;
        // Keep intersection if Dot(S(t) - p, S(t) - p) <= r^2
        return k + 2 * t * (mn + t * nn) <= 0.0f;
    } else if (md + t * nd > dd) {
        // Intersection outside cylinder on ‘q’ side
        if (nd >= 0.0f) return 0; // Segment pointing away from endcap
        t = (dd – md) / nd;
        // Keep intersection if Dot(S(t) - q, S(t) - q) <= r^2
        return k + dd – 2 * md + t * (2 * (mn – nd) + t * nn) <= 0.0f;
    }
    // Segment intersects cylinder between the end-caps; t is correct
    return 1;
}

=== Section 5.3.8: =============================================================

// Intersect segment S(t)=A+t(B-A), 0<=t<=1 against convex polyhedron specified
// by the n halfspaces defined by the planes p[]. On exit tfirst and tlast
// define the intersection, if any
int IntersectSegmentPolyhedron(Point a, Point b, Plane p[], int n,
                               float &tfirst, float &tlast)
{
    // Compute direction vector for the segment
    Vector d = b – a;
    // Set initial interval to being the whole segment. For a ray, tlast should be
    // set to +FLT_MAX. For a line, additionally tfirst should be set to –FLT_MAX
    tfirst = 0.0f;
    tlast = 1.0f;
    // Intersect segment against each plane 
    for (int i = 0; i < n; i++) {
        float denom = Dot(p[i].n, d);
        float dist = p[i].d - Dot(p[i].n, a);
        // Test if segment runs parallel to the plane
        if (denom == 0.0f) {
            // If so, return “no intersection” if segment lies outside plane
            if (dist > 0.0f) return 0;
        } else {
            // Compute parameterized t value for intersection with current plane
            float t = dist / denom;
            if (denom < 0.0f) {
                // When entering halfspace, update tfirst if t is larger
                if (t > tfirst) tfirst = t;
            } else {
                // When exiting halfspace, update tlast if t is smaller
                if (t < tlast) tlast = t;
            }
            // Exit with “no intersection” if intersection becomes empty
            if (tfirst > tlast) return 0;
        }
    }
    // A nonzero logical intersection, so the segment intersects the polyhedron
    return 1;
}

=== Section 5.4.1: =============================================================

// Test if point p lies inside ccw-specified convex n-gon given by vertices v[]
int PointInConvexPolygon(Point p, int n, Point v[])
{
    // Do binary search over polygon vertices to find the fan triangle
    // (v[0], v[low], v[high]) the point p lies within the near sides of
    int low = 0, high = n;
    do {
        int mid = (low + high) / 2;
        if (TriangleIsCCW(v[0], v[mid], p))
            low = mid;
        else
            high = mid;
    } while (low + 1 < high);

    // If point outside last (or first) edge, then it is not inside the n-gon
    if (low == 0 || high == n) return 0;

    // p is inside the polygon if it is left of
    // the directed edge from v[low] to v[high]
    return TriangleIsCCW(v[low], v[high], p);
}

=== Section 5.4.2: =============================================================

// Test if point P lies inside the counterclockwise triangle ABC
int PointInTriangle(Point p, Point a, Point b, Point c)
{
    // Translate point and triangle so that point lies at origin
    a -= p; b -= p; c -= p;
    // Compute normal vectors for triangles pab and pbc
    Vector u = Cross(b, c);
    Vector v = Cross(c, a);
    // Make sure they are both pointing in the same direction
    if (Dot(u, v) < 0.0f) return 0;
    // Compute normal vector for triangle pca
    Vector w = Cross(a, b);
    // Make sure it points in the same direction as the first two
    if (Dot(u, w) < 0.0f) return 0;
    // Otherwise P must be in (or on) the triangle
    return 1;
}

--------------------------------------------------------------------------------

// Test if point P lies inside the counterclockwise 3D triangle ABC
int PointInTriangle(Point p, Point a, Point b, Point c)
{
    // Translate point and triangle so that point lies at origin
    a -= p; b -= p; c -= p;

    float ab = Dot(a, b);
    float ac = Dot(a, c);
    float bc = Dot(b, c);
    float cc = Dot(c, c);
    // Make sure plane normals for pab and pbc point in the same direction
    if (bc * ac – cc * ab < 0.0f) return 0;
    // Make sure plane normals for pab and pca point in the same direction
    float bb = Dot(b, b);
    if (ab * bc – ac * bb < 0.0f) return 0;
    // Otherwise P must be in (or on) the triangle
    return 1;
}

--------------------------------------------------------------------------------

// Compute the 2D pseudo cross product Dot(Perp(u), v)
float Cross2D(Vector2D u, Vector2D v)
{
    return u.y * v.x – u.x * v.y;
}

--------------------------------------------------------------------------------

// Test if 2D point P lies inside the counterclockwise 2D triangle ABC
int PointInTriangle(Point2D p, Point2D a, Point2D b, Point2D c)
{
    // If P to the right of AB then outside triangle
    if (Cross2D(p – a, b – a) < 0.0f) return 0;
    // If P to the right of BC then outside triangle
    if (Cross2D(p – b, c – b) < 0.0f) return 0;
    // If P to the right of CA then outside triangle
    if (Cross2D(p – c, a – c) < 0.0f) return 0;
    // Otherwise P must be in (or on) the triangle
    return 1;
}

--------------------------------------------------------------------------------

// Test if 2D point P lies inside 2D triangle ABC
int PointInTriangle2D(Point2D p, Point2D a, Point2D b, Point2D c)
{
    float pab = Cross2D(p – a, b – a);
    float pbc = Cross2D(p – b, c – b);
    // If P left of one of AB and BC and right of the other, not inside triangle
    if (!SameSign(pab, pbc)) return 0;
    float pca = Cross2D(p – c, a – c);
    // If P left of one of AB and CA and right of the other, not inside triangle
    if (!SameSign(pab, pca)) return 0;
    // P left or right of all edges, so must be in (or on) the triangle
    return 1;
}

=== Section 5.4.3: =============================================================

// Test if point p inside polyhedron given as the intersection volume of n halfspaces
int TestPointPolyhedron(Point p, Plane *h, int n)
{
    for (int i = 0; i < n; i++) {
        // Exit with ‘no containment’ if p ever found outside a halfspace
        if (DistPointPlane(p, h[i]) > 0.0f) return 0;
    }
    // p inside all halfspaces, so p must be inside intersection volume
    return 1;
}

=== Section 5.4.4: =============================================================

// Given planes p1 and p2, compute line L = p+t*d of their intersection.
// Return 0 if no such line exists
int IntersectPlanes(Plane p1, Plane p2, Point &p, Vector &d)
{
    // Compute direction of intersection line
    d = Cross(p1.n, p2.n);

    // If d is zero, the planes are parallel (and separated)
    // or coincident, so they’re not considered intersecting
    if (Dot(d, d) < EPSILON) return 0;

    float d11 = Dot(p1.n, p1.n);
    float d12 = Dot(p1.n, p2.n);
    float d22 = Dot(p2.n, p2.n);

    float denom = d11*d22 - d12*d12;
    float k1 = (p1.d*d22 - p2.d*d12) / denom;
    float k2 = (p2.d*d11 - p1.d*d12) / denom;
    p = k1*p1.n + k2*p2.n;
    return 1;
}

--------------------------------------------------------------------------------

// Given planes p1 and p2, compute line L = p+t*d of their intersection.
// Return 0 if no such line exists
int IntersectPlanes(Plane p1, Plane p2, Point &p, Vector &d)
{
    // Compute direction of intersection line
    d = Cross(p1.n, p2.n);

    // If d is (near) zero, the planes are parallel (and separated)
    // or coincident, so they’re not considered intersecting
    float denom = Dot(d, d);
    if (denom < EPSILON) return 0;

    // Compute point on intersection line
    p = Cross(p1.d*p2.n - p2.d*p1.n, d) / denom;
    return 1;
}

=== Section 5.4.5: =============================================================

// Compute the point p at which the three planes p1, p2 and p3 intersect (if at all)
int IntersectPlanes(Plane p1, Plane p2, Plane p3, Point &p)
{
    Vector m1 = Vector(p1.n.x, p2.n.x, p3.n.x);
    Vector m2 = Vector(p1.n.y, p2.n.y, p3.n.y);
    Vector m3 = Vector(p1.n.z, p2.n.z, p3.n.z);

    Vector u = Cross(m2, m3);
    float denom = Dot(m1, u);
    if (Abs(denom) < EPSILON) return 0; // Planes do not intersect in a point
    Vector d(p1.d, p2.d, p3.d);
    Vector v = Cross(m1, d);
    float ood = 1.0f / denom;
    p.x = Dot(d, u) * ood;
    p.y = Dot(m3, v) * ood;
    p.z = -Dot(m2, v) * ood;
    return 1;
}

--------------------------------------------------------------------------------

// Compute the point p at which the three planes p1, p2, and p3 intersect (if at all)
int IntersectPlanes(Plane p1, Plane p2, Plane p3, Point &p)
{
    Vector u = Cross(p2.n, p3.n);
    float denom = Dot(p1.n, u);
    if (Abs(denom) < EPSILON) return 0; // Planes do not intersect in a point
    p = (p1.d * u + Cross(p1.n, p3.d * p2.n – p2.d * p3.n)) / denom;
    return 1;
}

=== Section 5.5.1: =============================================================

// Intersect sphere s0 moving in direction d over time interval t0 <= t <= t1, against
// a stationary sphere s1. If found intersecting, return time t of collision
int TestMovingSphereSphere(Sphere s0, Vector d, float t0, float t1, Sphere s1, float &t)
{
    // Compute sphere bounding motion of s0 during time interval from t0 to t1
    Sphere b;
    float mid = (t0 + t1) * 0.5f;
    b.c = s0.c + d * mid;
    b.r = (mid – t0) * Length(d) + s0.r;
    // If bounding sphere not overlapping s1, then no collision in this interval
    if (!TestSphereSphere(b, s1)) return 0;

    // Cannot rule collision out: recurse for more accurate testing. To terminate the
    // recursion, collision is assumed when time interval becomes sufficiently small
    if (t1 - t0 < INTERVAL_EPSILON) {
        t = t0;
        return 1;
    }

    // Recursively test first half of interval; return collision if detected
    if (TestMovingSphereSphere(s0, d, t0, mid, s1, t)) return 1;

    // Recursively test second half of interval
    return TestMovingSphereSphere(s0, d, mid, t1, s1, t);
}

--------------------------------------------------------------------------------

// Test collision between objects a and b moving over the time interval
// [startTime, endTime]. When colliding, time of collision is returned in hitTime
int IntervalCollision(Object a, Object b, float startTime, float endTime, float &hitTime)
{
    // Compute the maximum distance objects a and b move over the time interval
    float maxMoveA = MaximumObjectMovementOverTime(a, startTime, endTime);
    float maxMoveB = MaximumObjectMovementOverTime(b, startTime, endTime);
    float maxMoveDistSum = maxMoveA + maxMoveB;
    // Exit if distance between a and b at start larger than sum of max movements
    float minDistStart = MinimumObjectDistanceAtTime(a, b, startTime);
    if (minDistStart > maxMoveDistSum) return 0;
    // Exit if distance between a and b at end larger than sum of max movements
    float minDistEnd = MinimumObjectDistanceAtTime(a, b, endTime);
    if (minDistEnd > maxMoveDistSum) return 0;

    // Cannot rule collision out: recurse for more accurate testing. To terminate the
    // recursion, collision is assumed when time interval becomes sufficiently small
    if (endTime – startTime < INTERVAL_EPSILON) {
        hitTime = startTime;
        return 1;
    }
    // Recursively test first half of interval; return collision if detected
    float midTime = (startTime + endTime) * 0.5f;
    if (IntervalCollision(a, b, startTime, midTime, hitTime)) return 1;
    // Recursively test second half of interval
    return IntervalCollision(a, b, midTime, endTime, hitTime);
}

=== Section 5.5.3: =============================================================

// Intersect sphere s with movement vector v with plane p. If intersecting
// return time t of collision and point q at which sphere hits plane
int IntersectMovingSpherePlane(Sphere s, Vector v, Plane p, float &t, Point &q)
{
    // Compute distance of sphere center to plane
    float dist = Dot(p.n, s.c) - p.d;
    if (Abs(dist) <= s.r) {
        // The sphere is already overlapping the plane. Set time of
        // intersection to zero and q to sphere center
        t = 0.0f;
        q = s.c;
        return 1;
    } else {
        float denom = Dot(p.n, v);
        if (denom * dist >= 0.0f) {
            // No intersection as sphere moving parallel to or away from plane
            return 0;
        } else {
            // Sphere is moving towards the plane

            // Use +r in computations if sphere in front of plane, else -r
            float r = dist > 0.0f ? s.r : -s.r;
            t = (r - dist) / denom;
            q = s.c + t * v – r * p.n;
            return 1;
        }
    }
}

--------------------------------------------------------------------------------

// Test if sphere with radius r moving from a to b intersects with plane p
int TestMovingSpherePlane(Point a, Point b, float r, Plane p)
{
    // Get the distance for both a and b from plane p
    float adist = Dot(a, p.n) - p.d;
    float bdist = Dot(b, p.n) - p.d;
    // Intersects if on different sides of plane (distances have different signs)
    if (adist * bdist < 0.0f) return 1;
    // Intersects if start or end position within radius from plane
    if (Abs(adist) <= r || Abs(bdist) <= r) return 1;
    // No intersection
    return 0;
}

=== Section 5.5.5: =============================================================

int TestMovingSphereSphere(Sphere s0, Sphere s1, Vector v0, Vector v1, float &t)
{
    Vector s = s1.c - s0.c;      // Vector between sphere centers
    Vector v = v1 - v0;          // Relative motion of s1 with respect to stationary s0
    float r = s1.r + s0.r;       // Sum of sphere radii
    float c = Dot(s, s) – r * r;
    if (c < 0.0f) {
        // Spheres initially overlapping so exit directly
        t = 0.0f;
        return 1;
    }
    float a = Dot(v, v);
    if (a < EPSILON) return 0; // Spheres not moving relative each other
    float b = Dot(v, s);
    if (b >= 0.0f) return 0;   // Spheres not moving towards each other
    float d = b * b – a * c;
    if (d < 0.0f) return 0;    // No real-valued root, spheres do not intersect

    t = (-b – Sqrt(d)) / a;
    return 1;
}

--------------------------------------------------------------------------------

int TestMovingSphereSphere(Sphere s0, Sphere s1, Vector v0, Vector v1, float &t)
{
    // Expand sphere s1 by the radius of s0
    s1.r += s0.r;
    // Subtract movement of s1 from both s0 and s1, making s1 stationary
    Vector v = v0 – v1;
    // Can now test directed segment s = s0.c + tv, v = (v0-v1)/||v0-v1|| against
    // the expanded sphere for intersection
    Point q;
    float vlen = Length(v);
    if (IntersectRaySphere(s0.c, v / vlen, s1, t, q)) {
        return t <= vlen;
    }
    return 0;
}

=== Section 5.5.7: =============================================================

int IntersectMovingSphereAABB(Sphere s, Vector d, AABB b, float &t)
{
    // Compute the AABB resulting from expanding b by sphere radius r
    AABB e = b;
    e.min.x -= s.r; e.min.y -= s.r; e.min.z -= s.r;
    e.max.x += s.r; e.max.y += s.r; e.max.z += s.r;

    // Intersect ray against expanded AABB e. Exit with no intersection if ray
    // misses e, else get intersection point p and time t as result
    Point p;
    if (!IntersectRayAABB(s.c, d, e, t, p) || t > 1.0f)
        return 0;

    // Compute which min and max faces of b the intersection point p lies
    // outside of. Note, u and v cannot have the same bits set and
    // they must have at least one bit set amongst them
    int u = 0, v = 0;
    if (p.x < b.min.x) u |= 1;
    if (p.x > b.max.x) v |= 1;
    if (p.y < b.min.y) u |= 2;
    if (p.y > b.max.y) v |= 2;
    if (p.z < b.min.z) u |= 4;
    if (p.z > b.max.z) v |= 4;

    // ‘Or’ all set bits together into a bit mask (note: here u + v == u | v)
    int m = u + v;

    // Define line segment [c, c+d] specified by the sphere movement
    Segment seg(s.c, s.c + d);

    // If all 3 bits set (m == 7) then p is in a vertex region
    if (m == 7) {
        // Must now intersect segment [c, c+d] against the capsules of the three
        // edges meeting at the vertex and return the best time, if one or more hit
        float tmin = FLT_MAX;
        if (IntersectSegmentCapsule(seg, Corner(b, v), Corner(b, v ^ 1), s.r, &t))
            tmin = Min(t, tmin);
        if (IntersectSegmentCapsule(seg, Corner(b, v), Corner(b, v ^ 2), s.r, &t))
            tmin = Min(t, tmin);
        if (IntersectSegmentCapsule(seg, Corner(b, v), Corner(b, v ^ 4), s.r, &t))
            tmin = Min(t, tmin);
        if (tmin == FLT_MAX) return 0; // No intersection
        t = tmin;
        return 1; // Intersection at time t == tmin
    }
    // If only one bit set in m, then p is in a face region
    if ((m & (m - 1)) == 0) {
        // Do nothing. Time t from intersection with
        // expanded box is correct intersection time
        return 1;
    }
    // p is in an edge region. Intersect against the capsule at the edge
    return IntersectSegmentCapsule(seg, Corner(b, u ^ 7), Corner(b, v), s.r, &t);
}

// Support function that returns the AABB vertex with index n
Point Corner(AABB b, int n)
{
    Point p;
    p.x = ((n & 1) ? b.max.x : b.min.x);
    p.y = ((n & 2) ? b.max.y : b.min.y);
    p.z = ((n & 4) ? b.max.z : b.min.z);
    return p;
}

=== Section 5.5.8: =============================================================

// Intersect AABBs ‘a’ and ‘b’ moving with constant velocities va and vb.
// On intersection, return time of first and last contact in tfirst and tlast
int IntersectMovingAABBAABB(AABB a, AABB b, Vector va, Vector vb, float &tfirst, float &tlast)
{
    // Exit early if ‘a’ and ‘b’ initially overlapping
    if (TestAABBAABB(a, b)) {
        tfirst = tlast = 0.0f;
        return 1;
    }

    // Use relative velocity; effectively treating 'a' as stationary
    Vector v = vb - va;

    // Initialize times of first and last contact
    tfirst = 0.0f;
    tlast = 1.0f;

    // For each axis, determine times of first and last contact, if any
    for (int i = 0; i < 3; i++) {
        if (v[i] < 0.0f) {
            if (b.max[i] < a.min[i]) return 0; // Nonintersecting and moving apart
            if (a.max[i] < b.min[i]) tfirst = Max((a.max[i] - b.min[i]) / v[i], tfirst);
            if (b.max[i] > a.min[i]) tlast  = Min((a.min[i] - b.max[i]) / v[i], tlast);
        }
        if (v[i] > 0.0f) {
            if (b.min[i] > a.max[i]) return 0; // Nonintersecting and moving apart
            if (b.max[i] < a.min[i]) tfirst = Max((a.min[i] - b.max[i]) / v[i], tfirst);
            if (a.max[i] > b.min[i]) tlast = Min((a.max[i] - b.min[i]) / v[i], tlast);
        }

        // No overlap possible if time of first contact occurs after time of last contact
        if (tfirst > tlast) return 0;
    }

    return 1;
}
