// Planet.java
// basically a particle!
import java.util.ArrayList;

// planet object stores pos, vel, acc, mass, color

public class Planet{
    // Declaration
    public Vec3 pos;
    public Vec3 vel;
    public Vec3 acc;
    public Vec3 oldAcc;
    public float mass;
    public int c;


    public Planet(Vec3 pos, Vec3 vel, Vec3 acc, float mass, int c) {
      this.pos = pos;
      this.vel = vel;
      this.acc = acc;
      this.oldAcc = new Vec3(0,0,0);
      this.mass = mass;
      this.c = c;
    }
    
    public void updatePosition(float dt) {
      this.oldAcc = new Vec3(this.acc);
      Vec3 velTerm = Vec3.scale(this.vel, dt);
      Vec3 accTerm = Vec3.scale(this.acc, 0.5f * dt * dt);
      this.pos = Vec3.add(this.pos, Vec3.add(velTerm, accTerm));
    }
    
    public void updateVelocity(float dt) {
      Vec3 sumAcc = Vec3.add(this.oldAcc, this.acc);
      Vec3 avgAcc = Vec3.scale(sumAcc, 0.5f);
      this.vel = Vec3.add(this.vel, Vec3.scale(avgAcc, dt));
    }
}
