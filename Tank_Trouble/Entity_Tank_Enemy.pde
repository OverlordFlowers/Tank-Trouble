// Keeps track of which targeting state the AI is in.
enum AI_Targeting_State {
  // searches for player
  searching,
  // tracks the player
  tracking,
  destroyed
}

// Keeps track of which movement state the AI is in.
enum AI_Movement_State {
  // idle
  idle,
  // chasing the player
  chase,
  // moving to waypoints
  moving,
  // pursuing last known player position
  pursuit,
  // is stuck
  stuck,
  unstucking
}

public class Enemy extends Tank {
  // AI states
  AI_Movement_State state_movement = AI_Movement_State.idle;
  AI_Movement_State prev_state_movement = AI_Movement_State.idle;
  AI_Targeting_State state_targeting = AI_Targeting_State.searching;
  // Detection radius from which it can see the player.
  float detection_radius = 400.0f;
  

  
  // Movement
  // Stores the waypoints it will take.
  ArrayDeque<Vector2D_f> waypoints = new ArrayDeque<Vector2D_f>();
  // What is its current waypoint?
  Vector2D_f curr_waypoint = new Vector2D_f(0, 0);
  // How long has it been stuck for?
  int time_ms_stuck_timer = 0;
  // How long has it been reversing?
  int time_ms_reverse_timer = 0;
  // When has it started being idle?
  int time_ms_start_idle = 0;
  // When is it going to stop being idle?
  int time_ms_break_idle = 0;
  // How long is it going to be idle for
  int time_ms_idle_timer = 1500;
  float turn_degeneration = 0.2f;
  // Used because the tank was turning too fast when it gets near its target angle.
  private boolean enable_turn_degeneration = false;

  // player tracking
  // Variable used to adjust how closely the AI predicts where the player is moving to.
  protected float tracking = 70f;
  
  // Where is the last known player position after they break line of sight?
  Vector2D_f last_known_player_pos = new Vector2D_f(0, 0);
  // Where is the last valid position of itself?
  Vector2D_f last_valid_self_pos = new Vector2D_f(0, 0);
  // Is it chasing?
  private boolean set_chase = false;
  // How closely should it follow the player
  protected float chase_radius = 200f;
  // Is the player too close
  protected boolean player_in_radius = false;
  
  // How often should it add new waypoints
  int time_ms_next_waypoint;
  int time_ms_next_waypoint_interval = 400;
  // How many waypoints should there be stored
  int waypoint_limit = 6;
 
  // Constructor
  Enemy(Vector2D_f pos, float angle) {
    // Spawn position.
    this.pos = pos;
    // Spawning waypoint.
    this.curr_waypoint = pos;
    // Angle it is spawned at.
    this.body_angle = angle;
    // Turret angle
    this.turret_angle = angle;
    
    // When was it spawned
    time_ms = millis();
    
    // Hitbox vertices
    model_offsets = new ArrayList<Vector2D_f>();

    model_offsets.add(new Vector2D_f(-tank_hitbox_length / 2 * player_tank_scale, -tank_hitbox_height / 2 * player_tank_scale));
    model_offsets.add(new Vector2D_f(tank_hitbox_length / 2 * player_tank_scale, -tank_hitbox_height / 2 * player_tank_scale));
    model_offsets.add(new Vector2D_f(tank_hitbox_length / 2 * player_tank_scale, tank_hitbox_height / 2 * player_tank_scale));
    model_offsets.add(new Vector2D_f(-tank_hitbox_length / 2 * player_tank_scale, tank_hitbox_height / 2 * player_tank_scale));
    
    // Creates new hitbox
    hitbox_model = new Hitbox(model_offsets);
    
    // When should it stop being idle?
    time_ms_break_idle = time_ms + time_ms_idle_timer;
    
    // String that accesses the image cache.
    this.body = "Enemy_Body";
    this.turret = "Normal_Enemy_Turret";
  }
  
