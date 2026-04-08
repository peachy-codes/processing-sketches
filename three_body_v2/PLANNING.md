# Technical Feasibility and Strategic Planning Report

This document provides a detailed analysis of the proposed implementation plan for the Three-Body Painting project. It evaluates the feasibility, workload, and technical strategies required to achieve the goals outlined in `TODO.md`.

## 1. Executive Summary
The project is transitioning from a physical simulation to a "painting" or generative art tool. While the current foundation is solid (Verlet integration, modular force models), the proposed features introduce significant technical complexity, particularly in spatial partitioning and GPU offloading.

---

## 2. Stage-by-Stage Analysis

### Stage 1: Advanced Analysis & "Good Run" Detection
- **Feasibility:** High.
- **Workload:** Moderate. The challenge is defining "interesting" mathematically (e.g., low-distance encounters without immediate escape).
- **Best Practices:** Use **Heuristic-based Scoring**. Implement the `InteractionAnalyzer` as a stateless utility class.
- **Hurdles:** Balancing sensitivity; too many "good runs" makes the detection meaningless.
- **Design Pattern:** **Strategy Pattern**. You can have different "Interst Heuristics" for different aesthetic goals.

### Stage 2: Enhanced Aesthetics & Reset Logic
- **Feasibility:** High.
- **Workload:** Moderate-High (Creative intensive). Mixing colors based on mass and momentum requires careful interpolation logic.
- **Best Practices:** Use **Linear Interpolation (LERP)** for colors in the HSB space rather than RGB for more natural "paint-like" mixing. Use a **State Machine** for reset transitions (e.g., FadeOut -> Scramble -> FadeIn).
- **Hurdles:** Rapid resets can cause visual flickering if not handled with double-buffering or motion blur.

### Stage 3: Spatial Partitioning (Octrees)
- **Feasibility:** Moderate.
- **Workload:** High. Implementing an Octree (3D Quadtree) correctly is non-trivial.
- **Best Practices:** **Object Pooling**. Do not create new Octree nodes every frame; reuse them to avoid Garbage Collection (GC) spikes.
- **Hurdles:** Octrees only provide performance gains when $N > 100$. For small $N$, the overhead of building the tree exceeds the savings in force calculation.
- **Anti-pattern:** **Deep Recursion**. Ensure the tree has a maximum depth to prevent stack overflow in edge cases where many planets cluster in one spot.

### Stage 4: State Buffering & Pre-computation
- **Feasibility:** High.
- **Workload:** Moderate.
- **Best Practices:** Use **Circular Buffers** to manage history without constant memory allocation. Implement **Snapshotting** only for the minimum necessary data (e.g., positions and velocities) to save space.
- **Hurdles:** Memory management for large history buffers. Each snapshot takes $N \times 12$ bytes (for 3 floats per planet). For many planets and long histories, this can add up to several hundred MBs.
- **Hurdles (Pre-computation):** Stability of the integrator over long predictions. The pre-computation should use the same integration scheme (`VerletIntegrator`) as the main simulation to ensure visual consistency.

### Stage 5: GPU Offloading
- **Feasibility:** Low-to-Moderate (Environment Dependent).
...
| Stage | Estimated Effort | Primary Skill Required |
| :--- | :--- | :--- |
| Stage 1: Analysis | 1-2 days | Mathematics / Logic |
| Stage 2: Aesthetics | 2-3 days | Creative / UI Design |
| Stage 3: Octrees | 3-5 days | Data Structures |
| Stage 4: Buffering | 1-2 days | Memory Management |
| Stage 5: GPU | 7-10 days | Shader Programming (GLSL) |
| Stage 6: Camera | 1-2 days | Calculus / Smoothing |


---

## 5. Final Recommendation
Start with **Stage 1 and 2** in parallel. They offer the highest "Visual ROI" (Return on Investment) for the "Painting" goal. Delay **Stage 4 (GPU)** until the core artistic "feel" of the simulation is perfected on the CPU.
