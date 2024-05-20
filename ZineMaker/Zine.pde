import processing.data.JSONObject;

static final float mmPerInch = 25.4;

class Page {
  String name;
  float rotation;
  String contentPrefix;
  String imageFileType;
  String imageFilename;
  String imageFilenamepath;
  int imageBorderHorizontal;
  int imageBorderVertical;
  String textContentPrefix;
  String textImagePrefix;
  String textFilenamepath;
  PImage pageImage;
  PImage textImage;
  int pageWidthPx;
  int pageHeightPx;
  float pageAR;
  int pageImageWidthPx;
  int pageImageHeightPx;
  float pageImageAR;
}

class Sheet {
  String type; // single or double sided sheet
  String stereo; // 3D image mode: empty string "" or "sbs" or "xsbs"
  Page[] pages; // pages in a single sheet side
}

class Zine {

  boolean DEBUG = true;
  boolean templateOnly = false;

  // Style
  int TEMPLATE_FONT_SIZE = 96;
  int FONT_SIZE = 48;
  int MID_FONT_SIZE = 72;
  int COVER_FONT_SIZE = 96;
  int fontColor = 0xFF000000; // black

  PFont font;
  // The font must be located in the sketch's
  // "data" directory to load successfully
  //font = loadFont("LetterGothicStd.otf");
  //textFont(font, 128);

  String zineFilename ;
  String zineDescription;
  String contentFolderPath;
  int paperOrientation = LANDSCAPE;
  float paperWidth;
  float paperHeight;
  float printPPI;
  int paperWidthPx;
  int paperHeightPx;
  float paperAR = (float)paperWidthPx/(float)paperHeightPx;
  int pageColumns;
  int pageRows;
  int numPages;
  int numSheets;
  Sheet[] sheets;  // built from the config json file in content folder
  color templateColor = color(128);
  PImage[] zineImage;

  private static final int CONTENT_IMAGE = 0;
  private static final int TEXT_IMAGE = 1;
  String contentFolder;

  void init( String zineContentFolderPath, String zineContentFolder) {
    this.contentFolder = zineContentFolder;
    this.contentFolderPath = zineContentFolderPath;
  }

  PImage[] getZineImage() {
    return zineImage;
  }

  // Zine configuration
  // reads a config.json file describing the zine layout and content
  void configureZine() {
    readConfig(contentFolderPath + contentFolder + File.separator + contentFolder +".json");
  }

