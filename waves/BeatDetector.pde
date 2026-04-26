import ddf.minim.*;
import ddf.minim.analysis.*;

class BeatDetector {
  Minim minim;
  AudioInput in;
  BeatDetect beat;
  
  BeatDetector(PApplet parent) {
    minim = new Minim(parent);
    // getLineIn() usually works for default mic, but let's be explicit with buffer size
    in = minim.getLineIn(Minim.MONO, 1024);
    
    if (in == null) {
      println("ERROR: Could not initialize AudioInput. Check Microphone permissions.");
    }
    
    beat = new BeatDetect(in.bufferSize(), in.sampleRate());
    beat.setSensitivity(Settings.BEAT_SENSITIVITY); 
  }
  
  void update() {
    if (in == null) return;
    
    beat.detect(in.mix);
    float level = in.mix.level();
    
    // Level event
    JSONObject levelEvent = new JSONObject();
    levelEvent.setString("type", "LEVEL");
    levelEvent.setFloat("value", level);
    EventBus.publish("LEVEL", levelEvent);
    
    // Only detect beats if there is actual audio signal
    if (level > Settings.MIN_AUDIO_THRESHOLD) {
      if (beat.isKick()) {
        println("BEAT DETECTED | Level: " + nf(level, 1, 4) + " | Time: " + millis());
        
        JSONObject beatEvent = new JSONObject();
        beatEvent.setString("type", "BEAT");
        beatEvent.setLong("timestamp", System.currentTimeMillis());
        beatEvent.setFloat("magnitude", level);
        
        EventBus.publish("BEAT", beatEvent);
      }
    }
    
    // Diagnostic: if everything is 0, let the user know once in a while
    if (frameCount % 120 == 0 && level < 0.0001) {
       println("ADVISORY: Audio level is near zero. Check input source/mic.");
    }
  }
  
  void stop() {
    if (in != null) in.close();
    if (minim != null) minim.stop();
  }
}
