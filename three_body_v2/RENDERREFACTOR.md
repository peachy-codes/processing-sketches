# Rendering Refactor Proposal: Transitioning to Retained Mode (`PShape`)

This document outlines the detailed plan to refactor the simulation's rendering system from immediate mode to retained mode using Processing's `PShape` class. This refactor is critical for handling high particle counts and long trail histories without degrading frame rates.

## 1. Analysis of Current State

The current `StandardRenderer` utilizes **Immediate Mode Rendering**:
- **Tails:** Every frame, the entire `universe.history` is iterated. For each planet, `beginShape()`, thousands of `vertex()` calls, and `endShape()` are executed.
- **Planets:** Each planet is drawn using the `sphere()` command, which involves generating a high-poly sphere mesh on the CPU and sending it to the GPU every frame.
- **Complexity:** If there are 10 planets and 10,000 history steps, the renderer performs 100,000 `vertex()` calls per frame. This is the primary bottleneck for "Painting" aesthetics.

## 2. Desired State: Retained Mode (`PShape`)

Transitioning to **Retained Mode** allows vertex data to be stored in GPU memory (as Vertex Buffer Objects or VBOs):
- **Tails:** Each planet's trail will be a single `PShape` object. When a new position is recorded, we only need to update the `PShape` or append a vertex.
- **Planets:** A single sphere `PShape` can be created once and transformed (`translate`, `scale`) for each planet, or we can use a group shape.
- **Performance:** Reduces CPU-to-GPU data transfer by several orders of magnitude.

---

## 3. Implementation Plan

### Stage 1: Infrastructure for `PShape` Management
Modify `StandardRenderer` to store and manage `PShape` objects.

**Proposed Class Fields:**
```java
private HashMap<Planet, PShape> trailShapes = new HashMap<>();
private PShape planetSphere; // Shared high-poly sphere
```

### Stage 2: Trail Optimization (The "Painting" Component)
Instead of re-drawing the whole history, we will use a dynamic `PShape`.

**Implementation Steps:**
1.  On initialization, create a `PShape` of type `PATH` for each planet.
2.  In the `render()` loop, instead of iterating `universe.history`, simply call `p.shape(trailShapes.get(pl))`.
3.  Implement an `updateTails(Universe universe)` method that appends the latest planet positions to their respective `PShape`.

### Stage 3: Planet Rendering Optimization
**Implementation Steps:**
1.  In `setup()`, create a reference sphere: `planetSphere = p.createShape(PConstants.SPHERE, 1)`.
2.  In `drawPlanets()`, use:
    ```java
    p.pushMatrix();
    p.translate(pl.pos.x, pl.pos.y, pl.pos.z);
    p.scale(pl.mass);
    p.shape(planetSphere);
    p.popMatrix();
    ```

### Stage 4: Buffer and Reset Handling
When the simulation resets (Stage 2 of `NEXTSTEPS.md`), the `PShape` objects must be cleared or recreated to avoid drawing trails from previous episodes.

---

## 4. Modified Class Scaffolding

### `StandardRenderer` Refactor
```java
public class StandardRenderer implements Renderer {
    private ArrayList<PShape> trailShapes;
    private PShape sphereTemplate;
    private boolean initialized = false;

    private void initShapes(Universe universe, PApplet p) {
        trailShapes = new ArrayList<>();
        for (Planet pl : universe.planets) {
            PShape s = p.createShape();
            s.beginShape();
            s.noFill();
            s.stroke(pl.c);
            s.strokeWeight(pl.mass / 2.0f);
            s.endShape();
            trailShapes.add(s);
        }
        sphereTemplate = p.createShape(PConstants.SPHERE, 1.0f);
        initialized = true;
    }

    public void updateShapes(Universe universe) {
        // Efficiently append only the newest vertex to each trail PShape
        for (int i = 0; i < universe.planets.size(); i++) {
            Vec3 pos = universe.planets.get(i).pos;
            trailShapes.get(i).addChild(p.createShape(PConstants.POINT, pos.x, pos.y, pos.z)); 
            // Note: Exact PShape update method varies by Processing version (vertex appending vs rebuilding)
        }
    }

    @Override
    public void render(Universe universe, PApplet p) {
        if (!initialized) initShapes(universe, p);
        // ... rendering logic using p.shape(s) ...
    }
}
```

---

## 5. Performance Gains Analysis

| Metric | Current (Immediate) | Proposed (Retained) | Improvement |
| :--- | :--- | :--- | :--- |
| **CPU Overhead** | High (Looping 10k vertices) | Low (Single call to `shape()`) | ~10x-50x |
| **GPU Communication** | High (Resending all points) | Near Zero (Vertices stay in VRAM) | ~100x |
| **Memory usage** | Low (ArrayList of Vec3) | Moderate (GPU VBO overhead) | Negligible on modern hardware |

## 6. Hurdles & Considerations
1.  **PShape Mutability:** Appending to a `PShape` in Processing can sometimes be tricky. If the path becomes too long, it may need to be "baked" or split into chunks.
2.  **Reset Synchronization:** The `Scenario` must signal the `Renderer` to call `initShapes()` again whenever the planets are randomized.
3.  **Color Mixing:** If we implement Stage 2 of `NEXTSTEPS.md` (color mixing), the `PShape` will need to support per-vertex colors, which requires using `s.fill()` or `s.stroke()` before each `s.vertex()` call during initialization.
