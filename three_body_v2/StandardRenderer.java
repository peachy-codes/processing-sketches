import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PShape;
import java.util.ArrayList;

/**
 * High-performance, stable implementation of the Renderer interface.
 * Uses a hybrid approach: Baked PShape segments for history and Immediate Mode for the active tip.
 * This avoids GPU buffer churn and the Processing GROUP shape bug.
 */
public class StandardRenderer implements Renderer {
    
    public boolean showCenter = false;
    public boolean drawTails = false;
    public boolean drawPlanets = true;
    public boolean drawVelocities = false;
    public int cameraTargetIndex = -1;

    private PShape sphereTemplate;
    
    /** List of baked PShape segments for each planet: [planetIdx][segmentIdx] */
    private ArrayList<ArrayList<PShape>> trailSegments;
    /** Current vertex cache for the active (tip) segment of each planet. */
    private ArrayList<ArrayList<Vec3>> activeCaches;
    
    /** Max vertices per baked segment. */
    private final int MAX_VERTICES_PER_SEGMENT = 1000;

    /** Tracks the last processed simulation step. */
    private int lastProcessedTotalStep = -1;
    private Universe currentUniverse;

    @Override
    public void reset(Universe universe, PApplet p) {
        this.currentUniverse = universe;
        this.sphereTemplate = p.createShape(PConstants.SPHERE, 1.0f);
        this.sphereTemplate.setStroke(false);
        
        int numPlanets = universe.planets.size();
        this.trailSegments = new ArrayList<ArrayList<PShape>>();
        this.activeCaches = new ArrayList<ArrayList<Vec3>>();
        
        for (int i = 0; i < numPlanets; i++) {
            trailSegments.add(new ArrayList<PShape>());
            activeCaches.add(new ArrayList<Vec3>());
            
            // Populate initial paths from universe history
            int count = universe.getHistoryCount();
            for (int h = 0; h < count; h++) {
                addVertexToCache(i, universe.getHistoryPos(h, i), p);
            }
        }
        
        this.lastProcessedTotalStep = universe.totalSteps;
    }

    /**
     * Internal method to add a vertex to the active cache and bake if full.
     */
    private void addVertexToCache(int planetIdx, Vec3 v, PApplet p) {
        if (v == null || !isValid(v)) return;
        
        ArrayList<Vec3> cache = activeCaches.get(planetIdx);
        cache.add(v.copy());
        
        if (cache.size() >= MAX_VERTICES_PER_SEGMENT) {
            bakeSegment(planetIdx, p);
            // Continuity: keep last point as the start of the next segment
            Vec3 last = cache.get(cache.size() - 1);
            cache.clear();
            cache.add(last);
        }
    }

    /**
     * Converts the current cache into a retained PShape and stores it.
     */
    private void bakeSegment(int planetIdx, PApplet p) {
        ArrayList<Vec3> cache = activeCaches.get(planetIdx);
        if (cache.size() < 2) return;
        
        Planet pl = currentUniverse.planets.get(planetIdx);
        PShape baked = p.createShape();
        baked.beginShape(PConstants.LINE_STRIP);
        baked.noFill();
        baked.stroke(pl.c);
        baked.strokeWeight(pl.mass / 2.0f);
        for (Vec3 v : cache) {
            baked.vertex(v.x, v.y, v.z);
        }
        baked.endShape();
        
        trailSegments.get(planetIdx).add(baked);
    }

    private boolean isValid(Vec3 v) {
        return !Float.isNaN(v.x) && !Float.isInfinite(v.x) &&
               !Float.isNaN(v.y) && !Float.isInfinite(v.y) &&
               !Float.isNaN(v.z) && !Float.isInfinite(v.z);
    }

