/**
 * Interface representing a force model that can be applied to a universe.
 */
public interface ForceModel {
    /**
     * Applies forces to the planets in the given universe.
     * 
     * @param universe the universe to apply forces to
     */
    void applyForces(Universe universe);
}