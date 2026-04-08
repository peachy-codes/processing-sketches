import java.util.ArrayList;

/**
 * Represents a celestial body (planet) in the simulation.
 * A Planet object stores its position, velocity, acceleration, mass, and color.
 */
public class Planet {
    /** The position vector of the planet. */
    public Vec3 pos;
    /** The velocity vector of the planet. */
    public Vec3 vel;
    /** The current acceleration vector of the planet. */
    public Vec3 acc;
    /** The acceleration vector from the previous time step, used by certain integrators. */
    public Vec3 oldAcc;
    /** The mass of the planet. */
    public float mass;
    /** The color of the planet, represented as an integer (ARGB). */
    public int c;

    /**
     * Constructs a new Planet.
     * 
     * @param pos initial position
     * @param vel initial velocity
     * @param acc initial acceleration
     * @param mass mass of the planet
     * @param c color of the planet
     */
    public Planet(Vec3 pos, Vec3 vel, Vec3 acc, float mass, int c) {
        this.pos = pos;
        this.vel = vel;
        this.acc = acc;
        this.oldAcc = new Vec3(0, 0, 0);
        this.mass = mass;
        this.c = c;
    }
}
