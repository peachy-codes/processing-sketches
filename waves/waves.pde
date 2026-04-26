MeshSystem activeMesh; 
ArrayList<MeshSystem> meshes;
ArrayList<MusicPulseModifier> modifiers;
MeshRenderer renderer;
InteractionStrategy interaction;
BeatDetector beatDetector;

float angleX = 0;
float angleY = 0;

void setup() {
  size(1200, 800, P3D); 

  MeshFactory factory = new MeshFactory();
  renderer = new DefaultRenderer();
  meshes = new ArrayList<MeshSystem>();
  modifiers = new ArrayList<MusicPulseModifier>();
  
  float totalWidth = (Settings.MESH_COLS - 1) * Settings.MESH_SPACING_X;
  float totalDepth = (Settings.MESH_ROWS - 1) * Settings.MESH_SPACING_Z;
  float startXOffset = -totalWidth / 2f;
  float startZOffset = -totalDepth / 2f;

  for (int i = 0; i < Settings.MESH_COLS; i++) {
    for (int j = 0; j < Settings.MESH_ROWS; j++) {
      float offsetX = startXOffset + i * Settings.MESH_SPACING_X;
      float offsetZ = startZOffset + j * Settings.MESH_SPACING_Z;
      
      MeshSystem mesh = factory.createRectangularGrid(
        Settings.GRID_COLS, 
        Settings.GRID_ROWS, 
        Settings.GRID_SPACING, 
        Settings.DEFAULT_STIFFNESS,
        offsetX,
        offsetZ
      );
      meshes.add(mesh);

      // Add a music-driven modifier to the center of each mesh
      int gridCenterX = Settings.GRID_COLS / 2;
      int gridCenterY = Settings.GRID_ROWS / 2;
      Node centerNode = mesh.getNodeAt(gridCenterX, gridCenterY);
      
      MusicPulseModifier mod = new MusicPulseModifier(centerNode.pos, new PVector(0, -1, 0));
      mesh.addModifier(centerNode, mod);
      modifiers.add(mod);
    }
  }

  interaction = new DragInteraction(meshes);
  beatDetector = new BeatDetector(this);
}

void draw() {
  background(Settings.BACKGROUND_COLOR);

  beatDetector.update();
  
  // Random Walk Logic for each mesh
  if (Settings.RANDOM_WALK_ENABLED && frameCount % Settings.RANDOM_WALK_INTERVAL == 0) {
    for (int i = 0; i < meshes.size(); i++) {
      performRandomWalk(meshes.get(i), modifiers.get(i));
    }
  }

  lights();

  translate(width/2, height/2, Settings.CAMERA_Z);
  rotateX(QUARTER_PI + angleX);
  rotateY(angleY);

  long totalPhysicsTime = 0;
  
  for (MeshSystem mesh : meshes) {
    long startTime = System.nanoTime();
    mesh.update(frameCount);
    totalPhysicsTime += (System.nanoTime() - startTime);
    renderer.render(mesh);
  }
  
  Settings.LAST_PHYSICS_TIME_NS = totalPhysicsTime;

  // Instructions and Debug Window
  hint(DISABLE_DEPTH_TEST);
  camera();
  fill(255);
  int y = 20;
  text("Drag nodes with mouse. Use Arrow keys to rotate view.", 20, y); y += 20;
  text("Press 'C' to toggle color mode: " + getColorModeName(), 20, y); y += 20;
  text("Toggle: [N]odes | [E]dges | [S]urface", 20, y); y += 20;
  text("Freq: " + nf(Settings.OSC_FREQUENCY, 1, 3) + " (Use '[' and ']' to tune)", 20, y); y += 20;
  
  fill(0, 255, 0);
  text("FPS: " + nf(frameRate, 2, 1), 20, y); y += 20;
  text("Total Physics Time: " + (Settings.LAST_PHYSICS_TIME_NS / 1000000.0) + " ms", 20, y);
  
  hint(ENABLE_DEPTH_TEST);
}

void performRandomWalk(MeshSystem m, MusicPulseModifier mod) {
  Node currentNode = null;
  for (MeshSystem.ModifierEntry entry : m.modifiers) {
    if (entry.modifier == mod) {
      currentNode = entry.node;
      break;
    }
  }
  
  if (currentNode == null) return;
  
  ArrayList<Node> neighbors = new ArrayList<Node>();
  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      if (dx == 0 && dy == 0) continue;
      
      Node n = m.getNodeAt(currentNode.gridX + dx, currentNode.gridY + dy);
      if (n != null && !n.isPinned) {
        neighbors.add(n);
      }
    }
  }
  
  if (neighbors.size() > 0) {
    Node nextNode = neighbors.get((int)random(neighbors.size()));
    m.updateModifierNode(mod, nextNode);
  }
}

String getColorModeName() {
  switch(Settings.CURRENT_COLOR_MODE) {
    case Settings.COLOR_MODE_VELOCITY: return "Velocity";
    case Settings.COLOR_MODE_ACCELERATION: return "Acceleration";
    case Settings.COLOR_MODE_DISPLACEMENT: return "Displacement";
    default: return "Static";
  }
}

void mousePressed() {
  interaction.mousePressed(mouseX, mouseY, mouseButton);
}

void mouseDragged() {
  interaction.mouseDragged(mouseX, mouseY, pmouseX, pmouseY, mouseButton);
}

void mouseReleased() {
  interaction.mouseReleased(mouseButton);
}

void stop() {
  beatDetector.stop();
  super.stop();
}

void keyPressed() {
  if (key == 'c' || key == 'C') {
    Settings.CURRENT_COLOR_MODE = (Settings.CURRENT_COLOR_MODE + 1) % 4;
  }
  if (key == 'n' || key == 'N') Settings.DRAW_NODES = !Settings.DRAW_NODES;
  if (key == 'e' || key == 'E') Settings.DRAW_EDGES = !Settings.DRAW_EDGES;
  if (key == 's' || key == 'S') Settings.DRAW_SURFACE = !Settings.DRAW_SURFACE;
  
  if (key == '[') Settings.OSC_FREQUENCY = max(0, Settings.OSC_FREQUENCY - Settings.FREQUENCY_STEP);
  if (key == ']') Settings.OSC_FREQUENCY += Settings.FREQUENCY_STEP;
  
  if (keyCode == UP) angleX -= Settings.ROTATION_SPEED;
  if (keyCode == DOWN) angleX += Settings.ROTATION_SPEED;
  if (keyCode == LEFT) angleY -= Settings.ROTATION_SPEED;
  if (keyCode == RIGHT) angleY += Settings.ROTATION_SPEED;
}
