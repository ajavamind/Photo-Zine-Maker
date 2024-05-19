// Automated Multi-page layout and content Zine Maker.
// The example application uses 8.5 by 11 inch paper with 1 or 2 sides
// for a printer set to ppi 300

// Test Zine Folders
String testZinesFolder = "TestZines";
String zineContentFolder = 
  //"TestSquare_4_pages";
  //"TestSquare_8_pages";
  "TestSquare_16_pages";

int zineSelect=0;
int zineIndex = 0;
PImage[] zineImage;
int frameCounter = 0;
Zine zine;

// Modify to provide your own zine folder
// path is relative to this sketch path
String getZineFolderPath() {
  // using default test folders - change this line to find and make your own zines
  String path = sketchPath() + File.separator + testZinesFolder + File.separator;
  return path;
}

void settings() {
  // size a square screen to show all landscape, square, or
  // portrait layouts without resizing the window
  // on a 4K monitor
  int w = 1398;
  int h = 1398;
  size(w, h);  // paper screen size on screen
  println("screen dimensions for paper: width = " +w + " height = "+h);
}

void setup() {
  frameRate(10);
  frameCounter = 10;
  // get list of zine folders to process
  //zines = new PImage[zineContentFolder.length];
  zine = new Zine();
  zine.init(getZineFolderPath(), zineContentFolder);
  zine.configureZine();
  zine.createZine();
}

void draw() {
  // show latest zine sheet image
  background(0);

  zineImage = zine.getZineImage();
  if (zineImage == null) {
    fill(255);
    displayMessage( "Not Ready!", 96, 0xFFFFFF00);
    return;
  }
  PImage img = zineImage[zineIndex];
  if (img != null && img.width > 0 && img.height > 0) {
    float imgAR = ((float)img.width/(float)img.height);
    if (imgAR < 1.0) {
      image(img, 0, 0, (float)height * imgAR, height);
    } else {
      image(img, 0, 0, width, (float)width /imgAR);
    }
    if (frameCounter <= 0) {
      zineIndex++;
      if (zineIndex >= zineImage.length) zineIndex = 0;
      frameCounter = 10;
    } else {
      frameCounter--;
    }
  } else {
    displayMessage( "Working!", 96, 0xFF00FFFF);
  }
}

void displayMessage(String msg, int fontSize, color c) {
  fill(c);
  textSize(fontSize);
  text(msg, width/2-(textWidth(msg)/2), height/2);
}
