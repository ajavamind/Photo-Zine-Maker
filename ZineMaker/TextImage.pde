// Generate Text Image Files
//
import java.util.ArrayList;
import java.util.List;

PImage generateTextImage(String contentFolder, Zine zine, Sheet sheet, Page page) {
  String mode = sheet.stereo; // for stereo text layout
  String filename = page.textContentPrefix  + page.name + ".txt";
  String imagePrefix = page.textImagePrefix + page.name;
  String altText = page.name;
  PImage img = null;
  String[] lines;
  // check if text filename exists
  String path = getZineFolderPath() + contentFolder + File.separator + filename;
  File f = new File(path);
  if (f.exists()) {
    println("path="+ path);
    lines = loadStrings(path);
  } else {
    lines = new String[1];
    lines[0] = altText;
  }
  if (mode !=null && mode.equals("sbs")) {
    img = drawStereoText(lines, zine, page, zine.MID_FONT_SIZE, zine.fontColor);
  } else {
    img = drawLeftText(lines, zine, page, zine.MID_FONT_SIZE, zine.fontColor);
  }
  img.save(getZineFolderPath() + contentFolder + File.separator + imagePrefix +".png");
  return img;
}

// Draw stereo text image
// return PImage
PImage drawStereoText( String[] lines, Zine zine, Page page, int fontSize, color c) {
  int w = page.pageImageWidthPx;
  int h = page.pageImageHeightPx;
  println("drawStereoText w="+w+ " h="+h);
  // positive parallax in background
  // negative parallax in foreground
  // zero parallax at the stereo window
  // possible zoom for depth change arrays
  //int[] parallax = {40, 30, 20, 10, 0, -10, -20, -30, -40}; // display order positive to negative parallax
  //int[] parallax = {-40, -30, -20, -10, 0, 10, 20, 30, 40}; // display order negative to positive parallax
  //int[] parallax = { -20, -10, 0, 10, 20 }; // display order negative to positive parallax
  int parallax = 0;
  int stereoWindowParallax = 0;
  int foregroundParallax = -8;
  int numDisplayLines = 20; // maximum per page
  int hCurrent = 0;  // current line height
  float wordSpacing = 5;

  PGraphics pg;
  PImage img;
  String[] words;
  pg = createGraphics(w, h);
  pg.beginDraw();
  pg.background(#00010101);  // transparent background
  pg.textSize(fontSize);
  wordSpacing = pg.textWidth(" ");

  // left and right eye divider
  pg.fill(0);
  pg.line(w/2, 0, w/2, h);

  int count = 0;
  for (int i = 0; i < lines.length; i++) {
    if (count < numDisplayLines) {
      String line = lines[i];
      line = line.replace("#", "");
      float xl = (w/2 - pg.textWidth(line))/2;
      xl = xl - round(wordSpacing);
      float xr = xl;
      float y = hCurrent + count * fontSize;

      words = lines[i].split(" ");

      // do not show with retinal disparity
      for (int j = 0; j< words.length; j++) {
        String word = words[j];
        if (words[j].startsWith("#")) {
          word = words[j].substring(1);
          parallax = foregroundParallax;
        } else {
          parallax = stereoWindowParallax;
        }

        if (parallax == 0)
          pg.fill(c);
        else
          pg.fill(#FFFF0000);

        pg.text(word, xl, y);
        pg.text(word, w/2+ xr + parallax, y);
        xl = xl + wordSpacing + pg.textWidth(word);
        xr = xl;
      }
    }
    count++;
  }

  pg.endDraw();
  img = pg.copy();
  pg.dispose();
  return img;
}

PImage drawLeftText(String[] lines, Zine zine, Page page, int fontSize, color c) {
  int numDisplayLines = 20; // maximum per page
  int w = page.pageWidthPx;
  int h = page.pageHeightPx;
  PGraphics pg;
  PImage img;
  String[] words;
  pg = createGraphics(w, h);
  pg.beginDraw();
  pg.background(#00010101);  // transparent background
  pg.textSize(fontSize);
  
  int count = 0;
  for (int i = 0; i < lines.length; i++) {
    if (count < numDisplayLines) {
      int x = (i % zine.pageColumns) * w;
      int y = (i / zine.pageColumns) * h;
      for (int j=0; j<lines.length; j++) {
        pg.pushMatrix();
        pg.translate(x, y);
        pg.fill(c);
        pg.text(lines[j], 0, 0);

        y = y + fontSize;
        pg.popMatrix();
      }
    }
    count++;
  }

  pg.endDraw();
  img = pg.copy();
  pg.dispose();
  return img;
}

// Draw text image
// make image transparent
// return PImage
PImage drawText( String[] lines, int w, int h, int fontSize, color c) {
  int numDisplayLines = 20; // maximum per page
  int hCurrent = 0;  // current line height
  float wordSpacing = 5;

  PGraphics pg;
  PImage img;
  String[] words;
  pg = createGraphics(w, h);
  pg.beginDraw();
  pg.background(#00010101);  // transparent background
  pg.textSize(fontSize);
  wordSpacing = pg.textWidth("M ");

  int count = 0;
  for (int i = 0; i < lines.length; i++) {
    if (count < numDisplayLines) {
      String line = lines[i];
      line = line.replace("#", "");
      float x = (w/2 - pg.textWidth(line))/2;
      x = x - 3* round(wordSpacing);
      float y = hCurrent + count * fontSize;

      words = lines[i].split(" ");
      for (int j = 0; j< words.length; j++) {
        String word = words[j];
        if (words[j].startsWith("#")) {
          word = words[j].substring(1);
          // color change
          pg.fill(c);
        } else {
          // color change
          pg.fill(#FFFF0000);
        }

        pg.text(word, x, y);
        x = x + wordSpacing + pg.textWidth(word);
      }
    }
    count++;
  }

  pg.endDraw();
  img = pg.copy();
  pg.dispose();
  return img;
}
