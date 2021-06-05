
=== Section 4.2: ===============================================================

// region R = { (x, y, z) | min.x<=x<=max.x, min.y<=y<=max.y, min.z<=z<=max.z }
struct AABB {
    Point min;
    Point max;
};

--------------------------------------------------------------------------------

// region R = {(x, y, z) | min.x<=x<=min.x+dx, min.y<=y<=min.y+dy, min.z<=z<=min.z+dz }
struct AABB {
    Point min;
    float d[3];   // diameter or width extents (dx, dy, dz)
};

--------------------------------------------------------------------------------

// region R = { (x, y, z) | |c.x-x|<=rx, |c.y-y|<=ry, |c.z-z|<=rz }
struct AABB {
    Point c; // center point of AABB
    float r[3]; // radius or halfwidth extents (rx, ry, rz)
};

=== Section 4.2.1: =============================================================

int TestAABBAABB(AABB a, AABB b)
{
    // Exit with no intersection if separated along an axis
    if (a.max[0] < b.min[0] || a.min[0] > b.max[0]) return 0;
    if (a.max[1] < b.min[1] || a.min[1] > b.max[1]) return 0;
    if (a.max[2] < b.min[2] || a.min[2] > b.max[2]) return 0;
    // Overlapping on all axes means AABBs are intersecting
    return 1;
}

--------------------------------------------------------------------------------

int TestAABBAABB(AABB a, AABB b)
{
    float t;
    if ((t = a.min[0] - b.min[0]) > b.d[0] || -t > a.d[0]) return 0;
    if ((t = a.min[1] - b.min[1]) > b.d[1] || -t > a.d[1]) return 0;
    if ((t = a.min[2] - b.min[2]) > b.d[2] || -t > a.d[2]) return 0;
    return 1;
}

--------------------------------------------------------------------------------

int TestAABBAABB(AABB a, AABB b)
{
    if (Abs(a.c[0] - b.c[0]) > (a.r[0] + b.r[0])) return 0;
    if (Abs(a.c[1] - b.c[1]) > (a.r[1] + b.r[1])) return 0;
    if (Abs(a.c[2] - b.c[2]) > (a.r[2] + b.r[2])) return 0;
    return 1;
}

--------------------------------------------------------------------------------

overlap = (unsigned int)(B - C) <= (B - A) + (D - C);

--------------------------------------------------------------------------------

int TestAABBAABB(AABB a, AABB b)
{
    int r;
    r = a.r[0] + b.r[0]; if ((unsigned int)(a.c[0] - b.c[0] + r) > r + r) return 0;
    r = a.r[1] + b.r[1]; if ((unsigned int)(a.c[1] - b.c[1] + r) > r + r) return 0;
    r = a.r[2] + b.r[2]; if ((unsigned int)(a.c[2] - b.c[2] + r) > r + r) return 0;
    return 1;
}

=== Section 4.2.4: =============================================================

// Returns indices imin and imax into pt[] array of the least and
// most, respectively, distant points along the direction dir
void ExtremePointsAlongDirection(Vector dir, Point pt[], int n, int *imin, int *imax)
{
    float minproj = FLT_MAX, maxproj = -FLT_MAX;
    for (int i = 0; i < n; i++) {
        // Project vector from origin to point onto direction vector
        float proj = Dot(pt[i], dir);
        // Keep track of least distant point along direction vector
        if (proj < minproj) {
            minproj = proj;
            *imin = i;
        }
        // Keep track of most distant point along direction vector
        if (proj > maxproj) {
            maxproj = proj;
            *imax = i;
        }
    }
}

=== Section 4.2.6: =============================================================

B.max[0] = max(m[0][0] * A.min[0], m[0][0] * A.max[0])
         + max(m[0][1] * A.min[1], m[0][1] * A.max[1])
         + max(m[0][2] * A.min[2], m[0][2] * A.max[2]) + t[0];

--------------------------------------------------------------------------------

