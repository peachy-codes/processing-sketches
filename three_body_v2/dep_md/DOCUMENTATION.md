# Three-Body Simulation v2 Documentation

This project is a 3D N-body gravitational simulation built with Processing. It supports various integration schemes, force models, and automated logging for stability analysis.

## Project Structure

### Core Components

- **`Universe.java`**: The central class managing the simulation state. It utilizes an optimized circular buffer for history recording to eliminate GC pressure.
  ```java
  public class Universe {
      public ArrayList<Planet> planets;
      public float dt;
      public ForceModel forceModel;
      public Vec3 cm;
      public Vec3 cmVel;
      public int maxHistory;
      public Integrator integrator;
      public int totalSteps;

      public Universe(ArrayList<Planet> planets, float dt, ForceModel forceModel)
      public void findCenter()
      public void recordHistory()
      public void update()
      public Vec3 getHistoryPos(int stepIdx, int planetIdx)
      public int getHistoryCount()
  }
  ```
- **`Planet.java`**: Represents an individual body in the simulation.
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
- **`Vec3.java`**: A utility class for 3D vector operations.
  ```java
  public class Vec3 {
      public float x, y, z;
      public Vec3(float x, float y, float z)
      public static Vec3 zero()
      public static Vec3 add(Vec3 a, Vec3 b)
      public static Vec3 sub(Vec3 a, Vec3 b)
      public static Vec3 scale(Vec3 v, float f)
      public void normalize()
      public Vec3 copy()
      // ... (other vector operations)
  }
  ```

### Simulation Logic

- **`Integrator.java` (Interface)**: Defines the contract for numerical integration.
- **`VerletIntegrator.java`**: Implements the Velocity Verlet algorithm for stable energy conservation.
- **`NewtonianGravity.java`**: Implements gravitational forces with numerical softening to prevent singularities.
- **`SystemAnalyzer.java`**: Monitors system stability and detects numerical errors (NaN/Infinity).

### Rendering and Control

- **`StandardRenderer.java`**: A hybrid renderer using baked `PShape` segments for history and immediate mode for the active trail tip.
  ```java
  public class StandardRenderer implements Renderer {
      public boolean showCenter;
      public boolean drawTails;
      public boolean drawPlanets;
      public boolean drawVelocities;
      public int cameraTargetIndex;

      public void render(Universe universe, PApplet p)
      public void reset(Universe universe, PApplet p)
      // ... (internal drawing methods)
  }
  ```
- **`StandardInputHandler.java`**: Handles camera rotation, zoom, and simulation toggles.

## Program Workflow and Component Interaction

### The Simulation Loop
1.  **Update**: `RandomNBodyScenario` updates the `Universe` (typically multiple sub-steps per frame).
2.  **Physics**: `VerletIntegrator` calculates new positions using `NewtonianGravity`.
3.  **Recording**: `Universe` stores positions in a primitive `float[][]` circular buffer (Zero allocation).
4.  **Stability**: `SystemAnalyzer` checks for escape energy or numerical drift.
5.  **Rendering**: `StandardRenderer` pulls new vertices from the buffer into caches, occasionally "baking" them into static `PShape` segments for efficient GPU rendering.

This architecture allows the simulation to maintain high frame rates even with 100,000+ history points.
