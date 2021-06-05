
=== Section 6.2.1: =============================================================

// Construct a top-down tree. Rearranges object[] array during construction
void TopDownBVTree(Node **tree, Object object[], int numObjects)
{
    assert(numObjects > 0);

    const int MIN_OBJECTS_PER_LEAF = 1;
    Node *pNode = new Node;
    *tree = pNode;
    // Compute a bounding volume for object[0], ..., object[numObjects - 1]
    pNode->BV = ComputeBoundingVolume(&object[0], numObjects);
    if (numObjects <= MIN_OBJECTS_PER_LEAF) {
        pNode->type = LEAF;
        pNode->numObjects = numObjects;
        pNode->object = &object[0]; // Pointer to first object in leaf
    } else {        
        pNode->type = NODE;
        // Based on some partitioning strategy, arrange objects into
        // two partitions: object[0..k-1], and object[k..numObjects-1]
        int k = PartitionObjects(&object[0], numObjects);
        // Recursively construct left and right subtree from subarrays and
        // point the left and right fields of the current node at the subtrees
        TopDownBVTree(&(pNode->left), &object[0], k);
        TopDownBVTree(&(pNode->right), &object[k], numObjects - k);
    }
}

=== Section 6.2.2: =============================================================

Node *BottomUpBVTree(Object object[], int numObjects)
{
    assert(numObjects != 0);

    int i, j;

    // Allocate temporary memory for holding node pointers to
    // the current set of active nodes (initially the leaves)
    NodePtr *pNodes = new NodePtr[numObjects];

    // Form the leaf nodes for the given input objects
    for (i = 0; i < numObjects; i++) {
        pNodes[i] = new Node;
        pNodes[i]->type = LEAF;
        pNodes[i]->object = &object[i];
    }
    // Merge pairs together until just the root object left
    while (numObjects > 1) {
        // Find indices of the two "nearest" nodes, based on some criterion
        FindNodesToMerge(&pNodes[0], numObjects, &i, &j);
        // Group nodes i and j together under a new new internal node
        Node *pPair = new Node;
        pPair->type = NODE;
        pPair->left = pNodes[i];
        pPair->right = pNodes[j];
        // Compute a bounding volume for the two nodes
        pPair->BV = ComputeBoundingVolume(pNodes[i]->object, pNodes[j]->object);

        // Remove the two nodes from the active set and add in the new node.
        // Done by putting new node at index 'min' and copying last entry to 'max'
        int min = i, max = j;
        if (i > j) min = j, max = i;
        pNodes[min] = pPair;
        pNodes[max] = pNodes[numObjects - 1];
        numObjects--;
    }
    // Free temporary storage and return root of tree
    Node *pRoot = pNodes[0];
    delete pNodes;
    return pRoot;
}

=== Section 6.2.2.1: ===========================================================

Node *BottomUpBVTree(Object object[], int numObjects)
{
    PriorityQueue<Pair> q;
    InsertionBVTree t;

    // Bound all objects in BV, forming leaf nodes. Insert leaf nodes into a
    // dynamically changable insertion-built BV tree
    InitializeInsertionBVTree(t, object, numObjects);

    // For all nodes, form pair of references to the node and the node it pairs
    // best with (resulting in the smallest bounding volume). Add all pairs to
    // the priority queue, sorted on increasing volume order
    InitializePriorityQueue(q, object, numObjects);

    while (SizeOf(q) > 1) {
        // Fetch the smallest volume pair from the queue
        Pair *p = Dequeue(q);

        // Discard pair if the node has already been paired
        if (HasAlreadyBeenPaired(p->node)) continue;

        // Recompute the best pairing node for this node to see if
        // the stored pair node is still valid
        Node *bestpairnode = ComputeBestPairingNodeUsingTree(t, p->node);
        if (p->pairnode == bestpairnode) {
            // The store pair node is OK, pair the two nodes together;
            // link the nodes together under a new node
            Node *n = new Node;
            n->left = p->node;
            n->right = p->pairnode;

            // Add new node to BV tree; delete old nodes as not possible to pair with
            Delete(t, p->node);
            Delete(t, p->pairnode);
            Insert(t, n);

            // Compute a pairing node for the new node; insert it into queue
            Node *newbestpairnode = ComputeBestPairingNodeUsingTree(t, n);
            p = Pair(n, newbestpairnode);
        } else {
            // Best pair node changed since the pair was inserted;
            // update the pair, reinsert into queue and try again
            p = Pair(p->node, bestpairnode);
        }
        Enqueue(q, p, VolumeOfBVForPairedNodes(p)); // Queue, pair, priority
    }
    return Dequeue(q)->node;
}

