// CRT animation chasers dream

// the idea is we load an image, and then drag a bunch of segments to each loaded pixel
// the segment is assigned the idx at init and at draw time reads the corresponding pixel
// flat index would be nice (check how img stored)

// to animate the crt drawing we quickly cycle through each index
// we can use timesteps to get an idea for draw rate

// would be nice to have the image warped or bent to simulate a tv screen
// ill want to be able to load multiple images, maybe even a video?

// improtant imports

import java.util.ArrayList;
import java.io.File;

float rotX = 0.099;
float rotY = 0.659;
float zoom = 1f;

boolean drawDebug = false;
boolean frameToggle = false;
boolean emitterToggle = true;
boolean isPlaying = true;
boolean scanLine = true; // scanline is default behavior
boolean jumpAround = true;



Vec3 emitter;
float emitterDistance = -1000;// coords of the emitter location = (0, 0, distance)

float screenWidth = 1024;
float screenHeight = 1024;
float radius = 400;    // The radius of the tv screen
float curveAngle = PI/3; // How wide the curve is
Vec3 pTL;
Vec3 pTR;
Vec3 pBL;
Vec3 pBR; // hell yea brother


ArrayList<int[]> allFrames;
int drawImg;
int currentFrameIdx = 0;
int frameDuration = 600; // time per frame = this / fps
int frameTime = 1;
boolean autoCycle = false;
boolean autoPlay = true;

int drawIndex = 0;
int imgResolution = 120; // square dims
int imgSampleSizeDim = 120; // resize

Vec3[] targets;

int[] pixelData;
int[] screenBuffer; // The actual colors on the CRT phosphors

float[] alphaMap; // staying with the flat idx theme
float fadeSpeed = .99f;

// RefreshRates
int globalFPS = 60;
int pixelsPerSecond = 100; // this doesnt really do this rn


// Distortion Settings
boolean useDistortion = true;
float distortionMag = 5f;    // 0 = Clean, 50 = Glitchy
float distortionFreq = .85f;   // 0.1 = Wide waves, 0.5 = Tight static
float distortionSpeed = .4f;  // How fast the interference scrolls
  int distWindow =-1;


// jumparound
float jumpChance = .05f; // pct chance to jump to random pixel
// setup

void setup() {
  size(800, 600, P3D);
  frameRate(globalFPS);

  resetScene();
  
}



void draw() {
  background(255); 

  if (autoCycle && allFrames != null && allFrames.size() > 1 && isPlaying) {
    frameTime++;
    
    if (frameTime > frameDuration) {
      frameTime = 0;
      currentFrameIdx++;
      
      if (currentFrameIdx >= allFrames.size()) {
        currentFrameIdx = 0;
      }
      
      // SWAP THE DATA POINTER
      pixelData = allFrames.get(currentFrameIdx);
    }
  } 


  // --- 2. CAMERA & INTERACTION (Always runs) ---
  if (mousePressed) {
    rotY += (mouseX - pmouseX) * 0.01;
    rotX += (mouseY - pmouseY) * 0.01;
  }
  
  float defaultEyeZ = (height/2.0f) / tan(PI*30.0f / 180.0f);
  float currentEyeZ = zoom * defaultEyeZ;
  
  camera(width / 2.0f, height / 2.0f, currentEyeZ, 
         width / 2.0f, height / 2.0f, 0, 
         0, 1, 0);


  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(-rotX);
  rotateY(rotY);

  drawPhosphors();     
  drawEmitter();       
  drawScreenEdge();
  
  popMatrix();

  if (drawDebug) {
    fill(0);
    rect(10, 10, 200, 200); // Background box
    fill(0, 255, 0);
    textSize(14);
    text("RotX: " + (double)rotX, 20, 30);
    text("RotY: " + (double)rotY, 20, 50);

    text("FPS: " + int(frameRate), 20, 70);
    text("Image: " + (currentFrameIdx + 1) + " / " + (allFrames != null ? allFrames.size() : 0), 20, 90);
    text("Playing: " + isPlaying, 20, 110);

    text("Distortion Mag: " + distortionMag, 20, 120);
    text("Distortion Freq: " + distortionFreq, 20, 140);
    text("Distortion Speed: " + distortionSpeed, 20, 170);
    text("Distortion Window: " + distWindow, 20, 200);
  }
    
  
  if (jumpAround) {
    jumpAroundRNG();
  }
}
void resetScene() {

  loadSequence("data/sequence");
  setEmitterCoordinates(emitterDistance);
  calculateTargets();
  
  alphaMap = new float[targets.length];
  
  screenBuffer = new int[targets.length];
}



