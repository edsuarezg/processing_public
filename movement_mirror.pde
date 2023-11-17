/**
 * Frame Differencing 
 * by Golan Levin. 
 *
 * Quantify the amount of movement in the video frame using frame-differencing.
 */ 


import processing.video.*;

int numPixels;
int[] previousFrame;
Capture video;
int cols, rows;
int cellSize = 15;
// Characters sorted according to their visual density
String letterOrder = "ReCoNoCeRRECONOCERReconocerReCONOcerReconoceR";
char[] letters;

void create_mirror(PImage image){
  // Begin loop for columns
    for (int i = 0; i < cols;i++) {
      // Begin loop for rows
      for (int j = 0; j < rows;j++) {

        // Where are we, pixel-wise?
        int x = i * cellSize;
        int y = j * cellSize;
        int loc = (image.width - x - 1) + y*image.width; // Reversing x to mirror the image

        // Each rect is colored white with a size determined by brightness
        color c = image.pixels[loc];
        //float sz = (brightness(c) / 255.0) * cellSize;
        fill(c);
        noStroke();
        rect(x + cellSize/2, y + cellSize/2, cellSize, cellSize);
        }
    }
}

void setup() {
  size(640, 480);
  //fullScreen();
  cols = width / cellSize;
  rows = height / cellSize;
  background(0);
  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  video = new Capture(this, width, height);
  
  // Start capturing the images from the camera
  video.start(); 
  
  numPixels = video.width * video.height;
  // Create an array to store the previously captured frame
  previousFrame = new int[numPixels];
  //loadPixels();
  
  // create a letter for each pixel in the row-col space
  letters = new char[cols*rows];
  for (int i = 0; i < cols*rows; i++) {
    int index = int(map(i, 0, cols*rows, 0, letterOrder.length()));
    letters[i] = letterOrder.charAt(index);
  }
}

void draw() {
  if (video.available()) {
    // When using video to manipulate the screen, use video.available() and
    // video.read() inside the draw() method so that it's safe to draw to the screen
    video.read(); // Read the new frame from the camera
    video.loadPixels();
    PImage img = createImage(width, height, RGB);
    arrayCopy(video.pixels, img.pixels);
    
    int movementSum = 0; // Amount of movement in the frame
    for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
      color currColor = video.pixels[i];
      color prevColor = previousFrame[i];
      // Extract the red, green, and blue components from current pixel
      int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      // Extract red, green, and blue components from previous pixel
      int prevR = (prevColor >> 16) & 0xFF;
      int prevG = (prevColor >> 8) & 0xFF;
      int prevB = prevColor & 0xFF;
      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - prevR);
      int diffG = abs(currG - prevG);
      int diffB = abs(currB - prevB);
      // Add these differences to the running tally
      movementSum += diffR + diffG + diffB;
      // Render the difference image to the screen
      img.pixels[i] = color(diffR, diffG, diffB);
      
      // The following line is much faster, but more confusing to read
      //pixels[i] = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;
      // Save the current color into the 'previous' buffer
      previousFrame[i] = currColor;
    }
    //create_mirror(img);
    for (int i = 0; i < cols;i++) {
      // Begin loop for rows
      for (int j = 0; j < rows;j++) {

        // Where are we, pixel-wise?
        int x = i * cellSize;
        int y = j * cellSize;
        int loc = (img.width - x - 1) + y*img.width; // Reversing x to mirror the image

        // Each rect is colored white with a size determined by brightness
        color c = img.pixels[loc];
        float sz = (brightness(c) / 255.0) * cellSize;
        fill(c);
        noStroke();
        //ellipse(x + cellSize/2, y + cellSize/2, cellSize+2, cellSize+2);
        text(letters[i*j], x + cellSize/2, y + cellSize/2);
        //textSize(sz+1);
        }
    }
    
    // To prevent flicker from frames that are all black (no movement),
    // only update the screen if the image has changed.
    if (movementSum > 0) {
      //updatePixels();
      println(movementSum); // Print the total amount of movement to the console
    }
  }
}