// Transform AABB a by the matrix m and translation t,
// find maximum extents, and store result into AABB b.
void UpdateAABB(AABB a, float m[3][3], float t[3], AABB &b)
{
    // For all three axes
    for (int i = 0; i < 3; i++) {
        // Start by adding in translation
        b.min[i] = b.max[i] = t[i];
        // Form extent by summing smaller and larger terms respectively
        for (int j = 0; j < 3; j++) {
            float e = m[i][j] * a.min[j];
            float f = m[i][j] * a.max[j];
            if (e < f) {
                b.min[i] += e;
                b.max[i] += f;
            } else {
                b.min[i] += f;
                b.max[i] += e;
            }
        }
    }
}

--------------------------------------------------------------------------------

// Transform AABB a by the matrix m and translation t,
// find maximum extents, and store result into AABB b.
void UpdateAABB(AABB a, float m[3][3], float t[3], AABB &b)
{
    for (int i = 0; i < 3; i++) {
        b.c[i] = t[i];
        b.r[i] = 0.0f;
        for (int j = 0; j < 3; j++) {
            b.c[i] += m[i][j] * a.c[j];
            b.r[i] += Abs(m[i][j]) * a.r[j];
        }
    }
}

=== Section 4.3: ===============================================================

// Region R = { (x, y, z) | (x-c.x)^2 + (y-c.y)^2 + (z-c.z)^2 <= r^2 }
struct Sphere {
    Point c; // Sphere center
    float r; // Sphere radius
};

=== Section 4.3.1: =============================================================

int TestSphereSphere(Sphere a, Sphere b)
{
    // Calculate squared distance between centers
    Vector d = a.c – b.c;
    float dist2 = Dot(d, d);
    // Spheres intersect if squared distance is less than squared sum of radii
    float radiusSum = a.r + b.r;
    return dist2 <= radiusSum * radiusSum;
}

=== Section 4.3.2: =============================================================

// Compute indices to the two most separated points of the (up to) six points
// defining the AABB encompassing the point set. Return these as min and max.
void MostSeparatedPointsOnAABB(int &min, int &max, Point pt[], int numPts)
{
    // First find most extreme points along principal axes
    int minx = 0, maxx = 0, miny = 0, maxy = 0, minz = 0, maxz = 0;
    for (int i = 1; i < numPts; i++) {
        if (pt[i].x < pt[minx].x) minx = i;
        if (pt[i].x > pt[maxx].x) maxx = i;
        if (pt[i].y < pt[miny].y) miny = i;
        if (pt[i].y > pt[maxy].y) maxy = i;
        if (pt[i].z < pt[minz].z) minz = i;
        if (pt[i].z > pt[maxz].z) maxz = i;
    }

    // Compute the squared distances for the three pairs of points
    float dist2x = Dot(pt[maxx] – pt[minx], pt[maxx] – pt[minx]);
    float dist2y = Dot(pt[maxy] – pt[miny], pt[maxy] – pt[miny]);
    float dist2z = Dot(pt[maxz] – pt[minz], pt[maxz] – pt[minz]);
    // Pick the pair (min,max) of points most distant
    min = minx;
    max = maxx;
    if (dist2y > dist2x && dist2y > dist2z) {
        max = maxy;
        min = miny;
    }
    if (dist2z > dist2x && dist2z > dist2y) {
        max = maxz;
        min = minz;
    }
}

void SphereFromDistantPoints(Sphere &s, Point pt[], int numPts)
{
    // Find the most separated point pair defining the encompassing AABB
    int min, max;
    MostSeparatedPointsOnAABB(min, max, pt, numPts);

    // Set up sphere to just encompass these two points
    s.c = (pt[min] + pt[max]) * 0.5f;
    s.r = Dot(pt[max] - s.c, pt[max] - s.c);
    s.r = Sqrt(s.r);
}

--------------------------------------------------------------------------------

