/**
 * Implementation of the Velocity Verlet integration algorithm.
 * This integrator provides better stability and energy conservation than simple Euler integration.
 */
public class VerletIntegrator implements Integrator {

    /**
     * Updates the universe state using the Velocity Verlet algorithm.
     * 
     * @param universe the universe to update
     * @param dt the time step
     */
    public void update(Universe universe, float dt) {
        for (Planet p : universe.planets) {
            p.oldAcc.x = p.acc.x;
            p.oldAcc.y = p.acc.y;
            p.oldAcc.z = p.acc.z;

            p.pos.x += p.vel.x * dt + 0.5f * p.acc.x * dt * dt;
            p.pos.y += p.vel.y * dt + 0.5f * p.acc.y * dt * dt;
            p.pos.z += p.vel.z * dt + 0.5f * p.acc.z * dt * dt;
        }
    
        universe.forceModel.applyForces(universe);

        for (Planet p : universe.planets) {
            p.vel.x += 0.5f * (p.oldAcc.x + p.acc.x) * dt;
            p.vel.y += 0.5f * (p.oldAcc.y + p.acc.y) * dt;
            p.vel.z += 0.5f * (p.oldAcc.z + p.acc.z) * dt;
        }
    }
}
