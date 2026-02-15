// TargetGrid.java

// make a grid of targets

// Will Create n*n Targets based on x,y,z parameters

// grid pattern by step from x,y,z

// lerps color diagonally

import java.util.ArrayList;
import java.awt.Color;

public class TargetGrid {
  ArrayList<Target> targets;
  int n;
  float x;
  float y;
  float z;
  float xs;
  float ys;
  float zs;
  float r;
  


public TargetGrid(int n, float x, float y, float z, float xs, float ys, float zs, float r, int[] colors) { 
    this.n = n;
    this.x = x;
    this.y = y;
    this.z = z;
    this.xs = xs;
    this.ys = ys;
    this.zs = zs;
    this.r = r;
    this.targets = new ArrayList<Target>();

    
    this.createTargets(colors);
}

public void createTargets(int[] colors) {

    float maxIndexSum = (float)(n-1) + (n-1);


    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
          Target t = new Target(this.x + i * this.xs, this.y + j * this.ys, this.z , this.r);
          int index = i + (j * n);
  
          // Safety check to prevent crashing if array is too small
          if (index < colors.length) {
            t.c = colors[index];
          } else {
            t.c = 0xFFFFFFFF; // White fallback
          }
          
          targets.add(t);
            
                
        }
    }
}
}
