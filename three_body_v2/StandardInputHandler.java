import processing.core.PApplet;

/**
 * Standard implementation of InputHandler for the simulation.
 * Handles keyboard shortcuts for simulation control and mouse dragging for camera rotation.
 */
public class StandardInputHandler implements InputHandler {
    private Scenario scenario;
    private StandardRenderer renderer;
    private SimulationLogger logger;
    private PApplet p;
    
    /** The current rotation around the X axis. */
    private float rotX = 0;
    /** The current rotation around the Y axis. */
    private float rotY = 0;
    /** The current zoom level. */
    private float zoom = 1.5f;

    /**
     * Constructs a new StandardInputHandler.
     * 
     * @param scenario the current simulation scenario
     * @param renderer the current simulation renderer
     * @param logger the simulation logger
     * @param p the PApplet instance
     */
    public StandardInputHandler(Scenario scenario, StandardRenderer renderer, SimulationLogger logger, PApplet p) {
        this.scenario = scenario;
        this.renderer = renderer;
        this.logger = logger;
        this.p = p;
    }

    /**
     * Handles key press events.
     * 
     * @param key the key that was pressed
     */
    @Override
    public void handleKeyPressed(char key) {
        if (key == ' ') { scenario.toggleRunning(); }
        if (key == 's') { scenario.toggleStabilityOverride(); }
        if (key == ',') { scenario.modifyNumBodies(-1); }
        if (key == '.') { scenario.modifyNumBodies(1); }
        if (key == 'r') {
            scenario.reset();
            logger.setInitialConditions(scenario.getUniverse());
        }
        if (key == 'o') { zoom *= 1.1f; }
        if (key == 'p') { zoom *= 0.9f; }
        if (key == 'd') { renderer.showCenter = !renderer.showCenter; }
        if (key == 't') { renderer.drawTails = !renderer.drawTails; }
        if (key == 'y') { renderer.drawPlanets = !renderer.drawPlanets; }
        if (key == 'v') { renderer.drawVelocities = !renderer.drawVelocities; }
        if (key == 'c') {
            renderer.cameraTargetIndex++;
            if (renderer.cameraTargetIndex >= scenario.getUniverse().planets.size()) {
                renderer.cameraTargetIndex = -1;
            }
        }
        if (key == '-') { scenario.modifyStepsPerFrame(-1); }
        if (key == '=') { scenario.modifyStepsPerFrame(1); }
        if (key == 'q') {
            logger.closeLog();
            p.exit();
        }
        if (key == 'l') {
            logger.dumpCurrentState(scenario.getUniverse(), scenario.getTicks(), p.sketchPath(""));
        }
    }

    /**
     * Handles mouse drag events to rotate the camera.
     * 
     * @param mouseX the current mouse X position
     * @param pmouseX the previous mouse X position
     * @param mouseY the current mouse Y position
     * @param pmouseY the previous mouse Y position
     */
    @Override
    public void handleMouseDragged(float mouseX, float pmouseX, float mouseY, float pmouseY) {
        rotY += (mouseX - pmouseX) * 0.01f;
        rotX += (mouseY - pmouseY) * 0.01f;
    }

    /**
     * Returns the current X rotation.
     * 
     * @return the X rotation
     */
    @Override
    public float getRotX() { return rotX; }
    
    /**
     * Returns the current Y rotation.
     * 
     * @return the Y rotation
     */
    @Override
    public float getRotY() { return rotY; }
    
    /**
     * Returns the current zoom level.
     * 
     * @return the zoom level
     */
    @Override
    public float getZoom() { return zoom; }
}