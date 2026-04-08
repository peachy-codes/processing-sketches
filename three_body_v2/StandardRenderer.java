import processing.core.PApplet;
import processing.core.PConstants;

/**
 * Standard implementation of the Renderer interface.
 * Handles the visual representation of the universe, including planets, tails, and velocities.
 */
public class StandardRenderer implements Renderer {
    
    /** Whether to show a marker at the system's center of mass. */
    public boolean showCenter = false;
    /** Whether to draw trails (tails) behind planets based on their history. */
    public boolean drawTails = false;
    /** Whether to draw the planets as spheres. */
    public boolean drawPlanets = true;
    /** Whether to draw velocity vectors for planets and the center of mass. */
    public boolean drawVelocities = false;
    /** The index of the planet the camera is currently targeting. -1 for the center of mass. */
    public int cameraTargetIndex = -1;

    /**
     * Renders the current state of the universe.
     * 
     * @param universe the universe to render
     * @param p the PApplet instance to draw on
     */
    @Override
    public void render(Universe universe, PApplet p) {
        Vec3 centerTarget;
        if (cameraTargetIndex == -1) {
            centerTarget = universe.cm;
        } else {
            centerTarget = universe.planets.get(cameraTargetIndex).pos;
        }
        
        p.translate(-centerTarget.x, -centerTarget.y, -centerTarget.z);
        
        drawPlanets(universe, p);
        
        if (showCenter) {
            drawCenter(universe, p);
        }
        if (drawVelocities) {
            drawVelocity(universe, p);
        }
    }

    /**
     * Draws a marker at the universe's center of mass.
     * 
     * @param universe the current universe
     * @param p the PApplet instance
     */
    public void drawCenter(Universe universe, PApplet p) {
        p.pushMatrix();
        p.translate(universe.cm.x, universe.cm.y, universe.cm.z);
        p.fill(0xFF0000FF);
        p.noStroke();
        p.sphere(5);
        p.popMatrix();
    }

    /**
     * Draws all planets in the universe, optionally including their tails.
     * 
     * @param universe the current universe
     * @param p the PApplet instance
     */
    public void drawPlanets(Universe universe, PApplet p) {
        for (int i = 0; i < universe.planets.size(); i++) {
            Planet pl = universe.planets.get(i);
            
            if (drawTails) {
                p.noFill();
                p.stroke(pl.c);
                p.strokeWeight(pl.mass);
                p.beginShape();
                for (Vec3[] state : universe.history) {
                    p.vertex(state[i].x, state[i].y, state[i].z);
                }
                p.endShape();
            }
            
            if (drawPlanets) {
                p.pushMatrix();
                p.translate(pl.pos.x, pl.pos.y, pl.pos.z);
                p.fill(pl.c);
                p.noStroke();
                p.sphere(pl.mass);
                p.popMatrix();
            }
        }
    }

    /**
     * Draws velocity vectors for all planets and the center of mass.
     * 
     * @param universe the current universe
     * @param p the PApplet instance
     */
    public void drawVelocity(Universe universe, PApplet p) {
        float velScale = 10.0f;
        for (int i = 0; i < universe.planets.size(); i++) {
            Planet pl = universe.planets.get(i);
            drawArrow(pl.pos, pl.vel, velScale, pl.c, p);
        }
        drawArrow(universe.cm, universe.cmVel, velScale, 0xFF0000FF, p);
    }

    /**
     * Draws an arrow representing a vector.
     * 
     * @param start the starting position of the arrow
     * @param vec the vector to represent
     * @param scale the scaling factor for the vector length
     * @param col the color of the arrow
     * @param p the PApplet instance
     */
    public void drawArrow(Vec3 start, Vec3 vec, float scale, int col, PApplet p) {
        Vec3 scaledVec = Vec3.scale(vec, scale);
        Vec3 end = Vec3.add(start, scaledVec);
        
        p.stroke(col);
        p.strokeWeight(2);
        p.line(start.x, start.y, start.z, end.x, end.y, end.z);
        
        p.pushMatrix();
        p.translate(end.x, end.y, end.z);
        
        float headingY = p.atan2(scaledVec.x, scaledVec.z);
        float headingX = p.atan2(-scaledVec.y, p.sqrt(scaledVec.x * scaledVec.x + scaledVec.z * scaledVec.z));
        
        p.rotateY(headingY);
        p.rotateX(headingX);
        
        p.fill(col);
        p.noStroke();
        p.beginShape(PConstants.TRIANGLES);
        p.vertex(0, 0, 0);
        p.vertex(-2, 2, -6);
        p.vertex(2, 2, -6);
        
        p.vertex(0, 0, 0);
        p.vertex(2, 2, -6);
        p.vertex(2, -2, -6);
        
        p.vertex(0, 0, 0);
        p.vertex(2, -2, -6);
        p.vertex(-2, -2, -6);
        
        p.vertex(0, 0, 0);
        p.vertex(-2, -2, -6);
        p.vertex(-2, 2, -6);
        p.endShape();
        p.popMatrix();
    }
}
