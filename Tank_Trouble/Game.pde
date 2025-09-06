import java.util.*;

// Game class to represent game
public class Game {
  // Keeps track of all the entities
  ArrayList<Entity> entity_list = new ArrayList<Entity>();
  // Deletion list
  ArrayList<Entity> to_delete_list = new ArrayList<Entity>();
  // Creation list
  ArrayList<Entity> to_add_list = new ArrayList<Entity>();
  
  // Stores all the animations
  ArrayList<Animation> animation_list = new ArrayList<Animation>();
  // Delete animation list
  ArrayList<Animation> to_remove_animation_list = new ArrayList<Animation>();
  
  // Image cache
  HashMap<String, PImage> ImageCache;
  
  // Game windo
  public float game_width = 800;
  public float game_height = 800;
  
  // XML files
  XML xml_levels;
  XML xml_art;
  
  // Level state, number of enemies, number of enemies in the level, and the tanks destroyed
  int level = 0;
  int num_enemies = 0;
  int num_enemies_level = 0;
  int tanks_destroyed = 0;
  
  // Game won, game lost, or if the game is restarting.
  boolean game_won = false;
  boolean game_lost = false;
  boolean restart = false;
  
  // Are we in hard mode?
  boolean hard_mode;
  
  // When did the game start? When does it end?
  int time_ms_start_time = 0;
  int time_ms_end_time = 0;
 
  
  // This is the player.
  Player player;
  
  // Constructor
  Game(boolean hard_mode) {
    // Borders
    // Creates new image cache
    ImageCache = new HashMap<String, PImage>();
    // Sets to hard mode
    this.hard_mode = hard_mode;
    // Cache images
    cacheImages("data/art_assets.xml");
    // Loads the animations
    loadAnimations();
    // Loads the first level
    loadLevel(level);
    // Time starts now
    time_ms_start_time = millis();
  }

  void update() {
    // For each entity, update that entity
    for (Entity e : entity_list) {
      e.update();
    }
    
    // For each entity to be deleted, delete that entity
    for (Entity e : to_delete_list) {
      entity_list.remove(e);
    }
    
    // Add entity to the entity list
    for (Entity e : to_add_list) {
      entity_list.add(e);
    }
    
    // Removes animations to be removed
    for (Animation a : to_remove_animation_list) {
      animation_list.remove(a);
    }
    
    // Clear delete/add lists
    to_delete_list.clear();
    to_add_list.clear();
    to_remove_animation_list.clear();
    
    // If lost, then clear the lists
    if (game_lost || game_won) {
      clearLists();
    }
    
    // If the number of enemies are 0, and the game has not ended, then move on to the next level.
    if (num_enemies == 0 & !(game_won || game_lost)) {
      clearLists();
      level++;
      // If level is greater than the max number of levels, then the game is won.
      if (level >= max_levels) {
        time_ms_end_time = millis();
        game_won = true;
      } else {
        loadLevel(level);
      }
    }    
  }
  
  // Draw entity
  void draw() {
    // Draws the entities
    for (Entity e : entity_list) {
      e.drawEntity();
    }
    
    // Updates animations
    for (Animation a : animation_list) {
      a.display();
    }
    // Displays the GUI
    displayGUI();
  }
  
