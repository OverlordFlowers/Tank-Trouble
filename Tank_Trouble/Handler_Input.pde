// User input
boolean[] key_pressed = new boolean[5];
boolean[] mouse_pressed = new boolean[2];

// Keyboard presses
void keyPressed() {
  if (key == 'w') {
    key_pressed[0] = true;
  }
  
  if (key == 'a') {
    key_pressed[1] = true;
  }
  
  if (key == 's') {
    key_pressed[2] = true;
  }
  
  if (key == 'd') {
    key_pressed[3] = true;
  }
  
  if (keyCode == SHIFT) {
    key_pressed[4] = true;
  }
}

// Key released
void keyReleased() {
  if (key == 'w') {
    key_pressed[0] = false;
  }
  
  if (key == 'a') {
    key_pressed[1] = false;
  }
  
  if (key == 's') {
    key_pressed[2] = false;
  }
  
  if (key == 'd') {
    key_pressed[3] = false;
  }
  
  if (keyCode == SHIFT) {
    key_pressed[4] = false;
  }
}

// Which button was pressed?
void mousePressed() {
  // check through clickable entities to see if a menu item was clicked, else default to shoot
  if (mouseButton == LEFT) {
    mouse_pressed[0] = true;
  }
  
  if (mouseButton == RIGHT) {
    mouse_pressed[1] = true;
  }
}

// Which button was pressed?
void mouseReleased() {
  // check through clickable entities to see if a menu item was clicked, else default to shoot
  if (mouseButton == LEFT) {
    mouse_pressed[0] = false;
  }
  
  if (mouseButton == RIGHT) {
    mouse_pressed[1] = false;
  }
}

// Displays a button that is highlighted and returns true when pressed.
boolean displayButton(Vector2D_f pos, Vector2D_f dimensions, String display_text, int text_size) {
  rectMode(CENTER);
  stroke(#000000);
  // If mouse is within these dimensions,
  if (pos.x - dimensions.x / 2 <= mouseX && mouseX <= pos.x + dimensions.x / 2 && pos.y - dimensions.y / 2 <= mouseY && mouseY <= pos.y + dimensions.y / 2) {
    // return true that the button was pressed.
    if (mouse_pressed[0]) {
      mouse_pressed[0] = false;
      return true;
    }
    fill(#606060);
  } else {
    fill(#000000);
  }
  // Draw rectangle containing the text.
  rect(pos.x, pos.y, dimensions.x, dimensions.y);
  
  fill(#ffffff);
  textAlign(CENTER, CENTER);
  textSize(text_size);
  text(display_text, pos.x, pos.y);
  
  return false;
}

// Used to toggle a state.
boolean displayButtonToggle(Vector2D_f pos, Vector2D_f dimensions, String display_text, int text_size, boolean toggle, int toggle_color) {
  rectMode(CENTER);
  stroke(#000000);
  // Toggles the bool if the button is pressed.
  if (pos.x - dimensions.x / 2 <= mouseX && mouseX <= pos.x + dimensions.x / 2 && pos.y - dimensions.y / 2 <= mouseY && mouseY <= pos.y + dimensions.y / 2) {
    if (mouse_pressed[0]) {
      mouse_pressed[0] = false;
      return !toggle;
    }
    fill(#606060);
  } else {
    if (toggle) {
      fill(toggle_color);
    } else {
      fill(#000000);
    }
  }
  
    // Draw rectangle containing the text.
  rect(pos.x, pos.y, dimensions.x, dimensions.y);
  
  fill(#ffffff);
  textAlign(CENTER, CENTER);
  textSize(text_size);
  text(display_text, pos.x, pos.y);
  
  return toggle;
}

// Used to select a state.
boolean displayButtonSelect(Vector2D_f pos, Vector2D_f dimensions, String display_text, int text_size, boolean select, int select_color) {
  rectMode(CENTER);
  stroke(#000000);
  // Denotes if the button is selected. If pressed, select this button.
  if (pos.x - dimensions.x / 2 <= mouseX && mouseX <= pos.x + dimensions.x / 2 && pos.y - dimensions.y / 2 <= mouseY && mouseY <= pos.y + dimensions.y / 2) {
    if (mouse_pressed[0]) {
      mouse_pressed[0] = false;
      return select ? select : !select;
    }
    fill(#606060);
  } else {
    if (select) {
      fill(select_color);
    } else {
      fill(#000000);
    }
  }
  
  // Draw rectangle containing the text.
  rect(pos.x, pos.y, dimensions.x, dimensions.y);
  
  fill(#ffffff);
  textAlign(CENTER, CENTER);
  textSize(text_size);
  text(display_text, pos.x, pos.y);
  
  return select;
}
