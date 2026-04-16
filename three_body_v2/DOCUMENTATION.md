# Three-Body V2 Project Documentation

This document provides a comprehensive overview of the classes, methods, and interfaces within the `three_body_v2` project.

## RandomNBodyScenario.java

A scenario that generates a random number of bodies with random initial positions and velocities. It manages the simulation loop, stability checks, and resetting the simulation for multiple episodes.

### Class: `RandomNBodyScenario`
- **Dependencies**: `java.util.ArrayList`, `processing.core.PApplet`, `Universe`, `Planet`, `Vec3`, `NewtonianGravity`, `SystemAnalyzer`, `SimulationLogger`, `Scenario`.

#### Methods:
- **`RandomNBodyScenario(PApplet p)`**
  - **Input Params**: `PApplet p` (The Processing applet instance).
  - **Outputs**: None (Constructor).
  - **Methodology**: Initializes the scenario with the Processing applet and sets a random number of bodies between `minBodies` and `maxBodies`.
- **`setup(SimulationLogger logger)`**
  - **Input Params**: `SimulationLogger logger`.
  - **Outputs**: `void`.
  - **Methodology**: Resets the scenario state and provides initial conditions to the logger.
- **`update(SimulationLogger logger)`**
  - **Input Params**: `SimulationLogger logger`.
  - **Outputs**: `void`.
  - **Methodology**: Executes `stepsPerFrame` simulation steps. During each step, it updates the universe and checks for system instability or tick limits. If triggered, it logs the episode and either resets or terminates if `maxEpisodes` is reached.
- **`reset()`**
  - **Input Params**: None.
  - **Outputs**: `void`.
  - **Methodology**: Re-initializes simulation variables, generates planets with random attributes, ensures initial stability by adjusting velocities relative to potential energy, and creates a new `Universe` with `NewtonianGravity`.
- **`getUniverse()`**
  - **Input Params**: None.
  - **Outputs**: `Universe`.
  - **Methodology**: Returns the current `Universe` instance.
- **`isRunning()`**
  - **Input Params**: None.
  - **Outputs**: `boolean`.
  - **Methodology**: Returns whether the simulation is currently running.
- **`toggleRunning()`**
  - **Input Params**: None.
  - **Outputs**: `void`.
  - **Methodology**: Toggles the simulation's running state.
- **`toggleStabilityOverride()`**
  - **Input Params**: None.
  - **Outputs**: `void`.
  - **Methodology**: Toggles the stability check override.
- **`modifyNumBodies(int delta)`**
  - **Input Params**: `int delta`.
  - **Outputs**: `void`.
  - **Methodology**: Adjusts the `numBodies` count by the specified delta, ensuring it remains at least 2.
- **`modifyStepsPerFrame(int delta)`**
  - **Input Params**: `int delta`.
  - **Outputs**: `void`.
  - **Methodology**: Adjusts the `stepsPerFrame` speed control within a [1, 100] range.
- **`getTicks()`**
  - **Input Params**: None.
  - **Outputs**: `int`.
  - **Methodology**: Returns the current simulation step count.

## ForceModel.java

Interface representing a force model that can be applied to a universe.

### Interface: `ForceModel`
- **Dependencies**: `Universe`.

#### Methods:
- **`applyForces(Universe universe)`**
  - **Input Params**: `Universe universe`.
  - **Outputs**: `void`.
  - **Methodology**: Defines the contract for applying physical forces (e.g., gravity) to all planets within a given `Universe` instance.

## InputHandler.java

Interface for handling input events (keyboard and mouse) in the simulation.

### Interface: `InputHandler`
- **Dependencies**: None.

#### Methods:
- **`handleKeyPressed(char key)`**
  - **Input Params**: `char key`.
  - **Outputs**: `void`.
  - **Methodology**: Contract for handling keyboard inputs to control simulation state or camera.
- **`handleMouseDragged(float mouseX, float pmouseX, float mouseY, float pmouseY)`**
  - **Input Params**: `float mouseX`, `float pmouseX`, `float mouseY`, `float pmouseY`.
  - **Outputs**: `void`.
  - **Methodology**: Contract for handling mouse dragging to update camera orientation.
- **`getRotX()`**
  - **Input Params**: None.
  - **Outputs**: `float`.
  - **Methodology**: Returns the current X-axis rotation value.
