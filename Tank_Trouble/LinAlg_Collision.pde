// Check if there has been a collision between two polygons.
// Based on separating access theorem.
static boolean checkIfCollision(Vector2D_f[] poly1, Vector2D_f[] poly2) {
  // get normals for poly 1
  int poly1_points_num = poly1.length;
  int poly2_points_num = poly2.length;
  float[] comps1 = new float[poly1.length];
  float[] comps2 = new float[poly2.length];
  
  Vector2D_f norm;
  
  for (int i = 0; i < poly1_points_num; i++) {
    // For each side, get the normal vector.
    norm = poly1[i].sub(poly1[(i + 1) % poly1_points_num]).getOrthog();
    norm.removeTolerance();
    
    // Project each vertex of each polygon onto the normal vector
    for (int j = 0; j < poly1_points_num; j++) {
      comps1[j] = poly1[j].getCompOf(norm);
    }
    
    for (int k = 0; k < poly2_points_num; k++) {
      comps2[k] = poly2[k].getCompOf(norm);
    }
    
    // Is there an overlap between the two projections on the normal line? If not, there is no overlap.
    if (!isOverlap(comps1, comps2)) {
      return false;
    }
  }
  
  // Same process as above.
  for (int i = 0; i < poly2_points_num; i++) {
    norm = poly2[i].sub(poly2[(i + 1) % poly2_points_num]).getOrthog();
    norm.removeTolerance();
    
    for (int j = 0; j < poly1_points_num; j++) {
      comps1[j] = poly1[j].getCompOf(norm);
    }
    
    for (int k = 0; k < poly2_points_num; k++) {
      comps2[k] = poly2[k].getCompOf(norm);
    }
    
    if (!isOverlap(comps1, comps2)) {
      return false;
    }
  }
  
  // If all points overlap, there is a collision.
  return true;
  
  // get normals for poly 2
}

// See if the min of one array is less than the max of the other.
static boolean isOverlap(float[] comps1, float[] comps2) {
  if (min(comps2) <= max(comps1) && min(comps1) <= max(comps2)) {
    return true;
  }
  return false;
}

// Do two lines intersect?
static boolean getLineCollision(Vector2D_f point0, Vector2D_f point1, Vector2D_f point2, Vector2D_f point3) {
  
  float A = ((point3.x - point2.x) * (point0.y - point2.y) - (point3.y - point2.y) * (point0.x - point2.x)) / ((point3.y - point2.y) * (point1.x - point0.x) - (point3.x - point2.x) * (point1.y - point0.y));
  float B = ((point1.x - point0.x) * (point0.y - point2.y) - (point1.y - point0.y) * (point0.x - point2.x)) / ((point3.y - point2.y) * (point1.x - point0.x) - (point3.x - point2.x) * (point1.y - point0.y));
  
  A = tolerance(A, 0.0001);
  B = tolerance(B, 0.0001);

  
  if (0 <= A && A <= 1 && 0 <= B && B <= 1) {
    return true;
  }
  return false;
}
