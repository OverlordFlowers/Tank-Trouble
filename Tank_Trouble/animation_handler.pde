// Only one animation is used
PImage animation_explosion;

// Loads the animation
void loadAnimations() {
  animation_explosion = loadImage("assets/effects/explosion.png");
  pushMatrix();
  translate(0, 0);
  image(animation_explosion, width/2, height/2);
  popMatrix();
}

// ANimation class
public class Animation {
  // position
  private Vector2D_f pos;
  // which frame it is in
  private int frame;
  // The number of frames
  private int frame_count;
  // Which image is the animation
  private PImage animation;
  
  // The height and width of the image
  private int animation_width;
  private int animation_height;
  
  Animation(Vector2D_f pos, PImage animation, int frame_count) {
    this.pos = pos.copy();
    this.animation = animation;
    this.frame = 0;
    this.frame_count = frame_count;
    
    animation_width = animation.width;
    animation_height = animation.height;
  }
  
  void display() {
    if (frame < frame_count) {
      // get section of the image to be displayed
      PImage animation_frame = animation.get(frame * animation_width / frame_count, 0, animation_width / frame_count, animation_height);
      // displays image at necessary position
      pushMatrix();
      translate(pos.x, pos.y);
      image(animation_frame, 0, 0);
      popMatrix();
      
      // Increment the frame if the overall frame is divisible by 2.
      if (frameCount % 2 == 0) {
        frame++;
      }
    } else {
      // Once frames > frame_count, delete this animation.
      game.to_remove_animation_list.add(this);
    }
  }
}
