# Implementation Plan: Three-Body Painting

This document outlines the proposed stages for implementing the features and improvements identified in `TODO.md`.

---

## [COMPLETED] Stage 1: Advanced Analysis and "Good Run" Detection
*Implemented basic stability analysis and CSV logging.*

---

## [COMPLETED] Stage 2: Enhanced Aesthetics and Reset Logic
*Implemented randomized scenarios and robust reset handling.*

---

## [COMPLETED] Stage 3: Retained Mode Rendering Refactor
*Goal achieved: Transitioned to a hybrid rendering system using baked `PShape` segments and immediate-mode tips. Resolved all GPU address fault crashes and artifacts.*

---

## Stage 4: Spatial Partitioning and Physical Subdivision
*Goal: Optimize CPU-side calculations for many bodies (N > 100) using Octrees.*

### New Class: `QuadTree3D` (Octree)
```java
public class QuadTree3D {
    public void insert(Planet p)
    public ArrayList<Planet> query(Vec3 center, float radius)
}
```

---

## Stage 5: State Buffering and Pre-computation
*Goal: Implement efficient state storage for the "rewind," "decay," and "stutter" effects.*

### New Class: `HistoryBuffer`
```java
public class HistoryBuffer {
    public void pushState(Universe universe)
    public Vec3[] getStateAt(int stepsAgo)
}
```

---

## Stage 6: GPU Offloading
*Goal: Leverage Compute Shaders for physics calculations once N reaches large scales.*

---

## Stage 7: Intelligent Camera and Final Polish
*Goal: Automate camera movement to follow the most interesting planetary clusters.*
