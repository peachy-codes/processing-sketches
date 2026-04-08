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
}