- **`getRotY()`**
  - **Input Params**: None.
  - **Outputs**: `float`.
  - **Methodology**: Returns the current Y-axis rotation value.
- **`getZoom()`**
  - **Input Params**: None.
  - **Outputs**: `float`.
  - **Methodology**: Returns the current zoom level.

## Integrator.java

Interface for a numerical integrator used to update the universe.

### Interface: `Integrator`
- **Dependencies**: `Universe`.

#### Methods:
- **`update(Universe universe, float dt)`**
  - **Input Params**: `Universe universe`, `float dt`.
  - **Outputs**: `void`.
  - **Methodology**: Defines the contract for numerical integration (e.g., updating position and velocity) for all bodies in the universe over a time step `dt`.

## NewtonianGravity.java

Implementation of a force model based on Newtonian gravity.

### Class: `NewtonianGravity`
- **Dependencies**: `ForceModel`, `Universe`, `Planet`, `Vec3`.

#### Methods:
- **`NewtonianGravity(float G)`**
  - **Input Params**: `float G`.
  - **Outputs**: None (Constructor).
  - **Methodology**: Initializes the force model with a specific gravitational constant.
- **`applyForces(Universe universe)`**
  - **Input Params**: `Universe universe`.
  - **Outputs**: `void`.
  - **Methodology**: Iterates through all pairs of planets in the universe. It calculates the gravitational attraction force using Newton's law: $F = G \frac{m_1 m_2}{r^2 + \epsilon}$, where $\epsilon$ is a softening factor to avoid division by zero. The forces are then converted to accelerations ($a = F/m$) and applied to each planet's acceleration vector.

## Planet.java

Represents a celestial body in the simulation, storing physical state and visual properties.

### Class: `Planet`
- **Dependencies**: `Vec3`.

#### Methods:
- **`Planet(Vec3 pos, Vec3 vel, Vec3 acc, float mass, int c)`**
  - **Input Params**: `Vec3 pos`, `Vec3 vel`, `Vec3 acc`, `float mass`, `int c` (ARGB color).
  - **Outputs**: None (Constructor).
  - **Methodology**: Initializes the planet's state including position, velocity, and current/previous acceleration vectors. Sets the mass and display color.

## Renderer.java

Interface for rendering a universe.

### Interface: `Renderer`
- **Dependencies**: `Universe`, `processing.core.PApplet`.

#### Methods:
- **`render(Universe universe, PApplet p)`**
  - **Input Params**: `Universe universe`, `PApplet p`.
  - **Outputs**: `void`.
  - **Methodology**: Renders all bodies of the universe using Processing graphics functions.
- **`reset(Universe universe, PApplet p)`**
  - **Input Params**: `Universe universe`, `PApplet p`.
  - **Outputs**: `void`.
  - **Methodology**: Resets or initializes visual resources (like cached shapes or textures) based on the universe's state.

## Scenario.java

Interface representing a simulation scenario, defining how it is set up, updated, and reset.

### Interface: `Scenario`
- **Dependencies**: `SimulationLogger`, `Universe`.

#### Methods:
- **`setup(SimulationLogger logger)`**
  - **Input Params**: `SimulationLogger logger`.
  - **Outputs**: `void`.
  - **Methodology**: Prepares the scenario and initializes the logger with the starting state.
- **`update(SimulationLogger logger)`**
  - **Input Params**: `SimulationLogger logger`.
  - **Outputs**: `void`.
  - **Methodology**: Advances the scenario's simulation and logging state.
- **`reset()`**
  - **Input Params**: None.
  - **Outputs**: `void`.
  - **Methodology**: Restores the scenario to its initial conditions.
- **`getUniverse()`**
  - **Input Params**: None.
  - **Outputs**: `Universe`.
  - **Methodology**: Returns the current `Universe`.
- **`isRunning()`**
  - **Input Params**: None.
  - **Outputs**: `boolean`.
  - **Methodology**: Checks if the simulation is currently active.
- **`toggleRunning()`**
  - **Input Params**: None.
  - **Outputs**: `void`.
  - **Methodology**: Toggles the running state.
- **`toggleStabilityOverride()`**
  - **Input Params**: None.
  - **Outputs**: `void`.
  - **Methodology**: Toggles whether to ignore instability checks.
