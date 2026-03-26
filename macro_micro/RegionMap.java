import processing.core.PApplet;

class RegionMap {
    PApplet p;
    int[][] map;
    int width;
    int height;
    int numRegions;

    public RegionMap(PApplet p, int w, int h, int numRegions) {
        this.p = p;
        this.width = w;
        this.height = h;
        this.numRegions = numRegions;
        this.map = new int[w][h];
    }

    public void generateVoronoi() {
        int[][] seeds = new int[numRegions][2];
        for (int i = 0; i < numRegions; i++) {
            seeds[i][0] = (int)(p.random(width));
            seeds[i][1] = (int)(p.random(height));
        }

        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                float minDist = Float.MAX_VALUE;
                int closestRegion = 0;

                for (int i = 0; i < numRegions; i++) {
                    float dx = x - seeds[i][0];
                    float dy = y - seeds[i][1];
                    float dist = dx * dx + dy * dy;

                    if (dist < minDist) {
                        minDist = dist;
                        closestRegion = i;
                    }
                }
                map[x][y] = closestRegion;
            }
        }
    }

    public void generateNoise(float scale) {
        p.noiseSeed((long)(p.random(10000)));
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                float n = p.noise(x * scale, y * scale);
                int region = (int)(n * numRegions);
                map[x][y] = p.constrain(region, 0, numRegions - 1);
            }
        }
    }

    public void generateGrid() {
        int cols = (int)Math.ceil(Math.sqrt(numRegions));
        int rows = (int)Math.ceil((float)numRegions / cols);
        float cellW = (float)width / cols;
        float cellH = (float)height / rows;

        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                int col = (int)(x / cellW);
                int row = (int)(y / cellH);
                int region = col + row * cols;
                map[x][y] = p.constrain(region, 0, numRegions - 1);
            }
        }
    }
}
