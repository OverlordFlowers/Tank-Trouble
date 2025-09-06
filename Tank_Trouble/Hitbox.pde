// Hitboxes are simple rectangles. In this case, the hitbox also serves as the collision model.

public class Hitbox {
  // need four points
  Vector2D_f[] points;
  
  // 
  Hitbox(ArrayList<Vector2D_f> points) {
    // Creates new point vector based on size of the array list.
    this.points = new Vector2D_f[points.size()];
    int i = 0;
    
    // Populates new array.
    for (Vector2D_f p : points) {
      this.points[i] = p;
      i++;
    }
  }
  
  // Draws the hitbox.
  public void drawHitbox() {
    beginShape();
    noFill();
    stroke(#000000);
    for (int i = 0; i < points.length - 0; i++) {
      // gets points in the array.
      vertex(points[i].getFloatArray()); //<>// //<>//
    }
    endShape(CLOSE);
  }
  
  // updates the hitbox based on the new points.
  public void updateHitbox(ArrayList<Vector2D_f> points) {
    
    int i = 0;
    for (Vector2D_f p : points) {
      this.points[i] = p;
      i++;
    }
    
    return;
  }
  
  // Gets the points.
  Vector2D_f[] getPoints() {
    return this.points;
  }
  
  // Checks if there has been a collision with anything.
  public boolean checkCollision() {
    Hitbox h;
    for (Entity e : game.entity_list) {
      if (e.hitbox_model != this) {
        h = e.hitbox_model;
        if (checkIfCollision(this.getPoints(), h.getPoints())) {
          return true;
        }
      }
    }
    return false;
  }
  
  // Returns the entity that there has been a collision with.
  public Entity checkCollisionGetEntity() {
    Hitbox h;
    for (Entity e : game.entity_list) {
      if (e.hitbox_model != this) {
        h = e.hitbox_model;
        if (checkIfCollision(this.getPoints(), h.getPoints())) {
          return e;
        }
      }
    }
    return null; 
  }
}
