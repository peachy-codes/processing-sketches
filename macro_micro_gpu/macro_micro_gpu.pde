import controlP5.*;
import java.io.File;

ControlP5 cp5;
ImageSequence faceImages;
ArrayList<Face> facesToUse;
int resizeDims = 600;

MosaicFace targetFace;
RegionMap regionMap;
int activeIndex = 0;
float rotX = 0;
float rotY = 0;
float zoom = 0.9f;
float defaultEyeZ;
float currentEyeZ;
float ringRotationAngle = 0.0f;

ArrayList<ArrayList<Integer>> regionToVertices;
int[] regionAssignments;
float[] drawIndices;

boolean loadConfigOnLaunch = true;
boolean effectActive = false;
volatile boolean isReady = false;
boolean isLoading = false;
boolean animateFaces = false;
boolean prevEffectActive = false;
float scanSpeed = 0.40f;
int beamTailLength = 5;
float beamAlpha = 80.0f;

int numFacesConfig = 50;

float currentNoiseScale = 0.005f;
float baseNoiseScale = 0.005f;
float activeNoiseScale = 0.01f;
float rateNoiseScale = 0.05f;
float emitterScale = 0.2f;

float currentRingRadius = 100.0f;
float baseRingRadius = 100.0f;
float activeRingRadius = 1500.0f;
float rateRingRadius = 0.01f;

float currentBackgroundZ = -6000.0f;
float baseBackgroundZ = -6000.0f;
float activeBackgroundZ = -1200.0f;
float rateBackgroundZ = 0.001f;

float currentBackgroundDim = 0.00f;
float baseBackgroundDim = 0.00f;
float activeBackgroundDim = 0.37f;
float rateBackgroundDim = 0.05f;

float currentRingRotSpeed = 0.0001f;
float baseRingRotSpeed = 0.0001f;
float activeRingRotSpeed = 0.001f;
float rateRingRotSpeed = 0.01f;
float shiftPhase = 0.0f;
int lastMillis = 0;

int lastShiftTime = 0;
float currentShiftInterval = 100.0f;
float baseShiftInterval = 100.0f;
float activeShiftInterval = 10.0f;
float rateShiftInterval = 0.05f;

ArrayList<PImage> originalImages;

JSONArray globalAnimationData;
JSONArray globalTriangleData;

PShader mosaicShader;
PImage regionMapTexture;

void setup() {
    pixelDensity(1);
    size(1200, 1200, P3D);
    textureMode(NORMAL);
    defaultEyeZ = (height / 2.0f) / tan(PI * 30.0f / 180.0f);
    frameRate(60);

    cp5 = new ControlP5(this);
    cp5.setAutoDraw(false);
    
    cp5.addSlider("scanSpeed").setPosition(20, 20).setRange(0.01f, 2.0f).setValue(0.40f);
    cp5.addSlider("beamTailLength").setPosition(20, 50).setRange(1, 50).setValue(5);
    cp5.addSlider("beamAlpha").setPosition(20, 80).setRange(10.0f, 255.0f).setValue(80.0f);
    cp5.addSlider("numFacesConfig").setPosition(20, 110).setRange(1, 100).setValue(50);

    cp5.addSlider("baseRingRadius").setPosition(20, 170).setRange(100.0f, 1500.0f).setValue(100.0f);
    cp5.addSlider("activeRingRadius").setPosition(180, 170).setRange(100.0f, 1500.0f).setValue(1500.0f);
    cp5.addSlider("rateRingRadius").setPosition(340, 170).setRange(0.001f, 0.2f).setValue(0.01f);

    cp5.addSlider("baseBackgroundZ").setPosition(20, 200).setRange(-6000.0f, 0.0f).setValue(-3000.0f);
    cp5.addSlider("activeBackgroundZ").setPosition(180, 200).setRange(-3000.0f, 0.0f).setValue(-1200.0f);
    cp5.addSlider("rateBackgroundZ").setPosition(340, 200).setRange(0.001f, 0.2f).setValue(0.001f);

    cp5.addSlider("baseRingRotSpeed").setPosition(20, 230).setRange(0.0f, 0.1f).setValue(0.0001f);
    cp5.addSlider("activeRingRotSpeed").setPosition(180, 230).setRange(0.0f, 0.1f).setValue(0.001f);
    cp5.addSlider("rateRingRotSpeed").setPosition(340, 230).setRange(0.001f, 0.2f).setValue(0.01f);

    cp5.addSlider("baseBackgroundDim").setPosition(20, 260).setRange(0.0f, 1.0f).setValue(0.00f);
    cp5.addSlider("activeBackgroundDim").setPosition(180, 260).setRange(0.0f, 1.0f).setValue(0.37f);
    cp5.addSlider("rateBackgroundDim").setPosition(340, 260).setRange(0.001f, 0.2f).setValue(0.05f);

    cp5.addSlider("baseShiftInterval").setPosition(20, 290).setRange(10.0f, 300.0f).setValue(100.0f);
    cp5.addSlider("activeShiftInterval").setPosition(180, 290).setRange(1.0f, 100.0f).setValue(10.0f);
    cp5.addSlider("rateShiftInterval").setPosition(340, 290).setRange(0.001f, 0.2f).setValue(0.05f);

    cp5.addSlider("baseNoiseScale").setPosition(20, 320).setRange(0.001f, 0.05f).setValue(0.005f).hide();
    cp5.addSlider("activeNoiseScale").setPosition(180, 320).setRange(0.001f, 0.05f).setValue(0.01f).hide();
    cp5.addSlider("rateNoiseScale").setPosition(340, 320).setRange(0.001f, 0.2f).setValue(0.05f).hide();
    
    cp5.addButton("applyLayout").setPosition(20, 350).setSize(100, 20);

    if (loadConfigOnLaunch) {
        File configFile = new File(sketchPath("data/config.json"));
        if (configFile.exists()) {
            cp5.loadProperties("data/config.json");
            currentRingRadius = baseRingRadius;
            currentBackgroundZ = baseBackgroundZ;
            currentRingRotSpeed = baseRingRotSpeed;
            currentBackgroundDim = baseBackgroundDim;
            currentShiftInterval = baseShiftInterval;
            currentNoiseScale = baseNoiseScale;
        }
    }
    setupShader();
}

