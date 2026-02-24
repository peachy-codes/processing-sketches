//ImageSeauence.java

import processing.core.PApplet;
import processing.core.PImage;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;


public class ImageSequence {
  PApplet p;
  ArrayList<PImage> faceImages;
  int currentIndex;
  
  
public ImageSequence(PApplet p) {
  this.p = p;
  this.faceImages = null;
  this.currentIndex = 0;
}

public ImageSequence(PApplet p, ArrayList<PImage> images) {
  this.p = p;
    this.faceImages = images;
    this.currentIndex = 0;
  }

// loadImages
public ArrayList<PImage> loadImages(String folderPath) {
    ArrayList<PImage> tempImages = new ArrayList<PImage>();
    File dir = new File(p.sketchPath(), folderPath);
    File[] files = dir.listFiles();
    
    if (files == null) {
      return new ArrayList<>(0);
    }
    
    for (File f : files) {
      String name = f.getName().toLowerCase();
      if (f.isFile() && (name.endsWith(".png") || name.endsWith(".jpg"))) {
        PImage img = p.loadImage(f.getAbsolutePath());
        img.loadPixels();
        tempImages.add(img);
        
      }
    }
  this.faceImages = tempImages;
  return tempImages;
  
  }
  public PImage getNextImage() {
    if (this.faceImages == null || this.faceImages.size() == 0) {
      return null;
    }
    
    PImage img = faceImages.get(currentIndex);
    this.currentIndex++;
    
    if (this.currentIndex >= faceImages.size()) {
      this.currentIndex = 0;
    }
    
    return img;
  }
  
  public void scaleImages(int x, int y) {
    for (PImage img : this.faceImages) {
      img.resize(x, y);
    }
  }
}
