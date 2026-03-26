import java.io.File;

ImageSequence faceImages;
int resizeDims = 600;

MosaicFace targetFace;
float globalNoiseZ = 0.0f;

float rotX = 0;
float rotY = 0;
float zoom = 0.9f;
float defaultEyeZ;
float currentEyeZ;
float ringRotationAngle = 0.0f;

float[] drawIndicesT1;
float[][] drawIndicesT2;

boolean loadConfigOnLaunch = true;
volatile boolean isReady = false;
boolean isLoading = false;
boolean animateFaces = false;

float scanSpeed = 0.01f;
int beamTailLength = 50;
float beamAlpha = 59.49495f;
int numFacesConfig = 37;
int numTier2Faces = 8;
float noiseThreshold = 0.5555556f;
float emitterScale = 0.5f;

float ringRadius = 1500.0f;
float ringRotSpeed = 0.001010101f;
float backgroundDim = 0.0f;
float shiftInterval = 100.0f;
float noiseScale = 0.014949495f;

float oscillationRateRadius = 0.5f;
float oscillationAmpRadius = 60.0f;

float rootBaseZ = 200.0f;
float t1BaseZ = -333.33325f;
float t1OscRateZ = 0.3f;
float t1OscAmpZ = 120.0f;
float t2BaseZ = -500.0f;
float t2OscRateZ = 0.4f;
float t2OscAmpZ = 40.0f;

float t1Scale = 0.6f;
float t2Scale = 0.2f;
float t1NoiseScale = 0.02f;
float t1NoiseThreshold = 0.4f;
float t2NoiseScale = 0.03f;
float t2NoiseThreshold = 0.3f;
float t2OrbitalRadius = 600.0f;

float currentRingRadius;
float currentT1Z;
float currentT2Z;

int lastMillis = 0;
ArrayList<PImage> originalImages;

JSONArray globalAnimationData;
JSONArray globalTriangleData;

PShader mosaicShader;

void setup() {
    pixelDensity(1);
    size(1024, 768, P3D);
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
            ringRotSpeed = config.getFloat("ringRotSpeed", ringRotSpeed);
            backgroundDim = config.getFloat("backgroundDim", backgroundDim);
            shiftInterval = config.getFloat("shiftInterval", shiftInterval);
            noiseScale = config.getFloat("noiseScale", noiseScale);
            
            oscillationRateRadius = config.getFloat("oscillationRateRadius", oscillationRateRadius);
            oscillationAmpRadius = config.getFloat("oscillationAmpRadius", oscillationAmpRadius);

            t1Scale = config.getFloat("t1Scale", t1Scale);
            t2Scale = config.getFloat("t2Scale", t2Scale);
            t1NoiseScale = config.getFloat("t1NoiseScale", t1NoiseScale);
            t1NoiseThreshold = config.getFloat("t1NoiseThreshold", t1NoiseThreshold);
            t2NoiseScale = config.getFloat("t2NoiseScale", t2NoiseScale);
            t2NoiseThreshold = config.getFloat("t2NoiseThreshold", t2NoiseThreshold);
            t2OrbitalRadius = config.getFloat("t2OrbitalRadius", t2OrbitalRadius);

            rootBaseZ = config.getFloat("rootBaseZ", rootBaseZ);
            t1BaseZ = config.getFloat("t1BaseZ", t1BaseZ);
            t1OscRateZ = config.getFloat("t1OscRateZ", t1OscRateZ);
            t1OscAmpZ = config.getFloat("t1OscAmpZ", t1OscAmpZ);
            t2BaseZ = config.getFloat("t2BaseZ", t2BaseZ);
            t2OscRateZ = config.getFloat("t2OscRateZ", t2OscRateZ);
            t2OscAmpZ = config.getFloat("t2OscAmpZ", t2OscAmpZ);
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
    targetFace.z = rootBaseZ;
    targetFace.loadMeshData(globalAnimationData, globalTriangleData);

    applyLayout();
    isReady = true;
}