  void displayGUI() {
    
    // IF the game won, display winning message, number of levels complete, tanks eliminated, the time it took, and restart buttons.
    if (game_won) {
      textSize(24);
      textAlign(CENTER);
      fill(#000000);
      text("You win!", width/2, height/2 - 200);
      textSize(18);
      text("Levels completed: " + this.level, width/2, height/2 - 175);

      text("Tanks eliminated: " + this.tanks_destroyed, width/2, height/2 - 150);
      text("Time to Complete: " + ((time_ms_end_time - time_ms_start_time) / 1000) + " seconds", width/2, height/2 - 125);   
      displayRestart();
    // IF the game lost, display losing message, number of levels complete, tanks eliminated, and restart buttons.
    } else if (game_lost) {
      textSize(24);
      textAlign(CENTER);
      text("You lost!", width/2, height/2 - 200);
      textSize(18);
      text("Tanks eliminated: " + this.tanks_destroyed, width/2, height/2 - 150);
      text("Levels completed: " + this.level, width/2, height/2 - 175);
      displayRestart();
    } else {
      // By default, display a GUI at the right side of the screen.
      stroke(#000000);
      fill(#9b560c);
      rect(game.game_width, 0, width - game.game_width, game.game_height);
      fill(#000000);
      
      // display health
      textSize(24);
      textAlign(CENTER);
      fill(#1bd64a);
      text("Health", (((width - this.game_width) / 2) + this.game_width), 75);
      
      fill(#000000);
      
      text(str(player.health), (((width - this.game_width) / 2) + this.game_width), 100);
      
      // Display if the player can dash
      if(player.can_dash) {
        fill(#ffffff);
      } else {
        fill(#ff0000);
      }
      
      text("Dash Ready", (((width - this.game_width) / 2) + this.game_width), 150);
      
      // Display if the player can fire
      if(player.ready_to_fire) {
        fill(#ffffff);
      } else {
        fill(#ff0000);
      }
      
      text("Cannon Loaded", (((width - this.game_width) / 2) + this.game_width), 200);
      
      // Number of tanks destroyed
      fill(#000000);
      textSize(18);
      text("Tanks eliminated: " + this.tanks_destroyed, (((width - this.game_width) / 2) + this.game_width), 250);
      
      // Current level
      fill(#000000);
      textSize(18);
      text("Level: " + (this.level + 1), (((width - this.game_width) / 2) + this.game_width), 300);
      
      // Time elapsed
      fill(#000000);
      textSize(18);
      text("Time elapsed: " + ((millis() - time_ms_start_time) / 1000), (((width - this.game_width) / 2) + this.game_width), 350);
      
      
      // Exit button
      if (displayButton(new Vector2D_f((((width - this.game_width) / 2) + this.game_width), height - 50), new Vector2D_f(100, 50), "Exit", 24)) {
        exit();
      }
      
      if (displayButton(new Vector2D_f((((width - this.game_width) / 2) + this.game_width), height - 150), new Vector2D_f(100, 50), "Return to Menu", 12)) {
        mouse_pressed[0] = false;
        restart = true;
      }
     
      
      // When designing level, display the refresh button to enact any changes to the .xml file.
      if (designing_level) {
        if (displayButton(new Vector2D_f((((width - this.game_width) / 2) + this.game_width), height - 250), new Vector2D_f(100, 50), "Reload", 24)) {
          clearLists();
          loadLevel(level);
        }
      }

    }
  }
  

  // Caches the images
  private void cacheImages(String images) {
    // loads the XML
    xml_art = loadXML(images);
    XML[] art = xml_art.getChild("art_sources").getChildren();
    
    // Reads source paths from xml file and uses it to store the images.
    for (int i = 0; i < art.length; i++) {
      // Weird work-around, but it works
      if (art[i].getName() != "#text") {
        ImageCache.put(art[i].getName(), loadImage(art[i].getString("src")));
      }    
    }
  }
  
  // Loads the level
  private void loadLevel(int level) {
    String level_path;
    // If in design mode, load the specific xml file
    if (designing_level) {
      level_path = "data/levels/level_designer.xml";
    } else {
      // Else, just load the levels normally.
      level_path = "data/levels/level" + level + ".xml";
    }
        
    xml_levels = loadXML(level_path);
    float x, y, angle;
    
    // Draws world boundaries
    entity_list.add(new Rectangle(0, 0, game_width, 1));
    entity_list.add(new Rectangle(0, 0, 1, game_height));
    entity_list.add(new Rectangle(game_width-1, 0, 1, game_height));
    entity_list.add(new Rectangle(0, game_height-1, game_width, 1));
    
    // Spawns the player based on XML file data
    // gets position, angle
    x = xml_levels.getChild("player").getChild("posx").getFloatContent();
    y = xml_levels.getChild("player").getChild("posy").getFloatContent();
    angle = radians(xml_levels.getChild("player").getChild("angle").getFloatContent());
    player = new Player(new Vector2D_f(x, y), angle);
    entity_list.add(player);
    
    // Spawns obstacles using data from the XML file.
    XML[] environment = xml_levels.getChild("environment").getChildren();
    for (int i = 0; i < environment.length; i++) {
      if (environment[i].getName() == "rectangle") {
        float l, h;
        // get position, angle, length, and height
        x = environment[i].getChild("posx").getFloatContent();
        y = environment[i].getChild("posy").getFloatContent();
        angle = radians(environment[i].getChild("angle").getFloatContent());
        l = environment[i].getChild("length").getFloatContent();
        h = environment[i].getChild("height").getFloatContent();
        
        entity_list.add(new Rectangle(x, y, l, h, angle));
      }
    }
    
    // add enemies
    this.num_enemies = 0;
    XML[] enemies = xml_levels.getChild("enemies").getChildren();
    // add enemies based on type, position, and angle.
    for (int i = 0; i < enemies.length; i++) {
      if (enemies[i].getName() == "normal") {
        num_enemies++;
        
        x = enemies[i].getChild("posx").getFloatContent();
        y = enemies[i].getChild("posy").getFloatContent();
        angle = radians(enemies[i].getChild("angle").getFloatContent());
        
        entity_list.add(new Normal(new Vector2D_f(x, y), angle));
      }
      
      if (enemies[i].getName() == "heavy") {
        num_enemies++;
        
        x = enemies[i].getChild("posx").getFloatContent();
        y = enemies[i].getChild("posy").getFloatContent();
        angle = radians(enemies[i].getChild("angle").getFloatContent());
        
        entity_list.add(new Heavy(new Vector2D_f(x, y), angle));
        
      }
      
      if (enemies[i].getName() == "gunner") {
        num_enemies++;
        
        x = enemies[i].getChild("posx").getFloatContent();
        y = enemies[i].getChild("posy").getFloatContent();
        angle = radians(enemies[i].getChild("angle").getFloatContent());
        
        entity_list.add(new Gunner(new Vector2D_f(x, y), angle));
        
      }
      
      if (enemies[i].getName() == "sniper") {
        num_enemies++;
        
        x = enemies[i].getChild("posx").getFloatContent();
        y = enemies[i].getChild("posy").getFloatContent();
        angle = radians(enemies[i].getChild("angle").getFloatContent());
        
        entity_list.add(new Sniper(new Vector2D_f(x, y), angle));
        
      }
    }
    this.num_enemies_level = this.num_enemies;
  }
  
  // Clears all lists.
  private void clearLists() {
    entity_list.clear();
    animation_list.clear();
    to_delete_list.clear();
    to_add_list.clear();
    to_remove_animation_list.clear();
  }
  
  // Displays when in a restart state.
  private void displayRestart() {
    // Back to menu button
    if (displayButton(new Vector2D_f(width/2 - 150, height/2 + 50), new Vector2D_f(180, 50), "Back to Menu", 24)) {
      mouse_pressed[0] = false;
      restart = true;
    }
   
    // Exit game button
    if (displayButton(new Vector2D_f(width/2 + 150, height/2 + 50), new Vector2D_f(100, 50), "Exit Game", 18)) {
      mouse_pressed[0] = false;
      exit();
    }
    
    // Restarts the level if the game is lost.
    if (!game_won) {
      if (displayButton(new Vector2D_f(width/2, height - 450), new Vector2D_f(120, 50), "Restart Level", 18)) {
        mouse_pressed[0] = false;
        this.tanks_destroyed -= this.num_enemies_level - this.num_enemies;
        game_lost = false;
        loadLevel(level);
      }
    }
  }
}
