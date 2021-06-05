
=== Section 8.3: ===============================================================

// Constructs BSP tree from an input vector of polygons. Pass 'depth' as 0 on entry
BSPNode *BuildBSPTree(std::vector<Polygon *> &polygons, int depth)
{
    // Return NULL tree if there are no polygons
    if (polygons.empty()) return NULL;

    // Get number of polygons in the input vector
    int numPolygons = polygons.size();

    // If criterion for a leaf is matched, create a leaf node from remaining polygons
    if (depth >= MAX_DEPTH || numPolygons <= MIN_LEAF_SIZE) || ...etc...)
        return new BSPNode(polygons);

    // Select best possible partitioning plane based on the input geometry
    Plane splitPlane = PickSplittingPlane(polygons);

    std::vector<Polygon *> frontList, backList;

    // Test each polygon against the dividing plane, adding them
    // to the front list, back list, or both, as appropriate
    for (int i = 0; i < numPolygons; i++) {
        Polygon *poly = polygons[i], *frontPart, *backPart;
        switch (ClassifyPolygonToPlane(poly, splitPlane)) {
        case COPLANAR_WITH_PLANE:
            // What's done in this case depends on what type of tree is being
            // built. For a node-storing tree, the polygon is stored inside
            // the node at this level (along with all other polygons coplanar
            // with the plane). Here, for a leaf-storing tree, coplanar polygons
            // are sent to either side of the plane. In this case, to the front
            // side, by falling through to the next case
        case IN_FRONT_OF_PLANE:
            frontList.push_back(poly);
            break;
        case BEHIND_PLANE:
            backList.push_back(poly);
            break;
        case STRADDLING_PLANE:
            // Split polygon to plane and send a part to each side of the plane
            SplitPolygon(*poly, splitPlane, &frontPart, &backPart);
            frontList.push_back(frontPart);
            backList.push_back(backPart);
            break;
        }
    }

    // Recursively build child subtrees and return new tree root combining them
    BSPNode *frontTree = BuildBSPTree(frontList, depth + 1);
    BSPNode *backTree = BuildBSPTree(backList, depth + 1);
    return new BSPNode(frontTree, backTree);
}

=== Section 8.3.2: =============================================================

// Given a vector of polygons, attempts to compute a good splitting plane
Plane PickSplittingPlane(std::vector<Polygon *> &polygons)
{
    // Blend factor for optimizing for balance or splits (should be tweaked)
    const float K = 0.8f;
    // Variables for tracking best splitting plane seen so far
    Plane bestPlane;
    float bestScore = FLT_MAX;

    // Try the plane of each polygon as a dividing plane
    for (int i = 0; i < polygons.size(); i++) {
        int numInFront = 0, numBehind = 0, numStraddling = 0;
        Plane plane = GetPlaneFromPolygon(polygons[i]);
        // Test against all other polygons
        for (int j = 0; j < polygons.size(); j++) {
            // Ignore testing against self
            if (i == j) continue;
            // Keep standing count of the various poly-plane relationships
            switch (ClassifyPolygonToPlane(polygons[j], plane)) {
            case POLYGON_COPLANAR_WITH_PLANE:
                /* Coplanar polygons treated as being in front of plane */
            case POLYGON_IN_FRONT_OF_PLANE:
                numInFront++;
                break;
            case POLYGON_BEHIND_PLANE:
                numBehind++;
                break;
            case POLYGON_STRADDLING_PLANE:
                numStraddling++;
                break;
            }
        }
        // Compute score as a weighted combination (based on K, with K in range
        // 0..1) between balance and splits (lower score is better)
        float score = K * numStraddling + (1.0f - K) * Abs(numInFront - numBehind);
        if (score < bestScore) {
            bestScore = score;
            bestPlane = plane;
        }
    }
    return bestPlane;
}

=== Section 8.3.3: =============================================================

// Classify point p to a plane thickened by a given thickness epsilon
int ClassifyPointToPlane(Point p, Plane plane) {
    // Compute signed distance of point from plane
    float dist = Dot(plane.n, p) - plane.d;
    // Classify p based on the signed distance
    if (dist > PLANE_THICKNESS_EPSILON)
        return POINT_IN_FRONT_OF_PLANE;
    if (dist < -PLANE_THICKNESS_EPSILON)
        return POINT_BEHIND_PLANE;
    return POINT_ON_PLANE;
}

--------------------------------------------------------------------------------

