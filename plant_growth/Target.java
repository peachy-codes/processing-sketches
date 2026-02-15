// Target.java
public class Target {
  Vec3 pos;
  float radius;
  int c;
  
  public Target(float x, float y, float z, float r) {
    this.pos = new Vec3(x, y, z);
    this.radius = r;
    this.c = 255;
  }
  
  public boolean contains(Vec3 point) {
    float d = dist(point, this.pos);
    return d < radius;
  }
  
  private float dist(Vec3 v1, Vec3 v2) {
    float dx = v1.x - v2.x;
    float dy = v1.y - v2.y;
    float dz = v1.z - v2.z;
    return (float)Math.sqrt(dx*dx + dy*dy + dz*dz);
  }
}
