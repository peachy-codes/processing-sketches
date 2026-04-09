# Implementation Plan: Three-Body Painting

This document outlines the proposed stages for implementing the features and improvements identified in `TODO.md`. The plan is structured to build upon existing core components while introducing new specialized modules for analysis, aesthetics, and optimization.

---

## Stage 1: Advanced Analysis and "Good Run" Detection
*Goal: Implement logic to identify interesting planet interactions and automate the logging of high-quality simulation data.*

### New Class: `InteractionAnalyzer`
A utility class to detect specific orbital patterns, close encounters, and stable "dance" configurations.

```java
/**
 * Analyzes planet interactions to identify "desirable" or "good" runs.
 */
public class InteractionAnalyzer {
    /**
     * Detects if the current state of the universe contains interesting interactions.
     * @param universe The current universe.
     * @return float A score representing the "interest level" of the current interaction.
     */
    public static float calculateInterestScore(Universe universe)

    /**
     * Checks if a specific planet pair is in a stable or interesting configuration.
     * @param a The first planet.
     * @param b The second planet.
     * @return boolean True if the interaction is considered desirable.
     */
    public static boolean isInterestingPairing(Planet a, Planet b)
}
```

### Improvements to `SimulationLogger`
- Add `logGoodRun(Universe universe, float score)` to save high-interest initial conditions separately.
- Modify `RandomNBodyScenario` to use `InteractionAnalyzer` for triggering resets or extended logging.

---

## Stage 2: Enhanced Aesthetics and Reset Logic
*Goal: Improve the visual quality of the simulation and introduce stylized "on reset" effects.*

### New Class: `AestheticManager`
Handles color palette selection and mixing logic for trails.

```java
/**
 * Manages color palettes and visual effects for the simulation.
 */
public class AestheticManager {
    /**
     * Returns a blended color based on two source colors and their masses.
     * @param c1 First color.
     * @param c2 Second color.
     * @param m1 Mass of first body.
     * @param m2 Mass of second body.
     * @return int The resulting ARGB color.
     */
    public static int mixColors(int c1, int c2, float m1, float m2)

    /**
     * Generates a random color palette from a predefined set of "aesthetic" themes.
     * @return int[] An array of colors representing the current palette.
     */
    public static int[] getRandomPalette()
}
```

### New Methods in `Scenario` / `RandomNBodyScenario`
- `void triggerResetEffect()`: Implementation of "stutter," "rewind perturb," or "decay" visual transitions.
- `void applyResetAesthetics()`: Handles the "shapes jazz" visual logic during rapid resets.

---

## Stage 3: Retained Mode Rendering (`PShape`) Refactor
*Goal: Transition from immediate mode to retained mode rendering to support high vertex counts for "painting" trails.*

### Refactored `StandardRenderer`
Updates the renderer to use `PShape` for planets and trails, significantly reducing CPU-to-GPU overhead.

```java
public class StandardRenderer implements Renderer {
    /** List of PShape objects representing each planet's trail. */
    private ArrayList<PShape> trailShapes;
    /** A shared PShape template for planet spheres to use retained mode rendering. */
    private PShape sphereTemplate;
    
    /**
     * Initializes PShape objects for the current universe.
     * @param universe The current universe.
     * @param p The PApplet instance.
     */
    private void initShapes(Universe universe, PApplet p)

    /**
     * Appends the latest positions from the universe to the retained trail shapes.
     * @param universe The current universe.
     */
    public void updateShapes(Universe universe)
}
```

---

## Stage 4: Spatial Partitioning and Physical Subdivision
*Goal: Optimize CPU-side calculations and implement dynamic planet behavior.*

### New Class: `QuadTree3D` (Octree)
To find active spaces and optimize force calculations for many bodies.

```java
/**
 * A spatial partitioning structure to optimize proximity searches and force calculations.
 */
public class QuadTree3D {
    /**
     * Inserts a planet into the tree.
     * @param p The planet to insert.
     */
    public void insert(Planet p)

    /**
     * Returns a list of planets within a certain radius of a point.
     * @param center The search center.
     * @param radius The search radius.
     * @return ArrayList<Planet> List of nearby planets.
     */
    public ArrayList<Planet> query(Vec3 center, float radius)
}
```

### New Methods in `Planet`
- `public ArrayList<Planet> subdivide()`: Splits a planet into smaller "break off" fragments when certain conditions (e.g., high-speed collision) are met.

---

## Stage 5: State Buffering and Pre-computation
*Goal: Implement efficient state storage for the "rewind," "decay," and "stutter" effects, and pre-calculate orbital paths for "painting" aesthetics.*

### New Class: `HistoryBuffer`
Manages a circular buffer of planet states for effects like "rewind perturb" and "stutter."

```java
/**
 * Manages a history of universe states for effects like rewind, stutter, and decay.
 */
public class HistoryBuffer {
    /**
     * Pushes the current state of the universe into the buffer.
     * @param universe The current universe.
     */
    public void pushState(Universe universe)

    /**
     * Retrieves a state from 'n' steps ago.
     * @param stepsAgo The number of steps to look back.
     * @return Vec3[] Array of planet positions from that state.
     */
    public Vec3[] getStateAt(int stepsAgo)

    /**
     * Interpolates between current and past states for "stutter" or "decay" effects.
     * @param t Interpolation factor (0-1).
     * @return Vec3[] The interpolated positions.
     */
    public Vec3[] interpolateWithPast(float t)
}
```

### New Class: `PreComputeEngine`
Handles the pre-calculation of future orbits for "painting" or "predictive" trails.

```java
/**
 * Pre-calculates future states of the universe for visual effects.
 */
public class PreComputeEngine {
    /**
     * Predicts the next 'n' steps of the simulation without updating the main universe.
     * @param universe The source universe.
     * @param steps Number of steps to predict.
     * @return ArrayList<Vec3[]> List of predicted future positions.
     */
    public ArrayList<Vec3[]> preComputeFuture(Universe universe, int steps)
}
```

---

## Stage 6: GPU Offloading
*Goal: Leverage GPU acceleration for large-scale simulations and high-fidelity trail rendering.*

### New Class: `GPUSimulator` (Interface)
Defines the bridge between the Java simulation and GPU kernels (e.g., GLSL or OpenCL).

```java
/**
 * Manages GPU-accelerated force calculations and state updates.
 */
public interface GPUSimulator {
    /**
     * Uploads current planet data to GPU buffers.
     * @param planets List of planets to simulate.
     */
    public void uploadToBuffer(ArrayList<Planet> planets)

    /**
     * Executes the simulation kernel on the GPU.
     * @param dt The time step.
     */
    public void computeOnGPU(float dt)

    /**
     * Downloads updated positions and velocities from the GPU.
     * @return ArrayList<PlanetState> Updated states for rendering.
     */
    public ArrayList<PlanetState> downloadFromBuffer()
}
```

---

## Stage 7: Intelligent Camera and Final Polish
*Goal: Automate camera movement and refine user interactions.*

### New Class: `AutoCamera`
Implements logic for smooth panning and tracking of interesting clusters.

```java
/**
 * Automatically pans and zooms the camera to follow the most interesting action.
 */
public class AutoCamera {
    /**
     * Updates the camera position based on the center of interest.
     * @param universe The current universe.
     * @param currentCameraPos The current camera position.
     * @return Vec3 The target camera position for the next frame.
     */
    public Vec3 calculateNextCameraPos(Universe universe, Vec3 currentCameraPos)
}
```