// Given Sphere s and Point p, update s (if needed) to just encompass p
void SphereOfSphereAndPt(Sphere &s, Point &p)
{
    // Compute squared distance between point and sphere center
    Vector d = p – s.c;
    float dist2 = Dot(d, d);
    // Only update s if point p is outside it
    if (dist2 > s.r * s.r) {
        float dist = Sqrt(dist2);
        float newRadius = (s.r + dist) * 0.5f;
        float k = (newRadius - s.r) / dist;
        s.r = newRadius;
        s.c += d * k;
    }
}

--------------------------------------------------------------------------------

void RitterSphere(Sphere &s, Point pt[], int numPts)
{
    // Get sphere encompassing two approximately most distant points
    SphereFromDistantPoints(s, pt, numPts);

    // Grow sphere to include all points
    for (int i = 0; i < numPts; i++)
        SphereOfSphereAndPt(s, pt[i]);
}

=== Section 4.3.3: =============================================================

// Compute variance of a set of 1D values
float Variance(float x[], int n)
{
    float u = 0.0f;
    for (int i = 0; i < n; i++)
        u += x[i];
    u /= n;
    float s2 = 0.0f;
    for (int i = 0; i < n; i++)
        s2 += (x[i] - u) * (x[i] - u);
    return s2 / n;
}

--------------------------------------------------------------------------------

void CovarianceMatrix(Matrix33 &cov, Point pt[], int numPts)
{
    float oon = 1.0f / (float)numPts;
    Point c = Point(0.0f, 0.0f, 0.0f);
    float e00, e11, e22, e01, e02, e12;

    // Compute the center of mass (centroid) of the points
    for (int i = 0; i < numPts; i++)
        c += pt[i];
    c *= oon;
    
    // Compute covariance elements
    e00 = e11 = e22 = e01 = e02 = e12 = 0.0f;
    for (int i = 0; i < numPts; i++) {
        // Translate points so center of mass is at origin
        Point p = pt[i] - c;
        // Compute covariance of translated points
        e00 += p.x * p.x;
        e11 += p.y * p.y;
        e22 += p.z * p.z;
        e01 += p.x * p.y;
        e02 += p.x * p.z;
        e12 += p.y * p.z;
    }
    // Fill in the covariance matrix elements
    cov[0][0] = e00 * oon;
    cov[1][1] = e11 * oon;
    cov[2][2] = e22 * oon;
    cov[0][1] = cov[1][0] = e01 * oon;
    cov[0][2] = cov[2][0] = e02 * oon;
    cov[1][2] = cov[2][1] = e12 * oon;
}

--------------------------------------------------------------------------------

// 2-by-2 Symmetric Schur decomposition. Given an n-by-n symmetric matrix
// and indicies p, q such that 1 <= p < q <= n, computes a sine-cosine pair
// (s, c) that will serve to form a Jacobi rotation matrix.
//
// See Golub, Van Loan, Matrix Computations, 3rd ed, p428
void SymSchur2(Matrix33 &a, int p, int q, float &c, float &s)
{
    if (Abs(a[p][q]) > 0.0001f) {
        float r = (a[q][q] - a[p][p]) / (2.0f * a[p][q]);
        float t;
        if (r >= 0.0f)
            t = 1.0f / (r + Sqrt(1.0f + r*r));
        else
            t = -1.0f / (-r + Sqrt(1.0f + r*r));
        c = 1.0f / Sqrt(1.0f + t*t);
        s = t * c;
    } else {
        c = 1.0f;
        s = 0.0f;
    }
}

--------------------------------------------------------------------------------

