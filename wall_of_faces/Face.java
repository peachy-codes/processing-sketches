//Face.java

import processing.core.PApplet;
import processing.core.PImage;
import java.io.File;
import java.util.ArrayList;


class Face {
    PImage img;
    float x,y,z;
    boolean active;
    ArrayList<PixelRegion> activePixels; // <X, Y, W, H>
    

    
    public Face(PImage img) {
        this.img = img;
        this.x = 0;
        this.y = 0;
        this.z = 0;
        this.active = false;
        this.activePixels = new ArrayList<PixelRegion>();
    }

    public void activatePixels(PixelRegion region) {
      this.activePixels.add(region);
      this.activate();
    }
    
    public void activateRandomPixels() {
      int sX = (int)(Math.random() * this.img.width);
      int sY = (int)(Math.random() * this.img.height);
      int w = (int)(Math.random() * (this.img.width - sX));
      int h = (int)(Math.random() * (this.img.height - sY));
      PixelRegion pr = new PixelRegion(sX, sY, w, h);
      this.activePixels.add(pr);
      this.active = true;
    }
    
    public void deactivatePixels(PixelRegion region) {
      this.activePixels.remove(region);
      if (this.activePixels.isEmpty()) {
         this.deactivate();
      }    
    }
    
    public void activate() {
        if (!this.active) {
        this.active = true;
        this.z += 100;
        }
    }

    public void deactivate() {
      if (this.active) {
        this.active = false;
        this.z -= 100;
      }
    }

}
