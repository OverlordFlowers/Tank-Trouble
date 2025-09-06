// Vector class used to store vectors.
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
  
  // Copy the vector if needed.
  Vector2D_f copy() {
    return new Vector2D_f(x, y);
  }
  
  // Basic arithmetic operations
  Vector2D_f add(Vector2D_f vect2) {
    return new Vector2D_f(this.x + vect2.x, this.y + vect2.y);
  }
  
  // Subtraction
  Vector2D_f sub(Vector2D_f vect2) {
    return new Vector2D_f(this.x - vect2.x, this.y - vect2.y);
  }
  
  // Multiply the vector by a scalar
  Vector2D_f scalarMult(float scalar) {
    return new Vector2D_f(this.x * scalar, this.y * scalar);
  }
  
  // Get dot product
  float getDotProduct(Vector2D_f vect2) {
    return (this.x * vect2.x + this.y * vect2.y);
  }
  
  // Project this vector onto another vector
  Vector2D_f getProjOnto(Vector2D_f vect2) {
    float numer = this.getDotProduct(vect2);
    float denom = vect2.getDotProduct(vect2);
    
    float scalar = numer/denom;
    
    return vect2.scalarMult(scalar);
  }
  
  // Get the component of a vector
  float getCompOf(Vector2D_f vect2) {
    return (this.getDotProduct(vect2) / vect2.getMagnitude());
  }
  
  // Get the magnitude of this vector
  float getMagnitude() {
    return sqrt(pow(this.x, 2) + pow (this.y, 2));
  }
  
  // Get an orthogonal representation of this vector
  Vector2D_f getOrthog() {
    return new Vector2D_f(this.y, -this.x);
  }
  
  // Return these points as an array
  float[] getFloatArray() {
    float[] floats = {this.x, this.y};
    return floats;
  }
  
  // Clips to remove inaccuracies due to floating point
  void removeTolerance() {
    float tolerance = 0.0001;
    this.x = tolerance(this.x, tolerance);
    this.y = tolerance(this.y, tolerance);
  }
  
  // Prints the vector
  void printVector() {
    print("x: " + this.x + " y: " + this.y + "\n");
  }
}

// This is just a helper class for 3D matrix multiplications.
public class Vector3D_f {
  float x, y, z;
  
  Vector3D_f(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  // Gets the x, y, parts to create a new 2-D vector.
  public Vector2D_f getXY() {
    return new Vector2D_f(this.x, this.y);
  }
}
