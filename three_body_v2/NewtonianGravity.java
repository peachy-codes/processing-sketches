/**
 * Implementation of a force model based on Newtonian gravity.
 */
public class NewtonianGravity implements ForceModel {
    /** The gravitational constant. */
    public float G;

    /**
     * Constructs a NewtonianGravity force model with the given constant.
     * 
     * @param G the gravitational constant
     */
    public NewtonianGravity(float G) {
        this.G = G;
    }

    /**
     * Applies Newtonian gravitational forces between all pairs of planets in the universe.
     * 
     * @param universe the universe to apply forces to
     */
    public void applyForces(Universe universe) {
        for (Planet p : universe.planets) {
            p.acc = new Vec3(0, 0, 0);
        }

        for (int i = 0; i < universe.planets.size(); i++) {
            Planet a = universe.planets.get(i);
            for (int j = i + 1; j < universe.planets.size(); j++) {
                Planet b = universe.planets.get(j);

                Vec3 distVec = Vec3.sub(b.pos, a.pos);
                float r = distVec.mag();

                float strength = (this.G * a.mass * b.mass) / (r * r);

                distVec.normalize();
                Vec3 forceOnA = Vec3.scale(distVec, strength);
                Vec3 forceOnB = Vec3.neg(forceOnA);

                Vec3 accForA = Vec3.scale(forceOnA, 1.0f / a.mass);
                Vec3 accForB = Vec3.scale(forceOnB, 1.0f / b.mass);

                a.acc = Vec3.add(a.acc, accForA);
                b.acc = Vec3.add(b.acc, accForB);
            }
        }
    }
}