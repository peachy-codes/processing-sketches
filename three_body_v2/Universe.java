// Universe.java

import java.util.ArrayList;

/**
 * Represents the universe containing all planets and managing the simulation state.
 * It handles global forces, integration, and history recording using optimized buffers.
 */
public class Universe {
    /** The list of planets in the universe. */
    public ArrayList<Planet> planets;
    /** The time step for the simulation. */
    public float dt;
    /** The force model used to calculate interactions between planets. */
    public ForceModel forceModel;
    /** The center of mass of the system. */
    public Vec3 cm;
    /** The velocity of the center of mass. */
    public Vec3 cmVel;
    
    /** Circular buffer for planet positions: [step][planetIdx * 3 + (x,y,z)] */
    private float[][] historyBuffer;
    /** Current write index in the circular buffer. */
    private int historyIndex = 0;
    /** Number of steps currently stored in the buffer. */
    private int historyCount = 0;
    /** The maximum number of history steps to store. */
    public int maxHistory = 30000;
    
    /** The integrator used for updating planet states. */
    public Integrator integrator;
    /** Total number of simulation steps performed. */
    public int totalSteps = 0;

    /**
     * Constructs a new Universe.
     * 
     * @param planets list of planets
     * @param dt time step
     * @param forceModel force model to use
     */
    public Universe(ArrayList<Planet> planets, float dt, ForceModel forceModel) {
        this.planets = planets;
        this.dt = dt;
        this.forceModel = forceModel;
        this.cm = new Vec3(0f, 0f, 0f);
        this.cmVel = new Vec3(0f, 0f, 0f);
        
        // Pre-allocate history buffer
        this.historyBuffer = new float[maxHistory][planets.size() * 3];
        
        this.integrator = new VerletIntegrator();
        this.findCenter();
        this.forceModel.applyForces(this);
        this.recordHistory();
    }

    /**
     * Calculates the center of mass and its velocity for the system.
     */
    public void findCenter() {
        this.cm = new Vec3(0f, 0f, 0f);
        this.cmVel = new Vec3(0f, 0f, 0f);
        float totalMass = 0f;
        for (Planet p : planets) {
            Vec3 scaledPos = Vec3.scale(p.pos, p.mass);
            this.cm = Vec3.add(cm, scaledPos);

            Vec3 scaledVel = Vec3.scale(p.vel, p.mass);
            this.cmVel = Vec3.add(this.cmVel, scaledVel);

            totalMass += p.mass;
        }
        if (totalMass != 0) {
            this.cm = Vec3.scale(this.cm, 1.0f / totalMass);
            this.cmVel = Vec3.scale(this.cmVel, 1.0f / totalMass);
        }
    }

    /**
     * Records the current positions of all planets in the circular buffer.
     */
    public void recordHistory() {
        float[] currentStep = historyBuffer[historyIndex];
        for (int i = 0; i < planets.size(); i++) {
            Planet p = planets.get(i);
            currentStep[i * 3 + 0] = p.pos.x;
            currentStep[i * 3 + 1] = p.pos.y;
            currentStep[i * 3 + 2] = p.pos.z;
        }
        
        historyIndex = (historyIndex + 1) % maxHistory;
        if (historyCount < maxHistory) {
            historyCount++;
        }
    }

    /**
     * Updates the universe by one time step using the integrator.
     */
    public void update() {
        this.integrator.update(this, this.dt);
        this.totalSteps++;
        findCenter();
        recordHistory();
    }
    
    /**
     * Returns the position of a planet at a specific historical step.
     * 
     * @param stepIdx The historical step index (0 to historyCount - 1)
     * @param planetIdx The index of the planet
     * @return Vec3 The position at that step
     */
    public Vec3 getHistoryPos(int stepIdx, int planetIdx) {
        if (stepIdx < 0 || stepIdx >= historyCount) return null;
        
        // Calculate actual index in circular buffer
        int actualIdx;
        if (historyCount < maxHistory) {
            actualIdx = stepIdx;
        } else {
            actualIdx = (historyIndex + stepIdx) % maxHistory;
        }
        
        float[] stepData = historyBuffer[actualIdx];
        return new Vec3(stepData[planetIdx * 3 + 0], stepData[planetIdx * 3 + 1], stepData[planetIdx * 3 + 2]);
    }
    
    /**
     * Returns the current number of steps in history.
     * @return count
     */
    public int getHistoryCount() {
        return historyCount;
    }
}