void setupShader() {
    String[] fragSource = {
        "#ifdef GL_ES",
        "precision mediump float;",
        "precision mediump int;",
        "#endif",
        "uniform sampler2D texture;",
        "uniform sampler2D regionMapTex;",
        "uniform int regionAssignments[100];",
        "uniform int myFaceIndex;",
        "uniform float dimFactor;",
        "uniform bool isMosaicCenter;",
        "uniform vec2 texSize;",
        "varying vec4 vertColor;",
        "varying vec4 vertTexCoord;",
        "void main() {",
        "vec2 snappedUV = (floor(vertTexCoord.st * texSize) + 0.5) / texSize;",
        "vec4 texColor = texture2D(texture, vertTexCoord.st);",
        "vec4 regionColor = texture2D(regionMapTex, snappedUV);",
        "int rId = int(floor(regionColor.r * 255.0 + 0.5));",
        "if (rId >= 0 && rId < 100) {",
        "int assignedFace = regionAssignments[rId];",
        "if (assignedFace == myFaceIndex) {",
        "gl_FragColor = texColor;",
        "} else {",
        "if (isMosaicCenter) {",
        "discard;",
        "} else {",
        "float g = (texColor.r + texColor.g + texColor.b) / 3.0;",
        "gl_FragColor = vec4(g * dimFactor, g * dimFactor, g * dimFactor, texColor.a);",
        "}",
        "}",
        "} else {",
        "gl_FragColor = texColor;",
        "}",
        "}"
    };
    saveStrings("data/mosaic.glsl", fragSource);
    mosaicShader = loadShader("data/mosaic.glsl");
}

