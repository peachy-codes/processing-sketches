ImageSequence faceImages;
ArrayList<Face> facesToUse;
int resizeDims = 100;
PImage currentFrame = null;
boolean goToNextImage = false;
boolean mosaicEffectActive = false;
Grid faceGrid;
int gridN = 5;
int gridM = 5;
float gridW = 200.0f;

MosaicFace targetFace;
RegionMap regionMap;

int activeIndex = 0;
float rotX = 0;
float rotY = PI/5;
float zoom = 3.0f;
float defaultEyeZ;
float currentEyeZ;

void setup() {
    size(600, 600, P3D);
    textureMode(NORMAL);
    defaultEyeZ = (height/2.0f) / tan(PI*30.0f / 180.0f);

    frameRate(60);

    faceImages = new ImageSequence(this);
    faceImages.loadImages("data/faces", "data/uv_maps");
    faceImages.scaleImages(resizeDims,resizeDims);
    facesToUse = constructFaces(faceImages);
    
    faceGrid = new Grid(gridN, gridM, gridW, facesToUse);
    faceGrid.buildGrid();

    for (int i = 0; i < faceGrid.constructedFaceArray.size(); i++) {
        faceGrid.constructedFaceArray.get(i).loadMeshData(this, "data/animation_1.json", "data/triangles.json");
    }
    
    PImage targetImg = createImage(resizeDims, resizeDims, ARGB);
    
    JSONArray targetUVs = new JSONArray();

    if (facesToUse.size() > 0) {
        for (float[] uv : facesToUse.get(0).uvCoords) {
            JSONArray point = new JSONArray();
            point.setFloat(0, uv[0]);
            point.setFloat(1, uv[1]);
            targetUVs.append(point);
        }
    }
    
    targetFace = new MosaicFace(targetImg, targetUVs, 0x00000000);
    targetFace.x = 0; 
    targetFace.y = 0;
    targetFace.z = 800;
    
    targetFace.loadMeshData(this, "data/animation_1.json", "data/triangles.json");

    regionMap = new RegionMap(resizeDims, resizeDims, 10);
    regionMap.generateVoronoi();

    targetFace.updateFromGrid(faceGrid, regionMap,0);
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

    for (int i = 0; i < num_faces; i ++) {
        Face f = faceGrid.constructedFaceArray.get(i);
        pushMatrix();
        translate(f.x, f.y, f.z);
        
        f.updateAnimation();
        
        if (f.active && f.currentFrameVertices.size() > 0) {
            pushStyle();
            noStroke();
            fill(255);
            beginShape(TRIANGLES);
            texture(f.img);
            for (int[] tri : f.triangles) {
                for (int j = 0; j < 3; j++) {
                    int idx = tri[j];
                    float[] v = f.currentFrameVertices.get(idx);
                    float[] uv = f.uvCoords.get(idx);
                    vertex(v[0], v[1], v[2], uv[0], uv[1]);
                }
            }
            endShape();
            popStyle();
        } else {
            image(f.img, 0, 0);
        }
        
        popMatrix(); 
    }
    
    pushMatrix();
    translate(targetFace.x, targetFace.y, targetFace.z);
    
    targetFace.updateAnimation();
    if (faceGrid.activeIndices.size() > 0) {
      int currentShift = frameCount / 30;
      targetFace.updateFromGrid(faceGrid, regionMap, currentShift);
    }
    if (targetFace.currentFrameVertices.size() > 0) {
        pushStyle();
        noStroke();
        fill(255);
        beginShape(TRIANGLES);
        texture(targetFace.img);
        for (int[] tri : targetFace.triangles) {
            for (int j = 0; j < 3; j++) {
                int idx = tri[j];
                float[] v = targetFace.currentFrameVertices.get(idx);
                float[] uv = targetFace.uvCoords.get(idx);
                vertex(v[0], v[1], v[2], uv[0], uv[1]);
            }
        }
        endShape();
        popStyle();
    } else {
        image(targetFace.img, 0, 0);
    }
    
    pushStyle();
    noFill();
    stroke(0xFF0000AA);
    strokeWeight(1);
    rect(0, 0, targetFace.img.width, targetFace.img.height);
    popStyle();
    
    popMatrix();   
    popMatrix();

    if (mosaicEffectActive) {
      mosaicEffect();
    }
}

ArrayList<Face> constructFaces(ImageSequence withLoadedFaces) {
    ArrayList<Face> temp = new ArrayList<Face>();
    int num_faces = withLoadedFaces.faceImages.size();
    for (int i = 0; i < num_faces; i++) {
        PImage img = withLoadedFaces.getNextImage();
        JSONArray uv = withLoadedFaces.getNextUV();
        temp.add(new Face(img, uv));
    }
    return temp;
}

void activateRandomFace() {
    faceGrid.deactivate(activeIndex);
    activeIndex = (int)random(0, faceGrid.constructedFaceArray.size());
    faceGrid.activate(activeIndex);
    targetFace.updateFromGrid(faceGrid, regionMap, frameCount / 30);
}

void activateRandomFaces() {
    int num_generated = (int)random(0, gridN*gridM);
    for (int count = 0; count < num_generated; count ++) {
        int idx = (int)random(0,gridN*gridM);
        faceGrid.activate(idx);
    }
    targetFace.updateFromGrid(faceGrid, regionMap, frameCount / 30);
}

void deactivateAllFaces() {
    faceGrid.deactivateAll();
    targetFace.updateFromGrid(faceGrid, regionMap, frameCount / 30);
}

void mosaicEffect() {
    int randomIdx = (int)random(0, faceGrid.constructedFaceArray.size());
    faceGrid.activate(randomIdx);
    targetFace.updateFromGrid(faceGrid, regionMap, frameCount / 30);
}

void keyPressed() {
    if (key == ' ') {mosaicEffectActive = !mosaicEffectActive;}
    if (key == 'r') {mosaicEffect();}
    if (key == 'd') {deactivateAllFaces();}
    if (key == 'o') {zoom *= 1.1;}
    if (key == 'p') {zoom *= 0.9;}
}
