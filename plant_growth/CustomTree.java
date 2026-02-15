// CustomTree.java

import java.util.ArrayList;

public class CustomTree {
  Vec3 start;
  Vec3 end;
  float scale = .67f;
  
  CustomTree parent;
  ArrayList<CustomTree> children;
  Target target;
  
  float initialDist;
  float distanceToTarget;
  float theta;
  float phi;
  int c; 
  
  public CustomTree(Vec3 start, Vec3 end) {
    this.start = start;
    this.end = end;
    this.parent = null;
    this.children = new ArrayList<CustomTree>();
    
    this.theta = 0;
    this.phi = 0;
    this.c = 0xFF0000FF;
    
    this.target = null;
    this.initialDist = Float.MAX_VALUE;
    this.distanceToTarget = Float.MAX_VALUE;
  }

  // need one for children
  
  public CustomTree(Vec3 start, Vec3 end, CustomTree parent) {
    this.start = start;
    this.end = end;
    this.parent = parent;
    this.children = new ArrayList<CustomTree>();
    this.target = null;
    
    this.theta = 0;
    this.phi = 0;
    this.c = 0xFF0000FF; // this is a choice. default or inherit?
    if (this.parent != null) {
      this.initialDist = this.parent.initialDist;
    } else {
    this.initialDist = Float.MAX_VALUE;
    }
    this.distanceToTarget = Float.MAX_VALUE;
  }
  
  // one for passing segment
  
  public CustomTree(Segment s, CustomTree parent) {
    this.start = s.start;
    this.end = s.end;
    this.parent = parent;
    this.children = new ArrayList<CustomTree>();
    this.target = null;
  
    this.theta = 0;
    this.phi = 0;
    this.c = 0xFF0000FF;
    
    this.initialDist = parent.initialDist;
    this.distanceToTarget = Float.MAX_VALUE;
  }
public CustomTree createBranch(float theta, float phi, float scale) {

    
    Vec3 parentVector = Vec3.sub(this.end, this.start);
    Vec3 dir = Vec3.normalize(parentVector);
    
    
    Vec3 arbitraryAxis = new Vec3(0, 1, 0);
    if (Math.abs(dir.y) > 0.9f) { 
        arbitraryAxis = new Vec3(1, 0, 0);
    }
    
    Vec3 baseHinge = Vec3.cross(dir, arbitraryAxis);
    baseHinge.normalize();
    

    
    float spinAngle = phi;
    
    // i didnt code axis angle constructor but maybe i should?
    
    float sinSpin = (float)Math.sin(spinAngle / 2.0f);
    float cosSpin = (float)Math.cos(spinAngle / 2.0f);
    Quaternion qSpin = new Quaternion(cosSpin,
    dir.x * sinSpin,
    dir.y * sinSpin,
    dir.z * sinSpin);
    
    Vec3 currentHinge = qSpin.rotate(baseHinge);
      
    // axis angle for pivot
    float sinPivot = (float)Math.sin(theta / 2.0f);
    float cosPivot = (float)Math.cos(theta / 2.0f);
    Quaternion qPivot = new Quaternion(cosPivot, 
    currentHinge.x * sinPivot, 
    currentHinge.y * sinPivot, 
    currentHinge.z * sinPivot);
    
 
    
    Vec3 childVector = new Vec3(parentVector);
    childVector.scale(scale);
    childVector = qPivot.rotate(childVector);
    
    Vec3 newEnd = Vec3.add(this.end, childVector);
    
    CustomTree child = new CustomTree(this.end, newEnd, this);
    child.phi = phi;
    child.theta = theta;
    child.c = this.c;
    
    this.children.add(child);
    
    return child;
}

  
}