// Computes the eigenvectors and eigenvalues of the symmetric matrix A using
// the classic Jacobi method of iteratively updating A as A = J^T * A * J,
// where J = J(p, q, theta) is the Jacobi rotation matrix.
//
// On exit, v will contain the eigenvectors, and the diagonal elements
// of a are the corresponding eigenvalues.
//
// See Golub, Van Loan, Matrix Computations, 3rd ed, p428
void Jacobi(Matrix33 &a, Matrix33 &v)
{
    int i, j, n, p, q;
    float prevoff, c, s;
    Matrix33 J, b, t;

    // Initialize v to identity matrix
    for (i = 0; i < 3; i++) {
        v[i][0] = v[i][1] = v[i][2] = 0.0f;
        v[i][i] = 1.0f;
    }

    // Repeat for some maximum number of iterations
    const int MAX_ITERATIONS = 50;
    for (n = 0; n < MAX_ITERATIONS; n++) {
        // Find largest off-diagonal absolute element a[p][q]
        p = 0; q = 1;
        for (i = 0; i < 3; i++) {
            for (j = 0; j < 3; j++) {
                if (i == j) continue;
                if (Abs(a[i][j]) > Abs(a[p][q])) {
                    p = i;
                    q = j;
                }
            }
        }

        // Compute the Jacobi rotation matrix J(p, q, theta)
        // (This code can be optimized for the three different cases of rotation)
        SymSchur2(a, p, q, c, s);
        for (i = 0; i < 3; i++) {
            J[i][0] = J[i][1] = J[i][2] = 0.0f;
            J[i][i] = 1.0f;
        }
        J[p][p] =  c; J[p][q] = s;
        J[q][p] = -s; J[q][q] = c;

        // Cumulate rotations into what will contain the eigenvectors
        v = v * J;

        // Make 'a' more diagonal, until just eigenvalues remain on diagonal
        a = (J.Transpose() * a) * J;
    
        // Compute "norm" of off-diagonal elements
        float off = 0.0f;
        for (i = 0; i < 3; i++) {
            for (j = 0; j < 3; j++) {
                if (i == j) continue;
                off += a[i][j] * a[i][j];
            }
        }
        /* off = sqrt(off); not needed for norm comparison */

        // Stop when norm no longer decreasing
        if (n > 2 && off >= prevoff)
            return;
        
        prevoff = off;
    }
}

--------------------------------------------------------------------------------

void EigenSphere(Sphere &eigSphere, Point pt[], int numPts)
{
    Matrix33 m, v;

    // Compute the covariance matrix m
    CovarianceMatrix(m, pt, numPts);
    // Decompose it into eigenvectors (in v) and eigenvalues (in m)
    Jacobi(m, v);

    // Find the component with largest magnitude eigenvalue (largest spread)
    Vector e;
    int maxc = 0;
    float maxf, maxe = Abs(m[0][0]);
    if ((maxf = Abs(m[1][1])) > maxe) maxc = 1, maxe = maxf;
    if ((maxf = Abs(m[2][2])) > maxe) maxc = 2, maxe = maxf;
    e[0] = v[0][maxc];
    e[1] = v[1][maxc];
    e[2] = v[2][maxc];

    // Find the most extreme points along direction 'e'
    int imin, imax;
    ExtremePointsAlongDirection(e, pt, numPts, &imin, &imax);
    Point minpt = pt[imin];
    Point maxpt = pt[imax];

    float dist = Sqrt(Dot(maxpt - minpt, maxpt - minpt));
    eigSphere.r = dist * 0.5f;
    eigSphere.c = (minpt + maxpt) * 0.5f;
}

--------------------------------------------------------------------------------

void RitterEigenSphere(Sphere &s, Point pt[], int numPts)
{
    // Start with sphere from maximum spread
    EigenSphere(s, pt, numPts);

    // Grow sphere to include all points
    for (int i = 0; i < numPts; i++)
        SphereOfSphereAndPt(s, pt[i]);
}

=== Section 4.3.4: =============================================================

void RitterIterative(Sphere &s, Point pt[], int numPts)
{
    const int NUM_ITER = 8;
    RitterSphere(s, pt, numPts);
    Sphere s2 = s;
    for (int k = 0; k < NUM_ITER; k++) {
        // Shrink sphere somewhat to make it an underestimate (not bound)
        s2.r = s2.r * 0.95f;
	
        // Make sphere bound data again
        for (int i = 0; i < numPts; i++) {
            // Swap pt[i] with pt[j], where j randomly from interval [i+1,numPts-1]
            DoRandomSwap();
            SphereOfSphereAndPt(s2, pt[i]);
        }

        // Update s whenever a tighter sphere is found
        if (s2.r < s.r) s = s2;
    }
}

