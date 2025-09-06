// Used to denote which projectile type is being used. Unused.
enum projectile_type {
  Shell,
  Bullet,
  Rail
}

// Projectile class represents the projectiles in the environment.
public class Projectile extends Entity {
  // Damage this projectile does on impact.
  private int damage;
  // What is the hitbox scale? (Changes based on difficulty)
  private int hitbox_scale;
  // How many times can this projectile bounce?
  private int num_bounce;
  // Is this shell from an enemy AI?
  private boolean from_enemy = false;
  
  // Placeholder constructor for when I add more cannon types
  Projectile(projectile_type type, Vector2D_f pos, float angle) {
    if (type == projectile_type.Shell) {
      this.speed = 3f;
      this.pos = pos;
      this.body_angle = angle;
      this.damage = 40;
      this.static_object = false;
      this.num_bounce = 3;
      
      pos.x = pos.x + cos(angle);
      pos.y = pos.y + sin(angle);
      
      this.hitbox_scale = 4;
      if (hard_mode) {
        this.hitbox_scale = 2;
      }
      
      ArrayList<Vector2D_f> points = new ArrayList<Vector2D_f>();
      // Get transformation matrix
      
      Matrix3D_f transformation_matrix = getTransformationMatrix(this.pos, this.body_angle);
      Vector3D_f new_point = new Vector3D_f(0, 0, 1);
      
      new_point.x = pos.x - hitbox_scale;
      new_point.y = pos.y - hitbox_scale;
      points.add(transformation_matrix.matrix_multiply(new_point).getXY());
      
      new_point.x = pos.x + hitbox_scale;
      new_point.y = pos.y - hitbox_scale;
      points.add(transformation_matrix.matrix_multiply(new_point).getXY());
          
      new_point.x = pos.x + hitbox_scale;
      new_point.y = pos.y + hitbox_scale;
      points.add(transformation_matrix.matrix_multiply(new_point).getXY());
          
      new_point.x = pos.x - hitbox_scale;
      new_point.y = pos.y + hitbox_scale;
      points.add(transformation_matrix.matrix_multiply(new_point).getXY());
      
      this.hitbox_model = new Hitbox(points);
      AudioCache.get(0).play();
      
      // Check if, on spawn, there is a conflicting hitbox.
      Entity collided_with = this.hitbox_model.checkCollisionGetEntity();
      handleCollisionOnSpawn(collided_with);
    }
  }
  
