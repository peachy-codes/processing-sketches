interface MeshRenderer {
  void render(MeshSystem sys);
}

class DefaultRenderer implements MeshRenderer {
  
  void render(MeshSystem sys) {
    if (Settings.DRAW_SURFACE) {
      renderSurface(sys);
    }
    
    if (Settings.DRAW_EDGES) {
      renderEdges(sys);
    }
    
    if (Settings.DRAW_NODES) {
      renderNodes(sys);
    }
  }
  
  private void renderSurface(MeshSystem sys) {
    noStroke();
    beginShape(TRIANGLES);
    for (int[] face : sys.faces) {
      if (face.length == 3) {
        Node n1 = sys.nodes.get(face[0]);
        Node n2 = sys.nodes.get(face[1]);
        Node n3 = sys.nodes.get(face[2]);
        
        fill(sys.getNodeColor(n1));
        vertex(n1.pos.x, n1.pos.y, n1.pos.z);
        fill(sys.getNodeColor(n2));
        vertex(n2.pos.x, n2.pos.y, n2.pos.z);
        fill(sys.getNodeColor(n3));
        vertex(n3.pos.x, n3.pos.y, n3.pos.z);
      }
    }
    endShape();
  }
  
  private void renderEdges(MeshSystem sys) {
    stroke(Settings.CONSTRAINT_COLOR);
    strokeWeight(1);
    for (Constraint c : sys.constraints) {
      c.display();
    }
  }
  
  private void renderNodes(MeshSystem sys) {
    for (Node n : sys.nodes) {
      n.display();
    }
  }
}
