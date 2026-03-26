import java.io.File;

ImageSequence faceImages;
ArrayList<Face> facesToUse;
int resizeDims = 600;

MosaicFace targetFace;
float globalNoiseZ = 0.0f;

float rotX = 0;
float rotY = 0;
float zoom = 0.9f;
float defaultEyeZ;
float currentEyeZ;
float ringRotationAngle = 0.0f;

float[] drawIndices;

boolean loadConfigOnLaunch = true;
volatile boolean isReady = false;
boolean isLoading = false;
boolean animateFaces = false;

float scanSpeed = 0.01f;
int beamTailLength = 50;
float beamAlpha = 59.49495f;
int numFacesConfig = 37;
float noiseThreshold = 0.5555556f;
float emitterScale = 0.5f;

float ringRadius = 1500.0f;
float backgroundZ = -333.33325f;
float ringRotSpeed = 0.001010101f;
float backgroundDim = 0.0f;
float shiftInterval = 100.0f;
float noiseScale = 0.014949495f;

float oscillationRateRadius = 0.5f;
float oscillationAmpRadius = 60.0f;
float oscillationRateZ = 0.3f;
float oscillationAmpZ = 120.0f;

float currentRingRadius;
float currentBackgroundZ;

int lastMillis = 0;
ArrayList<PImage> originalImages;

JSONArray globalAnimationData;
JSONArray globalTriangleData;

PShader mosaicShader;

