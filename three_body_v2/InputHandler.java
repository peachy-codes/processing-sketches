/**
 * Interface for handling input events in the simulation.
 */
public interface InputHandler {
    /**
     * Handles a key press event.
     * 
     * @param key the key that was pressed
     */
    void handleKeyPressed(char key);

    /**
     * Handles a mouse drag event.
     * 
     * @param mouseX the current x position of the mouse
     * @param pmouseX the previous x position of the mouse
     * @param mouseY the current y position of the mouse
     * @param pmouseY the previous y position of the mouse
     */
    void handleMouseDragged(float mouseX, float pmouseX, float mouseY, float pmouseY);

    /**
     * Returns the rotation around the X-axis.
     * 
     * @return the rotation around the X-axis
     */
    float getRotX();

    /**
     * Returns the rotation around the Y-axis.
     * 
     * @return the rotation around the Y-axis
     */
    float getRotY();

    /**
     * Returns the current zoom level.
     * 
     * @return the current zoom level
     */
    float getZoom();
}