# Performance Analysis Report

This document identifies potential performance bottlenecks in the current implementation of the Three-Body Simulation.

---

## 1. Algorithmic Bottlenecks

### `NewtonianGravity.java`
- **Issue:** The `applyForces` method uses a nested loop to calculate gravitational forces between every pair of bodies.
- **Complexity:** $O(N^2)$, where $N$ is the number of planets.
- **Impact:** While acceptable for 3-10 bodies, performance will degrade exponentially as $N$ increases (e.g., $N > 100$).
- **Recommendation:** Implement a Barnes-Hut algorithm or the Octree structure proposed in `NEXTSTEPS.md` to reduce complexity to $O(N \log N)$.

### `Universe.java`
- **Issue:** The `findCenter` method recalculates the center of mass and its velocity by iterating through all planets every time-step.
- **Impact:** Minor, but redundant if the universe update is called many times per frame (sub-stepping).
- **Recommendation:** Update the center of mass incrementally as positions and velocities change, or only calculate it once per rendering frame rather than every time-step.

---

## 2. Memory & GC (Garbage Collection) Pressure

### `Universe.java`
- **Issue:** The `recordHistory()` method creates a new array (`new Vec3[planets.size()]`) and copies all planet positions every recording step.
- **Impact:** High frequency of small object allocations leading to GC "stutter" in long-running simulations.
- **Recommendation:** Use a pre-allocated pool of arrays or a more efficient flattened data structure (e.g., a single large `float[]`).

### `SimulationLogger.java`
- **Issue:** Uses `StringBuilder` and `toString()` for every logged episode and state dump.
- **Impact:** Frequent string allocations.
- **Recommendation:** Pre-format static parts of the string or use a more direct binary logging format if high-speed logging is required.

---

## 3. Rendering Bottlenecks

### `StandardRenderer.java`
- **Issue:** Uses immediate mode rendering commands (`sphere()`, `line()`, `beginShape()`) within the `draw()` loop.
- **Impact:** Every frame, Processing has to re-send all vertex data to the GPU. This is highly inefficient for drawing thousands of trail points.
- **Recommendation:** Move trail rendering to a `PShape` (retained mode) or use a Vertex Buffer Object (VBO).

### `three_body_v2.pde`
- **Issue:** `background(255)` and `camera()` resets occur every frame.
- **Impact:** Minor, but unnecessary for static UI elements.
- **Recommendation:** Only redraw the 3D scene when the simulation updates, and draw the 2D UI overlay on top.

---

## 4. Input & Control

### `StandardInputHandler.java`
- **Issue:** Continuous polling/handling in `draw()` can lead to missed frames if input processing becomes heavy.
- **Impact:** Low in the current state, but could become an issue if more complex logic is added to input events.

---

## 5. Summary Table

| File | Severity | Primary Issue | Recommendation |
| :--- | :--- | :--- | :--- |
| `NewtonianGravity.java` | **High** | $O(N^2)$ Complexity | Spatial Partitioning (Octree) |
| `Universe.java` | **Medium** | Array Allocations | Object Pooling / Flattening |
| `StandardRenderer.java` | **Medium** | Immediate Mode Rendering | Retained Mode (`PShape`) |
| `SimulationLogger.java` | **Low** | String Allocations | Buffer Reuse |
| `three_body_v2.pde` | **Low** | Redundant UI Drawing | Layered Rendering |