// utilities

void jumpAroundRNG() {
  if (random(0,1) < jumpChance) {
    
    // drawIndex = (int)random(targets.length);
    if (allFrames != null && allFrames.size() > 1) {
      currentFrameIdx = (int)random(allFrames.size());
      
      pixelData = allFrames.get(currentFrameIdx);
      
      println("Now drawing image " + currentFrameIdx);
    }
  }
}

void jumpToggle() {
  jumpAround = !jumpAround;
}



void setEmitterCoordinates(float distance) {
  emitter = new Vec3(0, 0, distance);
}






void calculateTargets() {
  int totalPixels = imgSampleSizeDim * imgSampleSizeDim;
  targets = new Vec3[totalPixels];

  for (int i = 0; i < totalPixels; i++) {
    int x = i % imgSampleSizeDim;
    int y = i / imgSampleSizeDim;
    
    float u = (float)x / (imgSampleSizeDim - 1);
    float v = (float)y / (imgSampleSizeDim - 1);
    
    targets[i] = getSurfacePoint(u, v);
  }
}

Vec3 getSurfacePoint(float u, float v) {
  
  // spherical rn
 

  float theta = map(u, 0, 1, -curveAngle/2, curveAngle/2); 
  float phi   = map(v, 0, 1, -curveAngle/2, curveAngle/2); 

  float sx = radius * sin(theta) * cos(phi);
  float sy = radius * sin(phi);
  float sz = radius * cos(theta) * cos(phi);

  sz -= radius; 
  
  return new Vec3(sx, sy, sz);
}

void drawScreenEdge() { // thanks LLM
  noFill();
  stroke(0, 100); // Black with transparency
  strokeWeight(4);

  int steps = 20; // Resolution of the curve (higher = smoother)

  // --- 1. TOP EDGE (v = 0, u changes) ---
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float u = (float)i / steps;
    Vec3 p = getSurfacePoint(u, 0.0); // v is fixed at Top (0.0)
    vertex(p.x, p.y, p.z);
  }
  endShape();

  // --- 2. BOTTOM EDGE (v = 1, u changes) ---
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float u = (float)i / steps;
    Vec3 p = getSurfacePoint(u, 1.0); // v is fixed at Bottom (1.0)
    vertex(p.x, p.y, p.z);
  }
  endShape();

  // --- 3. LEFT EDGE (u = 0, v changes) ---
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float v = (float)i / steps;
    Vec3 p = getSurfacePoint(0.0, v); // u is fixed at Left (0.0)
    vertex(p.x, p.y, p.z);
  }
  endShape();

  // --- 4. RIGHT EDGE (u = 1, v changes) ---
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float v = (float)i / steps;
    Vec3 p = getSurfacePoint(1.0, v); // u is fixed at Right (1.0)
    vertex(p.x, p.y, p.z);
  }
  endShape();
}

// Drawing