=== Section 4.3.5: =============================================================

Sphere WelzlSphere(Point pt[], unsigned int numPts, Point sos[], unsigned int numSos)
{
    // if no input points, the recursion has bottomed out. Now compute an
    // exact sphere based on points in set of support (zero through four points)
    if (numPts == 0) {
        switch (numSos) {
        case 0: return Sphere();
        case 1: return Sphere(sos[0]);
        case 2: return Sphere(sos[0], sos[1]);
        case 3: return Sphere(sos[0], sos[1], sos[2]);
        case 4: return Sphere(sos[0], sos[1], sos[2], sos[3]);
        }
    }
    // Pick a point at "random" (here just the last point of the input set)
    int index = numPts - 1;
    // Recursively compute the smallest bounding sphere of the remaining points
    Sphere smallestSphere = WelzlSphere(pt, numPts - 1, sos, numSos); // (*)
    // If the selected point lies inside this sphere, it is indeed the smallest
    if(PointInsideSphere(pt[index], smallestSphere))
        return smallestSphere;
    // Otherwise, update set of support to additionally contain the new point
    sos[numSos] = pt[index];
    // Recursively compute the smallest sphere of remaining points with new s.o.s.
    return WelzlSphere(pt, numPts - 1, sos, numSos + 1);
}

=== Section 4.4: ===============================================================

// Region R = { x | x = c+r*u[0]+s*u[1]+t*u[2] }, |r|<=e[0], |s|<=e[1], |t|<=e[2]
struct OBB {
    Point c;     // OBB center point
    Vector u[3]; // Local x-, y-, and z-axes
    Vector e;    // Positive halfwidth extents of OBB along each axis
};

=== Section 4.4.1: =============================================================

int TestOBBOBB(OBB &a, OBB &b)
{
    float ra, rb;
    Matrix33 R, AbsR;

    // Compute rotation matrix expressing b in a's coordinate frame
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            R[i][j] = Dot(a.u[i], b.u[j]);

    // Compute translation vector t
    Vector t = b.c - a.c;
    // Bring translation into a's coordinate frame
    t = Vector(Dot(t, a.u[0]), Dot(t, a.u[1]), Dot(t, a.u[2]));

    // Compute common subexpressions. Add in an epsilon term to
    // counteract arithmetic errors when two edges are parallel and
    // their cross product is (near) null (see text for details)
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            AbsR[i][j] = Abs(R[i][j]) + EPSILON;

    // Test axes L = A0, L = A1, L = A2
    for (int i = 0; i < 3; i++) {
        ra = a.e[i];
        rb = b.e[0] * AbsR[i][0] + b.e[1] * AbsR[i][1] + b.e[2] * AbsR[i][2];
        if (Abs(t[i]) > ra + rb) return 0;
    }

    // Test axes L = B0, L = B1, L = B2
    for (int i = 0; i < 3; i++) {
        ra = a.e[0] * AbsR[0][i] + a.e[1] * AbsR[1][i] + a.e[2] * AbsR[2][i];
        rb = b.e[i];
        if (Abs(t[0] * R[0][i] + t[1] * R[1][i] + t[2] * R[2][i]) > ra + rb) return 0;
    }

    // Test axis L = A0 x B0
    ra = a.e[1] * AbsR[2][0] + a.e[2] * AbsR[1][0];
    rb = b.e[1] * AbsR[0][2] + b.e[2] * AbsR[0][1];
    if (Abs(t[2] * R[1][0] - t[1] * R[2][0]) > ra + rb) return 0;

    // Test axis L = A0 x B1
    ra = a.e[1] * AbsR[2][1] + a.e[2] * AbsR[1][1];
    rb = b.e[0] * AbsR[0][2] + b.e[2] * AbsR[0][0];
    if (Abs(t[2] * R[1][1] - t[1] * R[2][1]) > ra + rb) return 0;

    // Test axis L = A0 x B2
    ra = a.e[1] * AbsR[2][2] + a.e[2] * AbsR[1][2];
    rb = b.e[0] * AbsR[0][1] + b.e[1] * AbsR[0][0];
    if (Abs(t[2] * R[1][2] - t[1] * R[2][2]) > ra + rb) return 0;

    // Test axis L = A1 x B0
    ra = a.e[0] * AbsR[2][0] + a.e[2] * AbsR[0][0];
    rb = b.e[1] * AbsR[1][2] + b.e[2] * AbsR[1][1];
    if (Abs(t[0] * R[2][0] - t[2] * R[0][0]) > ra + rb) return 0;

    // Test axis L = A1 x B1
    ra = a.e[0] * AbsR[2][1] + a.e[2] * AbsR[0][1];
    rb = b.e[0] * AbsR[1][2] + b.e[2] * AbsR[1][0];
    if (Abs(t[0] * R[2][1] - t[2] * R[0][1]) > ra + rb) return 0;

    // Test axis L = A1 x B2
    ra = a.e[0] * AbsR[2][2] + a.e[2] * AbsR[0][2];
    rb = b.e[0] * AbsR[1][1] + b.e[1] * AbsR[1][0];
    if (Abs(t[0] * R[2][2] - t[2] * R[0][2]) > ra + rb) return 0;

    // Test axis L = A2 x B0
    ra = a.e[0] * AbsR[1][0] + a.e[1] * AbsR[0][0];
    rb = b.e[1] * AbsR[2][2] + b.e[2] * AbsR[2][1];
    if (Abs(t[1] * R[0][0] - t[0] * R[1][0]) > ra + rb) return 0;

    // Test axis L = A2 x B1
    ra = a.e[0] * AbsR[1][1] + a.e[1] * AbsR[0][1];
    rb = b.e[0] * AbsR[2][2] + b.e[2] * AbsR[2][0];
    if (Abs(t[1] * R[0][1] - t[0] * R[1][1]) > ra + rb) return 0;

    // Test axis L = A2 x B2
    ra = a.e[0] * AbsR[1][2] + a.e[1] * AbsR[0][2];
    rb = b.e[0] * AbsR[2][1] + b.e[1] * AbsR[2][0];
    if (Abs(t[1] * R[0][2] - t[0] * R[1][2]) > ra + rb) return 0;

    // Since no separating axis found, the OBBs must be intersecting
    return 1;
}

