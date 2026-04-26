static class Settings {
  // Physics Constants
  static float GRAVITY = 0.01f;
  static float FRICTION = 0.99f;
  static int CONSTRAINT_ITERATIONS = 5;
  static float DEFAULT_STIFFNESS = 0.9f;
  static float DEFAULT_STRETCH_LIMIT = -1f; // -1 means unbreakable
  
  // Mesh Generation
  static int GRID_COLS = 30;
  static int GRID_ROWS = 30;
  static float GRID_SPACING = 2f;
  
  // Oscillator & Music Pulse Settings
  static float OSC_AMPLITUDE = 50.0f;
  static float OSC_FREQUENCY = 0.1f;
  static float FREQUENCY_STEP = 0.005f;
  static float BEAT_MAGNITUDE_SCALE = 500.0f;
  static float OSC_DECAY_RATE = 0.85f;
  
  // Random Walk Settings
  static int RANDOM_WALK_INTERVAL = 3;
  static boolean RANDOM_WALK_ENABLED = true;
  
  // Multi-Mesh Settings
  static int MESH_COLS = 8;
  static int MESH_ROWS = 8;
  static float MESH_SPACING_X = 60.0f;
  static float MESH_SPACING_Z = 60.0f;

  
  // Audio Settings
  static float MIN_AUDIO_THRESHOLD = 0.1f;
  static int BEAT_SENSITIVITY = 10;
  
  // Performance Tracking
  static long LAST_PHYSICS_TIME_NS = 0;
  
  // Interaction & View
  static float ROTATION_SPEED = 0.05f;
  static float CAMERA_Z = -200;
  static float DRAG_THRESHOLD = 20.0f;
  
  // Visuals
  static int BACKGROUND_COLOR = 255;
  static int NODE_COLOR = 200;
  static int CONSTRAINT_COLOR = 100;
  
  static boolean DRAW_NODES = false;
  static boolean DRAW_EDGES = false;
  static boolean DRAW_SURFACE = true;
  
  // Coloring Modes
  static final int COLOR_MODE_STATIC = 0;
  static final int COLOR_MODE_VELOCITY = 1;
  static final int COLOR_MODE_ACCELERATION = 2;
  static final int COLOR_MODE_DISPLACEMENT = 3;
  static int CURRENT_COLOR_MODE = COLOR_MODE_VELOCITY;
  
  // Color Scaling (Adjust these based on simulation scale)
  static float VELOCITY_SCALE = 5.0f;
  static float ACCELERATION_SCALE = 2.0f;
  static float DISPLACEMENT_SCALE = 0.05f;
}
