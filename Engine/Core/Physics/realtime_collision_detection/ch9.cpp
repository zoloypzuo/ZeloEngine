
=== Section 9.3.1: =============================================================

// Given a set s of vertices, compute a maximal set of independent vertices
Set IndependentSet(Set s)
{
    // Initialize i to the empty set
    Set i = EmptySet();
    // Loop over all vertices in the input set
    for (all vertices v in s) {
        // If unmarked and has 8 or fewer neighboring vertices...
        if (!Marked(v) && Degree(v) <= 8) {
            // Add v to the independent set and mark all of v's neighbors
            i.Add(v);
            s.MarkAllVerticesAdjacentToVertex(v);
        }
    }
    return i;
}
