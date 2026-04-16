# Next Steps: Project Improvement Roadmap

This document outlines proposed solutions to the architectural and design issues identified in the `CURRENT_REPORT.md`.

## 1. Enhancing Flexibility & Decoupling

### 1.1 Implement Dependency Injection
*   **Action**: Update the `Universe` constructor to accept an `Integrator` as an argument rather than hardcoding `VerletIntegrator`.
*   **Action**: Add `setIntegrator(Integrator i)` and `setForceModel(ForceModel f)` to the `Universe` class.
*   **Action**: Update `RandomNBodyScenario` to accept a `ForceModel` factory or instance during initialization to avoid hardcoding `NewtonianGravity`.

### 1.2 Decouple Scenario Logic
*   **Action**: Move the stability check and "episode reset" logic out of `RandomNBodyScenario.update()` and into the main simulation loop in `three_body_v2.pde` or a new `SimulationManager` class.
*   **Goal**: The Scenario should only define the *initial state* and *rules*, not control the application's lifecycle (like calling `p.exit()`).

## 2. Dynamic & Scalable Logging

### 2.1 Refactor SimulationLogger
*   **Action**: Remove the hardcoded 8-planet limit in `dumpCurrentState`.
*   **Action**: Implement dynamic header generation in the logger that checks `universe.planets.size()` and builds the CSV structure accordingly.
*   **Action**: Ensure `logEpisode` and `dumpCurrentState` use the same serialization logic to prevent data inconsistencies.

## 3. Centralizing Constants & Physics

### 3.1 Configuration Management
*   **Action**: Create a `SimulationConfig` class or a simple `Constants.java` file to store:
    *   Softening factor (e.g., `SOFTENING = 1.0f`).
    *   Instability threshold (e.g., `ESCAPE_ENERGY_THRESHOLD = 0.2f`).
    *   Rendering limits (e.g., `MAX_VERTICES_PER_SEGMENT`).
*   **Action**: Replace all occurrences of these magic numbers with references to this central config.

### 3.2 Optimize Physics Logic
*   **Action**: Add `float getPotentialEnergy(Universe u)` and `float getPotentialEnergy(Planet p, Universe u)` to the `ForceModel` interface.
*   **Action**: Update `SystemAnalyzer` to use these methods, ensuring that the physics engine and the analyzer are always using the same mathematical model.

## 4. Performance & Scalability

### 4.1 Advanced Force Models
*   **Action**: Implement a `BarnesHutGravity` class as an alternative `ForceModel`. This will reduce complexity from $O(N^2)$ to $O(N \log N)$, allowing the simulation to scale effectively to the 100+ bodies currently used.

### 4.2 Sparse History Recording
*   **Action**: Add a `recordingInterval` to `Universe.recordHistory()`. Instead of recording every step, record every $N$ steps to save memory while still providing enough data for smooth trail rendering.

## 5. UI & Interaction Improvements

### 5.1 Real-time Feedback
*   **Action**: Add methods to `Renderer` to display the current simulation settings (Force Model, Integrator, Softening) on the screen.
*   **Action**: Update `StandardInputHandler` to allow toggling between different `ForceModels` or `Integrators` at runtime using key triggers.

## Implementation Priority
1.  **High**: Fix `SimulationLogger` (Prevent data loss/crashes).
2.  **High**: Centralize Softening/Constants (Ensure physical accuracy).
3.  **Medium**: Implement Dependency Injection (Enable extensibility).
4.  **Low**: Implement $O(N \log N)$ Gravity (Performance optimization for large systems).
