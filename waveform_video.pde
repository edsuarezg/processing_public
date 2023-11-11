// Each pixel from the video source is drawn as
// a rectangle with size based on brightness.

import processing.video.*;
// Size of each cell in the grid
int videoScale = 10;
// Number of columns and rows in the system
int cols, rows;
// Variable for capture device
Capture video;

import processing.sound.*;
AudioIn in;
Waveform waveform;
int samples = 1000;

void setup() {
  size(640, 480);
  
  // Create a Sound object and select the second sound device (device ids start at 0) for input
  Sound.list();
  Sound s = new Sound(this);
  s.inputDevice(10);
    
  // Create the Input stream
  in = new AudioIn(this, 0);
  
  // in.play();
  
  // Create new Waveform object
  waveform = new Waveform(this, samples);
  waveform.input(in);
  
  // Initialize columns and rows
  cols = width / videoScale;
  rows = height / videoScale;
  // Construct the Capture object
  video = new Capture(this, cols, rows);
  video.start();
}

void captureEvent(Capture video) {
  video.read();
}

void draw() {
  background(0);
  waveform.analyze();
  video.loadPixels();
  // Begin loop for columns
  for (int i = 0; i < cols; i++) {
    // Begin loop for rows
    for (int j = 0; j < rows; j++) {
      // Where are you, pixel-wise?
      int x = i*videoScale;
      int y = j*videoScale;

      // Reverse the column to mirro the image.
      int loc = (video.width - i - 1) + j * video.width;

      color c = video.pixels[loc];
      // A rectangle's size is calculated as a function of the pixel’s brightness.
      // A bright pixel is a large rectangle, and a dark pixel is a small one.
      float sz = (brightness(c)/255) * videoScale;

      rectMode(CENTER);
      fill(map(waveform.data[i], -1, 1, 0, 255));
      noStroke();
      rect(x + videoScale/2, y + videoScale/2, sz, sz);
    }
  }
}
