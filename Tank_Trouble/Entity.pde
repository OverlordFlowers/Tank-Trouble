// Entities refer to world objects (obstacles and bullets), the player, or enemies.
abstract class Entity {
  // World state, keeps track of time.
  protected int time_ms = 0;
  
  // Game data
  public Vector2D_f pos = new Vector2D_f();
  protected Vector2D_f prev_pos = new Vector2D_f();
  
  // This is used to generate when generating and updating the hitbox. It tells you where the vertices are from the centerpoint.
  protected ArrayList<Vector2D_f> model_offsets;

  // Hitbox model object.
  protected Hitbox hitbox_model;
  
  // What angle is this at in the world
  protected float body_angle = 0f;
  protected float prev_body_angle = 0f;
  
  // How fast is this object moving, and is it a static object?
  protected float speed = 0f;
  protected Vector2D_f speed_vect = new Vector2D_f();
  protected boolean static_object = true;
  
  // Functions
  // Returns hitbox
  public Hitbox getHitbox() {
    return this.hitbox_model;
  }
  
  // Implement these functions
  // Called every time the game updates
  public abstract void update();
  // Updates the hitbox
  public abstract void updateHitbox();
  // Draws the object
  public abstract void drawEntity();
}
