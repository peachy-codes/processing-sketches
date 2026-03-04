// Universe.java

import java.util.ArrayList;

// to pass the update call to the objects and calculate global forces

public class Universe{
    // Declaration
    public ArrayList<Planet> planets;
    public float dt;
    public float G;
    public Vec3 cm;
    public ArrayList<Vec3[]> history;
    public int maxHistory = 10000;

    public Universe(ArrayList<Planet> planets, float dt, float G) {
        this.planets = planets;
        this.dt = dt;
        this.G = G;
        this.cm = new Vec3(0f,0f,0f);
        this.history = new ArrayList<Vec3[]>();
        this.findCenter();
        this.applyGravity();
        this.recordHistory();
    }

  // gets center of the system
    void findCenter() {
      this.cm = new Vec3(0f,0f,0f);
      float totalMass = 0f;
      for (Planet p : planets) {
        Vec3 scaledPos = Vec3.scale(p.pos, p.mass);
        this.cm = Vec3.add(cm, scaledPos);
        totalMass += p.mass;
      }
      if (totalMass != 0) {
        this.cm = Vec3.scale(this.cm, 1.0f / totalMass);
      }
    }


  void applyGravity() {
      for (Planet a : planets) {
          a.acc = new Vec3(0, 0, 0); 
  
          for (Planet b : planets) {
              if (a == b) continue;
  
              Vec3 distVec = Vec3.sub(b.pos, a.pos); 
              float r = distVec.mag();
              
              float strength = (this.G * a.mass * b.mass) / (r * r);
  
              distVec.normalize();
              Vec3 force = Vec3.scale(distVec, strength);
  
              Vec3 acceleration = Vec3.scale(force, 1.0f / a.mass);
              a.acc = Vec3.add(a.acc, acceleration);
          }
      }
  }
  
  public void recordHistory() {
    Vec3[] currentPositions = new Vec3[planets.size()];
    for (int i =0; i < planets.size(); i++) {
      currentPositions[i] = planets.get(i).pos.copy();
    }
    this.history.add(currentPositions);
    
    if (this.history.size() > this.maxHistory) {
      this.history.remove(0);
    }
  }
  
  public void update() {
    for (Planet p : this.planets) {
      p.updatePosition(this.dt);
     }
     
    applyGravity();
        
    for (Planet p : this.planets) {
      p.updateVelocity(this.dt);
          }
    findCenter();
    recordHistory();
  }
  
  public boolean isSystemUnstable() {
    for (Planet a : planets) {
        float vSq = a.vel.mag() * a.vel.mag();
        float kinetic = 0.5f * a.mass * vSq;
        float potential = 0.0f;

        for (Planet b : planets) {
            if (a == b) continue;
            Vec3 distVec = Vec3.sub(b.pos, a.pos);
            float r = distVec.mag();
            potential -= (this.G * a.mass * b.mass) / r;
        }

        if (kinetic + potential >= 0.2f) {
            return true;
        }
    }
    return false;
}
}
