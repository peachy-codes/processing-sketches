import processing.core.PApplet;
import processing.core.PImage;
import processing.data.JSONArray;
import java.io.File;
import java.util.ArrayList;

public class ImageSequence {
    PApplet p;
    ArrayList<PImage> faceImages;
    ArrayList<JSONArray> uvMaps;
    int currentIndex;
    
    public ImageSequence(PApplet p) {
        this.p = p;
        this.faceImages = new ArrayList<PImage>();
        this.uvMaps = new ArrayList<JSONArray>();
        this.currentIndex = 0;
    }

    public void loadImages(String folderPath, String uvPath) {
        File dir = new File(p.sketchPath(), folderPath);
        File[] files = dir.listFiles();
        
        if (files != null) {
            for (File f : files) {
                String name = f.getName().toLowerCase();
                if (f.isFile() && (name.endsWith(".png") || name.endsWith(".jpg"))) {
                    PImage img = p.loadImage(f.getAbsolutePath());
                    img.loadPixels();
                    this.faceImages.add(img);
                    
                    String baseName = f.getName().substring(0, f.getName().lastIndexOf('.'));
                    File uvFile = new File(p.sketchPath(), uvPath + "/" + baseName + "_uv.json");
                    
                    if (uvFile.exists()) {
                        this.uvMaps.add(p.loadJSONArray(uvFile.getAbsolutePath()));
                    } else {
                        this.uvMaps.add(new JSONArray());
                    }
                }
            }
        }
    }
    
    public PImage getNextImage() {
        if (this.faceImages == null || this.faceImages.size() == 0) {
            return null;
        }
        return faceImages.get(currentIndex);
    }

    public JSONArray getNextUV() {
        if (this.uvMaps == null || this.uvMaps.size() == 0) {
            return null;
        }
        return uvMaps.get(currentIndex);
    }
    
    public void advance() {
        if (this.faceImages != null && this.faceImages.size() > 0) {
            this.currentIndex++;
            if (this.currentIndex >= faceImages.size()) {
                this.currentIndex = 0;
            }
        }
    }
    
    public void scaleImages(int x, int y) {
        for (PImage img : this.faceImages) {
            img.resize(x, y);
        }
    }
}