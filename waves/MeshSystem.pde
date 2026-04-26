import java.util.ArrayList;
import java.util.Iterator;

class MeshSystem {
  ArrayList<Node> nodes;
  ArrayList<Constraint> constraints;
  ArrayList<ModifierEntry> modifiers;
  ArrayList<int[]> faces;
  
  class ModifierEntry {
    Node node;
    Modifier modifier;
    ModifierEntry(Node n, Modifier m) {
      this.node = n;
      this.modifier = m;
    }
  }
  
  MeshSystem() {
    nodes = new ArrayList<Node>();
    constraints = new ArrayList<Constraint>();
    modifiers = new ArrayList<ModifierEntry>();
    faces = new ArrayList<int[]>();
  }
  
  void addNode(Node n) {
    nodes.add(n);
  }
  
  void addConstraint(Constraint c) {
    constraints.add(c);
  }
  
  void addFace(int i1, int i2, int i3) {
    faces.add(new int[]{i1, i2, i3});
  }
  
  void addModifier(Node n, Modifier m) {
    modifiers.add(new ModifierEntry(n, m));
  }
  
  void updateModifierNode(Modifier m, Node newNode) {
    for (ModifierEntry entry : modifiers) {
      if (entry.modifier == m) {
        entry.node = newNode;
        // If the modifier is a MusicPulseModifier, it might need the new basePos
        if (m instanceof MusicPulseModifier) {
          ((MusicPulseModifier)m).basePos = newNode.pos.copy();
        }
        break;
      }
    }
  }
  
  Node getNodeAt(int gx, int gy) {
    if (gx < 0 || gx >= Settings.GRID_COLS || gy < 0 || gy >= Settings.GRID_ROWS) return null;
    // This assumes nodes were added in standard grid order by MeshFactory
    int idx = gx * Settings.GRID_ROWS + gy;
    if (idx >= 0 && idx < nodes.size()) {
      Node n = nodes.get(idx);
      if (n.gridX == gx && n.gridY == gy) return n;
    }
    
    // Fallback: search (less efficient)
    for (Node n : nodes) {
      if (n.gridX == gx && n.gridY == gy) return n;
    }
    return null;
  }
  
  void update(int time) {
    // 1. Inertia Pass
    for (Node n : nodes) {
      n.update();
    }
    
    // 2. Animation Pass
    for (ModifierEntry entry : modifiers) {
      entry.modifier.apply(entry.node, time);
    }
    
    // 3. Constraint Pass
    for (int i = 0; i < Settings.CONSTRAINT_ITERATIONS; i++) {
      for (Constraint c : constraints) {
        c.resolve();
      }
    }
    
    // 4. Culling Pass
    Iterator<Constraint> it = constraints.iterator();
    while (it.hasNext()) {
      if (it.next().isBroken()) {
        it.remove();
      }
    }
  }
  
  color getNodeColor(Node n) {
    float val = 0;
    color low = color(50, 50, 150);
    color high = color(255, 100, 100);
    
    switch(Settings.CURRENT_COLOR_MODE) {
      case Settings.COLOR_MODE_VELOCITY:
        val = n.getVelocity() * Settings.VELOCITY_SCALE;
        break;
      case Settings.COLOR_MODE_ACCELERATION:
        val = n.lastAccelMag * Settings.ACCELERATION_SCALE;
        break;
      case Settings.COLOR_MODE_DISPLACEMENT:
        val = PVector.dist(n.pos, n.originPos) * Settings.DISPLACEMENT_SCALE;
        break;
      default:
        return color(100, 150, 255, 150);
    }
    
    return lerpColor(low, high, constrain(val, 0, 1));
  }
  
  Node getClosestNode(float mx, float my, float threshold) {
    Node closest = null;
    float minDist = threshold;
    
    for (Node n : nodes) {
      float d = dist(mx, my, n.sx, n.sy);
      if (d < minDist) {
        minDist = d;
        closest = n;
      }
    }
    return closest;
  }
}