=== Section 4.4.4: =============================================================

// Compute the center point, 'c', and axis orientation, u[0] and u[1], of
// the minimum area rectangle in the xy plane containing the points pt[].
float MinAreaRect(Point2D pt[], int numPts, Point2D &c, Vector2D u[2])
{
    float minArea = FLT_MAX;

    // Loop through all edges; j trails i by 1, modulo numPts
    for (int i = 0, j = numPts - 1; i < numPts; j = i, i++) {
        // Get current edge e0 (e0x,e0y), normalized
        Vector2D e0 = pt[i] – pt[j];
        e0 /= Length(e0);
        
        // Get an axis e1 orthogonal to edge e0
        Vector2D e1 = Vector2D(-e0.y, e0.x); // = Perp2D(e0)

        // Loop through all points to get maximum extents
        float min0 = 0.0f, min1 = 0.0f, max0 = 0.0f, max1 = 0.0f;
        for (int k = 0; k < numPts; k++) {
            // Project points onto axes e0 and e1 and keep track
            // of minimum and maximum values along both axes
            Vector2D d = pt[k] – pt[j];
            float dot = Dot2D(d, e0);
            if (dot < min0) min0 = dot;
            if (dot > max0) max0 = dot;
            dot = Dot2D(d, e1);
            if (dot < min1) min1 = dot;
            if (dot > max1) max1 = dot;
        }
        float area = (max0 - min0) * (max1 - min1);
    
        // If best so far, remember area, center, and axes
        if (area < minArea) {
            minArea = area;
            c = pt[j] + 0.5f * ((min0 + max0) * e0 + (min1 + max1) * e1);
            u[0] = e0; u[1] = e1;
        }
    }
    return minArea;
}

