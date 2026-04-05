// i want to make a physics powered 3 body problem engine

// im thinking parameters are planet masses, distance between, and angles between

// ill probably need a planet object

// imports
import java.util.ArrayList;
import java.time.LocalTime;
import java.time.LocalDate;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.PrintWriter;
import java.io.IOException;
import java.io.File;

// resolution & framerate
int screenW = 800;
int screenH = 600;
int globalFrameRate = 240;

// camera 
float rotX = 0;
float rotY = 0;
float zoom = 1.5f;
float defaultEyeZ;
float currentEyeZ;
int cameraTargetIndex = -1;
float fov = PI / 3.0f;
float aspect = (float) width / height;
float zNear = currentEyeZ / 100.0f;
float zFar = currentEyeZ * 1000.0f;

// simulation settings
boolean isRunning = false;
boolean stabilityOverride = false;
boolean showCenter = false;
float timeStep = .05f;
int stepsPerFrame = 3;
int numBodies = 3; // i cant feel a thing

// our system
Universe universe;
float G = 10.0f;

// planets
ArrayList<Planet> planets;
Vec3 positionCenter;


// logging
PrintWriter output;
String currentInitialConditions = "";
String currentFinalState = "";

// experiment
int ticks = 0;
int maxTicks = 50000;
int episodeCount = 0;
int maxEpisodes = 1000;

// visual
boolean drawTails = false;
boolean drawPlanets = true;


void setup() {
  String currentTime = hour() + "_" + minute() + "_" + second();
  output = createWriter("_dt_" + timeStep + "_G_" + G + "_maxTicks_" + maxTicks+ "_nbody_data_"+ currentTime + ".csv");
  output.println("cmx,cmy,cmz,m1,x1,y1,z1,vx1,vy1,vz1,m2,x2,y2,z2,vx2,vy2,vz2,m3,x3,y3,z3,vx3,vy3,vz3,cmxf,cmyf,cmzf,x1f,y1f,z1f,vx1f,vy1f,vz1f,x2f,y2f,z2f,vx2f,vy2f,vz2f,x3f,y3f,z3f,vx3f,vy3f,vz3f,ticks");
  //size(800, 600, P3D);
  fullScreen(P3D,2);
  frameRate(globalFrameRate);
  resetSeed();
}

void draw() {
  float currentEyeZ = zoom * defaultEyeZ;
  Vec3 centerTarget;
  if (cameraTargetIndex == -1) {
    centerTarget = universe.cm;
  } else {
    centerTarget = planets.get(cameraTargetIndex).pos;
  }
  
  background(255); //white is more aesthetic generally, black is more comfortable at night.
  // still need to work on fixed palletes
  //lights();
  
  if (isRunning) {
    for (int i = 0; i < stepsPerFrame; i++) {
      ticks +=1;
      stepSimulation();
      
      
      if ((universe.isSystemUnstable() || ticks >= maxTicks) && !stabilityOverride) {
        println("A planet reached escape energy! Halting simulation.");
        println("Halted after " + ticks + " steps.");
        currentFinalState = universe.cm.x + "," + universe.cm.y + "," + universe.cm.z + ",";
        for (Planet p : planets) {
          currentFinalState += p.pos.x + "," + p.pos.y + "," + p.pos.z + "," +
                                      p.vel.x + "," + p.vel.y + "," + p.vel.z + ",";
        }
        output.println(currentInitialConditions + currentFinalState + ticks);
        output.flush();
        
        episodeCount += 1;
        
        if (episodeCount >= maxEpisodes) {
          output.close();
          exit();
        } else {
          resetSeed();
        }
        break;
      }
    }
  }  
  
  if (mousePressed) {
    rotY += (mouseX - pmouseX) * 0.01;
    rotX += (mouseY - pmouseY) * 0.01;
  }
  
  currentEyeZ = zoom * defaultEyeZ;
  //perspective(fov, aspect, zNear, zFar);
  camera(width / 2.0f, height / 2.0f, currentEyeZ, 
         width / 2.0f, height / 2.0f, 0, 
         0, 1, 0);


  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(-rotX);
  rotateY(rotY);
  translate(-centerTarget.x, -centerTarget.y, -centerTarget.z);
  drawPlanets();
  if (showCenter) {
    drawCenter();
  }
  popMatrix();
}
void resetSeed() {
  ticks = 0;
  positionCenter = new Vec3(0, 0, 0);
  Vec3 zeroVec = new Vec3(0, 0, 0);
  
  planets = new ArrayList<Planet>();
  numBodies = (int)random(3,8);
  for (int i = 0; i < numBodies; i++) {
    Vec3 pos = new Vec3(random(-100, 100), random(-100, 100), random(-100, 100));
    Vec3 vel = new Vec3(random(-5, 5), random(-5, 5), random(-5, 5));
    float mass = random(1.0f, 30.0f);
    int col = (int)random(0xFF000000, 0xFFFFFFFF);
    planets.add(new Planet(pos, vel, zeroVec, mass, col));
  }
  
  for (Planet a : planets) {
    float potential = 0.0f;
    for (Planet b : planets) {
      if (a == b) continue;
      Vec3 distVec = Vec3.sub(b.pos, a.pos);
      float r = distVec.mag();
      potential -= (G * a.mass * b.mass) / r;
    }
    
    float kinetic = 0.5f * a.mass * a.vel.mag() * a.vel.mag();
    if (kinetic >= -potential) {
      float maxV = sqrt((2.0f * 0.8f * -potential) / a.mass);
      a.vel.normalize();
      a.vel.scale(random(0.1f, maxV));
    }
  }
  
  universe = new Universe(planets, timeStep, G);
  universe.findCenter();
  defaultEyeZ = (height / 2.0f) / tan(PI * 30.0f / 180.0f);
  
  currentInitialConditions = universe.cm.x + "," + universe.cm.y + "," + universe.cm.z + ",";
  for (Planet p : planets) {
    currentInitialConditions += p.mass + "," + p.pos.x + "," + p.pos.y + "," + p.pos.z + "," +
                                p.vel.x + "," + p.vel.y + "," + p.vel.z + ",";
  }

}

