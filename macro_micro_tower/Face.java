import processing.core.PApplet;
import processing.core.PImage;
import processing.core.PGraphics;
import processing.data.JSONArray;
import java.util.ArrayList;

class Face {
    PImage img;
    PGraphics buffer; 
    
    float x, y, z;
    float rotationZ = 0.0f;
    boolean active;
    
    float globalX, globalY, globalZ;
    float globalRotationZ;
    
    public ArrayList<Face> children;
    public Face parent;
    
    public ArrayList<Integer> activeVertexIndices;
    
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
    float displayScale = 5.0f;

    public Face(PImage img, JSONArray uvData) {
        this.img = img;
        this.x = 0;
        this.y = 0;
        this.z = 0;
        this.active = false;
        
        this.children = new ArrayList<Face>();
        this.activeVertexIndices = new ArrayList<Integer>();
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
        
        this.children = new ArrayList<Face>();
        this.activeVertexIndices = new ArrayList<Integer>();
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

    public void initBuffer(PApplet p, int w, int h) {
        this.buffer = p.createGraphics(w, h, PApplet.P3D);
        this.img = this.buffer; 
    }

    public void updateGlobalTransform(float pX, float pY, float pZ, float pRot) {
        float cosR = (float) Math.cos(pRot);
        float sinR = (float) Math.sin(pRot);
        
        this.globalX = pX + (this.x * cosR - this.y * sinR);
        this.globalY = pY + (this.x * sinR + this.y * cosR);
        this.globalZ = pZ + this.z;
        this.globalRotationZ = pRot + this.rotationZ;
        
        for (Face child : children) {
            child.updateGlobalTransform(this.globalX, this.globalY, this.globalZ, this.globalRotationZ);
        }
    }

    public void loadMeshData(JSONArray animData, JSONArray triData) {
        this.triangles.clear();
        for (int i = 0; i < triData.size(); i++) {
            JSONArray tri = triData.getJSONArray(i);
            this.triangles.add(new int[]{tri.getInt(0), tri.getInt(1), tri.getInt(2)});
        }
    
        this.animationData = animData;
        this.totalFrames = animationData.size();
        
        this.updateAnimation();
    }

    public void updateAnimation() {
        if (totalFrames == 0) return;
    
        JSONArray frame = animationData.getJSONArray(currentFrameIndex);
        boolean initializeArrays = currentFrameVertices.size() != frame.size();
        
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
            
            if (initializeArrays) {
                currentFrameVertices.add(new float[]{vx, vy, vz});
            } else {
                float[] v = currentFrameVertices.get(i);
                v[0] = vx;
                v[1] = vy;
                v[2] = vz;
            }
        }
    
        currentFrameIndex = (currentFrameIndex + 1) % totalFrames;
        
        for (Face child : children) {
            child.updateAnimation();
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

    public void draw(PGraphics pg) {
        if (this.active && this.currentFrameVertices.size() > 0 && this.uvCoords.size() > 0){
            pg.pushStyle();
            pg.textureMode(PApplet.NORMAL);
            pg.noStroke();
            
            pg.tint(255);
            pg.fill(0xFF000000); 
            
            pg.beginShape(PApplet.TRIANGLES);
            pg.texture(this.img);

            for (int[] tri : this.triangles) {
                for (int j = 0; j < 3; j++) {
                    int idx = tri[j];
                    float[] v = this.currentFrameVertices.get(idx);
                    float[] uv = this.uvCoords.get(idx);
                    pg.vertex(v[0], v[1], v[2], uv[0], uv[1]);
                }
            }
            pg.endShape();
            pg.popStyle();
        } else if (this.img != null) {
            pg.image(this.img, 0, 0);
        }
    }
}