- **`modifyNumBodies(int delta)`**
  - **Input Params**: `int delta`.
  - **Outputs**: `void`.
  - **Methodology**: Adjusts the number of celestial bodies for next reset.
- **`modifyStepsPerFrame(int delta)`**
  - **Input Params**: `int delta`.
  - **Outputs**: `void`.
  - **Methodology**: Changes the speed of simulation updates per frame.
- **`getTicks()`**
  - **Input Params**: None.
  - **Outputs**: `int`.
  - **Methodology**: Returns the total simulation steps elapsed.

## SimulationLogger.java

Handles logging of simulation data to CSV files, including initial conditions and final states.

### Class: `SimulationLogger`
- **Dependencies**: `java.io.*`, `java.time.LocalDate`, `Universe`, `Planet`, `Vec3`.

#### Methods:
- **`SimulationLogger(String fileName, String header)`**
  - **Input Params**: `String fileName`, `String header`.
  - **Outputs**: None (Constructor).
  - **Methodology**: Initializes a `PrintWriter` to write to the specified file and writes the CSV header.
- **`setInitialConditions(Universe universe)`**
  - **Input Params**: `Universe universe`.
  - **Outputs**: `void`.
  - **Methodology**: Serializes the initial state of the universe (center of mass and all planet parameters) into a comma-separated string.
- **`logEpisode(Universe universe, int ticks)`**
  - **Input Params**: `Universe universe`, `int ticks`.
  - **Outputs**: `void`.
  - **Methodology**: Combines the stored initial conditions with the current (final) state of the universe and the total tick count, writing the result as a new line in the log file.
- **`closeLog()`**
  - **Input Params**: None.
  - **Outputs**: `void`.
  - **Methodology**: Safely closes the `PrintWriter`.
- **`dumpCurrentState(Universe universe, int ticks, String folderPath)`**
  - **Input Params**: `Universe universe`, `int ticks`, `String folderPath`.
  - **Outputs**: `void`.
  - **Methodology**: Appends the current simulation state to a daily CSV file. It handles header creation if the file is new and assumes a maximum of 8 planets for its fixed-column format.

## StandardInputHandler.java

Standard implementation of `InputHandler` that maps keyboard shortcuts to simulation actions and handles camera rotation via mouse dragging.

### Class: `StandardInputHandler`
- **Dependencies**: `processing.core.PApplet`, `Scenario`, `StandardRenderer`, `SimulationLogger`, `InputHandler`.

#### Methods:
- **`StandardInputHandler(Scenario scenario, StandardRenderer renderer, SimulationLogger logger, PApplet p)`**
  - **Input Params**: `Scenario scenario`, `StandardRenderer renderer`, `SimulationLogger logger`, `PApplet p`.
  - **Outputs**: None (Constructor).
  - **Methodology**: Connects the input handler to the simulation components and sets default camera parameters.
- **`handleKeyPressed(char key)`**
  - **Input Params**: `char key`.
  - **Outputs**: `void`.
  - **Methodology**: Implements logic for a wide range of keyboard controls including simulation toggles, reset functionality, zoom, visibility of visual elements, and data logging.
- **`handleMouseDragged(float mouseX, float pmouseX, float mouseY, float pmouseY)`**
  - **Input Params**: `float mouseX`, `float pmouseX`, `float mouseY`, `float pmouseY`.
  - **Outputs**: `void`.
  - **Methodology**: Updates the X and Y rotation angles based on mouse movement deltas.
- **`getRotX()`, `getRotY()`, `getZoom()`**
  - **Input Params**: None.
  - **Outputs**: `float`.
  - **Methodology**: Getters for the current camera state.

## StandardRenderer.java

High-performance implementation of the `Renderer` interface that uses a hybrid approach for rendering planet trails: baked `PShape` segments for history and Immediate Mode for the active "tip" to avoid GPU buffer churn.

### Class: `StandardRenderer`
- **Dependencies**: `processing.core.PApplet`, `processing.core.PConstants`, `processing.core.PShape`, `java.util.ArrayList`, `Universe`, `Planet`, `Vec3`, `Renderer`.

#### Methods:
- **`reset(Universe universe, PApplet p)`**
  - **Input Params**: `Universe universe`, `PApplet p`.
  - **Outputs**: `void`.
  - **Methodology**: Initializes a sphere template and rebuilds trail segments/caches from the universe's history to ensure visual continuity.
