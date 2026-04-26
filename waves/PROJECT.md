# Mesh Physics Engine Specification

This document details the architectural design and structural implementation of a generic, extensible 3D Mesh Physics Engine. The design prioritizes the decoupling of physical mass, topological constraints, and environmental forces.

## Core Architectural Components

### 1. The Point Mass (Node)
The fundamental unit of the simulation. It represents a single vertex in 3D space with inertia.
*   **Methodology:** Uses **Verlet Integration**.
*   **Contract:**
    *   `Node(float x, float y, float z, boolean isPinned)`: Initializes a node at a given 3D coordinate.
    *   `void update()`: Updates the node's position based on its velocity (derived from `x - oldX`) and environmental constants (friction, gravity).
    *   `float getVelocity()`: Returns the magnitude of the current velocity vector.

### 2. Constraints (Edge)
Constraints define the rules governing the relationship between Nodes.
*   **Methodology:** Implemented via an **Interface Pattern** (`Constraint`).
*   **Contract:**
    *   `interface Constraint`:
        *   `void resolve()`: Enforces the physical rule (e.g., pulls nodes together).
        *   `boolean isBroken()`: Returns true if the constraint has exceeded its failure threshold.
    *   `SpringConstraint(Node n1, Node n2, float stiffness, float stretchLimit)`: A specific distance constraint between two nodes.

### 3. The Mesh System (Orchestrator)
The high-level container that manages the lifecycle of all nodes and constraints.
*   **Contract:**
    *   `void update(int time)`: Performs one physics step (Node updates followed by iterative Constraint resolution). Handles the removal of broken constraints.
    *   `void display()`: Renders the mesh surface and caches `sx/sy` screen coordinates for picking.
    *   `Node getClosestNode(float mx, float my, float threshold)`: Performs a spatial search to find the nearest node to a screen coordinate.

### 4. Geometry Factory (Mesh Factory)
A structural pattern used to generate specific topologies.
*   **Contract:**
    *   `MeshSystem createRectangularGrid(int cols, int rows, float spacing, ...)`: Generates a standard grid mesh.
    *   `MeshSystem createCircularMesh(int rings, int segments, float radius, ...)`: Generates a radial mesh topology.
    *   `MeshSystem loadObj(String filename)`: Parses a Wavefront OBJ file into nodes and constraints.

### 5. Modifiers & Animations
Interface for driving kinematic animations on specific nodes.
*   **Contract:**
    *   `interface Modifier`:
        *   `void apply(Node n, int time)`: Directly modifies a node's position for a specific frame.
    *   `DirectionalOscillator(PVector dir, float amp, float freq)`: Implements a periodic movement along a 3D vector.

### 6. Interaction Strategies
Strategy pattern for decoupling input logic from the main application.
*   **Contract:**
    *   `interface InteractionStrategy`:
        *   `void mousePressed(float mx, float my, int button)`
        *   `void mouseDragged(float mx, float my, float pmx, float pmy, int button, ...)`
        *   `void mouseReleased(int button)`
    *   `DragInteraction(MeshSystem sys)`: Implements a strategy for picking and dragging nodes in 3D space.

## Functional Signatures Summary

| File | Class/Interface | Method Signature | Purpose |
| :--- | :--- | :--- | :--- |
| `Node.pde` | `Node` | `update()` | Applies Verlet integration and gravity. |
| `Constraint.pde` | `Constraint` | `resolve()` | Satisfies the spatial rule between connected nodes. |
| `MeshSystem.pde` | `MeshSystem` | `update(int time)` | Orchestrates the entire physics step. |
| `MeshSystem.pde` | `MeshSystem` | `getClosestNode(float, float, float)` | Resolves screen-to-world picking. |
| `MeshFactory.pde` | `MeshFactory` | `createCircularMesh(...)` | Generates radial connectivity. |
| `Settings.pde` | `Settings` | N/A | Centralizes all physical and structural constants. |
| `Modifier.pde` | `Modifier` | `apply(Node, int)` | Modifies node position for driven animations. |
| `InteractionStrategy.pde` | `InteractionStrategy` | `mousePressed(...)` | Decouples input state from the simulation loop. |
| `Renderer.pde` | `MeshRenderer` | `render(MeshSystem)` | Decouples visualization from physics. |
| `EventBus.pde` | `EventBus` | `publish(String, JSONObject)` | Global event dispatcher. |
| `BeatDetector.pde` | `BeatDetector` | `update()` | Wraps Minim for beat-based event emission. |

## Event System
The simulation uses a global `EventBus` to decouple modules. 
*   **Events:** Represented as `JSONObject` instances.
*   **Listeners:** Any class implementing `EventListener` can subscribe to specific event types.

## Music & Synchronization
Integrates with the **Minim** library to drive physical parameters through audio analysis.
*   **BeatDetector:** Publishes "BEAT" events to the bus when an audio peak is detected.
*   **MusicListener:** Interface for components that react to bus-driven audio events (e.g., modulating amplitude on a beat).

## Simulation Lifecycle
1.  **Inertia Pass:** Update every `Node` based on previous movement + global forces (Gravity).
2.  **Animation Pass:** Apply `Modifiers` to drive specific nodes (e.g., motor-driven corners).
3.  **Constraint Pass:** Run the `Constraint.resolve()` loop $N$ times (Stability vs. Performance trade-off).
4.  **Culling Pass:** Remove any constraints marked as `Broken`.
5.  **Render Pass:** Map node positions to vertices and draw the defined `Faces`.
