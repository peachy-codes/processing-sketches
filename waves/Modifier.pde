interface Modifier {
  void apply(Node n, int time);
}

class DirectionalOscillator implements Modifier {
  PVector basePos;
  PVector direction;
  float amplitude;
  
  DirectionalOscillator(PVector basePos, PVector direction, float amplitude, float frequency) {
    this.basePos = basePos.copy();
    this.direction = direction.copy().normalize();
    this.amplitude = amplitude;
  }
  
  void apply(Node n, int time) {
    float offset = sin(time * Settings.OSC_FREQUENCY) * amplitude;
    PVector targetPos = PVector.add(basePos, PVector.mult(direction, offset));
    
    n.pos.set(targetPos);
    n.oldPos.set(targetPos);
  }
}

class MusicPulseModifier implements Modifier, MusicListener {
  PVector basePos;
  PVector direction;
  float beatPulse = 0;
  
  MusicPulseModifier(PVector basePos, PVector direction) {
    this.basePos = basePos.copy();
    this.direction = direction.copy().normalize();
    registerAsMusicListener();
  }
  
  void onBeat(JSONObject event) {
    // Spike upward on beat
    float magnitude = event.getFloat("magnitude", 0.5f);
    beatPulse += magnitude * Settings.BEAT_MAGNITUDE_SCALE;
  }
  
  void onLevel(float level) {
    // Ignored as per request to focus only on beat pulses
  }
  
  void apply(Node n, int time) {
    // Decay the beat pulse
    beatPulse *= Settings.OSC_DECAY_RATE;
    
    PVector targetPos = PVector.add(basePos, PVector.mult(direction, beatPulse));
    
    n.pos.set(targetPos);
    n.oldPos.set(targetPos);
  }
}