void initializeHeavyAssets() {
    try {
        globalAnimationData = loadJSONArray("data/animation_1.json");
        globalTriangleData = loadJSONArray("data/triangles.json");
    } catch (Exception e) {
        globalAnimationData = new JSONArray();
        globalTriangleData = new JSONArray();
    }

    faceImages = new ImageSequence(this);
    faceImages.loadImages("data/faces", "data/uv_maps", resizeDims, resizeDims);

    PImage targetImg = createImage(resizeDims, resizeDims, ARGB);
    JSONArray targetUVs = new JSONArray();

    if (faceImages.uvMaps != null && faceImages.uvMaps.size() > 0 && faceImages.uvMaps.get(0) != null) {
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
    targetFace.loadMeshData(globalAnimationData, globalTriangleData);

    applyLayout();
    isReady = true;
}

void applyLayout() {
    facesToUse = constructFaces(faceImages, numFacesConfig);
    
    originalImages = new ArrayList<PImage>();

    for (Face f : facesToUse) {
        originalImages.add(f.img);
    }

    updateFacePositions();

    for (Face f : facesToUse) {
        f.loadMeshData(globalAnimationData, globalTriangleData);
        f.activate();
    }

    regionMap = new RegionMap(this, resizeDims, resizeDims, numFacesConfig);
    regionMap.generateNoise(activeNoiseScale);

    regionAssignments = new int[regionMap.numRegions];

    for (int i = 0; i < regionMap.numRegions; i++) {
        regionAssignments[i] = 0;
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

    updateRegionTexture();
    applyShiftOffset();
}

void updateRegionTexture() {
    if (regionMapTexture == null || regionMapTexture.width != regionMap.width) {
        regionMapTexture = createImage(regionMap.width, regionMap.height, RGB);
    }
    regionMapTexture.loadPixels();
    for (int x = 0; x < regionMap.width; x++) {
        for (int y = 0; y < regionMap.height; y++) {
            int rId = regionMap.map[x][y];
            regionMapTexture.pixels[x + y * regionMap.width] = color(rId, 0, 0);
        }
    }
    regionMapTexture.updatePixels();
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
        f.rotationZ = angle + HALF_PI;
    }
}

void draw() {
    if (!isReady) {
        background(20);

        fill(255);
        textSize(24);
        textAlign(CENTER, CENTER);
        text("Loading JSON data and rendering layout...", width/2, height/2);

        if (!isLoading) {
            isLoading = true;
            thread("initializeHeavyAssets");
        }
        return; 
    }

    background(0);

    float targetRingRadius = effectActive ? activeRingRadius : baseRingRadius;
    currentRingRadius = lerp(currentRingRadius, targetRingRadius, rateRingRadius);

    float targetBackgroundZ = effectActive ? activeBackgroundZ : baseBackgroundZ;

    currentBackgroundZ = lerp(currentBackgroundZ, targetBackgroundZ, rateBackgroundZ);

    float targetRingRotSpeed = effectActive ? activeRingRotSpeed : baseRingRotSpeed;
    currentRingRotSpeed = lerp(currentRingRotSpeed, targetRingRotSpeed, rateRingRotSpeed);

    float targetShiftSpeed = 1.0f / (effectActive ? activeShiftInterval : baseShiftInterval);
    float currentShiftSpeed = 1.0f / currentShiftInterval;

    currentShiftSpeed = lerp(currentShiftSpeed, targetShiftSpeed, rateShiftInterval);
    currentShiftInterval = 1.0f / currentShiftSpeed;

    float targetBackgroundDim = effectActive ? activeBackgroundDim : baseBackgroundDim;

    float prevBackgroundDim = currentBackgroundDim;
    currentBackgroundDim = lerp(currentBackgroundDim, targetBackgroundDim, rateBackgroundDim);

    int currentMillis = millis();
    if (lastMillis == 0) lastMillis = currentMillis;
    int deltaMillis = currentMillis - lastMillis;
    lastMillis = currentMillis;

    shiftPhase += (deltaMillis / 33.33f) * currentShiftSpeed;

    if (shiftPhase >= 1.0f) {
        applyShiftOffset();
        shiftPhase = 0.0f;
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

    shader(mosaicShader);
    mosaicShader.set("regionMapTex", regionMapTexture);
    mosaicShader.set("regionAssignments", regionAssignments);
    mosaicShader.set("dimFactor", currentBackgroundDim);
    mosaicShader.set("texSize", (float)resizeDims, (float)resizeDims);
    mosaicShader.set("isMosaicCenter", false);

    for (int i = 0; i < facesToUse.size(); i++) {
        Face f = facesToUse.get(i);
        mosaicShader.set("myFaceIndex", i);
        
        pushMatrix();
        translate(f.x, f.y, f.z);
        
        float fCenterX = f.meshScaleX / 2.0f;
        float fCenterY = f.meshScaleY / 2.0f;
        
        translate(fCenterX, fCenterY, 0);
        rotateZ(f.rotationZ);

        scale(emitterScale);
        translate(-fCenterX, -fCenterY, 0);
        
        if (animateFaces) {
          f.updateAnimation();
        }
        
        f.img = originalImages.get(i);
        f.draw(this);
        
        popMatrix();
    }

    pushMatrix();
    translate(targetFace.x, targetFace.y, targetFace.z);

    if (animateFaces) {
        targetFace.updateAnimation();
    }
    
    mosaicShader.set("isMosaicCenter", true);
    targetFace.drawMultiPass(this, facesToUse, mosaicShader);
    
    popMatrix();
    resetShader();

    drawBeams();

    popMatrix();

    hint(DISABLE_DEPTH_TEST);
    camera();
    noLights();
    cp5.draw();
    
    fill(0, 255, 0);
    textSize(16);
    textAlign(LEFT, TOP);
    text("FPS: " + (int)frameRate, width - 80, 20);
    
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

        PImage sourceImg = originalImages.get(faceIndex);

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

            float fCenterX = bgFace.meshScaleX / 2.0f;
            float fCenterY = bgFace.meshScaleY / 2.0f;

            float vx = (bgVert[0] - fCenterX) * emitterScale;

            float vy = (bgVert[1] - fCenterY) * emitterScale;
            float vz = bgVert[2] * emitterScale;

            float cosR = cos(bgFace.rotationZ);

            float sinR = sin(bgFace.rotationZ);

            float rotX = vx * cosR - vy * sinR;

            float rotY = vx * sinR + vy * cosR;

            float finalX = rotX + fCenterX;

            float finalY = rotY + fCenterY;

            float bgVertX = bgFace.x + finalX;
            float bgVertY = bgFace.y + finalY;

            float bgVertZ = bgFace.z + vz;

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

void applyShiftOffset() {
    int totalFaces = facesToUse.size();
    if (totalFaces == 0) return;

    int minFaces = max(1, totalFaces);
    int numFacesToSelect = (int)random(minFaces, totalFaces);

    ArrayList<Integer> available = new ArrayList<Integer>();

    for (int i = 0; i < totalFaces; i++) {
        available.add(i);

    }

    ArrayList<Integer> selectedFaces = new ArrayList<Integer>();
    for (int i = 0; i < numFacesToSelect; i++) {
        int idx = (int)random(available.size());

        selectedFaces.add(available.remove(idx));
    }

    for (int i = 0; i < regionMap.numRegions; i++) {
        regionAssignments[i] = selectedFaces.get((int)random(selectedFaces.size()));

    }
}

void printConfigState() {
    System.out.println("--- Current Config State ---");

    System.out.println("effectActive = " + effectActive);
    System.out.println("scanSpeed = " + scanSpeed);
    System.out.println("beamTailLength = " + beamTailLength);
    System.out.println("beamAlpha = " + beamAlpha);

    System.out.println("numFacesConfig = " + numFacesConfig);
    System.out.println("baseRingRadius = " + baseRingRadius);
    System.out.println("activeRingRadius = " + activeRingRadius);
    System.out.println("rateRingRadius = " + rateRingRadius);

    System.out.println("currentRingRadius = " + currentRingRadius);
    System.out.println("baseBackgroundZ = " + baseBackgroundZ);
    System.out.println("activeBackgroundZ = " + activeBackgroundZ);
    System.out.println("rateBackgroundZ = " + rateBackgroundZ);

    System.out.println("currentBackgroundZ = " + currentBackgroundZ);
    System.out.println("baseRingRotSpeed = " + baseRingRotSpeed);
    System.out.println("activeRingRotSpeed = " + activeRingRotSpeed);
    System.out.println("rateRingRotSpeed = " + rateRingRotSpeed);

    System.out.println("currentRingRotSpeed = " + currentRingRotSpeed);
    System.out.println("baseBackgroundDim = " + baseBackgroundDim);
    System.out.println("activeBackgroundDim = " + activeBackgroundDim);
    System.out.println("rateBackgroundDim = " + rateBackgroundDim);

    System.out.println("currentBackgroundDim = " + currentBackgroundDim);
    System.out.println("baseShiftInterval = " + baseShiftInterval);
    System.out.println("activeShiftInterval = " + activeShiftInterval);
    System.out.println("rateShiftInterval = " + rateShiftInterval);

    System.out.println("currentShiftInterval = " + currentShiftInterval);
    System.out.println("baseNoiseScale = " + baseNoiseScale);
    System.out.println("activeNoiseScale = " + activeNoiseScale);
    System.out.println("rateNoiseScale = " + rateNoiseScale);

    System.out.println("currentNoiseScale = " + currentNoiseScale);
    System.out.println("----------------------------");
}

void keyPressed() {
    if (key == 't') { 
        effectActive = !effectActive;

        System.out.println("effectiveActive state = " + effectActive);
    }
    if (key == 'c') {
        cp5.saveProperties("data/config.json");

        System.out.println("Configuration saved to data/config.json");
    }
    if (key == 'i') { printConfigState();

    }
    if (key == 'o') { zoom *= 1.1;

    }
    if (key == 'p') { zoom *= 0.9;

    }
    if (key == 's') { applyShiftOffset();

    }
    if (key == 'a') {animateFaces = !animateFaces;}
}