=== Section 6.3.2: =============================================================

// Generic recursive BVH traversal code.
// Assumes that leaves too have BVs
void BVHCollision(CollisionResult *r, BVTree a, BVTree b)
{
    if (!BVOverlap(a, b)) return;
    if (IsLeaf(a) && IsLeaf(b)) {
        // At leaf nodes. Perform collision tests on leaf node contents
        CollidePrimitives(r, a, b);
    } else {
        if (DescendA(a, b)) {
            BVHCollision(a->left, b);
            BVHCollision(a->right, b);
        } else {
            BVHCollision(a, b->left);
            BVHCollision(a, b->right);
        }
    }
}

--------------------------------------------------------------------------------

// ‘Descend A’ descent rule
bool DescendA(BVTree a, BVTree b)
{
    return !IsLeaf(a);
}

// ‘Descend B’ descent rule
bool DescendA(BVTree a, BVTree b)
{
    return IsLeaf(b);
}

// ‘Descend larger’ descent rule
bool DescendA(BVTree a, BVTree b)
{
    return IsLeaf(b) || (!IsLeaf(a) && (SizeOfBV(a) >= SizeOfBV(b)));
}

--------------------------------------------------------------------------------

// Non-recursive version
void BVHCollision(CollisionResult *r, BVTree a, BVTree b)
{
    Stack s = NULL;
    Push(s, a, b);
    while (!IsEmpty(s)) {
        Pop(s, a, b);

        if (!BVOverlap(a, b)) continue;
        if (IsLeaf(a) && IsLeaf(b)) {
            // At leaf nodes. Perform collision tests on leaf node contents
            CollidePrimitives(r, a, b);
            // Could have an exit rule here (eg. exit on first hit)
        } else {
            if (DescendA(a, b)) {
                Push(s, a->right, b);
                Push(s, a->left, b);
            } else {
                Push(s, a, b->right);
                Push(s, a, b->left);
            }
        }
    }
}

--------------------------------------------------------------------------------

// Stack-use optimized, non-recursive version
void BVHCollision(CollisionResult *r, BVTree a, BVTree b)
{
    Stack s = NULL;
    while (1) {
        if (BVOverlap(a, b)) {
            if (IsLeaf(a) && IsLeaf(b)) {
                // At leaf nodes. Perform collision tests on leaf node contents
                CollidePrimitives(r, a, b);
                // Could have an exit rule here (eg. exit on first hit)
            } else {
                if (DescendA(a, b)) {
                    Push(s, a->right, b);
                    a = a->left;
                    continue;
                } else {
                    Push(s, a, b->right);
                    b = b->left;
                    continue;
                }
            }
        }
        if (IsEmpty(s)) break;
        Pop(s, a, b);
    }
}

=== Section 6.3.3: =============================================================

// Recursive, simultaneous traversal
void BVHCollision(CollisionResult *r, BVTree a, BVTree b)
{

    if (!BVOverlap(a, b)) return;
    if (IsLeaf(a)) {
        if (IsLeaf(b)) {
           // At leaf nodes. Perform collision tests on leaf node contents
            CollidePrimitives(r, a, b);
            // Could have an exit rule here (eg. exit on first hit)
        } else {
            BVHCollision(a, b->left);
            BVHCollision(a, b->right);
        }
    } else {
        if (IsLeaf(b)) {
            BVHCollision(a->left, b);
            BVHCollision(a->right, b);
        } else {
            BVHCollision(a->left, b->left);
            BVHCollision(a->left, b->right);
            BVHCollision(a->right, b->left);
            BVHCollision(a->right, b->right);
        }
    }
}

=== Section 6.3.4: =============================================================

