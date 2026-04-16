/**
 * Utility class for analyzing the state of the simulation system.
 */
public class SystemAnalyzer {
    
    /**
     * Determines if the system is unstable based on energy criteria.
     * Checks if any planet has reached escape energy.
     * 
     * @param universe the universe to analyze
     * @param G the gravitational constant
     * @return true if the system is considered unstable, false otherwise
     */
    public static boolean isSystemUnstable(Universe universe, float G) {
        for (Planet a : universe.planets) {
            // Early NaN check
            if (Float.isNaN(a.pos.x) || Float.isNaN(a.pos.y) || Float.isNaN(a.pos.z) ||
                Float.isInfinite(a.pos.x) || Float.isInfinite(a.pos.y) || Float.isInfinite(a.pos.z)) {
                return true;
            }

            float vSq = a.vel.dot(a.vel);
            float kinetic = 0.5f * a.mass * vSq;
            float potential = 0.0f;

            for (Planet b : universe.planets) {
                if (a == b) continue;
                Vec3 distVec = Vec3.sub(b.pos, a.pos);
                float r = distVec.mag();
                
                // Soften in check as well
                float softening = 1.0f;
                potential -= (G * a.mass * b.mass) / (r + softening);
            }

            if (kinetic + potential >= 0.2f) {
                return true;
            }
        }
        return false;
    }
}