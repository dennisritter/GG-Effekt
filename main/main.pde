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
int MAX_POS_DELTA = 5;
float MAX_COLOR_DELTA = 1.0;

float angle = 0;
int radius = BASE_RADIUS;
int bloomSize = radius / 20;
ArrayList<PShape> shapes = new ArrayList<PShape>();
ArrayList<PVector> shapesDelta = new ArrayList<PVector>();
ArrayList<Integer> shapesColor = new ArrayList<Integer>();
boolean ellipsePosInc = true;

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
  PShape sphere = createShape(SPHERE, radius);
  // Center Sphere when not using PeasyCam
  // sphere.translate(width/2,height/2,-100);
  shape(sphere);
  
  // If Amplitude Peak is detected
  if (beatAMP.isOnset()) {
    Ani.to(this, .5, "radius", BASE_RADIUS * 1.05);
    Ani.to(this, .5, "bloomSize", radius / 3);
    if (true){
      // Create new Shape
      PShape shape = createShape(SPHERE, radius / 10);
      // Set Shapes Color
      int shapeColor = color(random(150, 255), random(150, 255), random(150, 255));
      // Define moving speed
      PVector shapeDelta = new PVector(random(-MAX_POS_DELTA, MAX_POS_DELTA), random(-MAX_POS_DELTA, MAX_POS_DELTA), random(-MAX_POS_DELTA, MAX_POS_DELTA));
      
      // Center when not using PeasyCam
      // shape.translate(width/2,height/2,0);
      shape.setFill(shapeColor);
      
      // Add dynamic values to Lists
      shapes.add(shape);
      shapesDelta.add(shapeDelta);
      shapesColor.add(shapeColor);
    }
  }else{
    Ani.to(this, .5, "radius", BASE_RADIUS);
    Ani.to(this, .5, "bloomSize", radius / 20);
  }
  // Do something with all (child)shapes
  for (int i = 0; i < shapes.size(); ++i){
    //if(x <= -width || x >= width) dx = dx * -1;
    PShape shape = shapes.get(i);
    shape.translate(shapesDelta.get(i).x, shapesDelta.get(i).y, shapesDelta.get(i).z);
    
    int shapeColor = shapesColor.get(i);
    float red = red(shapeColor) + random(-MAX_COLOR_DELTA);
    float green = green(shapeColor) + random(-MAX_COLOR_DELTA);
    float blue = blue(shapeColor) + random(-MAX_COLOR_DELTA);
    shapeColor = color(red, green, blue);
    shapesColor.set(i, shapeColor);
    shape.setFill(color(red, green, blue));
    shape(shape);
  }
  
  fx.render().bloom(.5, bloomSize, 30).compose();
  //cam.rotateX(radians(angle));
  cam.rotateZ(radians(angle));
  angle = (angle + 0.01) % 360;
  println(angle);
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
  // Space bar: play/pause
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
