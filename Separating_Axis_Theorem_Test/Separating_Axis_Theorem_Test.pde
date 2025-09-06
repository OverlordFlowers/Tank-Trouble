float[] rectangle1 = {0, 0, 5, 5};
float[] rectangle2 = {0, 0, 5, 5};

float pos_x1 = 25;
float pos_y1 = 25;
float rect1_width = 50;
float rect1_heigth = 50;
float angle1 = 0;

float pos_x2 = 25;
float pos_y2 = 61;
float rect2_width = 50;
float rect2_height = 50;
float angle2 = 0;


public Vector2D_f[] points1 = new Vector2D_f[4];
public Vector2D_f[] points2 = new Vector2D_f[4];

void setup() {
  float x;
  float y;
  
  for (int i = 0; i < 4; i++) {
    x = pos_x1 + rect1_width / 2 * cos(angle1 + radians((i * 90) + 45));
    y = pos_y1 + rect1_heigth / 2 * sin(angle1 + radians((i * 90) + 45));
    
    points1[i] = new Vector2D_f(x, y);
  }
  
  for (int i = 0; i < 4; i++) {
    x = pos_x2 + rect2_width / 2 * cos(angle2 + radians((i * 90) + 45));
    y = pos_y2 + rect2_height / 2 * sin(angle2 + radians((i * 90) + 45));
    
    points2[i] = new Vector2D_f(x, y);
  }
  size(640, 640);
  
  print(checkCollision(points1, points2));
}

void draw() {

  background(255);
  
  noFill();
  
  beginShape();
  for (int i = 0; i < points1.length; i++) {
    vertex(points1[i].getFloatArray());
  }
  endShape(CLOSE);
  
  beginShape();
  for (int i = 0; i < points1.length; i++) {
    vertex(points2[i].getFloatArray());
  }
  endShape(CLOSE);
}

boolean checkCollision(Vector2D_f[] poly1, Vector2D_f[] poly2) {
  // get normals for poly 1
  int poly1_points_num = poly1.length;
  int poly2_points_num = poly2.length;
  float[] comps1 = new float[poly1.length];
  float[] comps2 = new float[poly2.length];
  
  Vector2D_f norm;
  
  for (int i = 0; i < poly1_points_num; i++) {
    norm = poly1[i].sub(poly1[(i + 1) % poly1_points_num]).getOrthog();
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
  
  return true;
  
  // get normals for poly 2
}

boolean isOverlap(float[] comps1, float[] comps2) {
  if (min(comps2) <= max(comps1) && min(comps1) <= max(comps2)) {
    return true;
  }
  return false;
}
