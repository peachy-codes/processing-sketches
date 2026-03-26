import processing.core.PApplet;
import processing.core.PImage;
import processing.data.JSONArray;
import java.util.ArrayList;
import processing.opengl.PShader;

class MosaicFace extends Face {
    int emptyColor;

    public MosaicFace(PImage img, JSONArray uvData, int emptyColor) {
        super(img, uvData);
        this.emptyColor = emptyColor;
    }

    public void drawMultiPass(PApplet p, ArrayList<Face> activeFaces, PShader shader) {
        if (this.currentFrameVertices.size() == 0 || activeFaces.size() == 0) return;

        p.pushStyle();
        p.noStroke();
        p.blendMode(PApplet.BLEND);
        
        for (int i = 0; i < activeFaces.size(); i++) {
            shader.set("myFaceIndex", i);
            Face sourceFace = activeFaces.get(i);
            
            if (sourceFace.uvCoords.size() == 0) continue;
            
            p.beginShape(PApplet.TRIANGLES);
            p.texture(sourceFace.img);
            
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