- **`render(Universe universe, PApplet p)`**
  - **Input Params**: `Universe universe`, `PApplet p`.
  - **Outputs**: `void`.
  - **Methodology**: The main rendering loop. It handles reset detection, updates trail data with new simulation steps, centers the camera on the center of mass or a specific planet, and draws all enabled visual elements (tails, planets, velocity vectors, and center of mass).
- **`updateTrails(Universe universe, PApplet p)`**
  - **Input Params**: `Universe universe`, `PApplet p`.
  - **Outputs**: `void`.
  - **Methodology**: Identifies new simulation steps since the last frame and converts their coordinates into trail vertices stored in segments or caches.
- **`drawAllTails(PApplet p)`**
  - **Input Params**: `PApplet p`.
  - **Outputs**: `void`.
  - **Methodology**: Efficiently draws long trails by rendering retained `PShape` objects for older history and using immediate mode for the most recent points.
- **`drawAllPlanets(Universe universe, PApplet p)`**
  - **Input Params**: `Universe universe`, `PApplet p`.
  - **Outputs**: `void`.
  - **Methodology**: Iterates through all planets, applying transformations to a shared sphere template to draw them at their respective positions and scales.
- **`drawCenter(Universe universe, PApplet p)`**
  - **Input Params**: `Universe universe`, `PApplet p`.
  - **Outputs**: `void`.
  - **Methodology**: Renders a marker at the center of mass of the system.
- **`drawVelocity(Universe universe, PApplet p)`**
  - **Input Params**: `Universe universe`, `PApplet p`.
  - **Outputs**: `void`.
  - **Methodology**: Renders velocity vectors for each planet and the system's overall center of mass.
- **`drawArrow(Vec3 start, Vec3 vec, float scale, int col, PApplet p)`**
  - **Input Params**: `Vec3 start`, `Vec3 vec`, `float scale`, `int col`, `PApplet p`.
  - **Outputs**: `void`.
  - **Methodology**: A helper method that draws a 3D arrow representing a vector (like velocity or force) originating from a point.

## SystemAnalyzer.java

Utility class for analyzing the state of the simulation system, primarily for detecting instability.

### Class: `SystemAnalyzer`
- **Dependencies**: `Universe`, `Planet`, `Vec3`.

#### Methods:
- **`isSystemUnstable(Universe universe, float G)`**
  - **Input Params**: `Universe universe`, `float G`.
  - **Outputs**: `boolean`.
  - **Methodology**: Static utility method. Iterates through each planet and checks for:
    1.  `NaN` or `Infinite` coordinates.
    2.  Escape energy: Calculates kinetic energy ($K = \frac{1}{2} m v^2$) and potential energy ($U = -\sum \frac{G m_a m_b}{r + \epsilon}$). If $K + U \ge 0.2f$, the planet is considered to have sufficient energy to escape the system, triggering an instability flag.

## Universe.java

Represents the physical environment containing all planets and managing the simulation state, including global forces, integration, and history recording.

### Class: `Universe`
- **Dependencies**: `java.util.ArrayList`, `Planet`, `Vec3`, `ForceModel`, `Integrator`, `VerletIntegrator`.

#### Methods:
- **`Universe(ArrayList<Planet> planets, float dt, ForceModel forceModel)`**
  - **Input Params**: `ArrayList<Planet> planets`, `float dt`, `ForceModel forceModel`.
  - **Outputs**: None (Constructor).
  - **Methodology**: Initializes the universe with a set of planets, a time step, and a force model. Pre-allocates a large circular buffer for position history and performs initial physical calculations.
- **`findCenter()`**
  - **Input Params**: None.
  - **Outputs**: `void`.
  - **Methodology**: Calculates the center of mass (CM) and the CM velocity for the entire system by performing a mass-weighted average of all planets' positions and velocities.
- **`recordHistory()`**
  - **Input Params**: None.
  - **Outputs**: `void`.
  - **Methodology**: Captures the current positions of all planets and stores them in an optimized circular buffer for later rendering or analysis.
- **`update()`**
  - **Input Params**: None.
  - **Outputs**: `void`.
  - **Methodology**: Advances the simulation by one time step. It uses the assigned integrator to update planet states, updates the system's center of mass, and records the new state in history.
