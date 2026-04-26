interface MusicListener extends EventListener {
  
  /**
   * Helper method to "wire" this listener to the music-related events in the bus.
   */
  default void registerAsMusicListener() {
    EventBus.subscribe("BEAT", this);
    EventBus.subscribe("LEVEL", this);
  }
  
  /**
   * Implementation of the base EventListener onEvent.
   * Dispatches to specialized handlers based on event type.
   */
  default void onEvent(JSONObject event) {
    String type = event.getString("type", "");
    if (type.equals("BEAT")) {
      onBeat(event);
    } else if (type.equals("LEVEL")) {
      onLevel(event.getFloat("value", 0));
    }
  }
  
  void onBeat(JSONObject event);
  void onLevel(float level);
}
