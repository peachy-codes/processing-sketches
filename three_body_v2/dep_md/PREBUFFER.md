# Architectural Proposal: Precomputation and State Prebuffering

This document outlines the proposed refactor to transition the Three-Body Painting project from a real-time simulation to a **Decoupled Prebuffered Simulation Engine**. This architecture enables the system to anticipate future events (e.g., system collapses, high-speed encounters) and adjust visual aesthetics proactively.

---

## 1. The Core Limitation
Currently, the `Universe` is updated and rendered in the same thread (Processing's `draw()` loop).
- **Issue:** The renderer only knows the *present* and the *past* (history buffer).
- **Impact:** It is impossible to trigger visual cues (like a color shift or a camera zoom) *before* a collision happens, or to visualize "future paths" (ghost trails).

---

## 2. Proposed Architecture: Computation vs. Playback

The refactor introduces a separation between the **Simulation Engine** (the Producer) and the **Playback Engine** (the Consumer).

### A. The Episode Queue
A central buffer that stores "future" simulation episodes that have already been computed but not yet rendered.

### B. New Component: `SimulationWorker`
A background thread or high-speed loop that computes episodes as fast as the CPU allows.
- **Responsibility:** Runs the `VerletIntegrator`, performs `SystemAnalyzer` checks, and stores results into an `EpisodeContainer`.
- **Look-ahead:** Can maintain a buffer of 5-10 upcoming episodes.

### C. New Component: `AestheticDirector`
Analyzes the `Episode Queue` *before* playback.
- **Predictive Logic:** If it sees that Episode #4 only lasts for 50 ticks (a rapid collapse), it can send a signal to the `Renderer` to begin a "glitch" transition during Episode #3.
- **Metric Extraction:** Pre-calculates the "Interest Score" (from `NEXTSTEPS.md`) for upcoming episodes to prepare camera transitions.

---

## 3. Class Scaffolding

### `PreBufferQueue`
Manages the storage of future states.

```java
public class PreBufferQueue {
    /** Queue of completed episodes ready for playback. */
    private ArrayDeque<SimulationEpisode> queue;
    
    /** Maximum number of episodes to precompute. */
    private int lookAheadLimit = 5;

    public void addEpisode(SimulationEpisode ep)
    public SimulationEpisode getNextEpisode()
    public SimulationEpisode peekFuture(int count) // Look ahead 'n' episodes
}
```

### `SimulationEpisode` (Data Container)
A highly optimized snapshot of an entire run.

```java
public class SimulationEpisode {
    /** 
     * All states in the episode: [tick][planetIdx * 6 (posXYZ, velXYZ)]
     * Using flattened float arrays for extreme memory efficiency.
     */
    public float[][] stateData;
    public int totalTicks;
    public float initialPotentialEnergy;
    public float interestScore; // Pre-calculated by Director
}
```

---

## 4. Impact on Existing Files

### `Universe.java`
- Will be used primarily by the `SimulationWorker` as a "scratchpad" for computation.
- No longer needs to maintain a `historyBuffer` for rendering; the `PlaybackEngine` handles history.

### `StandardRenderer.java`
- **Transformation:** Instead of receiving a `Universe` object, it receives a `StateSnapshot` from the `PlaybackEngine`.
- **New Feature: Ghost Trails:** Can now peek into the `PreBufferQueue` to draw faint paths showing where planets *will* be in the next 500 steps.

### `RandomNBodyScenario.java`
- Acts as the orchestrator between the `SimulationWorker` and the `PreBufferQueue`.
- Handles the "Logic Reset" (generating new ICs) independently of the "Visual Reset".

---

## 5. Technical Challenges and Solutions

### Synchronization
- **Challenge:** User inputs (like toggling stability override) need to affect future computations.
- **Solution:** When a "Critical Setting" is changed, the `PreBufferQueue` is flushed, and the `SimulationWorker` restarts from the current playback state.

### Memory Pressure
- **Challenge:** Storing 100,000 steps for 5 episodes in advance could consume significant RAM.
- **Solution:** Store only positions in the prebuffer; velocities can be re-derived or stored at a lower temporal resolution (e.g., every 5th tick).

---

## 6. Visual Possibilities Enabled
1.  **Predictive Zoom:** Camera begins zooming into a close-encounter point *before* the planets arrive.
2.  **Harmonic Transitions:** Color palettes shift smoothly to match the "mood" of the upcoming episode (e.g., aggressive reds for high-speed collapses, calm blues for stable orbits).
3.  **Time Manipulation:** Slow down playback during the most "interesting" moments of an episode automatically.
