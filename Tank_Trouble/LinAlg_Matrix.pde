// 2D matrix.
public class Matrix2D_f {
  float a11, a12;
  float a21, a22;
  
  // Creates a matrix
  Matrix2D_f(float a11, float a12, float a21, float a22) {
    this.a11 = a11;
    this.a12 = a12;
    this.a21 = a21;
    this.a22 = a22;
  }
  
  // Creates a rotation matrix
  Matrix2D_f(float angle) {
    a11 = cos(angle);
    a12 = -sin(angle);
    a21 = sin(angle);
    a22 = cos(angle);
  }
  
  // Multiples a vector
  Vector2D_f matrix_multiply(Vector2D_f vect) {
    float x = 0;
    float y = 0;
    
    x = a11 * vect.x + a12 * vect.y;
    y = a21 * vect.x + a22 * vect.y;
    
    return new Vector2D_f(x, y);
  }
}

// 3D matrix I used for handling rotation.
public class Matrix3D_f {
  float a11, a12, a13;
  float a21, a22, a23;
  float a31, a32, a33;
  
  // Create a standard matrix
  Matrix3D_f(float a11, float a12, float a13, float a21, float a22, float a23, float a31, float a32, float a33) {
    this.a11 = a11;
    this.a12 = a12;
    this.a13 = a13;
    this.a21 = a21;
    this.a22 = a22;
    this.a23 = a23;
    this.a31 = a31;
    this.a32 = a32;
    this.a33 = a33;
  }
  
  // Create a rotation matrix
  Matrix3D_f(float angle) {
    a11 = cos(angle);
    a12 = -sin(angle);
    a13 = 0;
    a21 = sin(angle);
    a22 = cos(angle);
    a23 = 0;
    a31 = 0;
    a32 = 0;
    a33 = 1;
  }
  
  // Multiply by vector
  Vector3D_f matrix_multiply(Vector3D_f vect) {
    float x = 0;
    float y = 0;
    float z = 0;
    
    x = a11 * vect.x + a12 * vect.y + a13 * vect.z;
    y = a21 * vect.x + a22 * vect.y + a23 * vect.z;
    z = a31 * vect.x + a32 * vect.y + a33 * vect.z;
    
    return new Vector3D_f(x, y, z);
  }
  
  // Multiply the matrix by another matrix.
  Matrix3D_f matrix_multiply(Matrix3D_f matrix) {
    float a11, a12, a13;
    float a21, a22, a23;
    float a31, a32, a33;
    
    a11 = this.a11 * matrix.a11 + this.a12 * matrix.a21 + this.a13 * matrix.a31;
    a12 = this.a11 * matrix.a12 + this.a12 * matrix.a22 + this.a13 * matrix.a32;
    a13 = this.a11 * matrix.a13 + this.a12 * matrix.a23 + this.a13 * matrix.a33;
    
    a21 = this.a21 * matrix.a11 + this.a22 * matrix.a21 + this.a23 * matrix.a31;
    a22 = this.a21 * matrix.a12 + this.a22 * matrix.a22 + this.a23 * matrix.a32;
    a23 = this.a21 * matrix.a13 + this.a22 * matrix.a23 + this.a23 * matrix.a33;
    
    a31 = this.a31 * matrix.a11 + this.a32 * matrix.a21 + this.a33 * matrix.a31;
    a32 = this.a31 * matrix.a12 + this.a32 * matrix.a22 + this.a33 * matrix.a32;
    a33 = this.a31 * matrix.a13 + this.a32 * matrix.a23 + this.a33 * matrix.a33;
    
    return new Matrix3D_f(a11, a12, a13, a21, a22, a23, a31, a32, a33);
  }
}

// Get the transformation matrix given the position and an angle, used to rotate vertices around a point.
public Matrix3D_f getTransformationMatrix(Vector2D_f pos, float angle) {
  Matrix3D_f return_translation_matrix = new Matrix3D_f(1, 0, pos.x, 0, 1, pos.y, 0, 0, 1);
  Matrix3D_f translation_matrix = new Matrix3D_f(1, 0, -pos.x, 0, 1, -pos.y, 0, 0, 1);
  Matrix3D_f rotation = new Matrix3D_f(angle);
  
  return return_translation_matrix.matrix_multiply(rotation).matrix_multiply(translation_matrix);
}
