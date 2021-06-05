
=== Section 10.2: ==============================================================

// Initialize depth buffer to far Z (1.0)
glClearDepth(1.0f);
glClear(GL_DEPTH_BUFFER_BIT);
// Disable color buffer writes
glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
// Enable depth testing
glEnable(GL_DEPTH_TEST);
// Initialize occlusion queries
Gluint query[1], numSamplesRendered;
glGenQueries(1, query);

--------------------------------------------------------------------------------

// Set pixels to always write depth
glDepthFunc(GL_ALWAYS);
glDepthMask(GL_TRUE);
// Draw front faces of object A
glCullFace(GL_BACK);
RenderObject(A);
// Pass pixels if depth is greater than current depth value
glDepthFunc(GL_GREATER);
// Disable depth buffer updates
glDepthMask(GL_FALSE);
// Render back faces of B with occlusion testing enabled
glBeginQuery(GL_SAMPLES_PASSED, query[0]);
glCullFace(GL_FRONT);
RenderObject(B);
glEndQuery(GL_SAMPLES_PASSED);
// If occlusion test indicates no samples rendered, exit with no collision
glGetQueryObjectuiv(query[0], GL_QUERY_RESULT, &numSamplesRendered);
if (numSamplesRendered == 0) return NO_COLLISION;

--------------------------------------------------------------------------------

// Set pixels to always write depth
glDepthFunc(GL_ALWAYS);
glDepthMask(GL_TRUE);
// Draw front faces of object B
glCullFace(GL_BACK);
RenderObject(B);
// Pass pixels if depth is greater than current depth value
glDepthFunc(GL_GREATER);
// Disable depth buffer updates
glDepthMask(GL_FALSE);
// Render back faces of A with occlusion testing enabled
glBeginQuery(GL_SAMPLES_PASSED, query[0]);
glCullFace(GL_FRONT);
RenderObject(A);
glEndQuery(GL_SAMPLES_PASSED);
// If occlusion test indicates no pixels rendered, exit with no collision
glGetQueryObjectuiv(query[0], GL_QUERY_RESULT, &numSamplesRendered);
if (numSamplesRendered == 0) return NO_COLLISION;
// Objects A and B must be intersecting
return COLLISION;

=== Section 10.3: ==============================================================

// Disable color buffer writes
glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
// Clear depth and stencil buffers, initializing depth buffer to far Z (1.0)
glClearDepth(1.0f);
glClear(GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
// Enable depth buffer testing
glEnable(GL_DEPTH_TEST);

--------------------------------------------------------------------------------

// Enable depth buffer updates. Set all pixels to pass always
glDepthMask(GL_TRUE);
glDepthFunc(GL_ALWAYS);
// Draw edges of object B
glPushAttrib(GL_POLYGON_BIT);
glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
DrawObject(B);
glPopAttrib();

--------------------------------------------------------------------------------

// Disable depth buffer updates. Pass pixels if nearer than stored depth value
glDepthMask(GL_FALSE);
glDepthFunc(GL_LESS);
// Increment stencil buffer for object A frontfaces
glEnable(GL_STENCIL_TEST);
glStencilOp(GL_KEEP, GL_KEEP, GL_INCR);
glCullFace(GL_BACK);
DrawObject(A);
// Decrement stencil buffer for object A backfaces
glStencilOp(GL_KEEP, GL_KEEP, GL_DECR);
glCullFace(GL_FRONT);
DrawObject(A);
// Read back stencil buffer. Nonzero stencil values implies collision
...