// This routine recurses over the first hierarchy, into its leaves.
// The leaves are transformed once, and then passed off along with
// second hierarchy to a support routine
void BVHCollision(CollisionResult *r, BVTree a, BVTree b)
{
    if (!BVOverlap(a, b)) return; 
    if (!IsLeaf(a)) {
        BVHCollision(a->left, b);
        BVHCollision(a->right, b);
    } else {
        a2 = TransformLeafContentsOnce(a);
        BVHCollision2(r, a2, b);
    }
}

// The support routine takes what is known to be a leaf and a full
// hierarchy, recursing over the hierarchy, performing the low-level
// leaf-leaf collision tests once the hierarchy leaves are reached
void BVHCollision2(CollisionResult *r, BVTree a, BVTree b)
{
    if (!BVOverlap(a, b)) return;
    if (!IsLeaf(b)) {
        BVHCollision2(a, b->left);
        BVHCollision2(a, b->right);
    } else {
        // At leaf nodes. Perform collision tests on leaf node contents
        CollidePrimitives(r, a, b);
    }
}

=== Section 6.5.1: =============================================================

// Computes the AABB a of AABBs a0 and a1
void AABBEnclosingAABBs(AABB &a, AABB a0, AABB a1)
{
    for (int i = 0; i < 2; i++) {
        a.min[i] = Min(a0.min[i], a1.min[i]);
        a.max[i] = Max(a0.max[i], a1.max[i]);
    }
}

=== Section 6.5.2: =============================================================

// Computes the bounding sphere s of spheres s0 and s1
void SphereEnclosingSpheres(Sphere &s, Sphere s0, Sphere s1)
{
    // Compute the squared distance between the sphere centers
    Vector d = s1.c - s0.c;
    float dist2 = Dot(d, d);

    if (Sqr(s1.r - s0.r) >= dist2) {
        // The sphere with the larger radius encloses the other;
        // just set s to be the larger of the two spheres
        if (s1.r >= s0.r)
            s = s1;
        else
            s = s0;
    } else {
        // Spheres partially overlapping or disjoint
        float dist = Sqrt(dist2);
        s.r = (dist + s0.r + s1.r) * 0.5f;
        s.c = s0.c;
        if (dist > EPSILON)
            s.c += ((s.r - s0.r) / dist) * d;
    }
}

=== Section 6.5.4: =============================================================

// Computes the KDOP d of KDOPs d0 and d1
void KDOPEnclosingKDOPs(KDOP &d, KDOP d0, KDOP d1, int k)
{
    for (int i = 0; i < k / 2; i++) {
        d.min[i] = Min(d0.min[i], d1.min[i]);
        d.max[i] = Max(d0.max[i], d1.max[i]);
    }
}

=== Section 6.6.1: =============================================================

// First level
array[0] = *(root);
// Second level
array[1] = *(root->left);
array[2] = *(root->right);
// Third level
array[3] = *(root->left->left);
...

--------------------------------------------------------------------------------

// Given a tree t, outputs its nodes in breadth-first traversal order
// into the node array n. Call with i = 0.
void BreadthFirstOrderOutput(Tree *t, Tree n[], int i)
{
    // Copy over contents from tree node to breadth-first tree
    n[i].nodeData = t->nodeData;
    // If tree has a left node, copy its subtree recursively
    if (t->left)
        BreadthFirstOrderOutput(t->left, n, 2 * i + 1);
    // Ditto if it has a right subtree
    if (t->right)
        BreadthFirstOrderOutput(t->right, n, 2 * i + 2);
}

=== Section 6.6.2: =============================================================

// Given a tree t, outputs its nodes in preorder traversal order
// into the node array n. Call with i = 0.
int PreorderOutput(Tree *t, Tree n[], int i)
{
    // Implement a simple stack of parent nodes.
    // Note that the stack pointer ‘sp’ is automatically reset between calls
    const int STACK_SIZE = 100;
    static int parentStack[STACK_SIZE];
    static int sp = 0;
    
    // Copy over contents from tree node to PTO tree
    n[i].nodeData = t->nodeData;
    // Set the flag indicating whether there is a left child
    n[i].hasLeft = t->left != NULL;
    // If node has right child, push its index for backpatching
    if (t->right) {
        assert(sp < STACK_SIZE);
        parentStack[sp++] = i;
    }
    // Now recurse over left part of tree
    if (t->left)
        i = PreorderOutput(t->left, n, i + 1);
    if (t->right) {
        // Backpatch right-link of parent to point to this node
        int p = parentStack[--sp];
        n[p].rightPtr = &n[i + 1];
        // Recurse over right part of tree
        i = PreorderOutput(t->right, n, i + 1);
    }
    // Return the updated array index on exit
    return i;
}

