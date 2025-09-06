// Tank class represents the player and the enemies in the game world.
class Tank extends Entity {
  // Is it alive?
  public boolean is_alive = true;
  // Is it invincible? (only true in debug mode)
  protected boolean invincible = false;
  
  // Health
  protected int health = 80;
  // Angle turret is at
  protected float turret_angle = 0f;
  
  // How fast the tank can accelerate/deaccelerate
  protected float deacceleration= 0.05f;
  protected float acceleration = 0.5f;
  
  // How fast it turns (turret speed does not matter for player)
  protected float turret_rotation_speed = 0.05f;
  protected float body_rotation_speed = 0.05f;
  
  // World state, max speed and friction if it isn't actively moving.
  protected boolean is_accelerating = false;
  protected boolean is_reversing = false;
  protected float max_speed = 1.5f;
  protected float min_speed = -1.0f;
  protected float friction = 0.02f;
  protected float acceleration_modifier = 0.2f;
  
  // Firing state
  protected int time_ms_to_reload = 1000;
  protected int time_ms_next_shot_ready = 0;
  
  // Art
  String body;
  String turret;
  
  // Constructor.
  Tank () {
    // It is not a static object.
    this.static_object = false;
  }
  
  // Draws the tank body and turret based on its rotation and position.
  public void drawEntity() {
    // Rotate / move body
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(body_angle);
    image(game.ImageCache.get(body), 0, 0);
    //rect(0, 0, 32, 32);
    popMatrix();
    
    // Rotate turret
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(turret_angle);
    image(game.ImageCache.get(turret), 4, 0);
    popMatrix();
    
    // If in debug mode, draw its hitbox.
    if (debug) {
      hitbox_model.drawHitbox();
      circle(pos.x, pos.y, 5);
    }
  }
  
  // Unfortunately, update is going to be specific to an enemy or player.
  public void update() { }
  
  // Updates the hitbox
  public void updateHitbox() {
    ArrayList<Vector2D_f> points = new ArrayList<Vector2D_f>();
    // Get transformation matrix
    
    // Updates points based on the transformation matrix.
    Matrix3D_f transformation_matrix = getTransformationMatrix(this.pos, this.body_angle);
    Vector3D_f new_point = new Vector3D_f(0, 0, 1);
    
    for (Vector2D_f p : model_offsets) {
      new_point.x = pos.x + p.x;
      new_point.y = pos.y + p.y;
      points.add(transformation_matrix.matrix_multiply(new_point).getXY());
    }
    
    // Updates hitbox.
    this.hitbox_model.updateHitbox(points);
  }
  
  // Spawns projectile entity based on turret length, turret angle.
  public void shoot() {
    game.to_add_list.add(new Projectile(new Vector2D_f(this.pos.x + tank_hitbox_length * 0.5 * cos(this.turret_angle) , this.pos.y + tank_hitbox_height * 0.5 * sin(this.turret_angle)) , this.turret_angle, 3f, 40, 3, true));
  }
}
