// this exists as a test project for creating the wall of faces object for the many-to-one exhibit


// wall_of_faces.pde


// 2-23
// Grid of faces, can randomly activate. activating simply moves z at this moment
// TODO: 1) activePixels, 2A) Emitter class, 2B) Target Class, 3) Beaming logic, 4) Random Pixels, 5) Random Pixel Region
// TODO: Mossaic Algorithm
// TODO: Mask mesh
// TODO: Global animation
// TODO: Random simulacra
// TODO: Face Capture
// TODO: Empty Face for wall
// TODO: Emotional requests
// 

ImageSequence faceImages;
ArrayList<Face> facesToUse;
int resizeDims = 100;
PImage currentFrame = null;
boolean goToNextImage = false;

Grid faceGrid;
int gridN = 5;
int gridM = 5;
float gridW = 200.0f;

int activeIndex = 0;

// camera 
float rotX = 0;
float rotY = PI/5;
float zoom = 3.0f;
float defaultEyeZ;
float currentEyeZ;

void setup() {
  size(600, 600, P3D);
  defaultEyeZ = (height/2.0f) / tan(PI*30.0f / 180.0f);

  frameRate(60);  
  faceImages = new ImageSequence(this);
  faceImages.loadImages("data/faces");
  faceImages.scaleImages(resizeDims,resizeDims);
  facesToUse = constructFaces(faceImages);
  
  faceGrid = new Grid(gridN, gridM, gridW, facesToUse);
  faceGrid.buildGrid();
  
}

void draw() {
  background(255);
  int num_faces = faceGrid.constructedFaceArray.size();
  if (mousePressed) {
    rotY += (mouseX - pmouseX) * 0.01;
    rotX += (mouseY - pmouseY) * 0.01;
  }
  currentEyeZ = zoom * defaultEyeZ;
  
  camera(width / 2.0f, height / 2.0f, currentEyeZ, 
         width / 2.0f, height / 2.0f, 0, 
         0, 1, 0);
   
  pushMatrix();
  
  translate(width / 2.0f, height / 2.0f, -100);
  rotateX(rotX);
  rotateY(rotY);
  for (int i =0; i < num_faces; i ++) {
    
    Face f = faceGrid.constructedFaceArray.get(i);

    pushMatrix();
    translate(f.x, f.y, f.z);
    image(f.img, 0, 0);       // Draws at the new origin
    popMatrix(); 
  }
  popMatrix();
}

ArrayList<Face> constructFaces(ImageSequence withLoadedFaces) {
  ArrayList<Face> temp = new ArrayList<Face>();
  int num_faces = withLoadedFaces.faceImages.size();
  for (int i = 0; i < num_faces; i++) {
    temp.add(new Face(this, withLoadedFaces.getNextImage()));
  }

return temp;
}

void activateRandomFace() {
  if (activeIndex >= 0 && activeIndex < faceGrid.constructedFaceArray.size()) {
    faceGrid.constructedFaceArray.get(activeIndex).deactivate();
    Integer obj = Integer.valueOf(activeIndex);
    faceGrid.activeIndices.remove(obj);
  }
  activeIndex = (int)random(0, faceGrid.constructedFaceArray.size());
  faceGrid.activate(activeIndex);
}

void activateRandomFaces() {
  int num_generated = (int)random(0, gridN*gridM);
  for (int count = 0; count < num_generated; count ++) {
    int idx = (int)random(0,gridN*gridM);
    faceGrid.activate(idx);
    }
    println(faceGrid.activeIndices);
}

void deactivateAllFaces() {
  faceGrid.deactivateAll();
}

void keyPressed() {
  if (key == ' ') {activateRandomFace();}
  if (key == 't') {activateRandomFaces();}
  if (key == 'd') {deactivateAllFaces();}
  if (key == 'o') {zoom *= 1.1;}
  if (key == 'p') {zoom *= 0.9;}
}