  /**
   * This function reads the JSON file and stores the values into local variables.
   * You can replace these local variables with your own variables as needed.
   * Java function to read the JSON file using Processing's `loadJSONObject()` method.
   */
  void readConfig(String filenamePath) {
    int pageWidthPx;
    int pageHeightPx;
    float pageAR;
    if (DEBUG) println("readConfig at "+filenamePath);
    JSONObject json = loadJSONObject(filenamePath);
    JSONObject maker = json.getJSONObject("maker");
    DEBUG = maker.getBoolean("debug");
    templateOnly = maker.getBoolean("templateOnly");
    JSONObject header = json.getJSONObject("header");
    zineFilename = header.getString("zineName");
    zineDescription = header.getString("zineDescription");
    // contentFolderpath = header.getString("contentFolderpath");  //  TO DO
    paperWidth = header.getFloat("paperWidth");
    paperHeight = header.getFloat("paperHeight");
    printPPI = header.getInt("printPPI");
    pageColumns = header.getInt("pageColumns");
    pageRows = header.getInt("pageRows");
    JSONObject style = json.getJSONObject("style");
    TEMPLATE_FONT_SIZE = style.getInt("TEMPLATE_FONT_SIZE");
    FONT_SIZE = style.getInt("FONT_SIZE");
    MID_FONT_SIZE = style.getInt("MID_FONT_SIZE");
    COVER_FONT_SIZE = style.getInt("COVER_FONT_SIZE");
    paperWidthPx = (int) (paperWidth * printPPI);
    paperHeightPx = (int) (paperHeight * printPPI);
    paperAR = (float)paperWidthPx/(float)paperHeightPx;
    pageWidthPx = paperWidthPx / pageColumns;
    pageHeightPx = paperHeightPx / pageRows;
    pageAR = (float) pageWidthPx / (float) pageHeightPx;

    JSONArray configSheets = json.getJSONArray("sheets");
    numSheets = configSheets.size();
    sheets = new Sheet[numSheets];
    zineImage = new PImage[numSheets];
    for (int i = 0; i < sheets.length; i++) {
      sheets[i] = new Sheet();
      JSONObject configSheet = configSheets.getJSONObject(i);
      String type = configSheet.getString("type");
      sheets[i].type = type;
      String stereo = configSheet.getString("stereo");
      sheets[i].stereo = stereo;
      JSONArray configPages = configSheet.getJSONArray("pages");
      numPages = configPages.size();
      Page[] pages = new Page[numPages];
      sheets[i].pages = pages;
      if (numPages != (pageRows*pageColumns)) {
        println("Configuration ERROR Number of rows and columns not equal to number of Pages  ***********");
      }
      for (int j = 0; j < numPages; j++) {
        JSONObject configPage = configPages.getJSONObject(j);
        Page page = new Page();
        page.name = configPage.getString("name");
        page.rotation = radians(configPage.getFloat("rotation"));
        page.contentPrefix = configPage.getString("contentPrefix");
        page.imageFileType = configPage.getString("imageFileType");
        page.imageFilenamepath = configPage.getString("imageFilenamepath");
        page.imageBorderHorizontal = configPage.getInt("imageBorderHorizontal");
        page.imageBorderVertical = configPage.getInt("imageBorderVertical");
        page.textContentPrefix = configPage.getString("textContentPrefix");
        page.textImagePrefix = configPage.getString("textImagePrefix");
        page.textFilenamepath = configPage.getString("textFilenamepath");
        page.pageWidthPx = pageWidthPx;
        page.pageHeightPx = pageHeightPx;
        page.pageAR = pageAR;
        page.pageImageWidthPx = page.pageWidthPx - 2*page.imageBorderHorizontal;
        page.pageImageHeightPx = page.pageHeightPx - 2*page.imageBorderVertical;
        page.pageImageAR = (float)(page.pageImageWidthPx)/(float)page.pageImageHeightPx;
        pages[j] = page;
      }
    }
    println("paperWidth = " +paperWidth + " paperHeight = " + paperHeight+ " landscape");
    println("printPPI = "+printPPI);
    println("paperWidthPx = "+paperWidthPx+" paperHeightPx = "+paperHeightPx);
    println("paperAR = "+paperAR);
    println("pageColumns = "+ pageColumns + " pageRows = " + pageRows );
    println("numPages = "+numPages);
    println("page Width Px = "+pageWidthPx + " Height Px = "+pageHeightPx);
    println();
    println("Sketch folder path="+getZineFolderPath());
    println();
  }

  void createZine() {
    //thread("createZineImage");  // make a zine in the background
    createZineImage();
  }

  // A thread function to create a Zine in the background
  public void createZineImage() {

    println("****************** Content folder = " + contentFolder);
    println();
    String configFilename = contentFolderPath +contentFolder + File.separator + contentFolder +".json";
    println("configFilename path="+configFilename);

    // draw sheets
    for (int i=0; i<sheets.length; i++) {
      // create pages for each sheet
      // first convert all text page files into images
      for (int j=0; j<sheets[i].pages.length; j++) {
        Page page = sheets[i].pages[j];
        generateTextImage(contentFolder, zine, sheets[i], page);  // converts text file per page into a PImage
      }
      // Now draw a Zine page sheet with images according to configured layout
      templateOnly = true;
      for (int k=0; k<2; k++) { // include template
        zineImage[i] = drawZine(contentFolder, sheets[i].pages, templateOnly);
        // save a zine page sheet as a png image file
        // i+1 is the sheet number
        String templateSuffix = (templateOnly)? "_Template" : "";
        String path = getZineFolderPath() + contentFolder + File.separator + zineFilename + templateSuffix + "_"+(i+1)+".png";
        zineImage[i].save(path);
        templateOnly = false;
      }
    }
  }

