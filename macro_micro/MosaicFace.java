import processing.core.PApplet;
import processing.core.PImage;
import processing.data.JSONArray;
import java.util.ArrayList;
import java.util.Arrays;

class MosaicFace extends Face {
    int emptyColor;
    ArrayList<PImage> maskedImages;

    public MosaicFace(PImage img, JSONArray uvData, int emptyColor) {
        super(img, uvData);
        this.emptyColor = emptyColor;
        this.maskedImages = new ArrayList<PImage>();
    }

    public void updateMasks(PApplet p, ArrayList<Face> activeFaces, RegionMap regionMap, int[] regionAssignments) {
        int numActive = activeFaces.size();
        
        while (this.maskedImages.size() < numActive) {
            this.maskedImages.add(p.createImage(regionMap.width, regionMap.height, PApplet.ARGB));
        }
        
        for (int i = 0; i < numActive; i++) {
            PImage maskImg = this.maskedImages.get(i);
            PImage sourceImg = activeFaces.get(i).img;
            
            maskImg.loadPixels();
            sourceImg.loadPixels();
            
            Arrays.fill(maskImg.pixels, this.emptyColor);
            
            for (int x = 0; x < regionMap.width; x++) {
                for (int y = 0; y < regionMap.height; y++) {
                    int rId = regionMap.map[x][y];
                    if (regionAssignments[rId] == i) {
                        int idx = x + y * regionMap.width;
                        if (x < sourceImg.width && y < sourceImg.height) {
                            int sourceIdx = x + y * sourceImg.width;
                            maskImg.pixels[idx] = sourceImg.pixels[sourceIdx];
                        }
                    }
                }
            }
            maskImg.updatePixels();
        }
    }

    public void drawMultiPass(PApplet p, ArrayList<Face> activeFaces) {
        if (this.currentFrameVertices.size() == 0 || activeFaces.size() == 0) return;
        
        p.pushStyle();
        p.noStroke();
        p.fill(255);
        
        for (int i = 0; i < activeFaces.size(); i++) {
            if (i >= this.maskedImages.size()) break;
            
            PImage textureImg = this.maskedImages.get(i);
            Face sourceFace = activeFaces.get(i);
            
            p.beginShape(PApplet.TRIANGLES);
            p.texture(textureImg);
            
            for (int[] tri : this.triangles) {
                for (int j = 0; j < 3; j++) {
                    int idx = tri[j];
                    float[] v = this.currentFrameVertices.get(idx);
                    float[] uv = sourceFace.uvCoords.get(idx);
                    p.vertex(v[0], v[1], v[2], uv[0], uv[1]);
                }
            }
            p.endShape();
        }
        p.popStyle();
    }
}
