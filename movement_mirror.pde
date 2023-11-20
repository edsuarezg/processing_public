/*
 * Movement mirror 
 * Edgar Suarez
 *
 * A combo of frame-differencing and mirror to generate an interactive image.
 * Switches between a video and a 
 */ 


import processing.video.*;

int numPixels;
int[] previousFrame;
Capture video;
Movie movie;
int cols, rows;
int cellSize = 10;
// Characters sorted according to their visual density
String letterOrder = "ReCoNoCeRRECONOCERReconocerReCONOcerReconoceR";

char[] letters;
int movementSum = 0; // Amount of movement in the frame
float mov_counter;
int start;

void setup() {
  //size(640, 480);
  fullScreen();
  cols = width / cellSize;
  rows = height / cellSize;
  background(255);
  
  // Load and play the video in a loop
    movie = new Movie(this, "FINAL_05_.mp4");
  movie.loop();
  
  printArray(Capture.list());
  video = new Capture(this, width, height, Capture.list()[1]); //change number according to desired camera
  // Start capturing the images from the camera
  video.start(); 
  
  numPixels = video.width * video.height;
  // Create an array to store the previously captured frame
  previousFrame = new int[numPixels];
  //loadPixels();
  
  // create a letter for each pixel in the row-col space
  textAlign(CENTER, CENTER);
  letters = new char[cols*rows];
  for (int i = 0; i < cols*rows; i++) {
    int index = int(map(i, 0, cols*rows, 0, letterOrder.length()));
    letters[i] = letterOrder.charAt(index);
  }
}

void movement_mirror_draw(PImage img){
    background(0);
    //create_mirror(img);
    for (int i = 2; i < cols-2;i++) {
      // Begin loop for rows
      for (int j = 2; j < rows-2;j++) {

        // Where are we, pixel-wise?
        int x = i * cellSize;
        int y = j * cellSize;
        int loc = (img.width - x - 1) + y*img.width; // Reversing x to mirror the image

        // Each rect is colored white with a size determined by brightness
        color c = img.pixels[loc];
        float sz = (brightness(c)/255) * cellSize;
        fill(c); 
        ellipse( x + cellSize/2, y + cellSize/2, sz+1, sz+1);
        fill(255);
        textSize(10);
        noStroke();
        text(letters[i*j], x+ cellSize/2+ cellSize/2, y);
        }
    }
}

void movieEvent(Movie m) {
  m.read();
}

void draw() {
  //print(movementSum,"\n");
  
  if (video.available()) {
    // When using video to manipulate the screen, use video.available() and
    // video.read() inside the draw() method so that it's safe to draw to the screen
    video.read(); // Read the new frame from the camera
    video.loadPixels();
    PImage img = createImage(width, height, RGB);
    arrayCopy(video.pixels, img.pixels);
    
    movementSum = 0; // Amount of movement in the frame
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
      movementSum += diffR +  diffG + diffB;
      // Render the difference image to the screen
      img.pixels[i] = color(255- diffR+ 255 -diffG+ 255 -diffB)/3;
      
      // The following line is much faster, but more confusing to read
      //pixels[i] = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;
      // Save the current color into the 'previous' buffer
      previousFrame[i] = currColor;
    }
      print(movementSum,"\n");
      if (movementSum > 14540539) { // find a good threshold
          // there was some movement
          // reset the movement counter
          mov_counter = 0;
          // run the interactive part
          movement_mirror_draw(img);
      }else{
      // start a counter. 
        if (mov_counter == 0){
          // mark the moment when the system went "idle"
          start = frameCount;
          mov_counter ++;
        }else{
        mov_counter = frameCount - start;
        }
        //print("start: ",start,"\n");
        //print("counter", mov_counter,"\n");
        if (mov_counter > 5*frameRate){ //replace with sensible value. Thi would mean 5 seconds
          // If the system is idle for too long, let's switch! 
          // time to switch to the video
          start = 0;
          mov_counter = 6*frameRate;
            if (movie.available() == true) {
            movie.read(); 
            }
          image(movie, 0, 0, width, height);
          if (is_movie_finished(movie)){
          movie.jump(0);
          }
        }else{
          // continue running the interactive, while the count runs
          movement_mirror_draw(img);
        }
      }
  }
}

boolean is_movie_finished(Movie m) {
  return m.duration() - m.time() < 0.05;
}