  // Draw a Zine page sheet with pages defined in configuration json file
  PImage drawZine(String contentFolder, Page[] pages, boolean templateOnly) {
    PGraphics pg;
    PImage img;
    float w = 0;
    float h = 0;
    float hOffset = 0;
    float wOffset = 0;
    Page page;

    // create PGraphics image for drawing the zine pages
    pg = createGraphics(paperWidthPx, paperHeightPx);
    pg.beginDraw();
    pg.background(255);  // white

    if (templateOnly) {
      // draw page numbers bottom left
      pg.textSize(TEMPLATE_FONT_SIZE);
      pg.fill(0);
      //for (int i=0; i<pages.length; i++) {
      //  page = pages[i];
      //  int x = ((i % pageColumns) * page.pageWidthPx) + (page.pageWidthPx );
      //  int y = ((i / pageColumns) *page.pageHeightPx) ;
      //  pg.pushMatrix();
      //  if (page.rotation == 0) {
      //    pg.text(page.name, x-page.pageWidthPx, y+page.pageHeightPx);
      //  } else {
      //    pg.translate(x,y);
      //    pg.rotate(page.rotation);
      //    pg.text(page.name, 0, 0);
      //  }
      //  pg.popMatrix();
      //}

      // draw page number centered
      for (int i=0; i<pages.length; i++) {
        page = pages[i];
        int x = ((i % pageColumns) * page.pageWidthPx);
        int y = ((i / pageColumns) *page.pageHeightPx) ;
        pg.pushMatrix();
        if (page.rotation == 0) {
          pg.text(page.name, x+((page.pageWidthPx-pg.textWidth(page.name))/2), y+page.pageHeightPx/2);
        } else {
          pg.translate(x, y);
          pg.rotate(page.rotation);
          pg.text(page.name, -(page.pageWidthPx/2+(pg.textWidth(page.name)/2)), -page.pageHeightPx/2);
        }
        pg.popMatrix();
      }
    } else {
      // read page images and draw
      for (int i=0; i<pages.length; i++) {
        page = pages[i];

        for (int j=CONTENT_IMAGE; j<=TEXT_IMAGE; j++) {
          if (j == CONTENT_IMAGE) {  // content image, 1 text image
            page.imageFilename = page.contentPrefix + page.name + "." + page.imageFileType;
          } else {
            page.imageFilename = page.textImagePrefix + page.name + "." + "png"  ;  // text image always png
          }

          //if (DEBUG) {
          //  println("pageWidthPx = "+page.pageWidthPx + " pageHeightPx = "+page.pageHeightPx);
          //  println("pageWidthmm = "+ ((float)page.pageWidthPx/printPPI)*mmPerInch + " pageHeightmm = "+
          //    ((float)page.pageHeightPx/printPPI)*mmPerInch);
          //  println("pageAR = "+page.pageAR);
          //  println("page imageBorderHorizontal = "+ page.imageBorderHorizontal);
          //  println("page imageBorderVertical = "+ page.imageBorderVertical);
          //  println("pageImageWidth = "+ page.pageImageWidthPx + " pageImageHeight = " + page.pageImageHeightPx);
          //  println("pageImageAR = "+page.pageImageAR);
          //}

          // check if content image file path exists and if so use it instead of prefix defined content image files
          String path;
          if (page.imageFilenamepath != null && page.imageFilenamepath.length() > 1 && j == 0) {
            path = getZineFolderPath() + contentFolder + File.separator + page.imageFilenamepath;
          } else {
            path = getZineFolderPath() + contentFolder + File.separator + page.imageFilename;
          }
          println("loadImage path="+ path);
          File f = new File(path);
          if (f.exists()) {
            page.pageImage = loadImage(path);
            float imageWidth = page.pageImage.width;
            float imageHeight = page.pageImage.height;
            println("image w="+imageWidth +" h="+imageHeight);
            float imageAR = imageWidth/imageHeight;
            // x and y are coordinates for top left corner of page
            int x = (i % pageColumns) * page.pageWidthPx;
            int y = (i / pageColumns) *page.pageHeightPx;
            pg.pushMatrix();
            String imgName = page.contentPrefix;
            if (j == 1) imgName = page.textImagePrefix;
            println(imgName + " image="+str(i+1)+" imageAR="+page.pageImageAR + " pageAR="+page.pageAR);
            // Image Rotation
            if (page.rotation != 0) {
              pg.translate(x, y);
              pg.rotate(page.rotation);  // image rotate
              if (page.pageAR > 1.0) {   // landscape
                if (imageAR > 1.0) {
                  w = (float)page.pageImageWidthPx ;
                  h = w/imageAR ;
                  hOffset = ((float)page.pageHeightPx - h )/2;  // for centering in page
                  wOffset = ((float)page.pageWidthPx - w )/2; // for centering in page
                  pg.image(page.pageImage, -page.pageWidthPx+wOffset, hOffset-page.pageHeightPx, w, h);
                } else {
                  // pg.translate(x, y);
                  //pg.rotate(page.rotation);  // image rotate
                  h = (float)page.pageImageHeightPx ;
                  w = h*imageAR;
                  hOffset = ((float)page.pageHeightPx - h )/2;  // for centering in page
                  wOffset = ((float)page.pageWidthPx - w )/2; // for centering in page
                  pg.image(page.pageImage, -page.pageWidthPx+wOffset, hOffset-page.pageHeightPx, w, h);
                }
              } else {
                if (imageAR > 1.0) {
                  //pg.translate(x, y);
                  // pg.rotate(page.rotation);  // image rotate
                  w = (float)page.pageImageWidthPx;
                  h = w/imageAR;
                  hOffset = ((float)page.pageHeightPx - h )/2;  // for centering in page
                  wOffset = ((float)page.pageWidthPx - w )/2; // for centering in page
                  pg.image(page.pageImage, -page.pageWidthPx+wOffset, hOffset-page.pageHeightPx, w, h);
                } else {
                  // pg.translate(x, y);
                  //pg.rotate(page.rotation);  // image rotate
                  w = (float)page.pageImageWidthPx ;
                  h = w/imageAR;
                  hOffset = ((float)page.pageHeightPx - h )/2;  // for centering in page
                  wOffset = ((float)page.pageWidthPx - w )/2; // for centering in page
                  pg.image(page.pageImage, -page.pageWidthPx+wOffset, hOffset-page.pageHeightPx, w, h);
                }
              }
              ///  No Image Rotation -------------------------------------------------------------
            } else {
              if (page.pageAR > 1.0) { // landscape
                if (imageAR > 1.0) {
                  //w = h/imageAR;
                  w = (float)page.pageImageWidthPx ;
                  h = w/imageAR ;
                  hOffset = ((float)page.pageHeightPx - h )/2; // for centering in page
                  wOffset = ((float)page.pageWidthPx - w )/2; // for centering in page
                  pg.image(page.pageImage, x+wOffset, y+hOffset, w, h);  //
                } else {
                  h = (float)page.pageImageHeightPx ;
                  w = h*imageAR;
                  hOffset = ((float)page.pageHeightPx - h )/2; // for centering in page
                  wOffset = ((float)page.pageWidthPx - w )/2; // for centering in page
                  pg.image(page.pageImage, x+wOffset, y-hOffset, w, h);  //
                }
              } else {  // portrait
                if (imageAR > 1.0) {
                  w = (float)page.pageImageWidthPx ;
                  h = w/imageAR;
                  hOffset = ((float)page.pageHeightPx - h )/2; // for centering in page
                  wOffset = ((float)page.pageWidthPx - w )/2; // for centering in page
                  pg.image(page.pageImage, x+wOffset, y+hOffset, w, h);  //
                } else {
                  w = (float)page.pageImageWidthPx ;
                  h = w/imageAR;
                  hOffset = ((float)page.pageHeightPx - h )/2; // for centering in page
                  wOffset = ((float)page.pageWidthPx - w )/2; // for centering in page
                  pg.image(page.pageImage, x+wOffset, y+hOffset, w, h);  //
                }
              }
            }
            pg.popMatrix();
          } else {
            println(page.imageFilename + " does not exist");
          }
        }
      }
    }

    // draw grid fold lines for pages
    pg.strokeWeight(1);
    pg.fill(0); // black
    pg.stroke(templateColor); // stroke color for template fold lines

    page = pages[0];

    for (int row=0; row <= pageRows; row++) {
      pg.line(0, row*page.pageHeightPx, paperWidthPx, row*page.pageHeightPx);
    }
    for (int col=0; col <= pageColumns; col++) {
      pg.line(col*page.pageWidthPx, 0, col*page.pageWidthPx, paperHeightPx);
    }

    // draw cut lines
    pg.strokeWeight(3);
    pg.fill(0xFFF80000);
    pg.stroke(0xFFFF8000);
    if (numPages == 8 ) {
      if (pageColumns == 4) {
        pg.line(page.pageWidthPx, page.pageHeightPx, (3*paperWidthPx)/4, page.pageHeightPx);
      } else {
        pg.line(page.pageWidthPx, page.pageHeightPx, page.pageWidthPx, (3*page.pageHeightPx)/4);
      }
    } else if (numPages == 16) {
        pg.line(page.pageWidthPx, page.pageHeightPx, 3*page.pageWidthPx, page.pageHeightPx);
        pg.line(0, 2*page.pageHeightPx, page.pageWidthPx, 2*page.pageHeightPx);
        pg.line(3*page.pageWidthPx, 2*page.pageHeightPx, 4*page.pageWidthPx, 2*page.pageHeightPx);
        pg.line(page.pageWidthPx, 3*page.pageHeightPx, 3*page.pageWidthPx, 3*page.pageHeightPx);
        pg.line(2*page.pageWidthPx, page.pageHeightPx, 2*page.pageWidthPx, 3*page.pageHeightPx);
    }

    pg.endDraw();
    img = pg.copy();
    pg.dispose();
    return img;
  }
}
