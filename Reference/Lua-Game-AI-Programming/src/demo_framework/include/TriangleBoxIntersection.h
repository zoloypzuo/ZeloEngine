/**
 * The source code in this file is attributed to Tomas Akenine-Möller.
 * http://cs.lth.se/english/contact/jesper-pedersen-notander/tomas-akenine-moller/
 * http://fileadmin.cs.lth.se/cs/Personal/Tomas_Akenine-Moller/code/
 */

#ifndef DEMO_FRAMEWORK_TRIANGLE_BOX_INTERSECTION_H
#define DEMO_FRAMEWORK_TRIANGLE_BOX_INTERSECTION_H

int triBoxOverlap(
    float boxcenter[3], float boxhalfsize[3], float triverts[3][3]);

#endif  // DEMO_FRAMEWORK_TRIANGLE_BOX_INTERSECTION_H
