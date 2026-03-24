import processing.core.PApplet;
import processing.core.PImage;
import processing.data.JSONArray;
import java.util.Arrays;
import java.util.ArrayList;

class MosaicFace extends Face {
    int emptyColor;

    public MosaicFace(PImage img, JSONArray uvData, int emptyColor) {
        super(img, uvData);
        this.emptyColor = emptyColor;
    }

    public void updateFromImages(ArrayList<PImage> activeImages, RegionMap regionMap, int shiftOffset) {
        this.img.loadPixels();
        
        int numActive = activeImages.size();
        
        if (numActive == 0) {
            Arrays.fill(this.img.pixels, this.emptyColor);
            this.img.updatePixels();
            return;
        }

        for (PImage sourceImg : activeImages) {
            sourceImg.loadPixels();
        }

        int[] regionAssignments = new int[regionMap.numRegions];
        for (int i = 0; i < regionMap.numRegions; i++) {
            regionAssignments[i] = (i + shiftOffset) % numActive;
        }

        for (int x = 0; x < this.img.width; x++) {
            for (int y = 0; y < this.img.height; y++) {
                int targetIndex = x + y * this.img.width;
                
                if (x < regionMap.width && y < regionMap.height) {
                    int regionId = regionMap.map[x][y];
                    int activeListIndex = regionAssignments[regionId];
                    
                    PImage activeImg = activeImages.get(activeListIndex);
                    
                    if (x < activeImg.width && y < activeImg.height) {
                        int sourceIndex = x + y * activeImg.width;
                        this.img.pixels[targetIndex] = activeImg.pixels[sourceIndex];
                    } else {
                        this.img.pixels[targetIndex] = this.emptyColor;
                    }
                } else {
                     this.img.pixels[targetIndex] = this.emptyColor;
                }
            }
        }
        this.img.updatePixels();
    }

    public void draw(PApplet p) {
        if (this.currentFrameVertices.size() > 0) {
            p.pushStyle();
            p.noStroke();
            p.fill(255);
            p.beginShape(PApplet.TRIANGLES);
            p.texture(this.img);

            for (int[] tri : this.triangles) {
                for (int j = 0; j < 3; j++) {
                    int idx = tri[j];
                    float[] v = this.currentFrameVertices.get(idx);
                    float[] uv = this.uvCoords.get(idx);
                    p.vertex(v[0], v[1], v[2], uv[0], uv[1]);
                }
            }
            p.endShape();
            p.popStyle();
        } else {
            p.image(this.img, 0, 0);
        }
    }
}