// Return value specifying whether the polygon 'poly' lies in front of,
// behind of, on, or straddles the plane 'plane'
int ClassifyPolygonToPlane(Polygon *poly, Plane plane)
{
    // Loop over all polygon vertices and count how many vertices
    // lie in front of and how many lie behind of the thickened plane
    int numInFront = 0, numBehind = 0;
    int numVerts = poly->NumVertices();
    for (int i = 0; i < numVerts; i++) {
        Point p = poly->GetVertex(i);
        switch (ClassifyPointToPlane(p, plane)) {
        case POINT_IN_FRONT_OF_PLANE:
            numInFront++;
            break;
        case POINT_BEHIND_PLANE:
            numBehind++;
            break;
        }
    }
    // If vertices on both sides of the plane, the polygon is straddling
    if (numBehind != 0 && numInFront != 0)
        return POLYGON_STRADDLING_PLANE;
    // If one or more vertices in front of the plane and no vertices behind
    // the plane, the polygon lies in front of the plane
    if (numInFront != 0)
        return POLYGON_IN_FRONT_OF_PLANE;
    // Ditto, the polygon lies behind the plane if no vertices in front of
    // the plane, and one or more vertices behind the plane
    if (numBehind != 0)
        return POLYGON_BEHIND_PLANE;
    // All vertices lie on the plane so the polygon is coplanar with the plane
    return POLYGON_COPLANAR_WITH_PLANE;
}

=== Section 8.3.4: =============================================================

void SplitPolygon(Polygon &poly, Plane plane, Polygon **frontPoly, Polygon **backPoly) {
    int numFront = 0, numBack = 0;
    Point frontVerts[MAX_POINTS], backVerts[MAX_POINTS];

    // Test all edges (a, b) starting with edge from last to first vertex
    int numVerts = poly.NumVertices();
    Point a = poly.GetVertex(numVerts – 1);
    int aSide = ClassifyPointToPlane(a, plane);

    // Loop over all edges given by vertex pair (n-1, n)
    for (int n = 0; n < numVerts; n++) {
        Point b = poly.GetVertex(n);
        int bSide = ClassifyPointToPlane(b, plane);
        if (bSide == POINT_IN_FRONT_OF_PLANE) {
            if (aSide == POINT_BEHIND_PLANE) {
                // Edge (a, b) straddles, output intersection point to both sides
                Point i = IntersectEdgeAgainstPlane(a, b, plane);
                assert(ClassifyPointToPlane(i, plane) == POINT_ON_PLANE);
                frontVerts[numFront++] = backVerts[numBack++] = i;
            }
            // In all three cases, output b to the front side
            frontVerts[numFront++] = b;
        } else if (bSide == POINT_BEHIND_PLANE) {
            if (aSide == POINT_IN_FRONT_OF_PLANE) {
                // Edge (a, b) straddles plane, output intersection point
                Point i = IntersectEdgeAgainstPlane(a, b, plane);
                assert(ClassifyPointToPlane(i, plane) == POINT_ON_PLANE);
                frontVerts[numFront++] = backVerts[numBack++] = i;
            } else if (aSide == POINT_ON_PLANE) {
                // Output a when edge (a, b) goes from ‘on’ to ‘behind’ plane
                backVerts[numBack++] = a;
            }
            // In all three cases, output b to the back side
            backVerts[numBack++] = b;
        } else {
            // b is on the plane. In all three cases output b to the front side
            frontVerts[numFront++] = b;
            // In one case, also output b to back side
            if (aSide == POINT_BEHIND_PLANE)
                backVerts[numBack++] = b;
        }
        // Keep b as the starting point of the next edge
        a = b;
        aSide = bSide;
    }

    // Create (and return) two new polygons from the two vertex lists
    *frontPoly = new Polygon(numFront, frontVerts);
    *backPoly = new Polygon(numBack, backVerts);
}