void applyLayout() {
    drawIndicesT1 = new float[numFacesConfig];
    drawIndicesT2 = new float[numFacesConfig][numTier2Faces];

    originalImages = new ArrayList<PImage>();
    for (int i = 0; i < faceImages.faceImages.size(); i++) {
        originalImages.add(faceImages.faceImages.get(i));
    }

    for (int i = 0; i < numFacesConfig; i++) {
        MosaicFace t1 = new MosaicFace(null, targetFace.uvCoords, 0xFF000000);
        t1.initBuffer(this, 300, 300); 
        t1.loadMeshData(globalAnimationData, globalTriangleData);
        t1.activate();
        
        for(int j = 0; j < numTier2Faces; j++) {
            int imgIdx = (i * numTier2Faces + j) % originalImages.size();
            Face t2 = new Face(originalImages.get(imgIdx), targetFace.uvCoords);
            t2.loadMeshData(globalAnimationData, globalTriangleData);
            t2.activate();
            t1.children.add(t2);
        }
        
        targetFace.children.add(t1);
    }

    updateFacePositions();
}

void updateActiveVertices(float speed) {
    globalNoiseZ += speed * 0.2f;
    
    for (int i = 0; i < targetFace.children.size(); i++) {
        Face t1 = targetFace.children.get(i);
        t1.activeVertexIndices.clear();
        
        for (int v = 0; v < targetFace.uvCoords.size(); v++) {
            float[] uv = targetFace.uvCoords.get(v);
            float n = noise(uv[0] * noiseScale * 1000.0f, uv[1] * noiseScale * 1000.0f, globalNoiseZ + i * 10.0f);
            
            if (n > noiseThreshold) {
                t1.activeVertexIndices.add(v);
            }
        }
        
        for (int j = 0; j < t1.children.size(); j++) {
            Face t2 = t1.children.get(j);
            t2.activeVertexIndices.clear();
            
            float faceSeed = (j * 13 + 7) * 10.0f;
            for (int v = 0; v < targetFace.uvCoords.size(); v++) {
                float[] uv = targetFace.uvCoords.get(v);
                float n = noise(uv[0] * t1NoiseScale * 1000.0f, uv[1] * t1NoiseScale * 1000.0f + faceSeed, globalNoiseZ + faceSeed);
                
                if (n > t1NoiseThreshold) {
                    t2.activeVertexIndices.add(v);
                }
            }
        }
    }
}

void updateFacePositions() {
    int num_t1 = targetFace.children.size();
    float angleStepT1 = TWO_PI / max(1, num_t1);
    
    for (int i = 0; i < num_t1; i++) {
        Face t1 = targetFace.children.get(i);
        float angleT1 = i * angleStepT1 + ringRotationAngle;
        
        t1.x = cos(angleT1) * currentRingRadius;
        t1.y = sin(angleT1) * currentRingRadius;
        t1.z = currentT1Z;
        t1.rotationZ = angleT1 + HALF_PI;
        
        int num_t2 = t1.children.size();
        float angleStepT2 = TWO_PI / max(1, num_t2);
        for(int j = 0; j < num_t2; j++) {
            Face t2 = t1.children.get(j);
            float angleT2 = j * angleStepT2 - (ringRotationAngle * 3.0f); 
            
            t2.x = cos(angleT2) * t2OrbitalRadius;
            t2.y = sin(angleT2) * t2OrbitalRadius;
            t2.z = currentT2Z; 
            t2.rotationZ = angleT2 + HALF_PI;
        }
    }
}

