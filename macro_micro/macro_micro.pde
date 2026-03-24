import controlP5.*;

ControlP5 cp5;
ImageSequence faceImages;
ArrayList<Face> facesToUse;
int resizeDims = 100;

MosaicFace targetFace;
RegionMap regionMap;

int activeIndex = 0;
float rotX = 0;
float rotY = 0;
float zoom = 3.0f;
float defaultEyeZ;
float currentEyeZ;

float ringRotationAngle = 0.0f;

ArrayList<ArrayList<Integer>> regionToVertices;
int[] regionAssignments;
float[] drawIndices;

float scanSpeed = 0.40f;
int beamTailLength = 5;
int shiftOffset = 0;
float beamAlpha = 80.0f;

int numFacesConfig = 50;

float aberrationOffset = 3.0f;

boolean effectActive = false;

float currentRingRadius = 600.0f;
float startRingRadius = 600.0f;
float stopRingRadius = 1000.0f;
float rateRingRadius = 0.05f;

float currentBackgroundZ = -800.0f;
float startBackgroundZ = -800.0f;
float stopBackgroundZ = -1500.0f;
float rateBackgroundZ = 0.05f;

float currentBackgroundDim = 0.28f;
float startBackgroundDim = 0.28f;
float stopBackgroundDim = 0.8f;
float rateBackgroundDim = 0.05f;

float currentRingRotSpeed = 0.005f;
float startRingRotSpeed = 0.005f;
float stopRingRotSpeed = 0.02f;
float rateRingRotSpeed = 0.05f;

ArrayList<PImage> originalImages;
ArrayList<PImage> aberratedImages;
ArrayList<PImage> displayImages;

void setup() {
    size(1920, 1080, P3D);
    textureMode(NORMAL);
    defaultEyeZ = (height / 2.0f) / tan(PI * 30.0f / 180.0f);
    frameRate(60);

    cp5 = new ControlP5(this);
    cp5.setAutoDraw(false);
    
    cp5.addSlider("scanSpeed").setPosition(20, 20).setRange(0.01f, 2.0f).setValue(0.40f);
    cp5.addSlider("beamTailLength").setPosition(20, 50).setRange(1, 50).setValue(5);
    cp5.addSlider("beamAlpha").setPosition(20, 80).setRange(10.0f, 255.0f).setValue(80.0f);
    cp5.addSlider("numFacesConfig").setPosition(20, 110).setRange(1, 100).setValue(50);
    cp5.addSlider("aberrationOffset").setPosition(20, 140).setRange(0.0f, 15.0f).setValue(3.0f).onChange(event -> applyAberrationEffect());

    cp5.addSlider("startRingRadius").setPosition(20, 170).setRange(100.0f, 1500.0f).setValue(600.0f);
    cp5.addSlider("stopRingRadius").setPosition(180, 170).setRange(100.0f, 1500.0f).setValue(1000.0f);
    cp5.addSlider("rateRingRadius").setPosition(340, 170).setRange(0.001f, 0.2f).setValue(0.05f);

    cp5.addSlider("startBackgroundZ").setPosition(20, 200).setRange(-3000.0f, 0.0f).setValue(-800.0f);
    cp5.addSlider("stopBackgroundZ").setPosition(180, 200).setRange(-3000.0f, 0.0f).setValue(-1500.0f);
    cp5.addSlider("rateBackgroundZ").setPosition(340, 200).setRange(0.001f, 0.2f).setValue(0.05f);

    cp5.addSlider("startRingRotSpeed").setPosition(20, 230).setRange(0.0f, 0.1f).setValue(0.005f);
    cp5.addSlider("stopRingRotSpeed").setPosition(180, 230).setRange(0.0f, 0.1f).setValue(0.02f);
    cp5.addSlider("rateRingRotSpeed").setPosition(340, 230).setRange(0.001f, 0.2f).setValue(0.05f);

    cp5.addSlider("startBackgroundDim").setPosition(20, 260).setRange(0.0f, 1.0f).setValue(0.28f);
    cp5.addSlider("stopBackgroundDim").setPosition(180, 260).setRange(0.0f, 1.0f).setValue(0.8f);
    cp5.addSlider("rateBackgroundDim").setPosition(340, 260).setRange(0.001f, 0.2f).setValue(0.05f);

    cp5.addButton("applyLayout").setPosition(20, 290).setSize(100, 20);

    faceImages = new ImageSequence(this);
    faceImages.loadImages("data/faces", "data/uv_maps");
    faceImages.scaleImages(resizeDims, resizeDims);

    PImage targetImg = createImage(resizeDims, resizeDims, ARGB);
    JSONArray targetUVs = new JSONArray();
    
    if (faceImages.faceImages.size() > 0) {
        for (int i = 0; i < faceImages.uvMaps.get(0).size(); i++) {
            JSONArray point = new JSONArray();
            JSONArray sourceUV = faceImages.uvMaps.get(0).getJSONArray(i);
            point.setFloat(0, sourceUV.getFloat(0));
            point.setFloat(1, sourceUV.getFloat(1));
            targetUVs.append(point);
        }
    }

    targetFace = new MosaicFace(targetImg, targetUVs, 0x00000000);
    targetFace.x = 0;
    targetFace.y = 0;
    targetFace.z = 200.0f;
    targetFace.loadMeshData(this, "data/animation_1.json", "data/triangles.json");

    aberratedImages = new ArrayList<PImage>();
    displayImages = new ArrayList<PImage>();

    applyLayout();
}

