// Vec3.java

public class Vec3 {
  public float x;
  public float y;
  public float z;

  public Vec3(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

public Vec3(Vec3 v) {
    this.x = v.x;
    this.y = v.y;
    this.z = v.z;
  }
  
  public static Vec3 zero() {
    return new Vec3(0, 0, 0);
  }

  // static

  public static Vec3 add(Vec3 a, Vec3 b) {
    return new Vec3(a.x + b.x, a.y + b.y, a.z + b.z);
  }
  
  public static Vec3 sub(Vec3 a, Vec3 b) {
    return new Vec3(a.x - b.x, a.y - b.y, a.z - b.z);
  }

  public static Vec3 neg(Vec3 v) {
    return new Vec3(-v.x, -v.y, -v.z);
  }

  public static Vec3 scale(Vec3 v, float f) {
    return new Vec3(v.x * f, v.y * f, v.z * f);
  }

  public static float mag(Vec3 v) {
    return (float)Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
  }

  public static float dot(Vec3 a, Vec3 b) {
    return (float)(a.x * b.x + a.y * b.y + a.z * b.z);
  }

  public static Vec3 normalize(Vec3 v) {
    return scale(v, 1 / mag(v));
  }
  public static Vec3 cross(Vec3 a, Vec3 b) {
    return new Vec3(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    );
  }
  
  public static Vec3 rotateAround(Vec3 v, Vec3 axis, float theta) {
    Vec3 k = Vec3.normalize(axis); 
    
    float cosT = (float)Math.cos(theta);
    float sinT = (float)Math.sin(theta);
    
    float dot = Vec3.dot(k, v);
    Vec3 cross = Vec3.cross(k, v);

    // v_rot = v*cos(theta) + (k x v)*sin(theta) + k*(k.v)*(1-cos(theta))
    
    Vec3 part1 = Vec3.scale(v, cosT);
    Vec3 part2 = Vec3.scale(cross, sinT);
    Vec3 part3 = Vec3.scale(k, dot * (1.0f - cosT));
    
    Vec3 result = Vec3.add(part1, part2);
    result = Vec3.add(result, part3);
    
    return result;
  }
  

  // instance

  public void add(Vec3 v) {
    this.x += v.x;
    this.y += v.y;
    this.z += v.z;
  }

  public void sub(Vec3 v) {
    this.x -= v.x;
    this.y -= v.y;
    this.z -= v.z;
  }

  public void neg() {
    this.x = -this.x;
    this.y = -this.y;
    this.z = -this.z;
  }

  public void scale(float f) {
    this.x *= f;
    this.y *= f;
    this.z *= f;
  }

  public float dot(Vec3 v) {
    return this.x * v.x + this.y * v.y + this.z * v.z;
  }

  public float mag() {
    return (float)Math.sqrt(this.dot(this));
  }

  public void normalize() {
    float len = this.mag();
    if (len != 0) {
      this.scale(1 / len);
    }
  }

  public Vec3 cross(Vec3 v) {
    return Vec3.cross(this, v);
  
  }
  
  public void rotateAround(Vec3 axis, float theta) {
    Vec3 result = Vec3.rotateAround(this, axis, theta);
    this.x = result.x;
    this.y = result.y;
    this.z = result.z;
  }
  
  public Vec3 copy() {
    return new Vec3(this.x, this.y, this.z);
  }
}