void draw() {
    if (!isReady) {
        background(0);
        fill(255);
        textSize(24);
        textAlign(CENTER, CENTER);
        text("Loading JSON data and constructing hierarchy...", width/2, height/2);
        if (!isLoading) {
            isLoading = true;
            thread("initializeHeavyAssets");
        }
        return; 
    }

    background(0);

    float timeSecs = millis() * 0.001f;
    
    currentRingRadius = ringRadius + sin(timeSecs * oscillationRateRadius) * oscillationAmpRadius;
    currentT1Z = t1BaseZ + cos(timeSecs * t1OscRateZ) * t1OscAmpZ;
    currentT2Z = t2BaseZ + sin(timeSecs * t2OscRateZ) * t2OscAmpZ;
    
    targetFace.z = rootBaseZ;
    
    float currentShiftSpeed = 1.0f / shiftInterval;

    updateActiveVertices(currentShiftSpeed);
    ringRotationAngle += ringRotSpeed;
    updateFacePositions();

    targetFace.updateGlobalTransform(0, 0, 0, 0);

    mosaicShader.set("globalNoiseZ", globalNoiseZ);
    mosaicShader.set("noiseScale", t1NoiseScale * 1000.0f);
    mosaicShader.set("noiseThreshold", t1NoiseThreshold);
    
    for (int i = 0; i < targetFace.children.size(); i++) {
        MosaicFace t1 = (MosaicFace) targetFace.children.get(i);
        t1.renderBuffer(this, mosaicShader);
    }

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
    mosaicShader.set("noiseScale", t2NoiseScale * 1000.0f);
    mosaicShader.set("noiseThreshold", t2NoiseThreshold);
    mosaicShader.set("isMosaicCenter", false);

    for (int i = 0; i < targetFace.children.size(); i++) {
        Face t1 = targetFace.children.get(i);
        for (int j = 0; j < t1.children.size(); j++) {
            Face t2 = t1.children.get(j);
            mosaicShader.set("myFaceIndex", i * numTier2Faces + j);
            pushMatrix();
            translate(t2.globalX, t2.globalY, t2.globalZ);

            float cx = t2.meshScaleX / 2.0f;
            float cy = t2.meshScaleY / 2.0f;
            translate(cx, cy, 0);
            rotateZ(t2.globalRotationZ);
            scale(emitterScale * t2Scale); 
            translate(-cx, -cy, 0);

            if (animateFaces) t2.updateAnimation();
            t2.draw(this.g);
            popMatrix();
        }
    }

    mosaicShader.set("noiseScale", noiseScale * 1000.0f);
    mosaicShader.set("noiseThreshold", noiseThreshold);

    for (int i = 0; i < targetFace.children.size(); i++) {
        Face t1 = targetFace.children.get(i);
        mosaicShader.set("myFaceIndex", i);
        pushMatrix();
        translate(t1.globalX, t1.globalY, t1.globalZ);

        float cx = t1.meshScaleX / 2.0f;
        float cy = t1.meshScaleY / 2.0f;
        translate(cx, cy, 0);
        rotateZ(t1.globalRotationZ);
        scale(emitterScale * t1Scale);
        translate(-cx, -cy, 0);

        if (animateFaces) t1.updateAnimation();
        t1.draw(this.g);
        popMatrix();
    }

    pushMatrix();
    translate(targetFace.globalX, targetFace.globalY, targetFace.globalZ);
    if (animateFaces) targetFace.updateAnimation();
    
    mosaicShader.set("isMosaicCenter", true);
    mosaicShader.set("myFaceIndex", -1);
    targetFace.drawMultiPass(this.g, mosaicShader);
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
    text("FPS: " + (int)frameRate + " | Faces: " + (1 + numFacesConfig + (numFacesConfig * numTier2Faces)), width - 200, 20);
    
    hint(ENABLE_DEPTH_TEST);
}

float[] getGlobalPoint(Face f, int vIndex, float scaleFactor) {
    float[] v = f.currentFrameVertices.get(vIndex);
    float cx = f.meshScaleX / 2.0f;
    float cy = f.meshScaleY / 2.0f;

    float vx = (v[0] - cx) * scaleFactor;
    float vy = (v[1] - cy) * scaleFactor;
    float vz = v[2] * scaleFactor;

    float cosR = cos(f.globalRotationZ);
    float sinR = sin(f.globalRotationZ);

    float rotX = vx * cosR - vy * sinR;
    float rotY = vx * sinR + vy * cosR;

    return new float[]{ f.globalX + cx + rotX, f.globalY + cy + rotY, f.globalZ + vz };
}

