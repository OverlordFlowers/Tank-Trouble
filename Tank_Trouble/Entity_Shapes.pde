// Original plan was to have different types of shapes (circles, polygons, etc...)

// Represents obstacles in the environment
class Rectangle extends Entity {
  // Length and height of the rectangle.
  float l, h;
  
  // Constructor that accounts for the angle the rectangle is at.
  Rectangle(float pos_x, float pos_y, float l, float h, float angle) {
    // Stores position in world
    this.pos = new Vector2D_f(pos_x, pos_y);
    // Stores angle
    this.body_angle = angle;
    
    // Gets vertices from position and body dimensions
    ArrayList<Vector2D_f> vertices = new ArrayList<Vector2D_f>();
    vertices.add(new Vector2D_f(pos_x, pos_y));
    vertices.add(new Vector2D_f(pos_x + l, pos_y));
    vertices.add(new Vector2D_f(pos_x + l, pos_y + h));
    vertices.add(new Vector2D_f(pos_x, pos_y + h));
    
    // Creates new hitbox
    this.hitbox_model = new Hitbox(vertices);
    
    // Stores body dimensions
    this.l = l;
    this.h = h;
  }
  
  // Constructor that does not account for the angle the rectangle is at.
  Rectangle(float pos_x, float pos_y, float l, float h) {
    this.pos = new Vector2D_f(pos_x, pos_y);
    
    ArrayList<Vector2D_f> vertices = new ArrayList<Vector2D_f>();
    vertices.add(new Vector2D_f(pos_x, pos_y));
    vertices.add(new Vector2D_f(pos_x + l, pos_y));
    vertices.add(new Vector2D_f(pos_x + l, pos_y + h));
    vertices.add(new Vector2D_f(pos_x, pos_y + h));
    
    this.hitbox_model = new Hitbox(vertices);
    this.l = l;
    this.h = h;
  }
  
  // Updates hitbox (it doesn't move, but just in case I want to implement moving obstacles later)
  public void update() {
    updateHitbox();
    // Draws the hitbox if in debug mode
    if (debug) {
       this.hitbox_model.drawHitbox();
    }
   
  }
  
  public void updateHitbox() {
    ArrayList<Vector2D_f> points = new ArrayList<Vector2D_f>();
    // Get transformation matrix, rotates vertices based on position and angle of the entity.
    Matrix3D_f transformation_matrix = getTransformationMatrix(this.pos, this.body_angle);
    Vector3D_f new_point = new Vector3D_f(0, 0, 1);
    
    new_point.x = pos.x;
    new_point.y = pos.y;
    points.add(transformation_matrix.matrix_multiply(new_point).getXY());
    
    new_point.x = pos.x + l;
    new_point.y = pos.y;
    points.add(transformation_matrix.matrix_multiply(new_point).getXY());
        
    new_point.x = pos.x + l;
    new_point.y = pos.y + h;
    points.add(transformation_matrix.matrix_multiply(new_point).getXY());
        
    new_point.x = pos.x;
    new_point.y = pos.y + h;
    points.add(transformation_matrix.matrix_multiply(new_point).getXY());
     
    // Creates new hitbox to represent where it is.
    this.hitbox_model.updateHitbox(points);
  }
  
  // Draws the entity as a rectangle.
  public void drawEntity() {
    beginShape();
    fill(#000000);
    rectMode(CORNER);
    pushMatrix();
    translate(pos.x, pos.y);
    
    rotate(body_angle);
    if (debug) {
      stroke(#ef8009);
    }
    
    // display image if we include textures
    rect(0, 0, l, h);
    stroke(0);
    popMatrix();
    endShape();
  }
}