void applyLayout() {
    facesToUse = constructFaces(faceImages, numFacesConfig);
    
    originalImages = new ArrayList<PImage>();
    for (Face f : facesToUse) {
        originalImages.add(f.img);
    }

    updateFacePositions();
    
    for (Face f : facesToUse) {
        f.loadMeshData(this, "data/animation_1.json", "data/triangles.json");
        f.activate(); 
    }

    regionMap = new RegionMap(resizeDims, resizeDims, numFacesConfig);
    regionMap.generateVoronoi();

    regionAssignments = new int[regionMap.numRegions];
    for (int i = 0; i < regionMap.numRegions; i++) {
        regionAssignments[i] = (i + shiftOffset) % numFacesConfig;
    }

    regionToVertices = new ArrayList<ArrayList<Integer>>();
    for (int i = 0; i < regionMap.numRegions; i++) {
        regionToVertices.add(new ArrayList<Integer>());
    }

    for (int i = 0; i < targetFace.uvCoords.size(); i++) {
        float[] uv = targetFace.uvCoords.get(i);
        int px = constrain((int)(uv[0] * regionMap.width), 0, regionMap.width - 1);
        int py = constrain((int)(uv[1] * regionMap.height), 0, regionMap.height - 1);
        int rId = regionMap.map[px][py];
        regionToVertices.get(rId).add(i);
    }

    drawIndices = new float[numFacesConfig];
    for (int i = 0; i < numFacesConfig; i++) {
        drawIndices[i] = 0.0f;
    }

    applyAberrationEffect();
}

void applyAberrationEffect() {
    if (originalImages == null || originalImages.isEmpty()) return;

    aberratedImages.clear();
    int offset = (int)aberrationOffset;

    for (int i = 0; i < originalImages.size(); i++) {
        PImage orig = originalImages.get(i);
        PImage aberrated = orig.copy();
        orig.loadPixels();
        aberrated.loadPixels();
        
        for (int y = 0; y < orig.height; y++) {
            for (int x = 0; x < orig.width; x++) {
                int rX = constrain(x - offset, 0, orig.width - 1);
                int bX = constrain(x + offset, 0, orig.width - 1);
                
                int rIdx = rX + y * orig.width;
                int gIdx = x + y * orig.width;
                int bIdx = bX + y * orig.width;
                
                float r = red(orig.pixels[rIdx]);
                float g = green(orig.pixels[gIdx]);
                float b = blue(orig.pixels[bIdx]);
                
                aberrated.pixels[gIdx] = color(r, g, b);
            }
        }
        aberrated.updatePixels();
        aberratedImages.add(aberrated);
    }

    for (int i = 0; i < facesToUse.size(); i++) {
        facesToUse.get(i).img = aberratedImages.get(i);
    }
    targetFace.updateFromImages(getActiveImages(), regionMap, shiftOffset);

    generateDisplayImages();
}

