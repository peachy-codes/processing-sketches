// Quaternion.java

// ig we make our own quaternion class

public class Quaternion {
    public float w;
    public float x;
    public float y;
    public float z;

    public Quaternion(float w, float x, float y, float z) {
    this.w = w;
    this.x = x;
    this.y = y;
    this.z = z; 
}

public Quaternion(Quaternion q) {
    this.w = q.w;
    this.x = q.x;
    this.y = q.y;
    this.z = q.z;
}

public static Quaternion zero() {
    return new Quaternion(0, 0, 0, 0);
}

public static Quaternion identity() {
    return new Quaternion(1, 0, 0, 0);
}


// static

public static Quaternion add(Quaternion a, Quaternion b) {
    return new Quaternion(a.w + b.w, a.x + b.x, a.y + b.y, a.z + b.z);
}

public static Quaternion sub(Quaternion a, Quaternion b) {
    return new Quaternion(a.w - b.w, a.x - b.x, a.y - b.y, a.z - b.z);
}

public static Quaternion neg(Quaternion q) {
    return new Quaternion(-q.w, -q.x, -q.y, -q.z);
}

public static Quaternion scale(Quaternion q, float f) {
    return new Quaternion(q.w * f, q.x * f, q.y * f, q.z * f);
}

public static float norm(Quaternion q) {
    return (float)Math.sqrt(q.w * q.w + q.x * q.x + q.y * q.y + q.z * q.z);
}

public static Quaternion conj(Quaternion q) {
    return new Quaternion(q.w, -q.x, -q.y, -q.z);
}

public static float dist(Quaternion a, Quaternion b) {
    return norm(sub(a, b));
}

public static Quaternion normalize(Quaternion q) {
    float len = norm(q);
    if (len > 1e-6f) { // LLMao
        return scale(q, 1 / len);
    }
    return q;

}

public static Quaternion mult(Quaternion a, Quaternion b) {
    return new Quaternion(
        a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,
        a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
        a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
        a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w
    );
}

public static Quaternion mult(Quaternion q, Vec3 v) {
    return mult(q, new Quaternion(0, v.x, v.y, v.z));
}

public static Quaternion mult(Vec3 v, Quaternion q) {
    return mult(new Quaternion(0, v.x, v.y, v.z), q);
}


// instance


public void add(Quaternion q) {
    this.w += q.w;
    this.x += q.x;
    this.y += q.y;
    this.z += q.z;
}

public void sub(Quaternion q) {
    this.w -= q.w;
    this.x -= q.x;
    this.y -= q.y;
    this.z -= q.z;
}

public void neg() {
    this.w = -this.w;
    this.x = -this.x;
    this.y = -this.y;
    this.z = -this.z;
}

public void scale(float f) {
    this.w *= f;
    this.x *= f;
    this.y *= f;
    this.z *= f;
}

public float dot(Quaternion q) {
    return this.w * q.w + this.x * q.x + this.y * q.y + this.z * q.z;
}

public float norm() {
    return (float)Math.sqrt(this.dot(this));
}

public void normalize() {
    float len = this.norm();
    if (len > 1e-6f) {
        this.scale(1 / len);
    }
    this.w = 0;
    this.x = 0;
    this.y = 0;
    this.z = 0;
}

public Quaternion conj() {
    return new Quaternion(this.w, -this.x, -this.y, -this.z);
}

public float toFloat() {
    return this.w;
}

public Quaternion mult(Quaternion q) {
    return mult(this, q);
}

public Quaternion mult(Vec3 v) {
    return mult(this, v);
}   


public Vec3 toVec3() {
    return new Vec3(this.x, this.y, this.z);
}

// since Q mult returns Q, create a Qv = v product method
public Vec3 rotate(Vec3 v) {
    // v' = v + 2 * r x (r x v + w * v) where r is the vector part of q
    float vx = v.x, vy = v.y, vz = v.z;
    float rx = this.x, ry = this.y, rz = this.z;
    
    // cross(r, v)
    float cx = ry * vz - rz * vy;
    float cy = rz * vx - rx * vz;
    float cz = rx * vy - ry * vx;

    // cross(r, cross(r, v) + w * v)
    float k = 2.0f;
    float wx = cx + this.w * vx;
    float wy = cy + this.w * vy;
    float wz = cz + this.w * vz;
    
    return new Vec3(
        vx + k * (ry * wz - rz * wy),
        vy + k * (rz * wx - rx * wz),
        vz + k * (rx * wy - ry * wx)
    );
}

}