void drawCenter() {
      pushMatrix();
      translate(universe.cm.x, universe.cm.y, universe.cm.z);
      fill(0xFF0000FF); 
      noStroke();
      sphere(5);
      popMatrix();
}
void drawPlanets() {
  for (int i = 0; i < universe.planets.size(); i++) {
    Planet p = universe.planets.get(i);
    
    noFill();
    if (drawTails) {
      stroke(p.c);
      strokeWeight(p.mass);
      beginShape();
      for (Vec3[] state : universe.history) {
        vertex(state[i].x, state[i].y, state[i].z);
      }
      endShape();
    }
    if (drawPlanets) {
      pushMatrix();
      translate(p.pos.x, p.pos.y, p.pos.z);
      fill(p.c); 
      noStroke();
      sphere(p.mass);
      popMatrix();
    }
  }
}

void stepSimulation() {
  universe.update();
}



void keyPressed() {
  if (key == ' ') {isRunning = !isRunning;}
  if (key == 's') {stabilityOverride = !stabilityOverride;}
  if (key == ',') {
    if (numBodies > 2) {
      numBodies--;
    }
  }
  if (key == '.') {numBodies++;}
  if (key == 'r') {resetSeed();}
  if (key == 'o') {zoom *= 1.1;}
  if (key == 'p') {zoom *= 0.9;}
  if (key == 'd') {showCenter = !showCenter;}
  if (key == 't') {drawTails = !drawTails;}
  if (key == 'y') {drawPlanets = !drawPlanets;}
  if (key == 'c') {
    cameraTargetIndex++;
    if (cameraTargetIndex >= planets.size()) {
      cameraTargetIndex = -1;
    }
  }
  if (key == '-') {
    if (stepsPerFrame > 1) {
      stepsPerFrame --;
    }
  }
  if (key == '=') {
    if (stepsPerFrame < 100) {
      stepsPerFrame ++;
    }
  }
  if (key == 'q') {
    output.flush();
    output.close();
    exit();
  }
  if (key == 'l') {
    dumpCurrentStateToLog();
  }
}

String generateCSVHeader() {
  StringBuilder header = new StringBuilder("cmx_0,cmy_0,cmz_0,");
  for (int i = 1; i <= 8; i++) {
    header.append("m").append(i).append(",x0_").append(i).append(",y0_").append(i).append(",z0_").append(i)
          .append(",vx0_").append(i).append(",vy0_").append(i).append(",vz0_").append(i).append(",");
  }
  header.append("cmx_f,cmy_f,cmz_f,");
  for (int i = 1; i <= 8; i++) {
    header.append("x_").append(i).append(",y_").append(i).append(",z_").append(i)
          .append(",vx_").append(i).append(",vy_").append(i).append(",vz_").append(i).append(",");
  }
  header.append("ticks");
  return header.toString();
}

void dumpCurrentStateToLog() {
  String fileName = "saved_ics_" + LocalDate.now().toString() + ".csv";
  File file = new File(sketchPath(fileName));
  boolean fileExists = file.exists();
  
  try {
    PrintWriter dumper = new PrintWriter(new BufferedWriter(new FileWriter(file, true)));
    
    if (!fileExists) {
      dumper.println(generateCSVHeader());
    }
    
    String currentFinalStateStr = universe.cm.x + "," + universe.cm.y + "," + universe.cm.z + ",";
    for (int i = 0; i < 8; i++) {
      if (i < planets.size()) {
        Planet p = planets.get(i);
        currentFinalStateStr += p.pos.x + "," + p.pos.y + "," + p.pos.z + "," +
                                p.vel.x + "," + p.vel.y + "," + p.vel.z + ",";
      } else {
        currentFinalStateStr += ",,,,,,";
      }
    }
    
    dumper.println(currentInitialConditions + currentFinalStateStr + ticks);
    dumper.flush();
    dumper.close();
    println("Saved current state to " + fileName);
  } catch (IOException e) {
    e.printStackTrace();
  }
}