void updateFacePositions() {
    int num_faces = facesToUse.size();
    float angleStep = TWO_PI / max(1, num_faces);
    
    for (int i = 0; i < num_faces; i++) {
        Face f = facesToUse.get(i);
        float angle = i * angleStep + ringRotationAngle;
        f.x = cos(angle) * currentRingRadius;
        f.y = sin(angle) * currentRingRadius;
        f.z = currentBackgroundZ;
    }
}

void draw() {
    background(20);

    float targetRingRadius = effectActive ? stopRingRadius : startRingRadius;
    currentRingRadius = lerp(currentRingRadius, targetRingRadius, rateRingRadius);

    float targetBackgroundZ = effectActive ? stopBackgroundZ : startBackgroundZ;
    currentBackgroundZ = lerp(currentBackgroundZ, targetBackgroundZ, rateBackgroundZ);

    float targetRingRotSpeed = effectActive ? stopRingRotSpeed : startRingRotSpeed;
    currentRingRotSpeed = lerp(currentRingRotSpeed, targetRingRotSpeed, rateRingRotSpeed);

    float targetBackgroundDim = effectActive ? stopBackgroundDim : startBackgroundDim;
    float prevBackgroundDim = currentBackgroundDim;
    currentBackgroundDim = lerp(currentBackgroundDim, targetBackgroundDim, rateBackgroundDim);

    if (abs(currentBackgroundDim - prevBackgroundDim) > 0.005f) {
        generateDisplayImages();
    }

    ringRotationAngle += currentRingRotSpeed;
    updateFacePositions();

    if (mousePressed && !cp5.isMouseOver()) {
        rotY += (mouseX - pmouseX) * 0.01;
        rotX += (mouseY - pmouseY) * 0.01;
    }

    currentEyeZ = zoom * defaultEyeZ;
    camera(width / 2.0f, height / 2.0f, currentEyeZ,
           width / 2.0f, height / 2.0f, 0,
           0, 1, 0);

    pushMatrix();
    translate(width / 2.0f, height / 2.0f, 0);
    rotateX(rotX);
    rotateY(rotY);

    for (int i = 0; i < facesToUse.size(); i++) {
        Face f = facesToUse.get(i);
        pushMatrix();
        translate(f.x, f.y, f.z);
        f.updateAnimation();
        
        f.img = displayImages.get(i);
        f.draw(this);
        f.img = aberratedImages.get(i);
        
        popMatrix();
    }

    pushMatrix();
    translate(targetFace.x, targetFace.y, targetFace.z);
    targetFace.updateAnimation();
    targetFace.draw(this);
    popMatrix();

    drawBeams();

    popMatrix();

    hint(DISABLE_DEPTH_TEST);
    camera();
    noLights();
    cp5.draw();
    hint(ENABLE_DEPTH_TEST);
}

