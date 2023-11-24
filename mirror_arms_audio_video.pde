/**
 * Edgar Suarez: Instalación RECONOCER
 */

import processing.sound.*;
import processing.video.*;

// Declare the processing sound variables 
AudioIn in;
Amplitude rms;

// Declare a smooth factor to smooth out sudden changes in amplitude.
// With a smooth factor of 1, only the last measured amplitude is used for the
// visualisation, which can lead to very abrupt changes. As you decrease the
// smooth factor towards 0, the measured amplitudes are averaged across frames,
// leading to more pleasant gradual changes
float smoothingFactor = 0.1;

// Used for storing the smoothed amplitude value
float sum;

float x, y;
float angle1 = 0.0;
float angle2 = 0.0;
int segLength = 20;
int numrows=15;
int numcols=15;
float mov_counter;
int start;

Capture video;
Movie movie;

// For mirror
int numPixels;
int[] previousFrame;
int cols, rows;
int cellSize = 20;
// Characters sorted according to their visual density
String letterOrder = "AtüjaaYachayPi'yawejxiaBakakiAtüjaaYachayPi'yawejxiaBakaki";
//AtüjaaYachayPi'yawejxiaBakaki
char[] letters;
int movementSum = 0; // Amount of movement in the frame
boolean arms = true;
boolean mirror = false;


public void setup() {
  //size(640, 480);
  fullScreen();
    
  Sound.list();
  Sound s = new Sound(this);
  s.inputDevice(11);

  //Load and play a soundfile and loop it
  in = new AudioIn(this, 0);

  // Create and patch the rms tracker
  rms = new Amplitude(this);
  rms.input(in);
  
  // the arm
  strokeWeight(5);
  stroke(0,200);
  
  movie = new Movie(this, "FINAL_05_.mp4");
  movie.loop();
  
  // for mirror
  cols = width / cellSize;
  rows = height / cellSize;
    
  printArray(Capture.list());
  video = new Capture(this, width, height, Capture.list()[0]); //change number according to desired camera
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

void movieEvent(Movie m) {
  m.read();
}

void movement_mirror_draw(PImage img){
  background(200);
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
      float sz = (brightness(c)/255) * cellSize*1.5;
      fill(255-c);
      //ellipse( x + cellSize/2, y + cellSize/2, sz, sz);
      //fill(255);
      textSize(sz);
      noStroke();
      text(letters[i*j], x + cellSize/2, y + cellSize/2);
      }
  }
}
  
void segment(float x, float y, float a, float extra) {
  translate(x, y);
  rotate(a);
  //line(0, x, segLength, y);
  line(0, 0, segLength + extra, 0);  
}

void draw_arms(){
  strokeWeight(8);
  stroke(0,200);
  background(200);
  //int counter = 35;
  //int marginx = width/(2*numcols);
  //int marginy = height/(2*numrows);
  
  for (int i = 0; i <= numcols; i ++) {
    for (int j = 0; j <= numrows; j ++) {
    
  // smooth the rms data by smoothing factor
  sum += (numcols*2 - numrows*2 - sum*0.1 + frameCount) * smoothingFactor;
  // rms.analyze() return a value between 0 and 1. It's
  // scaled to height/2 and then multiplied by a fixed scale factor
  //float rms_scaled = sum * (height/2) * 5;

  // We draw an arm
  angle1 = (sum/float(width) - 0.5) * -PI;
  angle2 = (-sum/float(width) - 0.5) * PI;
  
  // draw the clocks
      pushMatrix();
    segment(i*width/numcols, j*height/numrows, angle1-i, rms.analyze()*250000); 
      popMatrix();//}
    
      pushMatrix();
    segment(i*width/numcols, j*height/numrows, angle2-j, rms.analyze()*250000);  
    popMatrix();//}
    }
  }
}

public void draw() {
  ///////
  // print rms value of mic
  float thresh = 0.0011;  
  if (rms.analyze()> thresh) { // find a good threshold
    print(thresh,"\n");
    // there was some movement
    // reset the movement counter
    start = 0;
    mov_counter = 0;
    // run the interactive part
    draw_arms();
    arms = true;
  }else{
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
    if (movementSum > 14637117 && !arms){ // find a good threshold
            // there was some movement. Run the video part.
            start = 0;
            mov_counter = 0;
            movement_mirror_draw(img);
            mirror = true; // false for arms, true for mirror
    }else{
      // start a counter. 
      if (mov_counter == 0){
        // mark the moment when the system went "idle"
        start = frameCount;
        mov_counter ++;
        }else{mov_counter = frameCount - start;}
        //print("start: ",start,"\n");
        //print("counter", mov_counter,"\n");
        if (mov_counter > 5*frameRate){  //replace with sensible value. Thi would mean 10 seconds?
          // If the system is idle for too long, let's switch! 
          // time to switch to mirror (if available)
          if (arms){arms = false;}
          if (mirror){mirror = false;}
        }
        if (!arms && !mirror){ //replace with sensible value. Thi would mean 10 seconds
          start = 0;
          mov_counter = 11*frameRate;
          // If the system is idle for too long and it is not on video, let us switch!
          // time to switch to the video
          if (movie.available() == true) {movie.read();}
          image(movie, 0, 0, width, height);
          if (is_movie_finished(movie)){movie.jump(0);}
        }else{
            // continue running the interactive, while the count runs
            if (arms){draw_arms();}
            else{if(mirror){movement_mirror_draw(img);}}
          }
      }
    }
  }
}

boolean is_movie_finished(Movie m) {
  return m.duration() - m.time() < 0.05;
}
