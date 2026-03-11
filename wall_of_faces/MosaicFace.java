import processing.core.PImage;
import processing.data.JSONArray;
import java.util.Arrays;

class MosaicFace extends Face {
    int emptyColor;

    public MosaicFace(PImage img, JSONArray uvData, int emptyColor) {
        super(img, uvData);
        this.emptyColor = emptyColor;
    }

    public void updateFromGrid(Grid sourceGrid, RegionMap regionMap, int shiftOffset) {
        this.img.loadPixels();
        
        int numActive = sourceGrid.activeIndices.size();
        
        if (numActive == 0) {
            Arrays.fill(this.img.pixels, this.emptyColor);
            this.img.updatePixels();
            return;
        }

        for (int index : sourceGrid.activeIndices) {
            Face f = sourceGrid.constructedFaceArray.get(index);
            f.img.loadPixels();
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
                    int faceIndex = sourceGrid.activeIndices.get(activeListIndex);
                    
                    Face f = sourceGrid.constructedFaceArray.get(faceIndex);
                    
                    if (x < f.img.width && y < f.img.height) {
                        int sourceIndex = x + y * f.img.width;
                        this.img.pixels[targetIndex] = f.img.pixels[sourceIndex];
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
}
