class Node {
  PVector pos, oldPos, originPos;
  PVector acceleration;
  float lastAccelMag = 0;
  boolean isPinned;
  int gridX, gridY; // Grid coordinates for topology navigation
  
  float sx, sy; // Screen coordinates for picking
  
  Node(float x, float y, float z, boolean isPinned) {
    this.pos = new PVector(x, y, z);
    this.oldPos = new PVector(x, y, z);
    this.originPos = new PVector(x, y, z);
    this.acceleration = new PVector(0, 0, 0);
    this.isPinned = isPinned;
    this.gridX = -1;
    this.gridY = -1;
  }
  
  void setGridPos(int x, int y) {
    this.gridX = x;
    this.gridY = y;
  }
  
  void applyForce(PVector force) {
    if (!isPinned) {
      acceleration.add(force);
    }
  }
  
  void update() {
    if (isPinned) {
      lastAccelMag = 0;
      return;
    }
    
    // Apply gravity
    applyForce(new PVector(0, Settings.GRAVITY, 0));
    
    lastAccelMag = acceleration.mag();
    
    PVector velocity = PVector.sub(pos, oldPos);
    velocity.mult(Settings.FRICTION);
    
    PVector nextPos = PVector.add(pos, velocity);
    nextPos.add(acceleration);
    
    oldPos.set(pos);
    pos.set(nextPos);
    
    acceleration.set(0, 0, 0);
  }
  
  float getVelocity() {
    return PVector.dist(pos, oldPos);
  }
  
  void display() {
    // Project 3D to 2D screen coordinates
    sx = screenX(pos.x, pos.y, pos.z);
    sy = screenY(pos.x, pos.y, pos.z);
    
    stroke(Settings.NODE_COLOR);
    strokeWeight(4);
    point(pos.x, pos.y, pos.z);
  }
}
