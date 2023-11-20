/**
 * This sketch shows how to use the Amplitude class to analyze the changing
 * "loudness" of a stream of sound. In this case an audio sample is analyzed.
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
int numrows=20;
int numcols=20;
float mov_counter;
int start;

Capture video;
Movie movie;

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
  strokeWeight(5);
  stroke(0,200);
  
  movie = new Movie(this, "FINAL_05_.mp4");
  movie.loop();
  
}

void movieEvent(Movie m) {
  m.read();
}

  
void segment(float x, float y, float a, float extra) {
  translate(x, y);
  rotate(a);
  //line(0, x, segLength, y);
  line(0, 0, segLength + extra, 0);  
}

void draw_arms(){
  //int counter = 35;
  //int marginx = width/(2*numcols);
  int marginy = height/(2*numrows);
  
  for (int i = 0; i < numcols; i ++) {
    for (int j = 0; j < numrows; j ++) {
    
  // smooth the rms data by smoothing factor
  sum += (numcols*2 - numrows*2 - sum*0.1 + frameCount) * smoothingFactor;
  // rms.analyze() return a value between 0 and 1. It's
  // scaled to height/2 and then multiplied by a fixed scale factor
  //float rms_scaled = sum * (height/2) * 5;

  // We draw an arm
  angle1 = (sum/float(width) - 0.5) * -PI/i - numrows;
  angle2 = (-sum/float(height) - 0.5) * PI/i;
  
  // draw the clocks
   
    //if (j%2 == 0){
    //  pushMatrix();
    //segment((i+0.5)*width/numcols, marginy + j*height/numrows, angle1, rms.analyze()*500);
    //    popMatrix();
    //}else{
      pushMatrix();
    segment(i*width/numcols, marginy + j*height/numrows, angle1, rms.analyze()*500); 
      popMatrix();//}
    
    //if (j%2 == 0){
    //  pushMatrix();
    //segment((i+0.5)*width/numcols, marginy + j*height/numrows, angle2, 0);
    //popMatrix();
    //}else{
      pushMatrix();
    segment(i*width/numcols, marginy + j*height/numrows, angle2, rms.analyze()*500);  
    popMatrix();//}

    }
  }
}

public void draw() {
  // Set background color, noStroke and fill color
  background(200);
  // print rms value of mic
  // print(rms.analyze(),"\n");
  if (rms.analyze()> 0.07) { // find a good threshold
          // there was some movement
          // reset the movement counter
          mov_counter = 0;
          // run the interactive part
          draw_arms();
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
          draw_arms();
        }
      }
}

boolean is_movie_finished(Movie m) {
  return m.duration() - m.time() < 0.05;
}
