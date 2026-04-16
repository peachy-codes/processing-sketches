# Project Design Analysis Report: Three-Body V2

This report analyzes the architectural design of the `three_body_v2` project based on the documentation of its components.

## 1. Architectural Overview
The project follows a modular, interface-driven design. It separates physics (Universe/Integrator/ForceModel), logic (Scenario/SystemAnalyzer), rendering (Renderer), and I/O (InputHandler/SimulationLogger). However, several tight couplings and inconsistencies exist.

## 2. Anti-Patterns & Tight Coupling

### Dependency Inversion Violations
*   **Universe.java**: The `Universe` constructor hardcodes `this.integrator = new VerletIntegrator()`. This prevents the use of other integrators despite the existence of the `Integrator` interface.
*   **RandomNBodyScenario.java**: The `reset()` method hardcodes the creation of `NewtonianGravity`. Scenarios should ideally be agnostic of the specific force model unless the scenario's definition requires it.

### Responsibility Overlap (God Object Tendencies)
*   **RandomNBodyScenario.java**: This class manages the simulation loop, stability checks, episode counting, and specific logging triggers (e.g., calling `logger.closeLog()` and `p.exit()`). This mixes high-level simulation management with scenario-specific configuration.
*   **SimulationLogger.java**: The `dumpCurrentState` method contains hardcoded logic for exactly 8 planets. This contradicts `RandomNBodyScenario`, which generates 100-101 bodies, leading to data loss or crashes when dumping state.

### Hardcoded Magic Numbers
*   **SystemAnalyzer.java**: Uses a hardcoded instability threshold of `0.2f`.
*   **StandardRenderer.java**: Uses a hardcoded `MAX_VERTICES_PER_SEGMENT = 1000`.
*   **RandomNBodyScenario.java**: Has hardcoded bounds (300) and mass ranges (1.0 - 30.0).

## 3. Potential Improvements

### Scalability
*   **Gravity Calculation**: `NewtonianGravity` uses an $O(N^2)$ approach. While acceptable for a few bodies, it will significantly lag with the 100+ bodies defined in `RandomNBodyScenario`. Implementation of a Barnes-Hut algorithm or similar would improve performance.
*   **Dynamic Logging**: `SimulationLogger` should dynamically generate CSV headers based on the actual number of planets in the `Universe` rather than assuming 3 (in `setup`) or 8 (in `dumpCurrentState`).

### Consistency
*   **Softening Factors**: Softening is applied inconsistently across the codebase. `NewtonianGravity` uses `1.0f`, `SystemAnalyzer` uses `1.0f`, but `RandomNBodyScenario.reset()` uses `r + 1.0f` for potential energy checks. These should be centralized.
*   **Center of Mass**: Both `Universe` and `StandardRenderer` calculate or handle the Center of Mass. `Universe` is the source of truth, but `StandardRenderer` performs its own validation.

### Performance
*   **History Buffer**: `Universe` stores a very large history buffer (30,000 steps). For 100+ planets, this represents a significant memory footprint. A more compressed or sparse history recording mechanism could be considered if memory becomes an issue.

## 4. Missing Methods/Functionality

*   **Universe.java**: Missing a `setIntegrator(Integrator i)` method to allow runtime switching of integration schemes.
*   **Scenario.java / Universe.java**: Missing a method to clear or export the history buffer manually without resetting the simulation.
*   **ForceModel.java**: Could benefit from a `getPotentialEnergy(Universe u)` method so that `SystemAnalyzer` doesn't have to re-implement gravity logic to check for instability.
*   **SimulationLogger.java**: Missing a method to resume logging or append to an existing file without overwriting or creating a new timestamped file every time (though `dumpCurrentState` attempts some appending).

## 5. Summary
The project has a solid foundation with clear interfaces. The primary risks are the hardcoded limits in the logger and the tight coupling between the physical containers (`Universe`/`Scenario`) and their specific implementations (`VerletIntegrator`/`NewtonianGravity`). Addressing these would make the system truly extensible for different physical simulations.
