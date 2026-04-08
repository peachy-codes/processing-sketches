# Three-Body Simulation v2 Documentation

This project is a 3D N-body gravitational simulation built with Processing. It supports various integration schemes, force models, and automated logging for stability analysis.

## Project Structure

### Core Components

- **`Universe.java`**: The central class managing the simulation state. It contains the list of `Planet` objects, the `Integrator`, and the `ForceModel`. It also calculates the system's center of mass and maintains a history of positions for rendering.
  ```java
  public class Universe {
      public ArrayList<Planet> planets;
      public float dt;
      public ForceModel forceModel;
      public Vec3 cm;
      public Vec3 cmVel;
      public ArrayDeque<Vec3[]> history;
      public int maxHistory;
      public Integrator integrator;

      public Universe(ArrayList<Planet> planets, float dt, ForceModel forceModel)
      public void findCenter()
      public void recordHistory()
      public void update()
  }
  ```
- **`Planet.java`**: Represents an individual body in the simulation with properties such as position, velocity, mass, and color.
  ```java
  public class Planet {
      public Vec3 pos;
      public Vec3 vel;
      public Vec3 acc;
      public Vec3 oldAcc;
      public float mass;
      public int c;

      public Planet(Vec3 pos, Vec3 vel, Vec3 acc, float mass, int c)
  }
  ```
- **`Vec3.java`**: A utility class for 3D vector operations (addition, scaling, dot/cross products, rotation, etc.).
  ```java
  public class Vec3 {
      public float x;
      public float y;
      public float z;

      public Vec3(float x, float y, float z)
      public Vec3(Vec3 v)
      public static Vec3 zero()
      public static Vec3 add(Vec3 a, Vec3 b)
      public static Vec3 sub(Vec3 a, Vec3 b)
      public static Vec3 neg(Vec3 v)
      public static Vec3 scale(Vec3 v, float f)
      public static float mag(Vec3 v)
      public static float dot(Vec3 a, Vec3 b)
      public static Vec3 normalize(Vec3 v)
      public static Vec3 cross(Vec3 a, Vec3 b)
      public static Vec3 rotateAround(Vec3 v, Vec3 axis, float theta)
      public void add(Vec3 v)
      public void sub(Vec3 v)
      public void neg()
      public void scale(float f)
      public float dot(Vec3 v)
      public float mag()
      public void normalize()
      public Vec3 cross(Vec3 v)
      public void rotateAround(Vec3 axis, float theta)
      public Vec3 copy()
  }
  ```

### Simulation Logic

- **`Integrator.java` (Interface)**: Defines the contract for numerical integration schemes.
  ```java
  public interface Integrator {
      void update(Universe universe, float dt);
  }
  ```
- **`VerletIntegrator.java`**: Implements the Velocity Verlet integration algorithm, providing better energy conservation than simple Euler integration.
  ```java
  public class VerletIntegrator implements Integrator {
      public void update(Universe universe, float dt)
  }
  ```
- **`ForceModel.java` (Interface)**: Defines how forces are applied to the planets in the universe.
  ```java
  public interface ForceModel {
      void applyForces(Universe universe);
  }
  ```
- **`NewtonianGravity.java`**: Implements standard Newtonian gravitational forces between all pairs of bodies.
  ```java
  public class NewtonianGravity implements ForceModel {
      public float G;

      public NewtonianGravity(float G)
      public void applyForces(Universe universe)
  }
  ```
- **`SystemAnalyzer.java`**: Contains utility methods for analyzing the system's state, such as determining if any body has reached escape velocity/energy (system instability).
  ```java
  public class SystemAnalyzer {
      public static boolean isSystemUnstable(Universe universe, float G)
  }
  ```

### Scenarios and Control

- **`Scenario.java` (Interface)**: Defines the lifecycle of a simulation scenario (setup, update, reset).
  ```java
  public interface Scenario {
      void setup(SimulationLogger logger);
      void update(SimulationLogger logger);
      void reset();
      Universe getUniverse();
      boolean isRunning();
      void toggleRunning();
      void toggleStabilityOverride();
      void modifyNumBodies(int delta);
      void modifyStepsPerFrame(int delta);
      int getTicks();
  }
  ```
- **`RandomNBodyScenario.java`**: A specific scenario that generates a random number of bodies with randomized initial conditions. It handles automatic resetting and episode management for data collection.
  ```java
  public class RandomNBodyScenario implements Scenario {
      public Universe universe;
      public boolean isRunning;
      public boolean stabilityOverride;
      public float timeStep;
      public int stepsPerFrame;
      public int numBodies;
      public float G;
      public int ticks;
      public int maxTicks;
      public int episodeCount;
      public int maxEpisodes;

      public RandomNBodyScenario(PApplet p)
      public void setup(SimulationLogger logger)
      public void update(SimulationLogger logger)
      public void reset()
      public Universe getUniverse()
      public boolean isRunning()
      public void toggleRunning()
      public void toggleStabilityOverride()
      public void modifyNumBodies(int delta)
      public void modifyStepsPerFrame(int delta)
      public int getTicks()
  }
  ```