  // Update
  void update() {
    // Updates time
    time_ms = millis();
    
    // Previous position is current position.
    prev_pos.x = pos.x;
    prev_pos.y = pos.y;
    prev_body_angle = body_angle;
    
    // If this is dead, then destroy it.
    if (this.health <= 0) {
      // Increment tanks destroyed counter
      game.tanks_destroyed++;
      // Explosion sound effect
      AudioCache.get(3).play();
      // Schedule for deletion
      game.to_delete_list.add(this);
      // Reduce number of enemies in level
      game.num_enemies--;
      // Add new explosion animation at this position
      game.animation_list.add(new Animation(this.pos.copy(), animation_explosion, 12));
      return;
    }

    // Is player in detection range?
    this.detectPlayer();
    // Resolve movement
    this.move();

    // Hitbox/Collision check
    // if geometry hit, revert back to previous un-obstructed position
    this.updateHitbox();
    this.handleCollision();
  }
  
  // Default shoot
  public void shoot() {
    game.to_add_list.add(new Projectile(new Vector2D_f(this.pos.x + tank_hitbox_length * cos(this.turret_angle), this.pos.y + tank_hitbox_height * sin(this.turret_angle)), this.turret_angle, 3f, 40, 3, true));
  }
  
  
  void move() {
    // How far has it moved from its last valid position?
    float dist_from_last = this.last_valid_self_pos.sub(this.pos).getMagnitude();
    
    // If position has deviated by a certain amount, or if it is idle, or if it has stopped to engage the player, this tank is not stuck.
    if (dist_from_last > 3.0f || state_movement == AI_Movement_State.idle || (player_in_radius & (state_targeting != AI_Targeting_State.searching))) {
      // If it is stuck, revert back to the last valid position.
      this.last_valid_self_pos.x = this.pos.x;
      this.last_valid_self_pos.y = this.pos.y;
      // It will be stuck for this long.
      time_ms_stuck_timer = time_ms + 500;
    }
    
    
    
    // If position has not deviated after a certain amount of time, and is not currently resolving being stuck, and is not idle, it is stuck.
    if (time_ms_stuck_timer <= time_ms && state_movement != AI_Movement_State.stuck && state_movement != AI_Movement_State.idle) {
      prev_state_movement = state_movement;
      // Reverse for a second.
      state_movement = AI_Movement_State.stuck;
      time_ms_reverse_timer = time_ms + 1000;
    }
    
    // Reverse for a second
    if (time_ms_reverse_timer <= time_ms && state_movement == AI_Movement_State.stuck) {
      // If previous state was chase, revert back to chase.
      if (set_chase == true) {
         set_chase = false;
         state_movement = AI_Movement_State.chase;
      } else {
        // Otherwise, check if there are any waypoints.
          curr_waypoint = waypoints.poll();
      } if (curr_waypoint == null) {
        // if there isn't, revert to idle.
          state_movement = AI_Movement_State.idle;
        } else {
          // If there is, move to that waypoint.
          state_movement = prev_state_movement;
        }
     }
    
    // When idle, stay still.
    if (state_movement == AI_Movement_State.idle) {
      is_accelerating = false;
      is_reversing = false;
      
      // After a certain amount of time, plot a new waypoint.
      if (time_ms_break_idle <= time_ms) {;
        curr_waypoint = new Vector2D_f(random(0, game.game_width), random(0, game.game_height));
        // If the waypoint is obstructed, generate new waypoint.
        while (!isWaypointValid(curr_waypoint)) {
          curr_waypoint = new Vector2D_f(random(0, game.game_width), random(0, game.game_height));
        }
        // Change state to movement.
        state_movement = AI_Movement_State.moving;
      }
    } else {
      // If it is not idle, then update the idle time.
      time_ms_break_idle = time_ms + time_ms_idle_timer;
    }
    
    // In this state, move to next valid waypoint.
    if (state_movement == AI_Movement_State.moving) {
      // If there are no valid waypoints, revert back to null.
      if (curr_waypoint == null) {
        state_movement = AI_Movement_State.idle;
      } else {
        // Move forward
        is_accelerating = true;
        is_reversing = false;
        
        // Checks distance to waypoint to avoid overshoot
        float tol_val = 20f;
        float dist_to_waypoint = this.pos.sub(this.curr_waypoint).getMagnitude();
       
        // Stops accelerating within a certain distance to the waypoint.
        if (dist_to_waypoint < tol_val * 0.6) {
          is_accelerating = false;
        }
        
        // If it has reached this point, move on to next waypoint or revert to idle.
        if (dist_to_waypoint < tol_val * 0.5) {
          if (waypoints.size() <= 0) {
            state_movement = AI_Movement_State.idle;
          } else {
            curr_waypoint = waypoints.poll();
          }
        }
      }    
    }
    
    // used if the AI has lost sight of the player while chasing them.
    if (state_movement == AI_Movement_State.pursuit) {
      // If they get line of sight back at any point in this state, immediately revert back to chasing them.
      if (getLineOfSight(game.player)) {
        state_targeting = AI_Targeting_State.tracking;
        state_movement = AI_Movement_State.chase;
      }
      
      is_accelerating = true;
      is_reversing = false;
      
      float tol_val = 20f;
      float dist_to_waypoint = this.pos.sub(this.curr_waypoint).getMagnitude();
     
      // Stops accelerating within a certain distance to the waypoint.
      if (dist_to_waypoint < tol_val * 0.6) {
        is_accelerating = false;
      }
      
      // If it has reached this point, move on to next waypoint or revert to idle.
      if (dist_to_waypoint < tol_val * 0.5) {
        if (waypoints.size() <= 0) {
          state_movement = AI_Movement_State.idle;
        } else {
          curr_waypoint = waypoints.poll();
        }
      }
    }
    
    // It is stuck and should reverse.
    if (state_movement == AI_Movement_State.stuck) {
      is_accelerating = false;
      is_reversing = true;
    }
    
    // Move directly to waypoint.
    if (state_movement == AI_Movement_State.chase) {
      curr_waypoint = game.player.pos;
      // Every so often, cache the player position as a waypoint (point is to follow them if the AI loses line of sight)
      if (time_ms_next_waypoint <= time_ms) {
        waypoints.add(curr_waypoint.copy());
        time_ms_next_waypoint += time_ms_next_waypoint_interval;
        if (waypoints.size() > waypoint_limit) {
          waypoints.poll();
        }
      }
      
      // Distance to player
      float dist_to_waypoint = this.pos.sub(game.player.pos).getMagnitude();
      
      // Stops if player is too close.
      if (dist_to_waypoint < chase_radius) {
        is_accelerating = false;
        is_reversing = false;
        player_in_radius = true;
      } else {
        is_accelerating = true;
        player_in_radius = false;
      }
    }
    
    // Uses control states specified in this function to resolve movement.
    resolve_move();
  }
  