void drawEmitter() {
  // Only run if the simulation is active
  if (!scanLine || !isPlaying) return;

  // Calculate batch size based on speed
  float batchSize = pixelsPerSecond;// This is wrong and needs to be fixed. 

  for (int i = 0; i < batchSize; i++) {
    
    // Safety check
    if (drawIndex < targets.length) {
      

      alphaMap[drawIndex] = 255; 

      screenBuffer[drawIndex] = pixelData[drawIndex];
      
      // B. DRAW BEAM: The line from the gun to the screen
      if (emitterToggle) {
        Vec3 target = targets[drawIndex];
        color c = pixelData[drawIndex];
        int amt = 50;
        stroke(c, amt);
        strokeWeight(4);
        line(emitter.x, emitter.y, emitter.z, target.x, target.y, target.z);
      }
      
      // C. ADVANCE: Move to the next pixel
      drawIndex++;
      
      // Wrap around if we hit the end
      if (drawIndex >= targets.length) {
        drawIndex = 0;
      }
    }
  }
}

void drawPhosphors() {
  strokeWeight(3); // Adjust dot size here
  
  for (int i = 0; i < targets.length; i++) {
    // Optimization: Only draw if visible
    if (alphaMap[i] > 1.0) {
      
      int sourceIdx = getDistortedIndex(i);
      Vec3 pos = targets[i];
      color c = screenBuffer[sourceIdx];
      
      // Use the alpha map to fade the color
      stroke(red(c), green(c), blue(c), alphaMap[i]);
      point(pos.x, pos.y, pos.z);
      
      alphaMap[i] *= fadeSpeed;
      
      if (alphaMap[i] < 0) alphaMap[i] = 0;
    }
  }
}
void nextImage() {
  if (allFrames == null || allFrames.size() == 0) return;
  
  currentFrameIdx++;
  
  // Loop back to start
  if (currentFrameIdx >= allFrames.size()) {
    currentFrameIdx = 0;
  }
  
  // SWAP THE POINTER
  pixelData = allFrames.get(currentFrameIdx);
  println("Switched to Image: " + currentFrameIdx);
}

int getDistortedIndex(int i) {
  // 1. Fast exit if disabled
  if (!useDistortion || distortionMag == 0) return i;

  // 2. Calculate Context (Row/Column)
  // We need 'y' because CRT distortion usually happens per scanline
  int y = i / imgSampleSizeDim; 
  
  // 3. Calculate The Offset (The "Effect")
  // Sine Wave: Simulates magnetic interference or sync loss
  float wave = sin(y * distortionFreq + frameCount * distortionSpeed);
  
  // Noise: Simulates static/snow (Optional, uncomment to mix in)
  // float noiseVal = noise(y * 0.1, frameCount * 0.5) - 0.5; 
  
  // Combine them into a integer pixel shift
  // Add vertical roll:
  int verticalOffset = (int)(frameCount + 5*wave) * imgSampleSizeDim; // 5 rows per frame
  int offset = (int)(distortionMag + 2) + verticalOffset;  
  
  // 4. Apply & Wrap
  // We add 'targets.length' before modulo to handle negative offsets correctly
  int newIdx = (i + offset) % targets.length;
  if (newIdx < 0) newIdx += targets.length; // Extra safety for Java modulo behavior
  
  return newIdx;
}

void keyPressed() {
  if (key == ' ') {isPlaying = !isPlaying;}
  if (key == 'e') {emitterToggle = !emitterToggle;}
  if (key == 'o') zoom *= 1.1;
  if (key == 'p') zoom *= 0.9;
  if (key == 'f') frameToggle = !frameToggle;
  if (key == 'j') jumpAround = !jumpAround;
  if (key == 'n') nextImage(); // Press 'n' for Next Image
  if (key == 'a') autoCycle = !autoCycle; // Press 'a' to toggle auto-timer
  if (key == 'q') drawDebug = !drawDebug;
  if (key == 'd') useDistortion = !useDistortion;
  if (key == '1') distortionMag *= 1.3; // Enhance
  if (key == '2') distortionMag *= .65; // Reduce
  if (key == '3') distortionFreq += 0.05; // Tighten wave
  if (key == '4') distortionFreq -= 0.05; // Loosen wave
  if (key == '5') distortionSpeed +=.1;
  if (key == '6') distortionSpeed -= 1;
  if (key == '[') distWindow -=10;
  if (key == ']') distWindow +=10;
}
