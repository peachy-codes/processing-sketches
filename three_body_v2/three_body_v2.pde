int globalFrameRate = 240;
float defaultEyeZ;

SimulationLogger logger;
StandardRenderer renderer;
RandomNBodyScenario scenario;
StandardInputHandler input;

void setup() {
  size(800,600,P3D);
  frameRate(globalFrameRate);
  
  scenario = new RandomNBodyScenario(this);
  
  String currentTime = hour() + "_" + minute() + "_" + second();
  String fileName = sketchPath("_dt_" + scenario.timeStep + "_G_" + scenario.G + "_maxTicks_" + scenario.maxTicks+ "_nbody_data_"+ currentTime + ".csv");
  String header = "cmx,cmy,cmz,m1,x1,y1,z1,vx1,vy1,vz1,m2,x2,y2,z2,vx2,vy2,vz2,m3,x3,y3,z3,vx3,vy3,vz3,cmxf,cmyf,cmzf,x1f,y1f,z1f,vx1f,vy1f,vz1f,x2f,y2f,z2f,vx2f,vy2f,vz2f,x3f,y3f,z3f,vx3f,vy3f,vz3f,ticks";
  
  logger = new SimulationLogger(fileName, header);
  scenario.setup(logger);
  
  renderer = new StandardRenderer();
  renderer.reset(scenario.getUniverse(), this);
  input = new StandardInputHandler(scenario, renderer, logger, this);
  
  defaultEyeZ = (height / 2.0f) / tan(PI * 30.0f / 180.0f);
}

void draw() {
  background(255);
  
  scenario.update(logger);
  
  if (mousePressed) {
    input.handleMouseDragged(mouseX, pmouseX, mouseY, pmouseY);
  }
  
  float currentEyeZ = input.getZoom() * defaultEyeZ;

  camera(width / 2.0f, height / 2.0f, currentEyeZ, 
         width / 2.0f, height / 2.0f, 0, 
         0, 1, 0);

  pushMatrix();
  translate(width / 2.0f, height / 2.0f, 0);
  rotateX(-input.getRotX());
  rotateY(input.getRotY());
  renderer.render(scenario.getUniverse(), this);
  popMatrix();
  
  lights();
  camera();
  fill(0, 255, 0);
  textSize(16);
  textAlign(LEFT, TOP);
  text("FPS: " + (int)frameRate, 10, 10);
}

void keyPressed() {
  input.handleKeyPressed(key);
}