  // For now, use this constructor which just adjusts the speed / number of bounces.
  Projectile(Vector2D_f pos, float angle, float speed, int damage, int bounce, boolean from_enemy) {
      this.pos = pos;
      this.body_angle = angle;
      this.speed = speed;
      this.damage = damage;
      this.num_bounce = bounce;
      this.from_enemy = from_enemy;
      
      // Starting position of the projectile.
      pos.x = pos.x + cos(angle);
      pos.y = pos.y + sin(angle);
      
      // Changes hitbox scale based on difficulty.
      this.hitbox_scale = 4;
      if (hard_mode) {
        this.hitbox_scale = 2;
      }
      
      // Stores the vertex points.
      ArrayList<Vector2D_f> points = new ArrayList<Vector2D_f>();
      // Get transformation matrix, rotates vertices based on position and angle of the entity.
      Matrix3D_f transformation_matrix = getTransformationMatrix(this.pos, this.body_angle);
      Vector3D_f new_point = new Vector3D_f(0, 0, 1);
      
      new_point.x = pos.x - hitbox_scale;
      new_point.y = pos.y - hitbox_scale;
      points.add(transformation_matrix.matrix_multiply(new_point).getXY());
      
      new_point.x = pos.x + hitbox_scale;
      new_point.y = pos.y - hitbox_scale;
      points.add(transformation_matrix.matrix_multiply(new_point).getXY());
          
      new_point.x = pos.x + hitbox_scale;
      new_point.y = pos.y + hitbox_scale;
      points.add(transformation_matrix.matrix_multiply(new_point).getXY());
          
      new_point.x = pos.x - hitbox_scale;
      new_point.y = pos.y + hitbox_scale;
      points.add(transformation_matrix.matrix_multiply(new_point).getXY());
      
      // Creates new hitbox
      this.hitbox_model = new Hitbox(points);
      // Plays the cannon shot sound effect
      AudioCache.get(0).play();
      
      // Check if the object collides with anything on spawn
      Entity collided_with = this.hitbox_model.checkCollisionGetEntity();
      
      // Does this projectile collide with an object on spawn?
      handleCollisionOnSpawn(collided_with);
  }
  
  
  // Draws the entity and loads its image from the image cache.
  void drawEntity() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(body_angle);
    image(game.ImageCache.get("Normal_Cannon"), 0, 0);
    popMatrix();
    if (debug) {
      this.hitbox_model.drawHitbox();
    }
  }
  
  // Updates the hitbox.
  void updateHitbox() {
      ArrayList<Vector2D_f> points = new ArrayList<Vector2D_f>();
      // Get transformation matrix, rotates vertices based on position and angle of the entity.
      Matrix3D_f transformation_matrix = getTransformationMatrix(this.pos, this.body_angle);
      Vector3D_f new_point = new Vector3D_f(0, 0, 1);
      
      new_point.x = pos.x - hitbox_scale;
      new_point.y = pos.y - hitbox_scale;
      points.add(transformation_matrix.matrix_multiply(new_point).getXY());
      
      new_point.x = pos.x + hitbox_scale;
      new_point.y = pos.y - hitbox_scale;
      points.add(transformation_matrix.matrix_multiply(new_point).getXY());
          
      new_point.x = pos.x + hitbox_scale;
      new_point.y = pos.y + hitbox_scale;
      points.add(transformation_matrix.matrix_multiply(new_point).getXY());
          
      new_point.x = pos.x - hitbox_scale;
      new_point.y = pos.y + hitbox_scale;
      points.add(transformation_matrix.matrix_multiply(new_point).getXY());
      
      // Creates new hitbox to represent where it is.
      this.hitbox_model = new Hitbox(points);
  }
  
  // Updates itself in the world.
  public void update() {
    // Updates time
    time_ms = millis();
    
    // Has this projectile run out of bounces? Delete it.
    if (this.num_bounce <= 0) {
      game.to_delete_list.add(this);
      return;
    }
    
    // Keeps track of previous position just in case it is in an invalid area.
    prev_pos.x = pos.x;
    prev_pos.y = pos.y;
    prev_body_angle = this.body_angle;
    
    // Calculates speed vectors.
    speed_vect.x = speed * cos(body_angle);
    speed_vect.y = speed * sin(body_angle);
    
    // Updates position based on speed.
    this.pos.x += speed_vect.x;
    this.pos.y += speed_vect.y;
    
    // Updates the hitbox.
    updateHitbox();
    
    // Check if the object has collided with anything.
    Entity collided_with = this.hitbox_model.checkCollisionGetEntity();
    handleCollision(collided_with);
  }
  
  // Handles collision, if the entity is not null.
  void handleCollision(Entity e) {
    // Normal vector represents the vector used to reflect the projectile on bounce.
    Vector2D_f norm_vect;
    if (e != null) {
      // Is the entity a tank?
      if (e instanceof Tank) {
        Tank t = (Tank) e;
        // If it is not invincible,
        if (!t.invincible) {
          // and if is friendly fire, half the damage.
          if (t instanceof Enemy && this.from_enemy) {
            t.health -= this.damage / 2;
          } else {
            // else, deal full damage.
            t.health -= this.damage;
          }
        }
        // Play hit sound effect.
        AudioCache.get(2).play();
        // Delete projectile.
        game.to_delete_list.add(this);
      } else if (e instanceof Projectile) {
        // If it hits another projectile, also delete it.
        game.to_delete_list.add(this);
        game.to_delete_list.add(e);
      } else {
        // Else it impacted an obstacle
        Hitbox h = e.getHitbox();
        // if next position intersects with another rectangle
        for (int i = 0; i < h.points.length; i++) {
          // Which section did it impact?
          if (getLineCollision(prev_pos, pos, h.points[(i + 1) % h.points.length], h.points[i])) {
            // Reduce the number of bounces.
            num_bounce--;

            pos.x = prev_pos.x;
            pos.y = prev_pos.y;
            
            // Gets the normal vector of the impacted surface vector.
            norm_vect = new Vector2D_f(h.points[(i + 1) % h.points.length].x - h.points[i].x, h.points[(i + 1) % h.points.length].y - h.points[i].y);
            norm_vect = norm_vect.getOrthog();
            
            // Subtracts the speed vector of the projectile by 2 * the projection onto the normal vector.
            speed_vect = speed_vect.sub(speed_vect.getProjOnto(norm_vect).scalarMult(2));
            
            // Gets the new body angle based on the new speed vector.
            this.body_angle = atan2(speed_vect.y, speed_vect.x);
            // Updates position.
            this.pos.x += speed_vect.x;
            this.pos.y += speed_vect.y;
            return;
          }
        }
      }
    }
    
    return;
  }
  
  // Same as above, only if it impacts an obstacle on spawn then it is instantly deleted. (Prevents self-destruction and projectiles spawning in walls).
  void handleCollisionOnSpawn(Entity e) {
    if (e != null) {
      if (e instanceof Tank) {
        Tank t = (Tank) e;
        if (!t.invincible) {
          if (t instanceof Enemy && this.from_enemy) {
            t.health -= this.damage / 2;
          } else {
            t.health -= this.damage;
          }
        }
        AudioCache.get(2).play();
        game.to_delete_list.add(this);
        return;
      } else if (e instanceof Projectile) {
        game.to_delete_list.add(this);
        game.to_delete_list.add(e);
        return;
      } else {
        this.num_bounce = 0;
        game.to_delete_list.add(this);
      }
    }
    
    return;
  }
}
