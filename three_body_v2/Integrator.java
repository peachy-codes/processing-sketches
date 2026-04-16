/**
 * Interface for a numerical integrator used to update the universe.
 */
public interface Integrator {
    /**
     * Updates the given universe by one time step.
     * 
     * @param universe the universe to update
     * @param dt the time step duration
     */
    void update(Universe universe, float dt);
}
