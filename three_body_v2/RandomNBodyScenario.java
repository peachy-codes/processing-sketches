import java.util.ArrayList;
import processing.core.PApplet;

/**
 * A scenario that generates a random number of bodies with random initial positions and velocities.
 * It manages the simulation loop, stability checks, and resetting the simulation for multiple episodes.
 */
public class RandomNBodyScenario implements Scenario {
    /** The universe instance for this scenario. */
    public Universe universe;
    /** Whether the simulation is currently running. */
    public boolean isRunning = false;
    /** Whether to override stability checks and continue the simulation regardless of instability. */
    public boolean stabilityOverride = false;
    
    /** The time step for each simulation update. */
    public float timeStep = 0.05f;
    /** The number of simulation steps to perform per rendering frame. */
    public int stepsPerFrame = 3;
    /** The current number of bodies in the simulation. */
    public int numBodies;
    /** The gravitational constant. */
    public float G = 10.0f;
    
    /** The current tick (step) count of the simulation. */
    public int ticks = 0;
    /** The maximum number of ticks allowed before resetting the simulation. */
    public int maxTicks = 5000000;
    /** The current episode count. */
    public int episodeCount = 0;
    /** The maximum number of episodes to run. Relevant when logging multiple episodes.*/
    public int maxEpisodes = 1000;

    public int minBodies = 100;
    public int maxBodies = 101;
    
    private PApplet p;

    /**
     * Constructs a new RandomNBodyScenario.
     * 
     * @param p the PApplet instance for random generation and logging
     */
    public RandomNBodyScenario(PApplet p) {
        this.p = p;
        this.numBodies = (int)p.random(minBodies, maxBodies);
    }

    /**
     * Sets up the scenario, resetting it and setting initial conditions for the logger.
     * 
     * @param logger the simulation logger
     */
    @Override
    public void setup(SimulationLogger logger) {
        reset();
        logger.setInitialConditions(this.universe);
    }

    /**
     * Updates the scenario by performing multiple simulation steps per frame.
     * Checks for system stability and resets the simulation if unstable or max ticks reached.
     * 
     * @param logger the simulation logger
     */
    @Override
    public void update(SimulationLogger logger) {
        if (!isRunning) return;
        
        for (int i = 0; i < stepsPerFrame; i++) {
            ticks += 1;
            universe.update();
            
            if ((SystemAnalyzer.isSystemUnstable(universe, this.G) || ticks >= maxTicks) && !stabilityOverride) {
                p.println("A planet reached escape energy! Halting simulation.");
                p.println("Halted after " + ticks + " steps.");
                
                logger.logEpisode(universe, ticks);
                episodeCount += 1;
                
                if (episodeCount >= maxEpisodes) {
                    logger.closeLog();
                    p.exit();
                } else {
                    reset();
                    logger.setInitialConditions(universe);
                }
                break;
            }
        }
    }

    /**
     * Resets the scenario by generating new random planets and initializing the universe.
     */
    public void reset() {
        ticks = 0;
        ArrayList<Planet> planets = new ArrayList<Planet>();
        this.numBodies = (int)p.random(minBodies, maxBodies);
        int bounds = 300;
        for (int i = 0; i < numBodies; i++) {
            Vec3 pos = new Vec3(p.random(-bounds, bounds), p.random(-bounds, bounds), p.random(-bounds, bounds));
            Vec3 vel = new Vec3(p.random(-5, 5), p.random(-5, 5), p.random(-5, 5));
            Vec3 acc = new Vec3(0, 0, 0);
            float mass = p.random(1.0f, 30.0f);
            int col = (int)p.random(0xFF000000, 0xFFFFFFFF);
            planets.add(new Planet(pos, vel, acc, mass, col));
        }
        
        for (Planet a : planets) {
            float potential = 0.0f;
            for (Planet b : planets) {
                if (a == b) continue;
                Vec3 distVec = Vec3.sub(b.pos, a.pos);
                float r = distVec.mag();
                // Soften potential energy check
                potential -= (G * a.mass * b.mass) / (r + 1.0f);
            }
            
            float kinetic = 0.5f * a.mass * a.vel.dot(a.vel);
            if (kinetic >= -potential || Float.isNaN(kinetic)) {
                float maxV = p.sqrt((2.0f * 0.8f * -potential) / a.mass);
                if (Float.isNaN(maxV)) maxV = 2.0f;
                a.vel.normalize();
                a.vel.scale(p.random(0.1f, maxV));
            }
        }
        
        universe = new Universe(planets, timeStep, new NewtonianGravity(G));
        universe.findCenter();
    }

    /**
     * Returns the current universe.
     * 
     * @return the universe
     */
    @Override
    public Universe getUniverse() { return universe; }
    
    /**
     * Returns whether the simulation is running.
     * 
     * @return true if running, false otherwise
     */
    @Override
    public boolean isRunning() { return isRunning; }
    
    /**
     * Toggles the running state of the simulation.
     */
    @Override
    public void toggleRunning() { isRunning = !isRunning; }
    
    /**
     * Toggles the stability override flag.
     */
    @Override
    public void toggleStabilityOverride() { stabilityOverride = !stabilityOverride; }
    
    /**
     * Modifies the number of bodies for the next reset.
     * 
     * @param delta the amount to change the number of bodies by
     */
    @Override
    public void modifyNumBodies(int delta) { 
        if (numBodies + delta >= 2) {
            numBodies += delta; 
        }
    }
    
    /**
     * Modifies the number of simulation steps performed per frame.
     * 
     * @param delta the amount to change the steps per frame by
     */
    @Override
    public void modifyStepsPerFrame(int delta) {
        stepsPerFrame += delta;
        if (stepsPerFrame < 1) stepsPerFrame = 1;
        if (stepsPerFrame > 100) stepsPerFrame = 100;
    }
    
    /**
     * Returns the current tick count.
     * 
     * @return the tick count
     */
    @Override
    public int getTicks() { return ticks; }
}
