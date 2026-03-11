import processing.core.PApplet;
import processing.core.PImage;
import processing.data.JSONArray;
import java.util.ArrayList;

class Face {
    PImage img;
    float x, y, z;
    boolean active;
    ArrayList<PixelRegion> activePixels;
    
    ArrayList<float[]> currentFrameVertices;
    ArrayList<int[]> triangles;
    ArrayList<float[]> uvCoords;
    int currentFrameIndex = 0;
    int totalFrames = 0;
    JSONArray animationData;
    
    float meshScaleX = 100.0f;
    float meshScaleY = 100.0f;
    float meshScaleZ = 100.0f;
    
    float captureAspectRatio = 640.0f / 480.0f;
    float displayScale = 2.5f;

    public Face(PImage img, JSONArray uvData) {
        this.img = img;
        this.x = 0;
        this.y = 0;
        this.z = 0;
        this.active = false;
        this.activePixels = new ArrayList<PixelRegion>();
        this.currentFrameVertices = new ArrayList<float[]>();
        this.triangles = new ArrayList<int[]>();
        this.uvCoords = new ArrayList<float[]>();
        
        if (img != null) {
            this.meshScaleX = img.width;
            this.meshScaleY = img.height;
            this.meshScaleZ = img.width;
        }

        if (uvData != null) {
            for (int i = 0; i < uvData.size(); i++) {
                JSONArray uv = uvData.getJSONArray(i);
                this.uvCoords.add(new float[]{uv.getFloat(0), uv.getFloat(1)});
            }
        }
    }

    public Face(PImage img, ArrayList<float[]> existingUVs) {
        this.img = img;
        this.x = 0;
        this.y = 0;
        this.z = 0;
        this.active = false;
        this.activePixels = new ArrayList<PixelRegion>();
        this.currentFrameVertices = new ArrayList<float[]>();
        this.triangles = new ArrayList<int[]>();
        this.uvCoords = new ArrayList<float[]>();
        
        if (img != null) {
            this.meshScaleX = img.width;
            this.meshScaleY = img.height;
            this.meshScaleZ = img.width;
        }

        if (existingUVs != null) {
            for (float[] uv : existingUVs) {
                this.uvCoords.add(new float[]{uv[0], uv[1]});
            }
        }
    }

    public void loadMeshData(PApplet p, String animFile, String triFile) {
        JSONArray triJson = p.loadJSONArray(triFile);
        for (int i = 0; i < triJson.size(); i++) {
            JSONArray tri = triJson.getJSONArray(i);
            triangles.add(new int[]{tri.getInt(0), tri.getInt(1), tri.getInt(2)});
        }

        animationData = p.loadJSONArray(animFile);
        totalFrames = animationData.size();
    }

    public void updateAnimation() {
        if (totalFrames == 0) return;

        JSONArray frame = animationData.getJSONArray(currentFrameIndex);
        currentFrameVertices.clear();
        
        float centerX = meshScaleX / 2.0f;
        float centerY = meshScaleY / 2.0f;
        
        for (int i = 0; i < frame.size(); i++) {
            JSONArray point = frame.getJSONArray(i);
            
            float normX = point.getFloat(0);
            float correctedX = (normX - 0.5f) * captureAspectRatio + 0.5f;
            
            float vxBase = correctedX * meshScaleX; 
            float vyBase = point.getFloat(1) * meshScaleY; 
            float vzBase = -point.getFloat(2) * meshScaleX * captureAspectRatio; 
            
            float vx = centerX + (vxBase - centerX) * displayScale;
            float vy = centerY + (vyBase - centerY) * displayScale;
            float vz = vzBase * displayScale;
            
            currentFrameVertices.add(new float[]{vx, vy, vz});
        }

        currentFrameIndex = (currentFrameIndex + 1) % totalFrames;
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
        this.activate();
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
            this.activePixels.clear();
        }
    }
}
