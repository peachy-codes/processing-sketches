//Grid.java


import java.util.ArrayList;

class Grid{
    int n,m;
    float w;
    ArrayList<Face> facesArray;
    ArrayList<Face> constructedFaceArray;
    ArrayList<Integer> activeIndices;


    public Grid(int n, int m, float w) {
        this.n = n;
        this.m = m;
        this.w = w;
        this.facesArray = new ArrayList<Face>();
        this.constructedFaceArray = new ArrayList<Face>();
        this.activeIndices = new ArrayList<Integer>();
    }

    public Grid(int n, int m, float w, ArrayList<Face> facesArray) {
        this.n = n;
        this.m = m;
        this.w = w;
        this.facesArray = facesArray;
        this.constructedFaceArray = new ArrayList<Face>();
        this.activeIndices = new ArrayList<Integer>();
    }

    // static

  public void deactivateAll() {
    for (int i : this.activeIndices) {
      this.constructedFaceArray.get(i).deactivate();

    }    this.activeIndices = new ArrayList<Integer>();

  }
  
  public void activate(int index) {
    if (!this.constructedFaceArray.get(index).active) {
    this.constructedFaceArray.get(index).activate();
    this.activeIndices.add(index);    
    }
  }
  
  public void deactivate(int index) {
    if (this.constructedFaceArray.get(index).active) {
      this.constructedFaceArray.get(index).deactivate();
      this.activeIndices.remove(Integer.valueOf(index));
    }
  }
  public void buildGrid() { 
    
    int num_source_faces = facesArray.size();
    ArrayList<Face> newGridFaces = new ArrayList<Face>();  
    float totalWidth = (n - 1) * w;
    float totalHeight = (m - 1) * w;
    
    float startX = -totalWidth / 2.0f;
    float startY = -totalHeight / 2.0f;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            int index = i + j * n;
          Face sourceFace = facesArray.get(index % num_source_faces);
          Face newFace = new Face(sourceFace.img);
          
          newFace.x = startX + (i * w);
          newFace.y = startY + (j * w);
          
          newGridFaces.add(newFace);
        }
      }
     this.constructedFaceArray = newGridFaces;
  }
    

    // instance
    
}
