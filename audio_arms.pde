/**
 * This sketch shows how to use the Amplitude class to analyze the changing
 * "loudness" of a stream of sound. In this case an audio sample is analyzed.
 */

import processing.sound.*;

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
int segLength = 70;
int numrows=10;
int numcols=10;
public void setup() {
  //size(640, 360);
  fullScreen();
  
  Sound.list();
  Sound s = new Sound(this);
  s.inputDevice(9);

  //Load and play a soundfile and loop it
  in = new AudioIn(this, 0);

  // Create and patch the rms tracker
  rms = new Amplitude(this);
  rms.input(in);
  
  // the arm
  strokeWeight(15);
  stroke(0,70);
  
  //x = width * 0.3;
  //y = height * 0.5;
}      

public void draw() {
  // Set background color, noStroke and fill color
  background(255);


  //int counter = 35;
  int marginx = width/(2*numcols);
  int marginy = height/(2*numrows);
  
  for (int i = 0; i < numcols; i ++) {
    for (int j = 0; j < numrows; j ++) {
    
  // smooth the rms data by smoothing factor
  sum += (abs(rms.analyze()*100) + numcols*2 - numrows*2 - sum*0.1 + frameCount) * smoothingFactor;
  // rms.analyze() return a value between 0 and 1. It's
  // scaled to height/2 and then multiplied by a fixed scale factor
  //float rms_scaled = sum * (height/2) * 5;

  // We draw an arm
  //ellipse(width/2, height/2, rms_scaled, rms_scaled);
  angle1 = (sum/float(width) - 0.5) * -PI + i-numrows;
  angle2 = (-sum/float(height) - 0.5) * PI + j;
  
  // draw the clocks
  // Set the left and top margin
      
    pushMatrix();
    if (j%2 == 0){
    segment(marginx + (i+0.5)*width/numcols, marginy + j*height/numrows, angle1);
    }else{
    segment(marginx + i*width/numcols, marginy + j*height/numrows, angle1); }
    popMatrix();
    
    pushMatrix();
    if (j%2 == 0){
    segment(marginx + (i+0.5)*width/numcols, marginy + j*height/numrows, angle2);
    }else{
    segment(marginx + i*width/numcols, marginy + j*height/numrows, angle2);  }
    popMatrix();

    }
  }
}
  
  void segment(float x, float y, float a) {
    translate(x, y);
    rotate(a);
    //line(0, x, segLength, y);
    line(0, 0, segLength, 0);
    
}
