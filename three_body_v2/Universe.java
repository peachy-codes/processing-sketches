// Universe.java

import java.util.ArrayList;
import java.util.ArrayDeque;

/**
 * Represents the universe containing all planets and managing the simulation state.
 * It handles global forces, integration, and history recording.
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
    /** A history of planet positions for rendering trails. */
    public ArrayDeque<Vec3[]> history;
    /** The maximum number of history steps to store. */
    public int maxHistory = 10000;
    /** The integrator used for updating planet states. */
    public Integrator integrator;

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
        this.history = new ArrayDeque<Vec3[]>();
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
     * Records the current positions of all planets in the history.
     */
    public void recordHistory() {
        Vec3[] currentPositions = new Vec3[planets.size()];
        for (int i = 0; i < planets.size(); i++) {
            currentPositions[i] = planets.get(i).pos.copy();
        }
        this.history.addLast(currentPositions);

        if (this.history.size() > this.maxHistory) {
            this.history.removeFirst();
        }
    }

    /**
     * Updates the universe by one time step using the integrator.
     */
    public void update() {
        this.integrator.update(this, this.dt);
        findCenter();
        recordHistory();
    }
}
