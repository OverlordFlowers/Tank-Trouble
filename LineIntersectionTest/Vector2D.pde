public class Vector2D_f {
  float x;
  float y;
  
  // Constructors
  Vector2D_f(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  Vector2D_f() {
    this.x = 0;
    this.y = 0;
  }
  
  // Basic arithmetic operations
  Vector2D_f add(Vector2D_f vect2) {
    return new Vector2D_f(this.x + vect2.x, this.y + vect2.y);
  }
  
  Vector2D_f sub(Vector2D_f vect2) {
    return new Vector2D_f(this.x - vect2.x, this.y - vect2.y);
  }
  
  Vector2D_f scalarMult(float scalar) {
    return new Vector2D_f(this.x * scalar, this.y * scalar);
  }
  
  float getDotProduct(Vector2D_f vect2) {
    return (this.x * vect2.x + this.y * vect2.y);
  }
  
  Vector2D_f getProjOnto(Vector2D_f vect2) {
    float numer = this.getDotProduct(vect2);
    float denom = vect2.getDotProduct(vect2);
    
    float scalar = numer/denom;
    
    return vect2.scalarMult(scalar);
  }
  
  float getCompOf(Vector2D_f vect2) {
    return (this.getDotProduct(vect2) / vect2.getMagnitude());
  }
  
  float getMagnitude() {
    return sqrt(pow(this.x, 2) + pow (this.y, 2));
  }
  
  Vector2D_f getOrthog() {
    return new Vector2D_f(this.y, -this.x);
  }
  
  float[] getFloatArray() {
    float[] floats = {this.x, this.y};
    return floats;
  }
  
  void removeTolerance() {
    float tolerance = 0.0001;
    if (abs(this.x) < tolerance) {
      this.x = 0;
    }
    
    if (abs(this.y) < tolerance) {
      this.y = 0;
    }
  }
  
  void printVector() {
    print("x: " + this.x + " y: " + this.y + "\n");
  }
}
