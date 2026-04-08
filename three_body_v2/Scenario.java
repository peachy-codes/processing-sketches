/**
 * Interface representing a simulation scenario.
 */
public interface Scenario {
    /**
     * Set up the scenario with the given logger.
     * 
     * @param logger the logger to use for recording the simulation
     */
    void setup(SimulationLogger logger);

    /**
     * Update the scenario.
     * 
     * @param logger the logger to use for recording the simulation
     */
    void update(SimulationLogger logger);

    /**
     * Reset the scenario to its initial state.
     */
    void reset();

    /**
     * Returns the universe of the scenario.
     * 
     * @return the universe
     */
    Universe getUniverse();

    /**
     * Checks if the simulation is currently running.
     * 
     * @return true if running, false otherwise
     */
    boolean isRunning();

    /**
     * Toggles the running state of the simulation.
     */
    void toggleRunning();

    /**
     * Toggles the stability override flag.
     */
    void toggleStabilityOverride();

    /**
     * Modifies the number of bodies in the scenario.
     * 
     * @param delta the amount to change the number of bodies by
     */
    void modifyNumBodies(int delta);

    /**
     * Modifies the number of simulation steps per frame.
     * 
     * @param delta the amount to change the steps per frame by
     */
    void modifyStepsPerFrame(int delta);

    /**
     * Returns the current number of ticks (simulation steps).
     * 
     * @return the current ticks
     */
    int getTicks();
}