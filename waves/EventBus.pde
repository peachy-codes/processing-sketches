import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

interface EventListener {
  void onEvent(JSONObject event);
}

static class EventBus {
  private static Map<String, List<EventListener>> listeners = new HashMap<String, List<EventListener>>();
  
  static void subscribe(String type, EventListener listener) {
    if (!listeners.containsKey(type)) {
      listeners.put(type, new ArrayList<EventListener>());
    }
    listeners.get(type).add(listener);
  }
  
  static void publish(String type, JSONObject data) {
    if (listeners.containsKey(type)) {
      for (EventListener listener : listeners.get(type)) {
        listener.onEvent(data);
      }
    }
  }
}