=== Section 4.5: ===============================================================

// Region R = { x | (x - [a + (b - a)*t])^2 <= r }, 0 <= t <= 1
struct Capsule {
    Point a;      // Medial line segment start point
    Point b;      // Medial line segment end point
    float r;      // Radius
};

// Region R = { x | (x - [a + u[0]*s + u[1]*t])^2 <= r }, 0 <= s,t <= 1
struct Lozenge {
    Point a;      // Origin
    Vector u[2];  // The two edges axes of the rectangle
    float r;      // Radius
};

=== Section 4.5.1: =============================================================

int TestSphereCapsule(Sphere s, Capsule capsule)
{
    // Compute (squared) distance between sphere center and capsule line segment
    float dist2 = SqDistPointSegment(capsule.a, capsule.b, s.c);

    // If (squared) distance smaller than (squared) sum of radii, they collide
    float radius = s.r + capsule.r;
    return dist2 <= radius * radius;
}

int TestCapsuleCapsule(Capsule capsule1, Capsule capsule2)
{
    // Compute (squared) distance between the inner structures of the capsules
    float s, t;
    Point c1, c2;
    float dist2 = ClosestPtSegmentSegment(capsule1.a, capsule1.b,
                                          capsule2.a, capsule2.b, s, t, c1, c2);

    // If (squared) distance smaller than (squared) sum of radii, they collide
    float radius = capsule1.r + capsule2.r;
    return dist2 <= radius * radius;
}

=== Section 4.6.1: =============================================================

// Region R = { (x, y, z) | dNear <= a*x + b*y + c*z <= dFar }
struct Slab {
    float n[3];  // Normal n = (a, b, c)
    float dNear; // Signed distance from origin for near plane (dNear)
    float dFar;  // Signed distance from origin for far plane (dFar)
};

=== Section 4.6.2: =============================================================

struct DOP8 {
    float min[4]; // Minimum distance (from origin) along axes 0 to 3
    float max[4]; // Maximum distance (from origin) along axes 0 to 3
};

=== Section 4.6.3: =============================================================

int TestKDOPKDOP(KDOP &a, KDOP &b, int k)
{
    // Check if any intervals are non-overlapping, return if so
    for (int i = 0; i < k / 2; i++)
        if (a.min[i] > b.max[i] || a.max[i] < b.min[i])
            return 0;

    // All intervals are overlapping, so k-DOPs must intersect
    return 1;
}

=== Section 4.6.4: =============================================================

// Compute 8-DOP for object vertices v[] in world space
// using the axes (1,1,1), (1,1,-1), (1,-1,1) and (-1,1,1)
void ComputeDOP8(Point v[], int numPts, DOP8 &dop8)
{
    // Initialize 8-DOP to an empty volume
    dop8.min[0] = dop8.min[1] = dop8.min[2] = dop8.min[3] = FLT_MAX;
    dop8.max[0] = dop8.max[1] = dop8.max[2] = dop8.max[3] = -FLT_MAX;

    // For each point, update 8-DOP bounds if necessary
    float value;
    for (int i = 0; i < numPts; i++) {
        // Axis 0 = (1,1,1)
        value = v[i].x + v[i].y + v[i].z;
        if (value < dop8.min[0]) dop8.min[0] = value;
        else if (value > dop8.max[0]) dop8.max[0] = value;

        // Axis 1 = (1,1,-1)
        value = v[i].x + v[i].y - v[i].z;
        if (value < dop8.min[1]) dop8.min[1] = value;
        else if (value > dop8.max[1]) dop8.max[1] = value;

        // Axis 2 = (1,-1,1)
        value = v[i].x - v[i].y + v[i].z;
        if (value < dop8.min[2]) dop8.min[2] = value;
        else if (value > dop8.max[2]) dop8.max[2] = value;

        // Axis 3 = (-1,1,1)
        value = -v[i].x + v[i].y + v[i].z;
        if (value < dop8.min[3]) dop8.min[3] = value;
        else if (value > dop8.max[3]) dop8.max[3] = value;
    }
}
