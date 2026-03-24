class RegionMap {
    int[][] map;
    int width;
    int height;
    int numRegions;

    public RegionMap(int w, int h, int numRegions) {
        this.width = w;
        this.height = h;
        this.numRegions = numRegions;
        this.map = new int[w][h];
    }

    public void generateVoronoi() {
        int[][] seeds = new int[numRegions][2];
        for (int i = 0; i < numRegions; i++) {
            seeds[i][0] = (int)(Math.random() * width);
            seeds[i][1] = (int)(Math.random() * height);
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
}