interface InteractionStrategy {
  void mousePressed(float mx, float my, int button);
  void mouseDragged(float mx, float my, float pmx, float pmy, int button);
  void mouseReleased(int button);
}

class DragInteraction implements InteractionStrategy {
  ArrayList<MeshSystem> meshes;
  Node activeNode = null;
  
  DragInteraction(ArrayList<MeshSystem> meshes) {
    this.meshes = meshes;
  }
  
  void mousePressed(float mx, float my, int button) {
    activeNode = null;
    float minDist = Settings.DRAG_THRESHOLD;
    
    for (MeshSystem sys : meshes) {
      Node n = sys.getClosestNode(mx, my, minDist);
      if (n != null) {
        activeNode = n;
        // The getClosestNode already checks against threshold, 
        // but we might want the absolute closest across all meshes.
        // For simplicity, first one found within threshold wins here.
        break; 
      }
    }
  }
  
  void mouseDragged(float mx, float my, float pmx, float pmy, int button) {
    if (activeNode != null) {
      // Simple dragging in 2D screen space mapped to 3D.
      // This is a bit tricky with 3D projection, but for now we'll just 
      // move it based on screen delta.
      float dx = mx - pmx;
      float dy = my - pmy;
      
      // Rough approximation: move in X and Y (world space) based on screen movement.
      // A better way would be raycasting, but this is a simple starting point.
      activeNode.pos.x += dx;
      activeNode.pos.y += dy;
      
      // We also update oldPos to avoid massive velocity injection unless desired.
      activeNode.oldPos.set(activeNode.pos);
    }
  }
  
  void mouseReleased(int button) {
    activeNode = null;
  }
}