=== Section 8.3.5: =============================================================

        ...
        if (bSide == POINT_IN_FRONT_OF_PLANE) {
            if (aSide == POINT_BEHIND_PLANE) {
                // Edge (a, b) straddles, output intersection point to both sides.
                // Consistently clip edge as ordered going from in front -> behind
                Point i = IntersectEdgeAgainstPlane(b, a, plane);
                ...
            }
            ...

=== Section 8.4: ===============================================================

// Render node-storing BSP tree back-to-front w/ respect to cameraPos
void RenderBSP(BSPNode *node, Point cameraPos)
{
    // Get index of which child to visit first (0 = front, 1 = back)
    int index = ClassifyPointToPlane(cameraPos, node->plane) == POINT_IN_FRONT_OF_PLANE;

    // First visit the side the camera is NOT on
    if (node->child[index]) RenderBSP(node->child[index], cameraPos);
    // Render all polygons stored in the node
    DrawFrontfacingPolygons(node->pPolyList);
    // Then visit the other side (the one the camera is on)
    if (node->child[index ^ 1]) RenderBSP(node->child[index ^ 1], cameraPos);
}

=== Section 8.4.1: =============================================================

int PointInSolidSpace(BSPNode *node, Point p)
{
    while (!node->IsLeaf()) {
        // Compute distance of point to dividing plane
        float dist = Dot(node->plane.n, p) - node->plane.d;
        if (dist > EPSILON) {
            // Point in front of plane, so traverse front of tree
            node = node->child[0];
        } else if (dist < -EPSILON) {
            // Point behind of plane, so traverse back of tree
            node = node->child[1];
        } else {
            // Point on dividing plane; must traverse both sides
            int front = PointInSolidSpace(node->child[0], p);
            int back = PointInSolidSpace(node->child[1], p);
            // If results agree, return that, else point is on boundary
            return (front == back) ? front : POINT_ON_BOUNDARY;
        }
    }
    // Now at a leaf, inside/outside status determined by solid flag
    return node->IsSolid() ? POINT_INSIDE : POINT_OUTSIDE;
}

--------------------------------------------------------------------------------

int PointInSolidSpace(BSPNode *node, Point p)
{
    while (!node->IsLeaf()) {
        // Compute distance of point to dividing plane
        float dist = Dot(node->plane.n, p) - node->plane.d;
        // Traverse front of tree when point in front of plane, else back of tree
        node = node->child[dist <= EPSILON];
    }
    // Now at a leaf, inside/outside status determined by solid flag
    return node->IsSolid() ? POINT_INSIDE : POINT_OUTSIDE;
}

=== Section 8.4.2: =============================================================

// Intersect ray/segment R(t) = p + t*d, tmin <= t <= tmax, against bsp tree
// 'node', returning time thit of first intersection with a solid leaf, if any
int RayIntersect(BSPNode *node, Point p, Vector d, float tmin, float tmax, float *thit)
{
    std::stack<BSPNode *> nodeStack;
    std::stack<float> timeStack;

    assert(node != NULL);

    while (1) {
        if (!node->IsLeaf()) {
            float denom = Dot(node->plane.n, d);
            float dist = node->plane.d - Dot(node->plane.n, p);
            int nearIndex = dist > 0.0f;
            // If denom is zero, ray runs parallel to plane. In this case,
            // just fall through to visit the near side (the one p lies on)
            if (denom != 0.0f) {
                float t = dist / denom;
                if (0.0f <= t && t <= tmax) {
                    if (t >= tmin) {
                        // Straddling, push far side onto stack, then visit near side
                        nodeStack.push(node->child[1 ^ nearIndex]);
                        timeStack.push(tmax);
                        tmax = t;
                    } else nearIndex = 1 ^ nearIndex; // 0 <= t < tmin, visit far side
                }
            }
            node = node->child[nearIndex];
        } else {
            // Now at a leaf. If it is solid, there’s a hit at time tmin, so exit
            if (node->IsSolid()) {
                *thit = tmin;
                return 1;
            }
            // Exit if no more subtrees to visit, else pop off a node and continue
            if (nodeStack.empty()) break;
            tmin = tmax;
            node = nodeStack.top(); nodeStack.pop();
            tmax = timeStack.top(); timeStack.pop();
        }
    }

    // No hit
    return 0;
}

=== Section 8.4.3: =============================================================

// Intersect polygon 'p' against the solid-leaf BSP tree 'node'
int PolygonInSolidSpace(Polygon *p, BSPNode *node)
{
    Polygon *frontPart, *backPart;
    while (!node->IsLeaf()) {
        switch (ClassifyPolygonToPlane(p, node->plane)) {
        case POLYGON_IN_FRONT_OF_PLANE:
            node = node->child[0];
            break;
        case POLYGON_BEHIND_PLANE:
            node = node->child[1];
            break;
        case POLYGON_STRADDLING_PLANE:
            SplitPolygon(*p, node->plane, &frontPart, &backPart);
            if (PolygonInSolidSpace(frontPart, node->child[0])) return 1;
            if (PolygonInSolidSpace(backPart, node->child[1])) return 1;
            // No collision
            return 0;
        }
    }
    // Now at a leaf, inside/outside status determined by solid flag
    return node->IsSolid();
}
