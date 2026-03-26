import processing.core.PApplet;
import processing.core.PGraphics;
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

    public MosaicFace(PImage img, ArrayList<float[]> existingUVs, int emptyColor) {
        super(img, existingUVs);
        this.emptyColor = emptyColor;
    }

    public void renderBuffer(PApplet p, PShader shader) {
        if (this.buffer == null || this.children.size() == 0) return;

        this.buffer.beginDraw();
        this.buffer.textureMode(PApplet.NORMAL); // CRITICAL FIX: Ensures UVs map correctly
        this.buffer.clear(); 
        this.buffer.noStroke();
        
        this.buffer.tint(255);
        this.buffer.fill(0xFF000000);
        
        shader.set("isMosaicCenter", true);
        this.buffer.shader(shader);
        
        float w = this.buffer.width;
        float h = this.buffer.height;
        
        for (int i = 0; i < this.children.size(); i++) {
            Face child = this.children.get(i);
            
            shader.set("myFaceIndex", i * 13 + 7); 
            
            if (child.uvCoords.size() == 0 || child.img == null) continue;
            
            this.buffer.beginShape(PApplet.TRIANGLES);
            this.buffer.texture(child.img);
            
            for (int[] tri : this.triangles) {
                for (int j = 0; j < 3; j++) {
                    int idx = tri[j];
                    float[] uv = child.uvCoords.get(idx);
                    this.buffer.vertex(uv[0] * w, uv[1] * h, 0, uv[0], uv[1]);
                }
            }
            this.buffer.endShape();
        }
        
        this.buffer.resetShader();
        this.buffer.endDraw();
        
        this.img = this.buffer;
    }

    public void drawMultiPass(PGraphics pg, PShader shader) {
        if (this.currentFrameVertices.size() == 0 || this.children.size() == 0) return;

        pg.pushStyle();
        pg.textureMode(PApplet.NORMAL);
        pg.noStroke();
        pg.blendMode(PApplet.BLEND);
        
        pg.tint(255);
        pg.fill(0xFF000000);
        
        for (int i = 0; i < this.children.size(); i++) {
            shader.set("myFaceIndex", i);
            Face child = this.children.get(i);
            
            if (child.uvCoords.size() == 0 || child.img == null) continue;
            
            pg.beginShape(PApplet.TRIANGLES);
            pg.texture(child.img);
            
            for (int[] tri : this.triangles) {
                for (int j = 0; j < 3; j++) {
                    int idx = tri[j];
                    float[] v = this.currentFrameVertices.get(idx);
                    float[] uv = child.uvCoords.get(idx);
                    pg.vertex(v[0], v[1], v[2], uv[0], uv[1]);
                }
            }
            pg.endShape();
        }

        pg.popStyle();
    }
}