    @Override
    public void render(Universe universe, PApplet p) {
        // Robust reset detection
        if (universe != currentUniverse || universe.totalSteps < lastProcessedTotalStep) {
            reset(universe, p);
        }
        
        // Batch process simulation sub-steps into the renderer's structures
        if (universe.totalSteps > lastProcessedTotalStep) {
            updateTrails(universe, p);
        }

        Vec3 centerTarget;
        if (cameraTargetIndex == -1) {
            centerTarget = universe.cm;
        } else if (cameraTargetIndex < universe.planets.size()) {
            centerTarget = universe.planets.get(cameraTargetIndex).pos;
        } else {
            centerTarget = universe.cm;
        }
        
        if (!isValid(centerTarget)) centerTarget = new Vec3(0, 0, 0);

        p.pushMatrix();
        // Camera centering: transformation is applied to everything inside
        p.translate(-centerTarget.x, -centerTarget.y, -centerTarget.z);
        
        if (drawTails) {
            drawAllTails(p);
        }
        
        if (drawPlanets) {
            drawAllPlanets(universe, p);
        }
        
        if (showCenter) drawCenter(universe, p);
        if (drawVelocities) drawVelocity(universe, p);
        p.popMatrix();
    }

    private void updateTrails(Universe universe, PApplet p) {
        int stepsToProcess = universe.totalSteps - lastProcessedTotalStep;
        if (stepsToProcess <= 0) return;
        
        int historyCount = universe.getHistoryCount();
        int startStep = Math.max(0, historyCount - stepsToProcess);
        
        for (int h = startStep; h < historyCount; h++) {
            for (int i = 0; i < universe.planets.size(); i++) {
                addVertexToCache(i, universe.getHistoryPos(h, i), p);
            }
        }
        
        lastProcessedTotalStep = universe.totalSteps;
    }

    /**
     * Draws both baked segments and the active immediate-mode tip.
     */
    private void drawAllTails(PApplet p) {
        for (int i = 0; i < trailSegments.size(); i++) {
            // 1. Draw baked retained segments (Fast)
            ArrayList<PShape> segments = trailSegments.get(i);
            for (PShape s : segments) {
                p.shape(s);
            }
            
            // 2. Draw active tip in Immediate Mode (Stable, No Churn)
            ArrayList<Vec3> cache = activeCaches.get(i);
            if (cache.size() >= 2) {
                Planet pl = currentUniverse.planets.get(i);
                p.noFill();
                p.stroke(pl.c);
                p.strokeWeight(pl.mass / 2.0f);
                p.beginShape(PConstants.LINE_STRIP);
                for (Vec3 v : cache) {
                    p.vertex(v.x, v.y, v.z);
                }
                p.endShape();
            }
        }
    }

    private void drawAllPlanets(Universe universe, PApplet p) {
        for (Planet pl : universe.planets) {
            if (!isValid(pl.pos)) continue;
            p.pushMatrix();
            p.translate(pl.pos.x, pl.pos.y, pl.pos.z);
            p.scale(pl.mass);
            sphereTemplate.setFill(pl.c);
            p.shape(sphereTemplate);
            p.popMatrix();
        }
    }

    public void drawCenter(Universe universe, PApplet p) {
        if (!isValid(universe.cm)) return;
        p.pushMatrix();
        p.translate(universe.cm.x, universe.cm.y, universe.cm.z);
        p.fill(0xFF0000FF);
        p.noStroke();
        p.sphere(5);
        p.popMatrix();
    }

    public void drawVelocity(Universe universe, PApplet p) {
        float velScale = 10.0f;
        for (int i = 0; i < universe.planets.size(); i++) {
            Planet pl = universe.planets.get(i);
            if (!isValid(pl.pos) || !isValid(pl.vel)) continue;
            drawArrow(pl.pos, pl.vel, velScale, pl.c, p);
        }
        if (isValid(universe.cm) && isValid(universe.cmVel)) {
            drawArrow(universe.cm, universe.cmVel, velScale, 0xFF0000FF, p);
        }
    }

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
        p.vertex(0, 0, 0); p.vertex(-2, 2, -6); p.vertex(2, 2, -6);
        p.vertex(0, 0, 0); p.vertex(2, 2, -6); p.vertex(2, -2, -6);
        p.vertex(0, 0, 0); p.vertex(2, -2, -6); p.vertex(-2, -2, -6);
        p.vertex(0, 0, 0); p.vertex(-2, -2, -6); p.vertex(-2, 2, -6);
        p.endShape();
        p.popMatrix();
    }
}