void drawBeams() {
    strokeWeight(2);
    int num_faces = facesToUse.size();

    for (int regionId = 0; regionId < regionMap.numRegions; regionId++) {
        int faceIndex = regionAssignments[regionId];
        if (faceIndex >= num_faces) continue;

        Face bgFace = facesToUse.get(faceIndex);
        ArrayList<Integer> assignedVerts = regionToVertices.get(regionId);
        
        int totalVerts = assignedVerts.size();
        if (totalVerts == 0) continue;

        PImage sourceImg = aberratedImages.get(faceIndex);

        if (drawIndices[faceIndex] >= totalVerts) {
            drawIndices[faceIndex] = 0.0f;
        }

        for (int b = 0; b < beamTailLength; b++) {
            int offsetIndex = (((int)drawIndices[faceIndex] - b) % totalVerts + totalVerts) % totalVerts;

            int targetVertIndex = assignedVerts.get(offsetIndex);
            
            float[] targetVert = targetFace.currentFrameVertices.get(targetVertIndex);
            float[] targetUV = targetFace.uvCoords.get(targetVertIndex);

            float globalTargetX = targetFace.x + targetVert[0];
            float globalTargetY = targetFace.y + targetVert[1];
            float globalTargetZ = targetFace.z + targetVert[2];

            float[] bgVert = bgFace.currentFrameVertices.get(targetVertIndex);
            float bgVertX = bgFace.x + bgVert[0];
            float bgVertY = bgFace.y + bgVert[1];
            float bgVertZ = bgFace.z + bgVert[2];

            int texX = constrain((int)(targetUV[0] * sourceImg.width), 0, sourceImg.width - 1);
            int texY = constrain((int)(targetUV[1] * sourceImg.height), 0, sourceImg.height - 1);
            int c = sourceImg.pixels[texX + texY * sourceImg.width];

            float tailAlpha = map(b, 0, beamTailLength, beamAlpha, 0);
            stroke(c, tailAlpha);
            line(bgVertX, bgVertY, bgVertZ, globalTargetX, globalTargetY, globalTargetZ);
        }

        drawIndices[faceIndex] += scanSpeed;
    }
}

void generateDisplayImages() {
    displayImages.clear();
    for (int i = 0; i < facesToUse.size(); i++) {
        PImage base = aberratedImages.get(i);
        PImage stolen = base.copy();
        stolen.loadPixels();
        
        for (int x = 0; x < stolen.width; x++) {
            for (int y = 0; y < stolen.height; y++) {
                int mapX = constrain((int)map(x, 0, stolen.width, 0, regionMap.width - 1), 0, regionMap.width - 1);
                int mapY = constrain((int)map(y, 0, stolen.height, 0, regionMap.height - 1), 0, regionMap.height - 1);
                int rId = regionMap.map[mapX][mapY];
                
                if (regionAssignments[rId] != i) {
                    int idx = x + y * stolen.width;
                    int c = stolen.pixels[idx];
                    float g = (red(c) + green(c) + blue(c)) / 3.0f;
                    stolen.pixels[idx] = color(g * currentBackgroundDim); 
                }
            }
        }
        stolen.updatePixels();
        displayImages.add(stolen);
    }
}

ArrayList<Face> constructFaces(ImageSequence withLoadedFaces, int count) {
    ArrayList<Face> temp = new ArrayList<Face>();
    int loadedSize = withLoadedFaces.faceImages.size();
    
    if (loadedSize == 0) return temp;

    for (int i = 0; i < count; i++) {
        int idx = i % loadedSize;
        PImage img = withLoadedFaces.faceImages.get(idx);
        
        JSONArray uv = new JSONArray();
        if (idx < withLoadedFaces.uvMaps.size()) {
            uv = withLoadedFaces.uvMaps.get(idx);
        }
        temp.add(new Face(img, uv));
    }
    return temp;
}

ArrayList<PImage> getActiveImages() {
    ArrayList<PImage> activeImages = new ArrayList<PImage>();
    for (Face f : facesToUse) {
        activeImages.add(f.img);
    }
    return activeImages;
}

void keyPressed() {
    if (key == 't') { effectActive = !effectActive; }
    if (key == 'o') { zoom *= 1.1; }
    if (key == 'p') { zoom *= 0.9; }
    if (key == 's') { 
        shiftOffset++;
        for (int i = 0; i < regionMap.numRegions; i++) {
            regionAssignments[i] = (i + shiftOffset) % facesToUse.size();
        }
        targetFace.updateFromImages(getActiveImages(), regionMap, shiftOffset);
        generateDisplayImages();
    }
}
