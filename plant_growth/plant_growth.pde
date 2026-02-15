import java.util.HashSet;

// --- CONFIGURATION ---

// Simulation Settings
// these look best when equal
int treeGridSize = 80;      // there will be n^2 trees
float treeSpacing = 4;      // Distance between roots
int numberGoals = 60;        // Grid dimensions for targets
int imageSampleDim = 60;     // Image resize dimension

// Genetic Algorithm Settings
int survivorsPerParent = 1;
int samplesPerBranch = 10;
float mutationRate = 0.2f;   // Random factor
int growthRate = 120;         // Ticks per second

// Geometry Settings
float goalSize = 3;
float scale = 0.95f;         // Branch shrinking factor PITA to tune. TODO: FIND BETTER

// Layout
float goalZ = 1000;          // Height of targets
float rootZ = 0;         // Height of roots
float rootX = 0;         // Starting X offset
float rootY = 100;         // Starting Y offset

// --- STATE VARIABLES ---

ArrayList<ArrayList<CustomTree>> layers;
ArrayList<Target> goals;

// Camera
float rotX, rotY;
float zoom = 0.5f;

// Toggles
boolean isClearMode = true;
boolean bGoalsVisible = false;
boolean topMode = true;
boolean isGrowing = false;

// Timing
int lastGrowthTime = 0;
int growthInterval = 1000 / growthRate;

// setup

void setup() {
  size(800, 600, P3D);
  frameRate(30);
  resetSeed();

  
  
}


// draw

void draw() {
  background(155);
  if (mousePressed) {
    rotY += (mouseX - pmouseX) * 0.01;
    rotX += (mouseY - pmouseY) * 0.01;
  };
  float defaultEyeZ = (height/2.0f) / tan(PI*30.0f / 180.0f);
  float currentEyeZ = zoom * defaultEyeZ;
  camera(width / 2.0f, height / 2.0f, currentEyeZ, 
         width / 2.0f, height / 2.0f, 0, 
         0, 1, 0);
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(-rotX);
  rotateY(rotY);
  
  Vec3 center = getGoalCenter();
  translate(-center.x, -center.y, -center.z);
  
  if (bGoalsVisible) {
    for (Target g : goals) {
      
      drawTarget(g);
    }
}
  drawTree();
  
  popMatrix();
  
  if (isGrowing) {
    if (millis() - lastGrowthTime > growthInterval) {
      evolveStep();
      lastGrowthTime = millis();
    }
  }
}


// genetic algorithm

void evolveStep() {
  if (layers.isEmpty()) return;
  
  ArrayList<CustomTree> currentGen = layers.get(layers.size() - 1);
  ArrayList<CustomTree> nextGeneration = new ArrayList<CustomTree>();
  
  // performance choke prevention
  
  if (currentGen.size() > 10000) {
    println("Max pop reached.");
    isGrowing = false;
    return;
  }
  // offspring generation
  
  for (CustomTree parent : currentGen) {
    // check if we are in the target, and if so stop.
    
    if (parent.target.contains(parent.end)) {
      parent.c = parent.target.c; //just flag magenta for now
      
      // TODO make it inherit the target's color! this would be a cool effect  
      continue;
    }
    ArrayList<CustomTree> offspring = new ArrayList<CustomTree>();
    
    for (int i = 0; i <samplesPerBranch; i++) {
      
      // this isnt a TRUE statistical variance
      // but i *do* like the idea of random smaples on some sort of normal curve
      // that is a KDE of the linear of angles in the branch
      // TODO because that feels awesome, and feels even closer to an NN tha GA does
      
      float childTheta = mutationRate*(parent.theta + random(-PI/4, PI/4)); 
      
      //childTheta = constrain(childTheta, 0, PI/2);
      
      float childPhi = parent.phi + random(-PI/4, PI/4); // Random for now
      

      Vec3 pVector = Vec3.sub(parent.end, parent.start);
      float parentLength = pVector.mag();
      float newScale = scale;
      if (parentLength < 5) {
        newScale = 1.001;
      }
      CustomTree child = parent.createBranch(childTheta, childPhi, newScale);
      
      child.target = parent.target;
      child.initialDist = parent.initialDist;
      child.distanceToTarget = dist(child.end.x, child.end.y, child.end.z,
      parent.target.pos.x, parent.target.pos.y, parent.target.pos.z);
      
      offspring.add(child);
    }
    
    offspring.sort((a,b) -> Float.compare(a.distanceToTarget, b.distanceToTarget));
    // interesting syntax looks like a lambda
    
    int count = min(offspring.size(), survivorsPerParent);
    
    parent.children.clear(); //createeBranch auto adds the children, so we remove it
    
    for (int k = 0; k < count; k++) {
      CustomTree survivor = offspring.get(k);
      
      nextGeneration.add(survivor);
      parent.children.add(survivor);
    }
  }
  
  if (nextGeneration.size() > 0) {
    layers.add(nextGeneration);
  }
}