void setup() {
    pixelDensity(1);
    size(1920, 1080, P3D);
    textureMode(NORMAL);

    defaultEyeZ = (height / 2.0f) / tan(PI * 30.0f / 180.0f);
    frameRate(60);

    if (loadConfigOnLaunch) {
        File configFile = new File(sketchPath("data/config.json"));
        if (configFile.exists()) {
            JSONObject config = loadJSONObject("data/config.json");
            
            scanSpeed = config.getFloat("scanSpeed", scanSpeed);
            beamTailLength = config.getInt("beamTailLength", beamTailLength);
            beamAlpha = config.getFloat("beamAlpha", beamAlpha);
            numFacesConfig = config.getInt("numFacesConfig", numFacesConfig);
            noiseThreshold = config.getFloat("noiseThreshold", noiseThreshold);
            
            ringRadius = config.getFloat("ringRadius", ringRadius);
            backgroundZ = config.getFloat("backgroundZ", backgroundZ);
            ringRotSpeed = config.getFloat("ringRotSpeed", ringRotSpeed);
            backgroundDim = config.getFloat("backgroundDim", backgroundDim);
            shiftInterval = config.getFloat("shiftInterval", shiftInterval);
            noiseScale = config.getFloat("noiseScale", noiseScale);
            
            oscillationRateRadius = config.getFloat("oscillationRateRadius", oscillationRateRadius);
            oscillationAmpRadius = config.getFloat("oscillationAmpRadius", oscillationAmpRadius);
            oscillationRateZ = config.getFloat("oscillationRateZ", oscillationRateZ);
            oscillationAmpZ = config.getFloat("oscillationAmpZ", oscillationAmpZ);
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
        "uniform int myFaceIndex;",
        "uniform float dimFactor;",
        "uniform bool isMosaicCenter;",
        "uniform float globalNoiseZ;",
        "uniform float noiseScale;",
        "uniform float noiseThreshold;",
        "varying vec4 vertColor;",
        "varying vec4 vertTexCoord;",
        
        "vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }",
        "vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }",
        "vec4 permute(vec4 x) { return mod289(((x*34.0)+1.0)*x); }",
        "vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }",
        
        "float snoise(vec3 v) {",
        "  const vec2 C = vec2(1.0/6.0, 1.0/3.0);",
        "  const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);",
        "  vec3 i  = floor(v + dot(v, C.yyy));",
        "  vec3 x0 = v - i + dot(i, C.xxx);",
        "  vec3 g = step(x0.yzx, x0.xyz);",
        "  vec3 l = 1.0 - g;",
        "  vec3 i1 = min(g.xyz, l.zxy);",
        "  vec3 i2 = max(g.xyz, l.zxy);",
        "  vec3 x1 = x0 - i1 + C.xxx;",
        "  vec3 x2 = x0 - i2 + C.yyy;",
        "  vec3 x3 = x0 - D.yyy;",
        "  i = mod289(i);",
        "  vec4 p = permute(permute(permute(i.z + vec4(0.0, i1.z, i2.z, 1.0)) + i.y + vec4(0.0, i1.y, i2.y, 1.0)) + i.x + vec4(0.0, i1.x, i2.x, 1.0));",
        "  float n_ = 0.142857142857;",
        "  vec3 ns = n_ * D.wyz - D.xzx;",
        "  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);",
        "  vec4 x_ = floor(j * ns.z);",
        "  vec4 y_ = floor(j - 7.0 * x_);",
        "  vec4 x = x_ * ns.x + ns.yyyy;",
        "  vec4 y = y_ * ns.x + ns.yyyy;",
        "  vec4 h = 1.0 - abs(x) - abs(y);",
        "  vec4 b0 = vec4(x.xy, y.xy);",
        "  vec4 b1 = vec4(x.zw, y.zw);",
        "  vec4 s0 = floor(b0) * 2.0 + 1.0;",
        "  vec4 s1 = floor(b1) * 2.0 + 1.0;",
        "  vec4 sh = -step(h, vec4(0.0));",
        "  vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;",
        "  vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;",
        "  vec3 p0 = vec3(a0.xy, h.x);",
        "  vec3 p1 = vec3(a0.zw, h.y);",
        "  vec3 p2 = vec3(a1.xy, h.z);",
        "  vec3 p3 = vec3(a1.zw, h.w);",
        "  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));",
        "  p0 *= norm.x;",
        "  p1 *= norm.y;",
        "  p2 *= norm.z;",
        "  p3 *= norm.w;",
        "  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);",
        "  m = m * m;",
        "  return 42.0 * dot(m*m, vec4(dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3)));",
        "}",

        "void main() {",
          "  vec4 texColor = texture2D(texture, vertTexCoord.st);",
          "  if (texColor.a < 0.05) discard;",
          "  ",
          "  float faceSeed = float(myFaceIndex) * 10.0;",
          "  vec3 noisePos = vec3(vertTexCoord.s * noiseScale, vertTexCoord.t * noiseScale + faceSeed, globalNoiseZ + faceSeed);",
          "  float n = (snoise(noisePos) + 1.0) * 0.5;",
          "  ",
          "  if (isMosaicCenter) {",
          "    if (n > noiseThreshold) {",
          "      gl_FragColor = texColor;",
          "    } else {",
          "      discard;",
          "    }",
          "  } else {",
          "    if (n > noiseThreshold) {",
          "      gl_FragColor = texColor;",
          "    } else {",
          "      float g = (texColor.r + texColor.g + texColor.b) / 3.0;",
          "      gl_FragColor = vec4(g * dimFactor, g * dimFactor, g * dimFactor, texColor.a);",
          "    }",
          "  }",
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

    targetFace = new MosaicFace(targetImg, targetUVs, 0xFF000000);
    targetFace.x = 0;
    targetFace.y = -100.0f;
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

    drawIndices = new float[facesToUse.size()];
    for (int i = 0; i < facesToUse.size(); i++) {
        drawIndices[i] = 0.0f;
    }
}

void updateActiveVertices(float speed) {
    globalNoiseZ += speed * 0.2f;
    
    for (int i = 0; i < facesToUse.size(); i++) {
        Face f = facesToUse.get(i);
        f.activeVertexIndices.clear();
        
        for (int v = 0; v < targetFace.uvCoords.size(); v++) {
            float[] uv = targetFace.uvCoords.get(v);
            float n = noise(uv[0] * noiseScale * 1000.0f, uv[1] * noiseScale * 1000.0f, globalNoiseZ + i * 10.0f);
            
            if (n > noiseThreshold) {
                f.activeVertexIndices.add(v);
            }
        }
    }
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
        background(0);
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

    float timeSecs = millis() * 0.001f;
    currentRingRadius = ringRadius + sin(timeSecs * oscillationRateRadius) * oscillationAmpRadius;
    currentBackgroundZ = backgroundZ + cos(timeSecs * oscillationRateZ) * oscillationAmpZ;

    float currentShiftSpeed = 1.0f / shiftInterval;

    int currentMillis = millis();
    if (lastMillis == 0) lastMillis = currentMillis;
    lastMillis = currentMillis;

    updateActiveVertices(currentShiftSpeed);
    
    ringRotationAngle += ringRotSpeed;
    updateFacePositions();

    if (mousePressed) {
        rotY += (mouseX - pmouseX) * 0.01;
        rotX += (mouseY - pmouseY) * 0.01;
    }

    currentEyeZ = zoom * defaultEyeZ;
    camera(width / 2.0f, height / 2.0f, currentEyeZ,
           width / 2.0f, height / 2.0f, 0,
           0, 1, 0);

    pushMatrix();
    translate(width / 2.0f, height / 2.0f - resizeDims/2, 0);
    rotateX(rotX);
    rotateY(rotY);

    shader(mosaicShader);
    mosaicShader.set("dimFactor", backgroundDim);
    mosaicShader.set("globalNoiseZ", globalNoiseZ);
    mosaicShader.set("noiseScale", noiseScale * 1000.0f);
    mosaicShader.set("noiseThreshold", noiseThreshold);
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
    mosaicShader.set("myFaceIndex", -1);
    targetFace.drawMultiPass(this, facesToUse, mosaicShader);
    
    popMatrix();
    resetShader();

    drawBeams();

    popMatrix();

    hint(DISABLE_DEPTH_TEST);
    camera();
    noLights();
    
    fill(0, 255, 0);
    textSize(16);
    textAlign(LEFT, TOP);
    text("FPS: " + (int)frameRate, width - 80, 20);
    
    hint(ENABLE_DEPTH_TEST);
}

void drawBeams() {
    strokeWeight(4);
    
    for (int faceIndex = 0; faceIndex < facesToUse.size(); faceIndex++) {
        Face bgFace = facesToUse.get(faceIndex);
        ArrayList<Integer> assignedVerts = bgFace.activeVertexIndices;
        
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

void printConfigState() {
    System.out.println("--- Current Config State ---");
    System.out.println("scanSpeed = " + scanSpeed);
    System.out.println("beamTailLength = " + beamTailLength);
    System.out.println("beamAlpha = " + beamAlpha);
    System.out.println("numFacesConfig = " + numFacesConfig);
    System.out.println("noiseThreshold = " + noiseThreshold);
    System.out.println("ringRadius = " + ringRadius);
    System.out.println("currentRingRadius = " + currentRingRadius);
    System.out.println("backgroundZ = " + backgroundZ);
    System.out.println("currentBackgroundZ = " + currentBackgroundZ);
    System.out.println("ringRotSpeed = " + ringRotSpeed);
    System.out.println("backgroundDim = " + backgroundDim);
    System.out.println("shiftInterval = " + shiftInterval);
    System.out.println("noiseScale = " + noiseScale);
    System.out.println("oscillationRateRadius = " + oscillationRateRadius);
    System.out.println("oscillationAmpRadius = " + oscillationAmpRadius);
    System.out.println("oscillationRateZ = " + oscillationRateZ);
    System.out.println("oscillationAmpZ = " + oscillationAmpZ);
    System.out.println("----------------------------");
}

void keyPressed() {
    if (key == 'i') { printConfigState(); }
    if (key == 'o') { zoom *= 1.1; }
    if (key == 'p') { zoom *= 0.9; }
    if (key == 'a') { animateFaces = !animateFaces; }
}
