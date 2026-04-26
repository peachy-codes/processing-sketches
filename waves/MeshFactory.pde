class MeshFactory {
  
  MeshSystem createRectangularGrid(int cols, int rows, float spacing, float stiffness, float offsetX, float offsetZ) {
    MeshSystem sys = new MeshSystem();
    Node[][] grid = new Node[cols][rows];
    
    float startX = (-(cols - 1) * spacing / 2f) + offsetX;
    float startZ = (-(rows - 1) * spacing / 2f) + offsetZ;
    
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        boolean pinned = (i == 0 || i == cols - 1 || j == 0 || j == rows - 1);
        grid[i][j] = new Node(startX + i * spacing, 0, startZ + j * spacing, pinned);
        grid[i][j].setGridPos(i, j);
        sys.addNode(grid[i][j]);
      }
    }
    
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        if (i < cols - 1) {
          sys.addConstraint(new SpringConstraint(grid[i][j], grid[i+1][j], stiffness, Settings.DEFAULT_STRETCH_LIMIT));
        }
        if (j < rows - 1) {
          sys.addConstraint(new SpringConstraint(grid[i][j], grid[i][j+1], stiffness, Settings.DEFAULT_STRETCH_LIMIT));
        }
        // Diagonal constraints for stability
        if (i < cols - 1 && j < rows - 1) {
          sys.addConstraint(new SpringConstraint(grid[i][j], grid[i+1][j+1], stiffness, Settings.DEFAULT_STRETCH_LIMIT));
          sys.addConstraint(new SpringConstraint(grid[i+1][j], grid[i][j+1], stiffness, Settings.DEFAULT_STRETCH_LIMIT));
          
          // Add faces
          int idx1 = i * rows + j;
          int idx2 = (i + 1) * rows + j;
          int idx3 = i * rows + (j + 1);
          int idx4 = (i + 1) * rows + (j + 1);
          sys.addFace(idx1, idx2, idx4);
          sys.addFace(idx1, idx4, idx3);
        }
      }
    }
    
    return sys;
  }
  
  MeshSystem createCircularMesh(int rings, int segments, float radius, float stiffness) {
    MeshSystem sys = new MeshSystem();
    Node[][] nodes = new Node[rings][segments];
    
    for (int r = 0; r < rings; r++) {
      float currentRadius = (r / (float)(rings - 1)) * radius;
      boolean pinned = (r == rings - 1);
      
      for (int s = 0; s < segments; s++) {
        float angle = TWO_PI * s / segments;
        float x = cos(angle) * currentRadius;
        float z = sin(angle) * currentRadius;
        
        nodes[r][s] = new Node(x, 0, z, pinned);
        sys.addNode(nodes[r][s]);
      }
    }
    
    for (int r = 0; r < rings; r++) {
      for (int s = 0; s < segments; s++) {
        // Radial connection
        if (r < rings - 1) {
          sys.addConstraint(new SpringConstraint(nodes[r][s], nodes[r+1][s], stiffness, Settings.DEFAULT_STRETCH_LIMIT));
        }
        // Circular connection
        int nextS = (s + 1) % segments;
        sys.addConstraint(new SpringConstraint(nodes[r][s], nodes[r][nextS], stiffness, Settings.DEFAULT_STRETCH_LIMIT));
        
        // Diagonal for stability
        if (r < rings - 1) {
          sys.addConstraint(new SpringConstraint(nodes[r][s], nodes[r+1][nextS], stiffness, Settings.DEFAULT_STRETCH_LIMIT));
          
          // Add faces
          int idx1 = r * segments + s;
          int idx2 = (r + 1) * segments + s;
          int idx3 = r * segments + nextS;
          int idx4 = (r + 1) * segments + nextS;
          sys.addFace(idx1, idx2, idx4);
          sys.addFace(idx1, idx4, idx3);
        }
      }
    }
    
    return sys;
  }
}