void drawBeams() {
    strokeWeight(2);
    
    for (int i = 0; i < targetFace.children.size(); i++) {
        Face t1 = targetFace.children.get(i);
        ArrayList<Integer> assignedVerts = t1.activeVertexIndices;
        
        int totalVerts = assignedVerts.size();
        if (totalVerts > 0) {
            PImage sourceImg = originalImages.get(i % originalImages.size());

            if (drawIndicesT1[i] >= totalVerts) {
                drawIndicesT1[i] = 0.0f;
            }

            for (int b = 0; b < beamTailLength; b++) {
                int offsetIndex = (((int)drawIndicesT1[i] - b) % totalVerts + totalVerts) % totalVerts;
                int targetVertIndex = assignedVerts.get(offsetIndex);
                
                float[] targetUV = targetFace.uvCoords.get(targetVertIndex);

                float[] rootPoint = getGlobalPoint(targetFace, targetVertIndex, 1.0f);
                float[] t1Point = getGlobalPoint(t1, targetVertIndex, emitterScale * t1Scale); 

                int texX = constrain((int)(targetUV[0] * sourceImg.width), 0, sourceImg.width - 1);
                int texY = constrain((int)(targetUV[1] * sourceImg.height), 0, sourceImg.height - 1);
                int c = sourceImg.pixels[texX + texY * sourceImg.width];
                
                float tailAlpha = map(b, 0, beamTailLength, beamAlpha, 0);
                stroke(c, tailAlpha);
                line(t1Point[0], t1Point[1], t1Point[2], rootPoint[0], rootPoint[1], rootPoint[2]);
            }

            drawIndicesT1[i] += scanSpeed;
        }

        for (int j = 0; j < t1.children.size(); j++) {
            Face t2 = t1.children.get(j);
            ArrayList<Integer> assignedVertsT2 = t2.activeVertexIndices;
            int totalVertsT2 = assignedVertsT2.size();
            
            if (totalVertsT2 == 0) continue;
            
            int imgIdx = (i * numTier2Faces + j) % originalImages.size();
            PImage sourceImgT2 = originalImages.get(imgIdx);
            
            if (drawIndicesT2[i][j] >= totalVertsT2) {
                drawIndicesT2[i][j] = 0.0f;
            }
            
            for (int b = 0; b < beamTailLength; b++) {
                int offsetIndex = (((int)drawIndicesT2[i][j] - b) % totalVertsT2 + totalVertsT2) % totalVertsT2;
                int targetVertIndex = assignedVertsT2.get(offsetIndex);
                
                float[] targetUV = targetFace.uvCoords.get(targetVertIndex);
                
                float[] t1Point = getGlobalPoint(t1, targetVertIndex, emitterScale * t1Scale);
                float[] t2Point = getGlobalPoint(t2, targetVertIndex, emitterScale * t2Scale);
                
                int texX = constrain((int)(targetUV[0] * sourceImgT2.width), 0, sourceImgT2.width - 1);
                int texY = constrain((int)(targetUV[1] * sourceImgT2.height), 0, sourceImgT2.height - 1);
                int c = sourceImgT2.pixels[texX + texY * sourceImgT2.width];
                
                float tailAlpha = map(b, 0, beamTailLength, beamAlpha, 0);
                stroke(c, tailAlpha);
                line(t2Point[0], t2Point[1], t2Point[2], t1Point[0], t1Point[1], t1Point[2]);
            }
            
            drawIndicesT2[i][j] += scanSpeed;
        }
    }
}

void printConfigState() {
    System.out.println("--- Current Config State ---");
    System.out.println("rootBaseZ = " + rootBaseZ);
    System.out.println("t1BaseZ = " + t1BaseZ);
    System.out.println("t1OscRateZ = " + t1OscRateZ);
    System.out.println("t1OscAmpZ = " + t1OscAmpZ);
    System.out.println("t2BaseZ = " + t2BaseZ);
    System.out.println("t2OscRateZ = " + t2OscRateZ);
    System.out.println("t2OscAmpZ = " + t2OscAmpZ);
    System.out.println("----------------------------");
}

void keyPressed() {
    if (key == 'i') { printConfigState(); }
    if (key == 'o') { zoom *= 1.1; }
    if (key == 'p') { zoom *= 0.9; }
    if (key == 'a') { animateFaces = !animateFaces; }
}
