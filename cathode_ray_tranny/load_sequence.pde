void loadSequence(String folderPath) {
  allFrames = new ArrayList<int[]>();
  
  // 1. Get the folder
  File dir = new File(sketchPath(folderPath)); 
  
  // 2. Get list of files
  File[] files = dir.listFiles();
  
  if (files == null) {
    println("Error: Folder not found or empty!");
    println(dir);
    return;
  }
  
  // 3. Sort files alphanumerically (01.jpg, 02.jpg, etc.)
  // We use a simple lambda comparator here
  java.util.Arrays.sort(files, (f1, f2) -> f1.getName().compareTo(f2.getName()));
  
  // 4. Load and Process each file
  for (File f : files) {
    String name = f.getName().toLowerCase();
    if (f.isFile() && (name.endsWith(".png") || name.endsWith(".jpg") || name.endsWith(".jpeg"))) {
      
      PImage img = loadImage(f.getAbsolutePath());
      
      // IMPORTANT: Resize to match our grid resolution!
      img.resize(imgSampleSizeDim, imgSampleSizeDim);
      img.loadPixels();
      
      // Add pixels to our sequence list
      allFrames.add(img.pixels);
      println("Loaded: " + f.getName());
    }
  }
  
  // 5. Set the first frame immediately
  if (allFrames.size() > 0) {
    pixelData = allFrames.get(0);
  }
}
