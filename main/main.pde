import peasy.*;

import ddf.minim.*;
import ddf.minim.analysis.*;

import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

import de.looksgood.ani.*;

PVector light = new PVector();  // Light direction for shading
PeasyCam cam;   // Useful camera library

Minim minim;
AudioPlayer song;
AudioInput input;
BeatDetect beatFRQ;
BeatDetect beatAMP;

PostFX fx;

int SONG_SKIP_MILLISECONDS = 5000;
int BASE_RADIUS = 300;

int radius = BASE_RADIUS;
int bloomSize = radius / 20;

void setup() {
    //fullScreen(P3D);
    size(1024, 720, P3D);
    
    // init PostFX
    fx = new PostFX(this);
    
    Ani.init(this);
    
    // Setup camera
    cam = new PeasyCam(this, 1000);
    cam.setWheelScale(0.1);
    
    // Setup Sound
    minim = new Minim(this);
    song = minim.loadFile("../assets/levitation.mp3", 1024);
    beatFRQ = new BeatDetect(song.bufferSize(), song.sampleRate());
    beatAMP = new BeatDetect(song.bufferSize(), song.sampleRate());
    input = minim.getLineIn();
      
    song.play();
}

void drawWaveform() {
  stroke(255);
  smooth();
  // we draw the waveform by connecting neighbor values with a line
  // we multiply each of the values by 50 
  // because the values in the buffers are normalized
  // this means that they have values between -1 and 1. 
  // If we don't scale them up our waveform 
  // will look more or less like a straight line.
  for(int i = 0; i < song.bufferSize() - 1; i++)
  {
    line(i - width/2, 50 + song.left.get(i)*50, i+1 - width/2, 50 + song.left.get(i+1)*50);
    line(i - width/2, 150 + song.right.get(i)*50, i+1 - width/2, 150 + song.right.get(i+1)*50);
  }
}

void draw() {
  background(0);
  // Calculate the light position
  //final float t = TWO_PI * (millis() / 1000.0) / 10.0;
  //light.set(sin(t) * 160, -160, cos(t) * 160);
  
  //drawWaveform();
  
  // Beat Detection Setup
  beatFRQ.detect(song.mix);
  beatFRQ.detectMode(BeatDetect.FREQ_ENERGY);
  PVector colorRGB = new PVector(0, 0, 0);
  if(beatFRQ.isKick()) {
    colorRGB.x = 255;
  };
  if(beatFRQ.isHat()) {
    //colorRGB.y = 255;
  };
  if(beatFRQ.isSnare()) {
    //colorRGB.z = 255;
  };
  if(colorRGB.x + colorRGB.y + colorRGB.z == 0) colorRGB.add(255, 255, 255);
  color c = color(colorRGB.x, colorRGB.y, colorRGB.z);
  
  beatAMP.detectMode(BeatDetect.SOUND_ENERGY);
  beatAMP.detect(song.mix);
  
  noStroke();
  fill(255,255,255);
  sphere(radius);
  if (beatAMP.isOnset()) {
    //bloomSize *= 4;
    Ani.to(this, .5, "radius", BASE_RADIUS * 1.05);
    Ani.to(this, .5, "bloomSize", radius / 3);
  }else{
    Ani.to(this, .5, "radius", BASE_RADIUS);
    Ani.to(this, .5, "bloomSize", radius / 20);
  }
  fx.render().bloom(.5, bloomSize, 30).compose();
  
}

void keyPressed() {
  if (key == CODED) {
    // Left/right arrow keys: seek song
    if (keyCode == LEFT) {
      song.skip(-SONG_SKIP_MILLISECONDS);
    } 
    else if (keyCode == RIGHT) {
      song.skip(SONG_SKIP_MILLISECONDS);
    }
  }
  // Space bar: play/payse
  else if (key == ' ') {
    if (song.isPlaying())
      song.pause();
    else
      song.play();
  }
  // Enter: spit out the current position
  // (for syncing)
  else if (key == ENTER) {
    print(song.position() + ", ");
  }
}
