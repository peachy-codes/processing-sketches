# Root Cause Analysis: Trail Rendering Failures and GPU Crashes

This document explains why the current chunked trail rendering system is failing despite previous optimization attempts.

---

## 1. The `PShape` GROUP Initialization Bug
**Issue:** The "dropping chunks" phenomenon (where the first segment is visible but subsequent ones disappear) is a direct result of how Processing's `P3D` renderer handles `GROUP` type `PShapes`.
- When `group.addChild(baked)` is called after the group has already been rendered once, the new child often fails to have its geometry uploaded to the GPU correctly.
- Because the renderer treats the `GROUP` as a retained object, it does not always check for new children unless the entire group is marked as "changed," which is inconsistent across Processing versions and platforms (especially Metal on macOS).

## 2. High-Frequency Buffer Creation (Churn)
**Issue:** The code currently calls `p.createShape()` and `s.beginShape()` every single frame for every planet's active tip.
- At 240 FPS with 8 planets, this creates **1,920 new GPU buffers per second**.
- This high churn rate leads to memory fragmentation in VRAM and eventually causes the `MTLCommandBufferErrorDomain Code=3` (GPU Address Fault) error. The GPU driver simply cannot keep up with the allocation/deallocation cycle.

## 3. History Retrieval Race Condition
**Issue:** The `updateTrails` logic relies on `stepsToProcess = universe.totalSteps - lastProcessedTotalStep`.
- If the simulation performs 5,000 sub-steps in one frame (e.g., during a "fast" segment), the renderer attempts to pull all 5,000 points from the circular buffer.
- If the buffer size or the retrieval logic doesn't perfectly align with the `lastProcessedTotalStep`, the renderer may read "stale" data from the buffer head that has already been overwritten, leading to the "vertices at infinite" jumps.

## 4. Continuity and Gaps
**Issue:** The "bridge" vertex logic (adding the last point of a full segment to the new segment) is correct in theory but fails if the `baked` segment itself is not rendered due to Bug #1. This makes the trail appear to have missing sections.

---

## Summary of Flawed Reasoning
The previous approach assumed that "Chunking" would solve the GPU overhead. However, it replaced one problem (large buffers) with another (buffer churn and group synchronization). The GPU is crashing not because of the *amount* of data, but because of the *way* the data is being fed to it (too many small objects created too fast).

---

## Required Architectural Shift
To solve this, the renderer must:
1.  **Eliminate the `GROUP` PShape**: Use a flat `ArrayList<PShape>` and iterate manually.
2.  **Stop per-frame `PShape` creation**: Use a small number of large, pre-allocated `PShape` objects and only update them when necessary.
3.  **Decouple Simulation and Rendering Steps**: Ensure the renderer only samples the *most recent* history instead of trying to catch up on thousands of sub-steps that aren't visually significant at 60-240 FPS.
