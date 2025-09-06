// Imports can be found by going to "tools -> add tools -> libraries" and searching for g4p and Sound.
import processing.sound.*;

// Java imports
import java.util.Queue;

// These are to track if the game is running.
boolean game_start = false;
boolean hard_mode = false;
boolean game_running = false;

// This is the game object.
Game game;

// This is the soundfile that caches the bgm.
SoundFile bgm;

// This is a hashmap so I don't have to instantiate a new soundfile object everytime I want to use a sound.
HashMap<Integer, SoundFile> AudioCache;

void setup() {
  // Game window size.
  size(1000, 800);
  
  AudioCache = new HashMap<Integer, SoundFile>();
  
  // Physics are **framerate dependent**. Don't change this.
  frameRate(60);
   //<>// //<>// //<>//
  // For some reason, can't do this in a function, so this is where I need to do it.
  // Cannon fire
  AudioCache.put(0, new SoundFile(this, "assets/sounds/kinetic_cannon.wav"));
  AudioCache.get(0).amp(0.15);
  // Hit taken
  AudioCache.put(2, new SoundFile(this, "assets/sounds/hit_taken.wav"));
  // Explosion
  AudioCache.put(3, new SoundFile(this, "assets/sounds/explosion.wav"));
  AudioCache.get(3).amp(0.50);
  
  // Loads the background music.
  bgm = new SoundFile(this, "assets/music/bonetrousle.mp3");
  bgm.amp(0.10);
  bgm.loop();
  
  imageMode(CENTER);
}

void draw() {
  // Background color.
  background(#6b6767);
  
  // If the game is not running, display the menu.
  if (!game_running) {
    displayMenu();
  }
  
  // If the game is scheduled to start, create a new game.
  if (game_start) {
    game_running = true;
    game_start = false;
    game = new Game(hard_mode);
  }
  
  // This is for after the game is over. If the game says to restart, then the game is no longer running and the game becomes null.
  if (game != null) {
    if (game.restart) {
      // Dereferences the original game object, causing it to be deleted.
      game = null;
      game_running = false;
    } else {
      // Update game if it exists and draw the game itself.
      game.update();
      game.draw();
    }
  }
}

// This is the main menu display.
void displayMenu() {
  // Start button
  if (displayButton(new Vector2D_f(width/2 - 150, height/2 + 50), new Vector2D_f(100, 50), "Start", 24)) {
    game_start = true;
  }
  
  // Exit button
  if (displayButton(new Vector2D_f(width/2 + 150, height/2 + 50), new Vector2D_f(100, 50), "Exit", 24)) {
    exit();
  }
  
  // Hard button
  hard_mode = displayButtonSelect(new Vector2D_f(width/2 + 150, height/2 - 100), new Vector2D_f(100, 50), "Hard Mode", 18, hard_mode, #8c0909);
  
  // Easy button
  hard_mode = !displayButtonSelect(new Vector2D_f(width/2 - 150, height/2 - 100), new Vector2D_f(100, 50), "Easy Mode", 18, !hard_mode, #1e8200);
  
  designing_level = displayButtonToggle(new Vector2D_f(width/2 + 150, height/2 + 150), new Vector2D_f(100, 50), "Design Mode", 14, designing_level, #1e8200);
  debug = displayButtonToggle(new Vector2D_f(width/2 - 150, height/2 + 150), new Vector2D_f(100, 50), "Debug Mode", 14, debug, #1e8200);
  // Title
  stroke(#ffffff);
  textSize(50);
  text("Tank Trouble", width/2, height/2 - 200);

}
