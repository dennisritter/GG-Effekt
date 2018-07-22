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
BeatDetect beatSENS;

PostFX fx;

int SONG_SKIP_MILLISECONDS = 5000;
int BASE_RADIUS = 300;
int MAX_POS_DELTA = 5;
float MAX_COLOR_DELTA = 1.0;
ColorFactory colorFactory = new ColorFactory();

PVector camRotationAngle = new PVector(0.5, 1.0, 2.0);
int radius = BASE_RADIUS;

// The main Sphere in Center
PShape sphere;

float forceStr = 0.0f;
int bloomSize = radius / 20;
ArrayList<Particle> particles = new ArrayList<Particle>();

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
    beatAMP.setSensitivity(200);
    beatSENS = new BeatDetect(song.bufferSize(), song.sampleRate());
    beatSENS.setSensitivity(10);
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
  
  // Beat Detection Setup
  /*beatFRQ.detect(song.mix);
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
  */
  
  beatAMP.detectMode(BeatDetect.SOUND_ENERGY);
  beatAMP.detect(song.mix);
  beatSENS.detectMode(BeatDetect.SOUND_ENERGY);
  beatSENS.detect(song.mix);
  
  noStroke();
  fill(255,255,255);
  sphere = createShape(SPHERE, radius);
  // Center Sphere when not using PeasyCam
  // sphere.translate(width/2,height/2,-100);
  shape(sphere);
  if (beatSENS.isOnset()) {
    // Create new Particle
    int pColor = colorFactory.randomBrightColor(150);
    int pRadius = BASE_RADIUS / 10;
    Particle p = new Particle(pRadius, pColor);
    p.move(p.getDirection().mult(BASE_RADIUS - pRadius));
    particles.add(p);
    forceStr += 0.25f;
   
  } else {
    forceStr -= 0.05f;
    if (forceStr < 0.0f) forceStr = 0.0f;
  }
  
  // If Amplitude Peak is detected
  if (beatAMP.isOnset()) {
    Ani.to(this, .5, "radius", BASE_RADIUS * 1.10);
    Ani.to(this, .5, "bloomSize", radius / 2);
    
    
    // Animate all particles
    for (int i = 0; i < particles.size(); ++i){
      
      Particle particle = particles.get(i);
      
      //particle.setColor(colorFactory.darken(particle.getColor(), 20));
      PVector pDirection = particle.getDirection();
      float pDistance = particle.getDistanceFromSpawn();
      
      PVector force = pDirection.mult(forceStr);
      
      // Increase force for objects that are far away
      force = force.mult((pDistance / 300.0f) * 2.0f);
     
      particle.applyForce(force);

    }  
  }else{
    
    Ani.to(this, .5, "radius", BASE_RADIUS);
    Ani.to(this, .5, "bloomSize", radius / 20);
  }
  
  for (int i = 0; i < particles.size(); ++i){
    Particle particle = particles.get(i);
    particle.update();
  }
  
  // Apply Bloom Effect
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