  void resolve_move() {
    // resolve movement to waypoint
    // get angle
    // get distance
    
    // If idle, don't do anything.
    if (state_movement == AI_Movement_State.idle) {
      return;
    }
    
    // If there is nowhere to move to, do nothing.
    if (curr_waypoint == null) {
      return;
    }
    
    // Get angle to waypoint
    float angle_to_waypoint = atan2(curr_waypoint.y - this.pos.y, curr_waypoint.x - this.pos.x);
    float angle_diff = body_angle - angle_to_waypoint;
    // Used to handle transitions from (-180) to (180) degrees.
    if (abs(angle_diff) > 2 * PI * 0.8) {
      body_angle *= -1;
    }
    
    // If not on the waypoint
    if (tolerance(curr_waypoint.x, 0.1) != tolerance(pos.x, 0.1) && tolerance(curr_waypoint.y, 0.1) != tolerance(pos.y, 0.1)) {
      
      // If not stuck, turn
      if (state_movement != AI_Movement_State.stuck) {
        // If approaching target angle, slow turning
        if (abs(angle_diff) < 0.1) {
          enable_turn_degeneration = true;
        } else {
          enable_turn_degeneration = false;
        }
        
        // How much to turn by
        float turn_delta;
        if (enable_turn_degeneration) {
          turn_delta = body_rotation_speed * turn_degeneration;
        } else {
          turn_delta = body_rotation_speed;
        }
        
        // Change angle
        if (angle_diff > 0.05) {
          body_angle -= turn_delta;
        } else if (angle_diff < -0.05) {
          body_angle += turn_delta;
        }
      }
    } 
    
    // if stuck, reverse for 0.5 seconds
        // Resolve movement
    if (is_accelerating) {
      // If accelerating, increase the speed
      speed += acceleration * acceleration_modifier;
      // Clamps speed.
      if (speed > max_speed) {
        speed = max_speed;
      }
      // Else if reversing, deacclerate.
    } else if (is_reversing) {
      speed -= deacceleration;
      // Clamps speed.
      if (speed < min_speed) {
        speed = min_speed;
      }
    } else {
      // If neither accelerating or reversing, account for friction to do a natural slowdown.
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
    
    // Update position.
    pos.x += speed * cos(body_angle);
    pos.y += speed * sin(body_angle);
    
    // If debug mode is on, draw a line to the current waypoint.
    if (debug) {
      stroke(#000bed);
      line(curr_waypoint.x, curr_waypoint.y, this.pos.x, this.pos.y);
      circle(curr_waypoint.x, curr_waypoint.y, 5);
    }
  }
  
  // Used to detect the player
  void detectPlayer() {
    // Do we have line of sight?
    boolean has_los = getLineOfSight(game.player);
    // Used for aiming
    Vector2D_f predicted_position = null;
    
    // If searching,
    if (state_targeting == AI_Targeting_State.searching) {
      // Is player in detection radius?
      if (this.pos.sub(game.player.pos).getMagnitude() < this.detection_radius) {
        // Do we have line of sight?
        if (has_los) {
          if (state_movement != AI_Movement_State.chase) {
            // Switch movement state to chase
            state_movement = AI_Movement_State.chase;
            // Create new set of waypoints
            waypoints = new ArrayDeque<Vector2D_f>();
            // First waypoint is the player position
            waypoints.add(game.player.pos.copy());
            // Space out waypoint caching
            time_ms_next_waypoint += time_ms_next_waypoint_interval;
          }
          // Switch targeting state to tracking
          state_targeting = AI_Targeting_State.tracking;
        }
      }
      
      // Keep turret pointed forward
      if (turret_angle < body_angle - 0.05) {
        turret_angle += turret_rotation_speed;
      } else if (turret_angle > body_angle + 0.05) {
        turret_angle -= turret_rotation_speed;
      }
    }
    
    // If actively following the player
    if (state_targeting == AI_Targeting_State.tracking) {
      float angle_to_player;
      float angle_diff;
      
      // Makes sure the movement is in chase
      if (state_movement != AI_Movement_State.stuck) {
        state_movement = AI_Movement_State.chase;
      }
      
      // Predicts where the player position will be based on their speed.
      predicted_position = getFiringSolution();
      
      // Gets angle to that position
      angle_to_player = atan2(predicted_position.y - this.pos.y, predicted_position.x - this.pos.x);
      angle_diff = turret_angle - angle_to_player;

      // Used to handle transitions from (-180) to (180) degrees.
      if (abs(angle_diff) > 2*PI*0.95) {
        turret_angle *= -1;
      }
      
      //angle_diff = turret_angle - angle_to_player;
      // If ready to fire, draw a white circle to give player time to react.
      if (time_ms >= time_ms_next_shot_ready - 500) {
        stroke(#ffffff);
        noFill();
        circle(this.pos.x, this.pos.y, 50);
      }
      // Is the turret pointed at the player?
      if (angle_diff > 0.05) {
        turret_angle -= turret_rotation_speed;
        // This is a really weird way to take care of a rotation issue, where past a certain point the signs would flip.
        // If it works, it works, right?
      } else if (angle_diff < -0.05) {
        turret_angle += turret_rotation_speed;
      } else { 
        // Checks if a friendly is in the way. If not, and ready to fire, then shoot.
        if (time_ms >= time_ms_next_shot_ready && !friendlyInTheWay(predicted_position)) {
          this.shoot();
          // Reload timer
          time_ms_next_shot_ready = time_ms + time_ms_to_reload;
        }
      }
      
      // Lost sight of player, or player is destroyed
      if (!has_los) {
        state_targeting = AI_Targeting_State.searching;
        last_known_player_pos = game.player.pos.copy();
        curr_waypoint = game.player.pos.copy();
        waypoints.add(curr_waypoint.copy());
        // Follow last known player movements
        state_movement = AI_Movement_State.pursuit;
        prev_state_movement = AI_Movement_State.chase;
      }
    }
    
    // Draws lines denoting if the AI can see the player, does not have line of sight, or is actively engaging the player.
    if (debug) {
      if (!has_los) {
        stroke(#ff0000);
        line(game.player.pos.x, game.player.pos.y, this.pos.x, this.pos.y);
      } else {
        if (state_targeting == AI_Targeting_State.searching) {
          stroke(#ffff00);
          line(game.player.pos.x, game.player.pos.y, this.pos.x, this.pos.y);
        } else if (state_targeting == AI_Targeting_State.tracking) {
          stroke(#00ff0c);
          if (predicted_position != null) {
            line(predicted_position.x, predicted_position.y, this.pos.x, this.pos.y);
            circle(predicted_position.x, predicted_position.y, 5);
          }
        }
      }
    }
  }
  
  // Checks if there is a collision with an obstacle.
  void handleCollision() {
    if (hitbox_model.checkCollision()) {
      pos.x = prev_pos.x;
      pos.y = prev_pos.y;
      this.body_angle = this.prev_body_angle;
      speed = 0;
    }
  }
  
  // Gets line of sight.
  boolean getLineOfSight(Entity other_entity) {
    // Looks through entity list through obstacles. If any obstacles intersect line of sight, there is no line of sight.
    for (Entity e : game.entity_list) {
      if (e instanceof Rectangle) {
        Hitbox h = e.getHitbox();
        for (int i = 0; i < h.points.length; i++) {
          if (getLineCollision(this.pos, other_entity.pos, h.points[(i + 1) % h.points.length], h.points[i])) {
            return false;
          }
        }
      }
    }
    return true;
  }
  
  // This should be called when shooting at a position. It checks to see if there is a friendly in the way of the position, so it won't shoot.
  boolean friendlyInTheWay(Vector2D_f target_point) {
    for (Entity e : game.entity_list) {
      if (e != this && (e instanceof Enemy)) {
        Hitbox h = e.getHitbox();
        for (int i = 0; i < h.points.length; i++) {
          // If the line from the target point to current position intersects an enemy, then there is a friendly in the way.
          if (getLineCollision(this.pos, target_point, h.points[(i + 1) % h.points.length], h.points[i])) {
            return true;
          }
        }
      }
    }
    return false;
  }
  
  // If the waypoint intersects an obstacle
  boolean isWaypointValid(Vector2D_f waypoint) {
  for (Entity e : game.entity_list) {
    if (e instanceof Rectangle) {
      Hitbox h = e.getHitbox();
      for (int i = 0; i < h.points.length; i++) {
        if (getLineCollision(this.pos, waypoint, h.points[(i + 1) % h.points.length], h.points[i])) {
          return false;
        }
      }
    }
  }
  return true;
}
  
  // Predicts new position based on player speed and angle.
  Vector2D_f getFiringSolution() {
    float x = game.player.pos.x + (game.player.speed * cos(game.player.body_angle) * this.tracking);
    float y = game.player.pos.y + (game.player.speed * sin(game.player.body_angle) * this.tracking);
    
    return new Vector2D_f(x, y);
  }
}


//  enemy variants
// Normal
public class Normal extends Enemy {
  Normal(Vector2D_f pos, float angle) {
    super(pos, angle);
    this.max_speed = 1.5f;
    this.body_rotation_speed = 0.05f;
    this.health = 80;
    this.time_ms_to_reload = 1000;
    this.detection_radius = 400f;
    // String to access hashmap storing images.
    this.turret = "Normal_Enemy_Turret";
    this.tracking = 30f;
    
    // Scales parameters based on hard mode.
    if (hard_mode) {
      this.time_ms_to_reload *= hardmode_enemy_reload_scale;
      this.health *= hardmode_enemy_health_scale;
      this.max_speed *= hardmode_enemy_speed_scale;
    }
  }
}

// More health, tank
public class Heavy extends Enemy {
  
  Heavy(Vector2D_f pos, float angle) {
    super(pos, angle);
    this.max_speed = 1.0f;
    this.body_rotation_speed = 0.02f;
    this.health = 120;
    this.time_ms_to_reload = 1000;
    this.turret = "Heavy_Enemy_Turret";
    this.tracking = 20f;
    
    if (hard_mode) {
      this.time_ms_to_reload *= hardmode_enemy_reload_scale;
      this.health *= hardmode_enemy_health_scale;
      this.max_speed *= hardmode_enemy_speed_scale;
    }
  }
}

// Faster shooty
// Saturates space with bullets
// Weaknesses: short detection range, slower bullets, weaker tracking
public class Gunner extends Enemy {
  // Modifies shooting parameters.
  private float projectile_velocity = 2f;
  private int projectile_damage = 15;
  private int num_bounces = 2;
  
  Gunner(Vector2D_f pos, float angle) {
    super(pos, angle);
    this.max_speed = 0.2f;
    this.body_rotation_speed = 0.02f;
    this.turret_rotation_speed = 0.03f;
    this.health = 40;
    this.time_ms_to_reload = 300;
    this.detection_radius = 300f;
    this.turret = "Gunner_Enemy_Turret";
    this.tracking = 10f;
    this.chase_radius = 400f;
    
    if (hard_mode) {
      this.time_ms_to_reload *= hardmode_enemy_reload_scale;
      this.health *= hardmode_enemy_health_scale;
      this.max_speed *= hardmode_enemy_speed_scale;
    }
  }
  
  @Override
  void shoot() {
    // Adds a spread to the shots fired.
    float spread = random(-0.2, 0.2);
    game.to_add_list.add(new Projectile(new Vector2D_f(this.pos.x + tank_hitbox_length * cos(this.turret_angle), this.pos.y + tank_hitbox_height * sin(this.turret_angle)), this.turret_angle + spread, projectile_velocity, projectile_damage, num_bounces, true));
  }
}

// Sniper:
// Concept is a longer-range, slower firing enemy that deals more damage than usual.
// Weak at close range (tracking is bad), strong at higher ranges and catches player off guard
public class Sniper extends Enemy {
  private float projectile_velocity = 15f;
  private int projectile_damage = 60;
  private int num_bounces = 1;
  
  Sniper(Vector2D_f pos, float angle) {
    super(pos, angle);
    this.max_speed = 0.2f;
    this.body_rotation_speed = 0.05f;
    this.turret_rotation_speed = 0.02f;
    this.health = 40;
    this.time_ms_to_reload = 4000;
    this.turret = "Sniper_Enemy_Turret";
    this.detection_radius = 800f;
    this.tracking = 40f;
    this.chase_radius = 700f;
    
    if (hard_mode) {
      this.time_ms_to_reload *= hardmode_enemy_reload_scale;
      this.health *= hardmode_enemy_health_scale;
      this.max_speed *= hardmode_enemy_speed_scale;
    }
  }
  
  @Override
  void shoot() {
    game.to_add_list.add(new Projectile(new Vector2D_f(this.pos.x + tank_hitbox_length * cos(this.turret_angle), this.pos.y + tank_hitbox_height * sin(this.turret_angle)), this.turret_angle, projectile_velocity, projectile_damage, num_bounces, true));
  }
}
