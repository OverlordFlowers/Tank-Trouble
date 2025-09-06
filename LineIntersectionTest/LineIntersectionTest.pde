public Vector2D_f[] points1 = new Vector2D_f[2];
public Vector2D_f[] points2 = new Vector2D_f[2];

void setup() {
  size(640, 640);
  points1[0] = new Vector2D_f(0f, 320f);
  points1[1] = new Vector2D_f(640f, 320f);
  points2[0] = new Vector2D_f(0f, 0f);
  points2[1] = new Vector2D_f(0f, 0f);
}

void draw() {
  background(255);
  points2[1].x = mouseX;
  points2[1].y = mouseY;
  beginShape();
  vertex(points1[0].getFloatArray());
  vertex(points1[1].getFloatArray());
  endShape();
  
  beginShape();
  vertex(points2[0].getFloatArray());
  vertex(points2[1].getFloatArray());
  endShape();
  
  getLineCollision(points1[0], points1[1], points2[0], points2[1]);
  

  
}

boolean getLineCollision(Vector2D_f point0, Vector2D_f point1, Vector2D_f point2, Vector2D_f point3) {
  
  float A = ((point3.x - point2.x) * (point0.y - point2.y) - (point3.y - point2.y) * (point0.x - point2.x)) / ((point3.y - point2.y) * (point1.x - point0.x) - (point3.x - point2.x) * (point1.y - point0.y));
  float B = ((point1.x - point0.x) * (point0.y - point2.y) - (point1.y - point0.y) * (point0.x - point2.x)) / ((point3.y - point2.y) * (point1.x - point0.x) - (point3.x - point2.x) * (point1.y - point0.y));
  
  if (abs(A) < 0.00001) {
    A = 0;
  }
  
  if (abs(B) < 0.00001) {
    B = 0;
  }
  
  if (0 <= A && A <= 1 && 0 <= B && B <= 1) {
    return true;
  }
  return false;
}