- **`InputHandler.java` (Interface)**: Defines methods for handling user input.
  ```java
  public interface InputHandler {
      void handleKeyPressed(char key);
      void handleMouseDragged(float mouseX, float pmouseX, float mouseY, float pmouseY);
      float getRotX();
      float getRotY();
      float getZoom();
  }
  ```
- **`StandardInputHandler.java`**: Implements keyboard and mouse controls for toggling the simulation, resetting, zooming, and rotating the camera.
  ```java
  public class StandardInputHandler implements InputHandler {
      private Scenario scenario;
      private StandardRenderer renderer;
      private SimulationLogger logger;
      private PApplet p;
      private float rotX;
      private float rotY;
      private float zoom;

      public StandardInputHandler(Scenario scenario, StandardRenderer renderer, SimulationLogger logger, PApplet p)
      public void handleKeyPressed(char key)
      public void handleMouseDragged(float mouseX, float pmouseX, float mouseY, float pmouseY)
      public float getRotX()
      public float getRotY()
      public float getZoom()
  }
  ```

### Rendering and Logging

- **`Renderer.java` (Interface)**: Defines the contract for rendering the universe.
  ```java
  public interface Renderer {
      void render(Universe universe, PApplet p);
  }
  ```
- **`StandardRenderer.java`**: Implements 3D rendering using Processing's P3D engine. It supports drawing planets, motion trails (tails), and velocity vectors.
  ```java
  public class StandardRenderer implements Renderer {
      public boolean showCenter;
      public boolean drawTails;
      public boolean drawPlanets;
      public boolean drawVelocities;
      public int cameraTargetIndex;

      public void render(Universe universe, PApplet p)
      public void drawCenter(Universe universe, PApplet p)
      public void drawPlanets(Universe universe, PApplet p)
      public void drawVelocity(Universe universe, PApplet p)
      public void drawArrow(Vec3 start, Vec3 vec, float scale, int col, PApplet p)
  }
  ```
- **`SimulationLogger.java`**: Manages data persistence, logging initial conditions and final states of simulation episodes to CSV files for further analysis.
  ```java
  public class SimulationLogger {
      public PrintWriter output;
      public String currentInitialConditions;

      public SimulationLogger(String fileName, String header)
      public void setInitialConditions(Universe universe)
      public void logEpisode(Universe universe, int ticks)
      public void closeLog()
      public void dumpCurrentState(Universe universe, int ticks, String folderPath)
  }
  ```

## Main Entry Point

- **`three_body_v2.pde`**: The Processing sketch file that initializes the application, sets up the scenario, and orchestrates the main draw loop by calling the scenario's update and the renderer's render methods.

## Program Workflow and Component Interaction

### Entry Point and Initialization
The simulation begins in `three_body_v2.pde`. During the `setup()` phase:
1.  A `Scenario` (e.g., `RandomNBodyScenario`) is initialized.
2.  A `SimulationLogger` is created to record data to a CSV file.
3.  The scenario is set up, which triggers its internal `reset()` method to generate initial conditions (planets, masses, velocities) and then records these to the logger via `setInitialConditions`.
4.  The `Renderer` (e.g., `StandardRenderer`) and `InputHandler` (e.g., `StandardInputHandler`) are initialized, connecting the scenario, renderer, and logger.

### Core Component Interactions
- **`Universe`**: Acts as the container for the simulation state. It holds a list of `Planet` objects and manages the `Integrator` and `ForceModel`.
- **`Planet`**: Stores physical properties (position, velocity, acceleration, mass).
- **`Vec3`**: Provides the mathematical foundation for all 3D operations.

### The Simulation Loop
The `draw()` loop in `three_body_v2.pde` drives the simulation:
1.  **Update Phase**: `scenario.update(logger)` is called. Inside the scenario:
    - It iterates through a number of `stepsPerFrame` (sub-steps for higher accuracy).
    - For each step, it calls `universe.update()`.
    - `Universe` uses its `Integrator` (e.g., `VerletIntegrator`) to update the planets' state.
    - The `Integrator` calls the `ForceModel` (e.g., `NewtonianGravity`) to calculate gravitational forces and update accelerations.
    - After the physical update, `SystemAnalyzer.isSystemUnstable()` is called to check if any planet has reached escape velocity/energy or if the simulation has reached `maxTicks`.
    - If instability or timeout is detected, the `SimulationLogger` logs the episode's results via `logEpisode`, and the scenario resets with new initial conditions.
2.  **Input Handling**: User inputs (key presses and mouse drags) are processed via the `InputHandler` to modify simulation parameters (pausing, resetting, or changing camera zoom/rotation) and toggle renderer features.
3.  **Rendering Phase**: The `Renderer.render()` method is called within Processing's 3D coordinate system. It uses the current state of the `Universe` (planet positions, history for tails) and the `InputHandler`'s camera state to draw the simulation.

This cycle ensures that the physical simulation, data logging, and user visualization are decoupled yet synchronized within the main execution loop.
