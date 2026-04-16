import processing.core.PApplet;

/**
 * Interface for rendering a universe.
 */
public interface Renderer {
    /**
     * Renders the given universe using the provided PApplet.
     * 
     * @param universe the universe to render
     * @param p the PApplet to use for rendering
     */
    void render(Universe universe, PApplet p);

    /**
     * Resets or initializes retained rendering structures (like PShapes).
     * 
     * @param universe the current universe
     * @param p the PApplet instance
     */
    void reset(Universe universe, PApplet p);
}