- **`getHistoryPos(int stepIdx, int planetIdx)`**
  - **Input Params**: `int stepIdx`, `int planetIdx`.
  - **Outputs**: `Vec3`.
  - **Methodology**: Retrieves a planet's position from a specific point in time from the circular history buffer, handling index wrapping logic.
- **`getHistoryCount()`**
  - **Input Params**: None.
  - **Outputs**: `int`.
  - **Methodology**: Returns the number of historical snapshots currently available in the buffer.

## Vec3.java

A utility class representing a 3D vector, providing a suite of static and instance methods for vector mathematics.

### Class: `Vec3`
- **Dependencies**: None.

#### Methods:
- **`Vec3(float x, float y, float z)`**
  - **Input Params**: `float x`, `float y`, `float z`.
  - **Outputs**: None (Constructor).
  - **Methodology**: Initializes a 3D vector with the specified spatial components.
- **`zero()`, `add()`, `sub()`, `neg()`, `scale()`, `mag()`, `dot()`, `normalize()`, `cross()` (Static)**
  - **Input Params**: Vectors and/or scalar values.
  - **Outputs**: New `Vec3` instances or `float` results.
  - **Methodology**: Implements standard linear algebra operations for 3D vectors.
- **`rotateAround(Vec3 v, Vec3 axis, float theta)` (Static)**
  - **Input Params**: `Vec3 v` (target), `Vec3 axis`, `float theta` (angle in radians).
  - **Outputs**: New `Vec3` (rotated).
  - **Methodology**: Implements Rodrigues' rotation formula to rotate a vector around an arbitrary axis.
- **`add()`, `sub()`, `neg()`, `scale()`, `normalize()`, `rotateAround()` (Instance)**
  - **Input Params**: Vectors and/or scalar values.
  - **Outputs**: `void`.
  - **Methodology**: Mutates the current vector instance by applying the respective mathematical operation.
- **`dot()`, `mag()`, `cross()`, `copy()` (Instance)**
  - **Input Params**: Vectors (for dot/cross).
  - **Outputs**: `float`, `Vec3`, or a new copy of the current vector.
  - **Methodology**: Returns information about the current vector or a related vector without mutating the original.

## VerletIntegrator.java

Implementation of the Velocity Verlet integration algorithm, providing superior stability and energy conservation compared to basic Euler integration.

### Class: `VerletIntegrator`
- **Dependencies**: `Integrator`, `Universe`, `Planet`, `Vec3`.

#### Methods:
- **`update(Universe universe, float dt)`**
  - **Input Params**: `Universe universe`, `float dt`.
  - **Outputs**: `void`.
  - **Methodology**: Executes the Velocity Verlet integration steps:
    1.  Stores the current acceleration as `oldAcc`.
    2.  Updates positions using current velocity and acceleration: $r(t + \Delta t) = r(t) + v(t)\Delta t + \frac{1}{2}a(t)\Delta t^2$.
    3.  Calculates new forces/accelerations for the updated positions.
    4.  Updates velocities using the average of old and new accelerations: $v(t + \Delta t) = v(t) + \frac{1}{2}(a(t) + a(t + \Delta t))\Delta t$.

## three_body_v2.pde

The main Processing entry point for the three-body simulation. It orchestrates the initialization and execution of all system components.

### Global Variables:
- `globalFrameRate`: Target frame rate for the applet.
- `defaultEyeZ`: Calculated initial Z position for the camera based on field of view.
- `logger`: Instance of `SimulationLogger`.
- `renderer`: Instance of `StandardRenderer`.
- `scenario`: Instance of `RandomNBodyScenario`.
- `input`: Instance of `StandardInputHandler`.

#### Methods:
- **`setup()`**
  - **Input Params**: None (Processing callback).
  - **Outputs**: `void`.
  - **Methodology**: Configures the 3D rendering environment, initializes the simulation scenario, sets up the CSV logging file with a timestamped name, and initializes the renderer and input handler.
- **`draw()`**
  - **Input Params**: None (Processing callback).
  - **Outputs**: `void`.
  - **Methodology**: The core animation loop. It updates the simulation state, processes user input for camera control, calculates the 3D perspective based on rotation and zoom, and renders the current state of the universe. It also displays an FPS counter in the UI.
- **`keyPressed()`**
  - **Input Params**: None (Processing callback).
  - **Outputs**: `void`.
  - **Methodology**: Intercepts keyboard events and delegates them to the `StandardInputHandler` for processing.

