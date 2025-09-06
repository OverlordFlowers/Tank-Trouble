// This class represents the player.

public class Player extends Tank {
  // State
  // Dashing
  private boolean can_dash = true;
  private boolean is_dashing = false;
  // When can dash next?
  private int time_ms_next_dash = 0;
  // When does the dash end?
  private int time_ms_end_dash = 0;
  
  // Firing
  // Reload timer
  private int time_ms_next_fire;
  // Is ready to fire
  private boolean ready_to_fire;
  
  // Shot parameters
  private float projectile_velocity = 3f;
  private int projectile_damage = 40;
  private int num_bounces = 3;
 

  // Upgradables (if adding in)
  public float dash_power = 10f;
  private int time_ms_dash_ready_timer = 1000;
  
  // Constructor
  Player(Vector2D_f pos, float angle) {
    this.pos = pos.copy();
    this.body_angle = angle;
    this.time_ms = millis();
    this.time_ms_next_fire = 0;
    this.time_ms_to_reload = 600;
    this.ready_to_fire = false;
    this.health = 200;
    
    // Modifies the body rotation speed
    this.body_rotation_speed = 0.05f;
    
    // Changes the max speed (too fast makes the game hard to play)
    this.max_speed = 2.0;
    
    // Creates hitbox using vertices offset
    model_offsets = new ArrayList<Vector2D_f>();

    model_offsets.add(new Vector2D_f(-tank_hitbox_length / 2 * player_tank_scale, -tank_hitbox_height / 2 * player_tank_scale));
    model_offsets.add(new Vector2D_f(tank_hitbox_length / 2 * player_tank_scale, -tank_hitbox_height / 2 * player_tank_scale));
    model_offsets.add(new Vector2D_f(tank_hitbox_length / 2 * player_tank_scale, tank_hitbox_height / 2 * player_tank_scale));
    model_offsets.add(new Vector2D_f(-tank_hitbox_length / 2 * player_tank_scale, tank_hitbox_height / 2 * player_tank_scale));
    
    // Strings used to access images hashmap
    this.body = "Player_Body";
    this.turret = "Player_Turret";

    // Creates new hitbox model
    hitbox_model = new Hitbox(model_offsets);
    
    // Changes parameters based on game difficulty
    if (hard_mode) {
      this.health *= hardmode_player_health_scale;
      this.time_ms_dash_ready_timer *= hardmode_player_dash_recharge_scale;
      this.time_ms_to_reload *= hardmode_player_reload_scale;
    }
  }
  
  // Updates the rotation if moving
  void updateRotation(float add_rotation) {
    this.body_angle += add_rotation;
  }
  
  // Check if any keypresses have occured
  @Override
  void update() {
    if (debug) {
      this.invincible = true;
    }
    // update time and state
    time_ms = millis();
    prev_pos.x = pos.x;
    prev_pos.y = pos.y;
    prev_body_angle = this.body_angle;
    
    // If health is less than 0, die.
    if (this.health <= 0) {
      is_alive = false;
      game.to_delete_list.add(this);
      // Changes game state to lost
      game.game_lost = true;
      return;
    }
    
    // Can player dash again?
    if (time_ms >= time_ms_next_dash) {
      can_dash = true;
    }
    
    // Is the cannon reloaded?
    if (time_ms >= time_ms_next_fire) {
      ready_to_fire = true;
    }
    
    /***********KEYBOARD COMMANDS************/
    // If w pressed, accelerate
    if (key_pressed[0]) {
      is_accelerating = true;
    } else {
      is_accelerating = false;
    }
    
    // If s pressed, reverse
    if (key_pressed[2]) {
      is_reversing = true;
    } else {
      is_reversing = false;
    }
    
    // Resolve movement
    if (is_accelerating) {
      // adds acceleration to speed
      speed += acceleration * acceleration_modifier;
      if (speed > max_speed) {
        speed = max_speed;
      }
    } else if (is_reversing) {
      // reverses
      speed -= deacceleration;
      if (speed < min_speed) {
        speed = min_speed;
      }
    } else {
      // if not moving, slow down using friction
      if (speed < 0) {
        speed += friction;
        speed = tolerance(speed, 0.001);
      } else if (0 < speed) {
        speed -= friction;
        speed = tolerance(speed, 0.001);
      } else {
        speed = 0;
      }
    }
    
    // If it is dashing, move forward faster.
    if (is_dashing) {
      if (time_ms < time_ms_end_dash) {
        pos.x += dash_power * cos(body_angle);
        pos.y += dash_power * sin(body_angle);
      } else {
        this.invincible = false;
        is_dashing = false;
      }
    } else {
      // Is shift pressed?
      if (key_pressed[4]) {
        // If dash is available, dash.
        if (can_dash) {
          // become invincible while dashing
          this.invincible = true;
          can_dash = false;
          is_dashing = true;
          // When does the dash end
          time_ms_end_dash = time_ms + 300;
          // When will the next dash be ready
          time_ms_next_dash = time_ms + time_ms_dash_ready_timer;
        } else {
          // Else, resolve next position normally
          pos.x += speed* cos(body_angle);
          pos.y += speed* sin(body_angle);
        }
      } else {
        // Else, update position normally.    
        pos.x += speed * cos(body_angle);
        pos.y += speed * sin(body_angle);
      }
    }
    
    // Is a pressed? Turn left
    if (key_pressed[1]) {
      body_angle -= body_rotation_speed;
    }
    
    // If d pressed, turn right
    if (key_pressed[3]) {
      body_angle += body_rotation_speed;
    }
    
    // If left mouse button pressed,
    if (mouse_pressed[0]) {
      // if cannon loaded,
      if (ready_to_fire) {
        // fire
        ready_to_fire = false;
        // begin reload
        time_ms_next_fire = time_ms + time_ms_to_reload;
        // spawn new projectile
        game.to_add_list.add(new Projectile(new Vector2D_f(this.pos.x + tank_hitbox_length * 0.7 * cos(this.turret_angle), this.pos.y + tank_hitbox_height * 0.7 * sin(this.turret_angle)), this.turret_angle, projectile_velocity, projectile_damage, num_bounces, false));
        
      }
    }
    

    // If right mouse button pressed
    if (mouse_pressed[1]) {
      mouse_pressed[1] = false;
    }
    
    // Gets turret angle based on where the mouse is relative to the tank position
    turret_angle = atan2((mouseY - pos.y), (mouseX - pos.x));
    /***********END KEYBOARD COMMANDS**********/
    
    // Update hitbox
    this.updateHitbox();
    // Hitbox/Collision check
    // if geometry hit, revert back to previous un-obstructed position.
    Entity collided_with = hitbox_model.checkCollisionGetEntity();
    
    if (collided_with != null) {
      // Does not stop if colliding with a projectile
      if (!(collided_with instanceof Projectile)) {
        // Revert back to previous valid state
        pos.x = prev_pos.x;
        pos.y = prev_pos.y;
        this.body_angle = this.prev_body_angle;
        speed = 0;
      }
    }
  }
}