=== Section 6.6.6: =============================================================

#include <setjmp.h>
jmp_buf gJmpBuf;

int BVHTestCollision(BVTree a, BVTree b)
{
    int r = setjmp(gJmpBuf);
    if (r == 0) {
        BVHTestCollisionR(a, b);
        return 0;
    } else return r - 1;
}
// Generic recursive BVH traversal code
// assumes that leaves too have BVs
void BVHTestCollisionR(BVTree a, BVTree b)
{
    if (!BVOverlap(a, b))
        longjmp(gJmpBuf, 0 + 1); /* false */
    if (IsLeaf(a) && IsLeaf(b)) {
        if (PrimitivesOverlap(a, b))
            longjmp(gJmpBuf, 1 + 1); /* true */
    } else {
        if (DescendA(a, b)) {
            BVHTestCollisionR(a->left, b);
            BVHTestCollisionR(a->right, b);
        } else {
            BVHTestCollisionR(a, b->left);
            BVHTestCollisionR(a, b->right);
        }
    }
}

=== Section 6.6.7: =============================================================

Sphere s[NUM_SPHERES];
...
for (int i = 0; i < NUM_SPHERES; i++)
    if (SphereTreeCollision(s[i], worldHierarchy))
        ...

--------------------------------------------------------------------------------

bool SphereTreeCollision(Sphere s, Tree *root)
{
    // If an alternative start node has been set, use it;
    // if not, use the provided start root node
    if (gStartNode != NULL) root = gStartNode;

    ...original code goes here...
}

--------------------------------------------------------------------------------

// Specifies an alternative starting node, or none (if null)
Tree *gStartNode = NULL;

// Set a new alternative start node
void BeginGroupedQueryTestVolume(Sphere *s, Tree *root)
{
    // Descend into the hierarchy as long as the given sphere
    // overlaps either child bounding sphere (but not both)
    while (root != NULL) {
        bool OverlapsLeft = root->left && SphereOverlapTest(s, root->left.bvSphere);
        bool OverlapsRight = root->right && SphereOverlapTest(s, root->right.bvSphere);
        if (OverlapsLeft && !OverlapsRight) root = root->left;
        else if (!OverlapsLeft && OverlapsRight) root = root->right;
        else break;
    }
    // Set this as the new alternative starting node
    gStartNode = root;
}

// Reset the alternative start node
void EndGroupedQueryTestVolume(void)
{
    gStartNode = NULL;
}

--------------------------------------------------------------------------------

Sphere s[NUM_SPHERES];
...
// Compute a bounding sphere for the query spheres
Sphere bs = BoundingSphere(&s[0], NUM_SPHERES);
BeginGroupedQueryTestVolume(bs, worldHierarchy);
// Do the original queries just as before
for (int i = 0; i < NUM_SPHERES; i++)
    if (SphereTreeCollision(s[i], worldHierarchy))
        ...
// Reset everything back to not used a grouped query
EndGroupedQueryTestVolume();
...

=== Section 6.7.1: =============================================================

int ObjectsCollidingWithCache(Object a, Object b)
{
    // Check to see if this pair of objects is already in cache
    pair = FindObjectPairInCache(a, b);
    if (pair != NULL) {
        // Is so, see if the cached primitives overlap; if not,
        // lazily delete the pair from the collision cache
        if (PrimitivesOverlapping(pair->objAPrimitives, pair->ObjBPrimitives))
            return COLLIDING;
        else DeleteObjectPairFromCache(a, b);
    }
    // Do a full collision query, that caches the result
    return ObjectCollidingCachePrims(Object a, Object b)
}

int ObjectCollidingCachePrims(Object a, Object b)
{
    if (BVOverlap(a, b)) {
        if (IsLeaf(a) && IsLeaf(b) {
            if (CollidePrimitives(a, b)) {
                // When two objects are found colliding, add the pair
                // along with the witness primitives to the shared cache
                AddObjectPairToCache(a, b);
                return COLLIDING;
            } else return NOT_COLLIDING;
        } else {
            ...
        }
    }
    ...
}
