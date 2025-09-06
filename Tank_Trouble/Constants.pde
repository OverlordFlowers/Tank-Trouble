// This is used to change the hitbox size. Enemies and players both have the same hitbox, but the player is a little smaller.
float tank_hitbox_height = 32.0f;
float tank_hitbox_length = 32.0f;
float player_tank_scale = 0.75f;

// Constants that modify parameters while in hard mode.
float hardmode_enemy_reload_scale = 0.8f;
float hardmode_enemy_health_scale = 1.4f;
float hardmode_enemy_speed_scale = 1.5f;

float hardmode_player_reload_scale = 1.2f;
float hardmode_player_health_scale = 0.6f;
float hardmode_player_dash_recharge_scale = 2.0f;

// How many levels are in the level pack.
// I could have made this differently, but that made the XML file unreadable, so a hard-coded max_level counter is used for now.
int max_levels = 10;

// Debug mode shows hitboxes, gives player invincibility, shows enemy targeting. Not accessible through menu.
boolean debug = false;

// This is used when designing a level, which can be done by modifying .xml files and changing the total number of levels in the Constants tab.
boolean designing_level = false;
