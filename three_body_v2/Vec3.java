/**
 * A class representing a 3D vector.
 * Provides static and instance methods for common vector operations.
 */
public class Vec3 {
    /** The x component of the vector. */
    public float x;
    /** The y component of the vector. */
    public float y;
    /** The z component of the vector. */
    public float z;

    /**
     * Constructs a new Vec3 with the given components.
     * 
     * @param x the x component
     * @param y the y component
     * @param z the z component
     */
    public Vec3(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    /**
     * Copy constructor. Creates a new Vec3 with the same components as the given vector.
     * 
     * @param v the vector to copy
     */
    public Vec3(Vec3 v) {
        this.x = v.x;
        this.y = v.y;
        this.z = v.z;
    }

    /**
     * Returns a new Vec3 with components (0, 0, 0).
     * 
     * @return the zero vector
     */
    public static Vec3 zero() {
        return new Vec3(0, 0, 0);
    }

    /**
     * Returns a new Vec3 that is the sum of two vectors.
     * 
     * @param a first vector
     * @param b second vector
     * @return the sum vector
     */
    public static Vec3 add(Vec3 a, Vec3 b) {
        return new Vec3(a.x + b.x, a.y + b.y, a.z + b.z);
    }

    /**
     * Returns a new Vec3 that is the difference of two vectors (a - b).
     * 
     * @param a first vector
     * @param b second vector
     * @return the difference vector
     */
    public static Vec3 sub(Vec3 a, Vec3 b) {
        return new Vec3(a.x - b.x, a.y - b.y, a.z - b.z);
    }

    /**
     * Returns a new Vec3 that is the negation of the given vector.
     * 
     * @param v the vector to negate
     * @return the negated vector
     */
    public static Vec3 neg(Vec3 v) {
        return new Vec3(-v.x, -v.y, -v.z);
    }

    /**
     * Returns a new Vec3 that is the given vector scaled by a factor.
     * 
     * @param v the vector to scale
     * @param f the scaling factor
     * @return the scaled vector
     */
    public static Vec3 scale(Vec3 v, float f) {
        return new Vec3(v.x * f, v.y * f, v.z * f);
    }

    /**
     * Returns the magnitude (length) of the given vector.
     * 
     * @param v the vector
     * @return the magnitude of the vector
     */
    public static float mag(Vec3 v) {
        return (float) Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
    }

    /**
     * Returns the dot product of two vectors.
     * 
     * @param a first vector
     * @param b second vector
     * @return the dot product
     */
    public static float dot(Vec3 a, Vec3 b) {
        return (float) (a.x * b.x + a.y * b.y + a.z * b.z);
    }

    /**
     * Returns a new Vec3 that is the normalization of the given vector.
     * 
     * @param v the vector to normalize
     * @return the normalized vector (length 1)
     */
    public static Vec3 normalize(Vec3 v) {
        return scale(v, 1 / mag(v));
    }

    /**
     * Returns a new Vec3 that is the cross product of two vectors.
     * 
     * @param a first vector
     * @param b second vector
     * @return the cross product vector
     */
    public static Vec3 cross(Vec3 a, Vec3 b) {
        return new Vec3(
            a.y * b.z - a.z * b.y,
            a.z * b.x - a.x * b.z,
            a.x * b.y - a.y * b.x
        );
    }

    /**
     * Returns a new Vec3 that is the rotation of the given vector around an axis by a given angle.
     * Uses Rodrigues' rotation formula.
     * 
     * @param v the vector to rotate
     * @param axis the axis of rotation
     * @param theta the angle of rotation in radians
     * @return the rotated vector
     */
    public static Vec3 rotateAround(Vec3 v, Vec3 axis, float theta) {
        Vec3 k = Vec3.normalize(axis);

        float cosT = (float) Math.cos(theta);
        float sinT = (float) Math.sin(theta);

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

    /**
     * Adds the given vector to this vector.
     * 
     * @param v the vector to add
     */
    public void add(Vec3 v) {
        this.x += v.x;
        this.y += v.y;
        this.z += v.z;
    }

    /**
     * Subtracts the given vector from this vector.
     * 
     * @param v the vector to subtract
     */
    public void sub(Vec3 v) {
        this.x -= v.x;
        this.y -= v.y;
        this.z -= v.z;
    }

    /**
     * Negates this vector.
     */
    public void neg() {
        this.x = -this.x;
        this.y = -this.y;
        this.z = -this.z;
    }

    /**
     * Scales this vector by a factor.
     * 
     * @param f the scaling factor
     */
    public void scale(float f) {
        this.x *= f;
        this.y *= f;
        this.z *= f;
    }

    /**
     * Returns the dot product of this vector and another vector.
     * 
     * @param v the other vector
     * @return the dot product
     */
    public float dot(Vec3 v) {
        return this.x * v.x + this.y * v.y + this.z * v.z;
    }

    /**
     * Returns the magnitude (length) of this vector.
     * 
     * @return the magnitude
     */
    public float mag() {
        return (float) Math.sqrt(this.dot(this));
    }

    /**
     * Normalizes this vector (scales it to length 1).
     */
    public void normalize() {
        float len = this.mag();
        if (len != 0) {
            this.scale(1 / len);
        }
    }

    /**
     * Returns a new Vec3 that is the cross product of this vector and another vector.
     * 
     * @param v the other vector
     * @return the cross product vector
     */
    public Vec3 cross(Vec3 v) {
        return Vec3.cross(this, v);
    }

    /**
     * Rotates this vector around an axis by a given angle.
     * 
     * @param axis the axis of rotation
     * @param theta the angle of rotation in radians
     */
    public void rotateAround(Vec3 axis, float theta) {
        Vec3 result = Vec3.rotateAround(this, axis, theta);
        this.x = result.x;
        this.y = result.y;
        this.z = result.z;
    }

    /**
     * Returns a copy of this vector.
     * 
     * @return a new Vec3 with the same components
     */
    public Vec3 copy() {
        return new Vec3(this.x, this.y, this.z);
    }
}