void pruneMiss() {
  // This isnt presently used
  HashSet<CustomTree> vipList = new HashSet<CustomTree>();
  boolean hitTarget = false;

  for (ArrayList<CustomTree> layer : layers) {
    for (CustomTree t : layer) {
      
      for (Target goal : goals) {
      if (goal.contains(t.end)) {
        hitTarget = true;
        CustomTree tracer = t;
        while (tracer != null) {
          vipList.add(tracer);
          tracer = tracer.parent;
        }
      }
      }
    }
  }

  if (!hitTarget) {
    println("Target not reached yet.");
    return;
  }

  for (int i = layers.size() - 1; i >= 0; i--) {
    ArrayList<CustomTree> layer = layers.get(i);
    
    for (int j = layer.size() - 1; j >= 0; j--) {
      CustomTree t = layer.get(j);
      
      if (!vipList.contains(t)) {
        // Remove from the master draw list
        layer.remove(j);
        
        // Remove from the parent's child list
        if (t.parent != null) {
          t.parent.children.remove(t);
        }
      }
    }
    if (layer.isEmpty()) {
      layers.remove(i);
    }
  }
}
// utilities

void resetSeed() {
  // 1. Load Image
  PImage img = loadImage("image.png");
  if (img == null) {
    img = createImage(numberGoals, numberGoals, RGB);
    img.loadPixels();
    for (int i = 0; i < img.pixels.length; i++) {
      img.pixels[i] = color(random(255), random(255), 255);
    }
  }
  
  img.resize(imageSampleDim, imageSampleDim);
  img.loadPixels();

  //TODO make resolution settings here
  TargetGrid grid = new TargetGrid(
    numberGoals, 0, 0, goalZ, 
    2, 2, 2, goalSize, 
    img.pixels
  );
  
  goals = new ArrayList<Target>();
  goals.addAll(grid.targets);

  // 3. Setup Trees
  layers = new ArrayList<ArrayList<CustomTree>>();
  ArrayList<CustomTree> seedLayer = new ArrayList<CustomTree>();

  for (int i = 0; i < treeGridSize; i++) {
    for (int j = 0; j < treeGridSize; j++) {
      
      float x = rootX + (i * treeSpacing);
      float y = rootY + (j * treeSpacing);
      float z = rootZ;

      Vec3 rootStart = new Vec3(x, y, z);
      Vec3 rootEnd = new Vec3(x, y, z + 20); // Initial growth vector
      
      CustomTree t = new CustomTree(rootStart, rootEnd, null);
      
      // Assign Random Target
      Target goal = goals.get(floor(random(goals.size())));
      t.target = goal;
      
      // Initial Stats
      t.initialDist = dist(t.start.x, t.start.y, t.start.z, t.target.pos.x, t.target.pos.y, t.target.pos.z);
      t.distanceToTarget = t.initialDist;
      t.c = goal.c; // Store color (though drawTree handles the gradient)
      
      seedLayer.add(t);
    }
  }
  layers.add(seedLayer);
}

void drawTree() {
  strokeWeight(3);
  int grey = color(180, 180, 180, 50);

  for (ArrayList<CustomTree> layer : layers) {
    for (CustomTree t : layer) {
      
      if (t.target == null) continue;

      boolean isTip = t.children.isEmpty();
      boolean isWinner = t.distanceToTarget < t.target.radius; 


      if (!topMode) {
        if (isWinner) {
           stroke(t.target.c);
        } else {
           float amt = map(t.distanceToTarget, t.initialDist, 0, 0, 1);
           stroke(lerpColor(grey, t.target.c, constrain(amt, 0, 1)));
        }
        line(t.start.x, t.start.y, t.start.z, t.end.x, t.end.y, t.end.z);
        
      } else {

        if (isWinner || isTip) {
          stroke(t.target.c);
          line(t.start.x, t.start.y, t.start.z, t.end.x, t.end.y, t.end.z);
          
        } else {
          
          if (!isClearMode) {
            stroke(grey);
            line(t.start.x, t.start.y, t.start.z, t.end.x, t.end.y, t.end.z);
          }
        }
      }
    }
  }
}

void drawTarget(Target t) {
  pushMatrix();
  translate(t.pos.x, t.pos.y, t.pos.z);
  
  rotate(-PI/2);
  noFill();  
  stroke(t.c);
  strokeWeight(4);
  ellipse(0, 0, t.radius * 2, t.radius * 2);
  
  fill(255, 255, 0, 40);
  ellipse(0, 0, t.radius * 2, t.radius * 2);
  popMatrix();
}

Vec3 getGoalCenter() {
  if (goals == null || goals.isEmpty()) return new Vec3(0, 0, 0);
  
  float sumX = 0, sumY = 0, sumZ = 0;
  for (Target g : goals) {
    sumX += g.pos.x;
    sumY += g.pos.y;
    sumZ += g.pos.z;
  }
  
  float n = (float)goals.size();
  return new Vec3(sumX / n, sumY / n, sumZ / n);
}

void topOnly() {
  topMode = !topMode;
}

void goalsVisible() {
  bGoalsVisible = ! bGoalsVisible;
}

void clearMode() {
  isClearMode = !isClearMode;
}

void keyPressed() {
  if (key == ' ') isGrowing = !isGrowing; // Toggle Growth
  if (key == 'r') setup(); // Reset
  if (key == 'o') zoom *= 1.1;
  if (key == 'p') zoom *= 0.9;
  if (key == 'x') pruneMiss();
  if (key == 't') topOnly();
  if (key == 'r') resetSeed();
  if (key == 'g') goalsVisible();
  if (key == 'm') clearMode();
}
